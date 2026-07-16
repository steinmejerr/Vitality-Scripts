local ESX = exports['es_extended']:getSharedObject()
local shopPed
local tableObject
local nuiOpen = false
local activeMission
local rockObjects = {}
local rockStates = {}
local mining = false
local pickaxeObject
local equippedPickaxe
local equippedPickaxeItem
local rockOreTypes = {}
local rockOreVisuals = {}

local function notify(description, notifyType)
    lib.notify({ title = 'Minearbejde', description = description, type = notifyType or 'inform', position = 'top-right' })
end

local function loadModel(model)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(0) end
    return HasModelLoaded(model)
end

local function loadAnim(dict)
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do Wait(0) end
    return HasAnimDictLoaded(dict)
end


local function isInsideMiningArea(coords)
    for _, zone in pairs(Config.Zones) do
        local radius = (zone.radius or 0.0) + (Config.BlockedVehicles.extraRadius or 0.0)
        if #(coords - zone.center) <= radius then
            return true
        end
    end
    return false
end

local function removeBlockedVehicles()
    if not Config.BlockedVehicles or not Config.BlockedVehicles.enabled then
        return
    end

    local blocked = {}
    for _, model in ipairs(Config.BlockedVehicles.models or {}) do
        blocked[model] = true
    end

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) and blocked[GetEntityModel(vehicle)] and isInsideMiningArea(GetEntityCoords(vehicle)) then
            NetworkRequestControlOfEntity(vehicle)
            local timeout = GetGameTimer() + 750
            while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
                Wait(0)
                NetworkRequestControlOfEntity(vehicle)
            end
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
            if DoesEntityExist(vehicle) then
                DeleteEntity(vehicle)
            end
        end
    end
end

local function closeNui()
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openNui(tab)
    local data, errorMessage = lib.callback.await('sb_mining:server:getMenuData', false)

    if not data then
        notify(errorMessage or 'Menuen kunne ikke indlæses.', 'error')
        SetNuiFocus(false, false)
        return
    end

    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', tab = tab or 'shop', data = data })
end


local function getRockLabel(oreKey)
    local labels = Config.RockVisuals and Config.RockVisuals.labels or {}
    return labels[oreKey] or 'Malmåre'
end

local function fetchRockVisuals()
    local state = lib.callback.await('sb_mining:server:getRockVisuals', false)
    if state then
        rockOreVisuals = state
    end
end

local function setRockVisual(zoneKey, rockIndex, oreKey)
    rockOreVisuals[zoneKey] = rockOreVisuals[zoneKey] or {}
    rockOreVisuals[zoneKey][rockIndex] = oreKey
end

local function deletePickaxe()
    if pickaxeObject and DoesEntityExist(pickaxeObject) then DeleteEntity(pickaxeObject) end
    pickaxeObject = nil
end

local function attachPickaxe()
    deletePickaxe()
    local ped = PlayerPedId()
    local data = Config.Rock.pickaxeProp
    if not loadModel(data.model) then return end
    pickaxeObject = CreateObject(data.model, GetEntityCoords(ped), true, true, false)
    AttachEntityToEntity(pickaxeObject, ped, GetPedBoneIndex(ped, data.bone), data.offset.x, data.offset.y, data.offset.z, data.rotation.x, data.rotation.y, data.rotation.z, true, true, false, true, 2, true)
    SetModelAsNoLongerNeeded(data.model)
end

local function usePickaxe(itemName)
    local ok, message, action, key, label = lib.callback.await('sb_mining:server:equipPickaxe', false, itemName)
    notify(message, ok and 'success' or 'error')

    if not ok then
        return
    end

    if action == 'unequipped' then
        equippedPickaxe = nil
        equippedPickaxeItem = nil
        deletePickaxe()
        return
    end

    equippedPickaxe = {
        key = key,
        label = label
    }
    equippedPickaxeItem = itemName
    attachPickaxe()
end

exports('usePickaxe', function(data)
    local itemName = type(data) == 'table' and data.name or data
    if not itemName then
        notify('Hakken kunne ikke genkendes.', 'error')
        return
    end

    usePickaxe(itemName)
end)

local function mineRock(zoneKey, rockIndex)
    if mining then return end
    local object = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
    if not object or not DoesEntityExist(object) then return end

    local pickaxe, errorMessage = lib.callback.await('sb_mining:server:getEquippedPickaxe', false)
    if not pickaxe then
        equippedPickaxe = nil
        notify(errorMessage or 'Brug en hakke fra dit inventory først.', 'error')
        return
    end

    equippedPickaxe = pickaxe
    mining = true
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, object, 500)
    Wait(500)
    if not pickaxeObject or not DoesEntityExist(pickaxeObject) then
        attachPickaxe()
    end
    local animation = Config.Rock.animation
    if loadAnim(animation.dict) then TaskPlayAnim(ped, animation.dict, animation.clip, 3.0, 3.0, -1, animation.flag, 0.0, false, false, false) end
    local duration = math.floor(Config.Rock.mineDuration * (pickaxe.speedMultiplier or 1.0))
    local success = lib.progressCircle({ duration = duration, label = 'Bryder stenen...', position = 'bottom', canCancel = true, disable = { move = true, car = true, combat = true } })
    ClearPedTasks(ped)
    if success then
        local ok, message = lib.callback.await('sb_mining:server:mineRock', false, zoneKey, rockIndex)
        if ok then
            notify(('Du fandt: %s'):format(message), 'success')
            if rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex] then
                SetEntityVisible(rockObjects[zoneKey][rockIndex], false, false)
                SetEntityCollision(rockObjects[zoneKey][rockIndex], false, false)
                rockStates[zoneKey .. ':' .. rockIndex] = true
            end
        else
            notify(message or 'Stenen kunne ikke brydes.', 'error')
        end
    end
    mining = false
end

local function getOreLabel(oreKey)
    local ore = Config.Ores[oreKey]
    return ore and ore.label or 'Malm'
end

local function getOreModel(oreKey, rockIndex)
    local data = Config.MiningProps[oreKey] or Config.MiningProps.stone
    local variants = data.variants or { data.model }
    return variants[((rockIndex - 1) % #variants) + 1]
end

local function removeRock(zoneKey, rockIndex)
    local object = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
    if object and DoesEntityExist(object) then
        exports.ox_target:removeLocalEntity(object)
        DeleteEntity(object)
    end
    if rockObjects[zoneKey] then
        rockObjects[zoneKey][rockIndex] = nil
    end
end

local function createRock(zoneKey, rockIndex)
    local zone = Config.Zones[zoneKey]
    local coords = zone and zone.rocks[rockIndex]
    local oreKey = rockOreTypes[zoneKey] and rockOreTypes[zoneKey][rockIndex]
    if not coords or not oreKey then return end

    removeRock(zoneKey, rockIndex)
    local model = getOreModel(oreKey, rockIndex)
    if not loadModel(model) then
        notify(('Mine-proppet til %s kunne ikke indlæses.'):format(getOreLabel(oreKey)), 'error')
        return
    end

    local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(object, coords.w)
    PlaceObjectOnGroundProperly(object)
    FreezeEntityPosition(object, true)
    rockObjects[zoneKey] = rockObjects[zoneKey] or {}
    rockObjects[zoneKey][rockIndex] = object

    exports.ox_target:addLocalEntity(object, {
        {
            name = ('sb_mining_%s_%s'):format(zoneKey, rockIndex),
            icon = 'fas fa-hammer',
            label = ('Mine %s'):format(getOreLabel(oreKey)),
            distance = Config.Rock.interactionDistance,
            canInteract = function()
                return not mining and not rockStates[zoneKey .. ':' .. rockIndex]
            end,
            onSelect = function()
                mineRock(zoneKey, rockIndex)
            end
        }
    })

    SetModelAsNoLongerNeeded(model)
end

local function createRocks()
    local state = lib.callback.await('sb_mining:server:getRockState', false)
    if type(state) ~= 'table' then
        notify('Mine-props kunne ikke synkroniseres.', 'error')
        return
    end

    rockOreTypes = state
    for zoneKey, zone in pairs(Config.Zones) do
        for rockIndex = 1, #zone.rocks do
            createRock(zoneKey, rockIndex)
        end
    end
end

local function createShop()
    local pedData = Config.Shop.ped
    if loadModel(pedData.model) then
        shopPed = CreatePed(4, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, pedData.coords.w, false, true)
        FreezeEntityPosition(shopPed, true)
        SetEntityInvincible(shopPed, true)
        SetBlockingOfNonTemporaryEvents(shopPed, true)
        TaskStartScenarioInPlace(shopPed, pedData.scenario, 0, true)
        exports.ox_target:addLocalEntity(shopPed, {
            { name = 'sb_mining_shop', icon = 'fas fa-store', label = 'Åbn minebutik', onSelect = function() openNui('shop') end },
            { name = 'sb_mining_missions', icon = 'fas fa-clipboard-list', label = 'Se missioner', onSelect = function() openNui('missions') end },
            { name = 'sb_mining_sell', icon = 'fas fa-coins', label = 'Sælg malm', onSelect = function() openNui('sell') end }
        })
    end
    local tableData = Config.Shop.table
    if shopPed and DoesEntityExist(shopPed) and loadModel(tableData.model) then
        local coords = GetOffsetFromEntityInWorldCoords(shopPed, tableData.offset.x, tableData.offset.y, tableData.offset.z)
        tableObject = CreateObject(tableData.model, coords.x, coords.y, coords.z, false, false, false)
        local heading = pedData.coords.w + tableData.headingOffset
        SetEntityHeading(tableObject, heading)
        PlaceObjectOnGroundProperly(tableObject)
        SetEntityRotation(tableObject, 0.0, 0.0, heading, 2, true)
        FreezeEntityPosition(tableObject, true)
    end
    if Config.Shop.blip.enabled then
        local blip = AddBlipForCoord(pedData.coords.x, pedData.coords.y, pedData.coords.z)
        SetBlipSprite(blip, Config.Shop.blip.sprite)
        SetBlipColour(blip, Config.Shop.blip.colour)
        SetBlipScale(blip, Config.Shop.blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Shop.blip.label)
        EndTextCommandSetBlipName(blip)
    end
end

RegisterNUICallback('close', function(_, cb) closeNui() cb(1) end)
RegisterNUICallback('buyPickaxe', function(data, cb)
    local ok, message = lib.callback.await('sb_mining:server:buyPickaxe', false, data.key)
    notify(message, ok and 'success' or 'error')
    cb({ ok = ok })
end)
RegisterNUICallback('startMission', function(data, cb)
    local ok, message = lib.callback.await('sb_mining:server:startMission', false, data.key, data.members or {})
    notify(message, ok and 'success' or 'error')
    if ok then closeNui() end
    cb({ ok = ok })
end)
RegisterNUICallback('sellOre', function(data, cb)
    local ok, message = lib.callback.await('sb_mining:server:sellOre', false, data.key, data.amount)
    notify(message, ok and 'success' or 'error')
    cb({ ok = ok })
end)
RegisterNUICallback('sellAll', function(_, cb)
    local ok, message = lib.callback.await('sb_mining:server:sellAll', false)
    notify(message, ok and 'success' or 'error')
    cb({ ok = ok })
end)

RegisterNetEvent('sb_mining:client:missionStarted', function(mission)
    activeMission = mission
    SetNewWaypoint(Config.Zones[mission.zone].center.x, Config.Zones[mission.zone].center.y)
    notify(('Mission startet: %s'):format(mission.label), 'success')
end)

RegisterNetEvent('sb_mining:client:missionProgress', function(mission)
    activeMission = mission
    SendNUIMessage({ action = 'missionProgress', mission = mission })
end)

RegisterNetEvent('sb_mining:client:missionComplete', function(money, xp)
    activeMission = nil
    notify(('Mission fuldført. Bonus: %s kr. og %s XP.'):format(money, xp), 'success')
end)

RegisterNetEvent('sb_mining:client:missionCancelled', function()
    activeMission = nil
    notify('Missionen blev annulleret.', 'error')
end)

RegisterNetEvent('sb_mining:client:rockRespawn', function(zoneKey, rockIndex, seconds, oreKey)
    CreateThread(function()
        Wait(seconds * 1000)
        rockStates[zoneKey .. ':' .. rockIndex] = nil
        rockOreTypes[zoneKey] = rockOreTypes[zoneKey] or {}
        rockOreTypes[zoneKey][rockIndex] = oreKey or rockOreTypes[zoneKey][rockIndex]
        createRock(zoneKey, rockIndex)
    end)
end)



CreateThread(function()
    while true do
        removeBlockedVehicles()
        Wait((Config.BlockedVehicles and Config.BlockedVehicles.checkInterval) or 2000)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        if equippedPickaxeItem then
            local ped = PlayerPedId()
            local shouldUnequip = IsEntityDead(ped)

            if not shouldUnequip and Config.UseOxInventory then
                local count = exports.ox_inventory:Search('count', equippedPickaxeItem) or 0
                shouldUnequip = count < 1
            end

            if shouldUnequip then
                lib.callback.await('sb_mining:server:unequipPickaxe', false)
                equippedPickaxe = nil
                equippedPickaxeItem = nil
                deletePickaxe()
            elseif not pickaxeObject or not DoesEntityExist(pickaxeObject) then
                attachPickaxe()
            end
        end
    end
end)

CreateThread(function()
    while GetResourceState(Config.PropResource) ~= 'started' do
        Wait(500)
    end
    createShop()
    createRocks()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeNui()
    deletePickaxe()
    if shopPed and DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    if tableObject and DoesEntityExist(tableObject) then DeleteEntity(tableObject) end
    for _, rocks in pairs(rockObjects) do
        for _, object in pairs(rocks) do
            if DoesEntityExist(object) then DeleteEntity(object) end
        end
    end
end)
