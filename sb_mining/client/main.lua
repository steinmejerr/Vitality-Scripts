local ESX = exports['es_extended']:getSharedObject()
local shopPed
local tableObject
local nuiOpen = false
local activeMission
local rockObjects = {}
local rockStates = {}
local mining = false
local pickaxeObject

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

local function closeNui()
    nuiOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openNui(tab)
    local data = lib.callback.await('sb_mining:server:getMenuData', false)
    if not data then notify('Menuen kunne ikke indlæses.', 'error') return end
    nuiOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', tab = tab or 'shop', data = data })
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

local function mineRock(zoneKey, rockIndex)
    if mining or not activeMission then return end
    local object = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
    if not object or not DoesEntityExist(object) then return end
    mining = true
    local ped = PlayerPedId()
    TaskTurnPedToFaceEntity(ped, object, 500)
    Wait(500)
    attachPickaxe()
    local animation = Config.Rock.animation
    if loadAnim(animation.dict) then TaskPlayAnim(ped, animation.dict, animation.clip, 3.0, 3.0, -1, animation.flag, 0.0, false, false, false) end
    local success = lib.progressCircle({ duration = Config.Rock.mineDuration, label = 'Bryder stenen...', position = 'bottom', canCancel = true, disable = { move = true, car = true, combat = true } })
    ClearPedTasks(ped)
    deletePickaxe()
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

local function createRocks()
    for zoneKey, zone in pairs(Config.Zones) do
        rockObjects[zoneKey] = rockObjects[zoneKey] or {}
        for index, coords in ipairs(zone.rocks) do
            if not rockObjects[zoneKey][index] or not DoesEntityExist(rockObjects[zoneKey][index]) then
                if loadModel(Config.Rock.model) then
                    local object = CreateObject(Config.Rock.model, coords.x, coords.y, coords.z - 1.0, false, false, false)
                    SetEntityHeading(object, coords.w)
                    FreezeEntityPosition(object, true)
                    PlaceObjectOnGroundProperly(object)
                    rockObjects[zoneKey][index] = object
                    exports.ox_target:addLocalEntity(object, {
                        {
                            name = ('sb_mining_%s_%s'):format(zoneKey, index),
                            icon = 'fas fa-hammer',
                            label = 'Bryd sten',
                            distance = Config.Rock.interactionDistance,
                            canInteract = function()
                                return activeMission and activeMission.zone == zoneKey and not mining and not rockStates[zoneKey .. ':' .. index]
                            end,
                            onSelect = function()
                                mineRock(zoneKey, index)
                            end
                        }
                    })
                end
            end
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
    if loadModel(tableData.model) then
        local forward = GetEntityForwardVector(shopPed)
        local coords = GetEntityCoords(shopPed) + forward * tableData.offset.y
        tableObject = CreateObject(tableData.model, coords.x, coords.y, coords.z + tableData.offset.z, false, false, false)
        SetEntityHeading(tableObject, pedData.coords.w + tableData.headingOffset)
        FreezeEntityPosition(tableObject, true)
        PlaceObjectOnGroundProperly(tableObject)
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

RegisterNetEvent('sb_mining:client:rockRespawn', function(zoneKey, rockIndex, seconds)
    CreateThread(function()
        Wait(seconds * 1000)
        rockStates[zoneKey .. ':' .. rockIndex] = nil
        local object = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
        if object and DoesEntityExist(object) then
            SetEntityVisible(object, true, false)
            SetEntityCollision(object, true, true)
        end
    end)
end)

CreateThread(function()
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
