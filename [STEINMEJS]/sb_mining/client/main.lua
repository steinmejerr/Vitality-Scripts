local ESX = exports['es_extended']:getSharedObject()
local shopPed
local tableObject
local nuiOpen = false
local activeMission
local rockObjects = {}
local oreObjects = {}
local oreTargetEntities = {}
local rockStates = {}
local mining = false
local pickaxeObject
local equippedPickaxe
local equippedPickaxeItem
local rockOreTypes = {}
local rockOreVisuals = {}
local miningSoundSession = 0

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


local function isMiningPropModel(model)
    if Config.Rock and Config.Rock.baseModel == model then
        return true
    end
    for _, data in pairs(Config.MiningProps or {}) do
        if data.model == model then
            return true
        end
    end
    for _, legacyModel in ipairs(Config.LegacyMiningProps or {}) do
        if legacyModel == model then
            return true
        end
    end
    return false
end

local function cleanupUnusedMiningProps()
    local cleanup = Config.CleanupUnusedMiningProps
    if not cleanup or not cleanup.enabled then
        return
    end

    for _, object in ipairs(GetGamePool('CObject')) do
        if DoesEntityExist(object) and isMiningPropModel(GetEntityModel(object)) then
            local objectCoords = GetEntityCoords(object)
            local insideArea = false

            for _, zone in pairs(Config.Zones) do
                local radius = (zone.radius or 0.0) + (cleanup.radiusPadding or 0.0)
                if #(objectCoords - zone.center) <= radius then
                    insideArea = true
                    break
                end
            end

            if insideArea then
                SetEntityAsMissionEntity(object, true, true)
                DeleteEntity(object)
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


local function updateMissionHud(mission)
    if not mission then
        SendNUIMessage({ action = 'hideMissionHud' })
        return
    end

    local missionConfig = Config.Missions[mission.key]
    if not missionConfig then
        SendNUIMessage({ action = 'hideMissionHud' })
        return
    end

    local requirements = {
        {
            label = 'Mine ores',
            current = mission.mined or 0,
            required = missionConfig.rocks or mission.rocks or 0
        }
    }

    if missionConfig.requiredOre and missionConfig.requiredOreAmount then
        local ore = Config.Ores[missionConfig.requiredOre]
        requirements[#requirements + 1] = {
            label = ore and ore.label or missionConfig.requiredOre,
            current = mission.ores and mission.ores[missionConfig.requiredOre] or 0,
            required = missionConfig.requiredOreAmount
        }
    end

    SendNUIMessage({
        action = 'showMissionHud',
        mission = {
            label = mission.label or missionConfig.label,
            description = missionConfig.description,
            requirements = requirements
        }
    })
end




local function hideXpHud()
    SendNUIMessage({ action = 'hideXpHud' })
end

local function showXpHud(data)
    if not data then
        hideXpHud()
        return
    end

    SendNUIMessage({
        action = 'showXpHud',
        xp = data
    })
end

local function refreshXpHud()
    if not equippedPickaxeItem then
        hideXpHud()
        return
    end

    local data = lib.callback.await('sb_mining:server:getXpData', false)
    showXpHud(data)
end

local function stopMiningSound()
    miningSoundSession = miningSoundSession + 1
end

local function startMiningSound(ped, animation)
    local sound = Config.Rock.miningSound
    if not sound or not sound.enabled then
        return
    end

    miningSoundSession = miningSoundSession + 1
    local session = miningSoundSession
    local hitDelays = sound.hitDelays or { 0, 3000, 6000 }

    CreateThread(function()
        local elapsed = 0

        for _, delay in ipairs(hitDelays) do
            local waitTime = math.max(0, delay - elapsed)
            Wait(waitTime)
            elapsed = delay

            if not mining or session ~= miningSoundSession or not IsEntityPlayingAnim(ped, animation.dict, animation.clip, 3) then
                break
            end

            SendNUIMessage({ action = 'playMiningSound', volume = sound.volume or 0.18 })
        end
    end)
end

local function removePickaxeEntity(object)
    if not object or object == 0 or not DoesEntityExist(object) then
        return
    end

    DetachEntity(object, true, true)
    SetEntityAsMissionEntity(object, true, true)
    DeleteObject(object)

    if DoesEntityExist(object) then
        DeleteEntity(object)
    end
end

local function deletePickaxe()
    local ped = PlayerPedId()
    local model = Config.Rock.pickaxeProp and Config.Rock.pickaxeProp.model

    removePickaxeEntity(pickaxeObject)
    pickaxeObject = nil

    if model then
        for _, object in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(object) and GetEntityModel(object) == model and IsEntityAttachedToEntity(object, ped) then
                removePickaxeEntity(object)
            end
        end
    end
end

local function attachPickaxe()
    deletePickaxe()
    local ped = PlayerPedId()
    local data = Config.Rock.pickaxeProp
    if not loadModel(data.model) then return end
    local coords = GetEntityCoords(ped)
    pickaxeObject = CreateObjectNoOffset(data.model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityCollision(pickaxeObject, false, false)
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
        hideXpHud()
        return
    end

    equippedPickaxe = {
        key = key,
        label = label
    }
    equippedPickaxeItem = itemName
    attachPickaxe()
    refreshXpHud()
end

exports('usePickaxe', function(data)
    local itemName = type(data) == 'table' and data.name or data
    if not itemName then
        notify('Hakken kunne ikke genkendes.', 'error')
        return
    end

    usePickaxe(itemName)
end)

local function oreStateKey(zoneKey, rockIndex, nodeIndex)
    return ('%s:%s:%s'):format(zoneKey, rockIndex, nodeIndex)
end

local function getOreLabel(oreKey)
    local ore = Config.Ores[oreKey]
    return ore and ore.label or 'Malm'
end

local function getOreModel(oreKey)
    local data = Config.MiningProps[oreKey]
    return data and data.model or nil
end

local function deleteOreObject(zoneKey, rockIndex, nodeIndex)
    local key = oreStateKey(zoneKey, rockIndex, nodeIndex)
    local object = oreObjects[zoneKey] and oreObjects[zoneKey][rockIndex] and oreObjects[zoneKey][rockIndex][nodeIndex]
    local targetId = oreTargetEntities[key]

    if targetId then
        exports.ox_target:removeZone(targetId)
        oreTargetEntities[key] = nil
    end

    if object and DoesEntityExist(object) then
        DetachEntity(object, true, true)
        SetEntityAsMissionEntity(object, true, true)
        DeleteEntity(object)
    end

    if oreObjects[zoneKey] and oreObjects[zoneKey][rockIndex] then
        oreObjects[zoneKey][rockIndex][nodeIndex] = nil
    end
end

local function mineOreNode(zoneKey, rockIndex, nodeIndex)
    if mining then return end
    local object = oreObjects[zoneKey] and oreObjects[zoneKey][rockIndex] and oreObjects[zoneKey][rockIndex][nodeIndex]
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
    local animationStarted = false
    if loadAnim(animation.dict) then
        TaskPlayAnim(ped, animation.dict, animation.clip, 3.0, 3.0, -1, animation.flag, 0.0, false, false, false)
        animationStarted = true
        startMiningSound(ped, animation)
    end
    local duration = math.floor(Config.Rock.mineDuration * (pickaxe.speedMultiplier or 1.0))
    local success = lib.progressCircle({ duration = duration, label = 'Bryder malmen...', position = 'bottom', canCancel = true, disable = { move = true, car = true, combat = true } })
    stopMiningSound()
    ClearPedTasks(ped)

    if success then
        local ok, message, _, _, _, gainedXp, xpData = lib.callback.await('sb_mining:server:mineRock', false, zoneKey, rockIndex, nodeIndex)
        if ok then
            notify(('Du fandt: %s'):format(message), 'success')
            if gainedXp and gainedXp > 0 then
                notify(('Du fik %s mining XP.'):format(gainedXp), 'success')
            end
            if equippedPickaxeItem then
                showXpHud(xpData)
            end
        else
            notify(message or 'Malmen kunne ikke brydes.', 'error')
        end
    end

    stopMiningSound()
    mining = false
end

local function createOreNode(zoneKey, rockIndex, nodeIndex)
    local baseObject = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
    local node = Config.Rock.oreNodes and Config.Rock.oreNodes[nodeIndex]
    local oreKey = rockOreTypes[zoneKey] and rockOreTypes[zoneKey][rockIndex] and rockOreTypes[zoneKey][rockIndex][nodeIndex]
    local stateKey = oreStateKey(zoneKey, rockIndex, nodeIndex)

    if not baseObject or not DoesEntityExist(baseObject) or not node or not oreKey or rockStates[stateKey] then
        return
    end

    deleteOreObject(zoneKey, rockIndex, nodeIndex)

    local model = getOreModel(oreKey)
    if not model or not loadModel(model) then
        notify(('Ore-proppet til %s kunne ikke indlæses.'):format(getOreLabel(oreKey)), 'error')
        return
    end

    local worldCoords = GetOffsetFromEntityInWorldCoords(baseObject, node.offset.x, node.offset.y, node.offset.z)
    local object = CreateObjectNoOffset(model, worldCoords.x, worldCoords.y, worldCoords.z, false, false, false)
    SetEntityCollision(object, false, false)
    AttachEntityToEntity(
        object,
        baseObject,
        0,
        node.offset.x,
        node.offset.y,
        node.offset.z,
        node.rotation.x,
        node.rotation.y,
        node.rotation.z,
        false,
        false,
        false,
        false,
        2,
        true
    )

    Wait(0)
    local targetCoords = GetEntityCoords(object)
    local targetId = exports.ox_target:addSphereZone({
        coords = targetCoords,
        radius = node.radius or 0.38,
        debug = false,
        options = {
            {
                name = ('sb_mining_%s_%s_%s'):format(zoneKey, rockIndex, nodeIndex),
                icon = 'fas fa-hammer',
                label = ('Mine %s'):format(getOreLabel(oreKey)),
                distance = Config.Rock.interactionDistance,
                canInteract = function()
                    return not mining and not rockStates[stateKey] and DoesEntityExist(object)
                end,
                onSelect = function()
                    mineOreNode(zoneKey, rockIndex, nodeIndex)
                end
            }
        }
    })

    oreObjects[zoneKey] = oreObjects[zoneKey] or {}
    oreObjects[zoneKey][rockIndex] = oreObjects[zoneKey][rockIndex] or {}
    oreObjects[zoneKey][rockIndex][nodeIndex] = object
    oreTargetEntities[stateKey] = targetId
    SetModelAsNoLongerNeeded(model)
end

local function createRock(zoneKey, rockIndex)
    local zone = Config.Zones[zoneKey]
    local coords = zone and zone.rocks[rockIndex]
    if not coords then return end

    local existing = rockObjects[zoneKey] and rockObjects[zoneKey][rockIndex]
    if existing and DoesEntityExist(existing) then return end

    local model = Config.Rock.baseModel
    if not model or not loadModel(model) then
        notify('Mine-stenen kunne ikke indlæses.', 'error')
        return
    end

    local placement = Config.Rock.groundPlacement or {}
    local groundZ = coords.z
    local foundGround = false

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    for attempt = 1, placement.groundChecks or 20 do
        local probeHeight = coords.z + (placement.probeHeight or 10.0) + attempt
        local found, result = GetGroundZFor_3dCoord(coords.x, coords.y, probeHeight, false)

        if found then
            groundZ = result
            foundGround = true
            break
        end

        Wait(placement.attemptDelay or 50)
    end

    if not foundGround then
        groundZ = coords.z
    end

    local object = CreateObjectNoOffset(model, coords.x, coords.y, groundZ + (placement.spawnAboveGround or 0.5), false, false, false)
    SetEntityHeading(object, coords.w)
    SetEntityCollision(object, true, true)
    FreezeEntityPosition(object, false)
    PlaceObjectOnGroundProperly(object)
    Wait(0)

    local finalCoords = GetEntityCoords(object)
    if math.abs(finalCoords.z - groundZ) > (placement.maxGroundDifference or 1.0) then
        finalCoords = vec3(coords.x, coords.y, groundZ)
    end

    SetEntityCoordsNoOffset(object, coords.x, coords.y, finalCoords.z + (placement.zOffset or 0.0), false, false, false)
    SetEntityHeading(object, coords.w)
    FreezeEntityPosition(object, true)

    rockObjects[zoneKey] = rockObjects[zoneKey] or {}
    rockObjects[zoneKey][rockIndex] = object

    for nodeIndex = 1, math.min(Config.Rock.oresPerStone or 1, #(Config.Rock.oreNodes or {})) do
        createOreNode(zoneKey, rockIndex, nodeIndex)
    end

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
    updateMissionHud(mission)
    notify(('Mission startet: %s'):format(mission.label), 'success')
end)

RegisterNetEvent('sb_mining:client:missionProgress', function(mission)
    activeMission = mission
    updateMissionHud(mission)
    SendNUIMessage({ action = 'missionProgress', mission = mission })
end)

RegisterNetEvent('sb_mining:client:missionComplete', function(money, xp)
    activeMission = nil
    updateMissionHud(nil)
    notify(('Mission fuldført. Bonus: %s kr. og %s XP.'):format(money, xp), 'success')
end)

RegisterNetEvent('sb_mining:client:missionCancelled', function()
    activeMission = nil
    updateMissionHud(nil)
    notify('Missionen blev annulleret.', 'error')
end)

RegisterNetEvent('sb_mining:client:oreDepleted', function(zoneKey, rockIndex, nodeIndex)
    rockStates[oreStateKey(zoneKey, rockIndex, nodeIndex)] = true
    deleteOreObject(zoneKey, rockIndex, nodeIndex)
end)

RegisterNetEvent('sb_mining:client:rockRespawn', function(zoneKey, rockIndex, nodeIndex, seconds, oreKey)
    CreateThread(function()
        Wait(seconds * 1000)
        rockStates[oreStateKey(zoneKey, rockIndex, nodeIndex)] = nil
        rockOreTypes[zoneKey] = rockOreTypes[zoneKey] or {}
        rockOreTypes[zoneKey][rockIndex] = rockOreTypes[zoneKey][rockIndex] or {}
        rockOreTypes[zoneKey][rockIndex][nodeIndex] = oreKey
        createOreNode(zoneKey, rockIndex, nodeIndex)
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
                hideXpHud()
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
    cleanupUnusedMiningProps()
    Wait(250)
    createShop()
    createRocks()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeNui()
    hideXpHud()
    deletePickaxe()
    if shopPed and DoesEntityExist(shopPed) then DeleteEntity(shopPed) end
    if tableObject and DoesEntityExist(tableObject) then DeleteEntity(tableObject) end
    for _, rocks in pairs(oreObjects) do
        for _, nodes in pairs(rocks) do
            for _, object in pairs(nodes) do
                if object and DoesEntityExist(object) then
                    exports.ox_target:removeLocalEntity(object)
                    DeleteEntity(object)
                end
            end
        end
    end
    for zoneKey, rocks in pairs(oreObjects) do
        for rockIndex, nodes in pairs(rocks) do
            for nodeIndex in pairs(nodes) do
                deleteOreObject(zoneKey, rockIndex, nodeIndex)
            end
        end
    end
    for _, rocks in pairs(rockObjects) do
        for _, object in pairs(rocks) do
            if DoesEntityExist(object) then DeleteEntity(object) end
        end
    end
end)
