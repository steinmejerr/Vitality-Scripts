local ESX = exports['es_extended']:getSharedObject()
local spawnedPeds = {}
local blips = {}
local menuOpen = false
local currentLocation
local activeMission
local missionZones = {}
local missionObjects = {}
local missionBlip
local areaBlip
local gearEnabled = false
local oxygenStartedAt = 0
local oxygenRemaining = 0
local oxygenWarningsShown = {}
local savedAppearance
local gearObjects = {}
local gearPed
local lastGearToggleAt = 0

local function notify(description, notifyType)
    lib.notify({
        title = 'Dykkercenter',
        description = description,
        type = notifyType or 'inform',
        position = Config.Notify.position,
        duration = Config.Notify.duration
    })
end

RegisterNetEvent('sb_diving:client:notify', notify)


-- ox_inventory kalder denne export, når diving_gear bruges.
exports('useDivingGear', function(data, slot)
    TriggerServerEvent('sb_diving:server:validateGear')
end)

-- Kan også kaldes fra andre scripts eller item-systemer.
RegisterNetEvent('sb_diving:client:useGear', function()
    TriggerServerEvent('sb_diving:server:validateGear')
end)


local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do Wait(25) end
    return HasModelLoaded(hash) and hash or nil
end

local function setUiFocus(state)
    menuOpen = state
    SetNuiFocus(state, state)
end

local function openUi(view, locationId)
    local data = lib.callback.await('sb_diving:server:getUiData', false, locationId)
    if not data then return notify('Dykkercenteret kunne ikke indlæses.', 'error') end
    currentLocation = locationId
    setUiFocus(true)
    SendNUIMessage({ action = 'open', view = view, data = data })
end

local function closeUi()
    setUiFocus(false)
    SendNUIMessage({ action = 'close' })
end

local function removeMissionObject(pointIndex)
    local entry = missionObjects[pointIndex]
    if not entry then return end

    if entry.entity and DoesEntityExist(entry.entity) then
        exports.ox_target:removeLocalEntity(entry.entity, entry.targetName)
        SetEntityAsMissionEntity(entry.entity, true, true)
        DeleteEntity(entry.entity)
    end

    missionObjects[pointIndex] = nil
end

local function clearMissionZones()
    for i = 1, #missionZones do
        exports.ox_target:removeZone(missionZones[i])
    end
    missionZones = {}

    for pointIndex in pairs(missionObjects) do
        removeMissionObject(pointIndex)
    end
    missionObjects = {}

    if missionBlip then RemoveBlip(missionBlip) missionBlip = nil end
    if areaBlip then RemoveBlip(areaBlip) areaBlip = nil end
end

local function deleteGearObjects()
    for _, object in pairs(gearObjects) do
        if DoesEntityExist(object) then
            DeleteEntity(object)
        end
    end
    gearObjects = {}
end

local function captureSkinchangerSkin()
    local skin
    local completed = false

    -- ESX skinchanger returnerer normalt synkront gennem callbacken,
    -- men vi giver den kort tid for kompatibilitet med custom clothing-scripts.
    TriggerEvent('skinchanger:getSkin', function(currentSkin)
        if type(currentSkin) == 'table' then
            skin = currentSkin
        end
        completed = true
    end)

    local timeout = GetGameTimer() + 500
    while not completed and GetGameTimer() < timeout do
        Wait(0)
    end

    return skin
end

local function saveAppearance(ped)
    local appearance = {
        components = {},
        props = {},
        skin = captureSkinchangerSkin()
    }

    for component = 0, 11 do
        appearance.components[component] = {
            drawable = GetPedDrawableVariation(ped, component),
            texture = GetPedTextureVariation(ped, component),
            palette = GetPedPaletteVariation(ped, component)
        }
    end

    for prop = 0, 7 do
        appearance.props[prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture = GetPedPropTextureIndex(ped, prop)
        }
    end

    return appearance
end

local function applyNativeAppearance(ped, appearance)
    if not appearance then return end

    for component, data in pairs(appearance.components or {}) do
        SetPedComponentVariation(
            ped,
            tonumber(component),
            data.drawable,
            data.texture,
            data.palette or 0
        )
    end

    for prop, data in pairs(appearance.props or {}) do
        prop = tonumber(prop)
        if data.drawable and data.drawable >= 0 then
            SetPedPropIndex(ped, prop, data.drawable, data.texture or 0, true)
        else
            ClearPedProp(ped, prop)
        end
    end
end

local function restoreAppearance(ped)
    if not savedAppearance then return end

    local appearance = savedAppearance
    savedAppearance = nil

    -- Brug clothing-systemets egen skin, når skinchanger er tilgængelig.
    -- Det er mere stabilt end kun at ændre GTA components direkte.
    if appearance.skin then
        TriggerEvent('skinchanger:loadSkin', appearance.skin)
        Wait(150)
    end

    -- Fallback og sidste sikkerhed: gendan også de præcise components/props.
    applyNativeAppearance(ped, appearance)

    -- Nogle clothing-scripts anvender deres ændringer en frame senere.
    -- Gentag derfor én gang kort efter, så scuba-outfittet ikke bliver stående.
    CreateThread(function()
        Wait(500)
        local currentPed = PlayerPedId()
        if not gearEnabled and DoesEntityExist(currentPed) then
            if appearance.skin then
                TriggerEvent('skinchanger:loadSkin', appearance.skin)
                Wait(100)
            end
            applyNativeAppearance(currentPed, appearance)
        end
    end)
end

local function applyDivingOutfit(ped)
    local outfit = Config.Diving.outfit
    if not outfit or not outfit.enabled then return end

    local model = GetEntityModel(ped)
    local components

    if model == joaat('mp_m_freemode_01') then
        components = outfit.male
    elseif model == joaat('mp_f_freemode_01') then
        components = outfit.female
    end

    if not components then
        notify('Din karaktermodel understøtter ikke standard-dykkertøjet. Synlige udstyrsdele kan derfor være begrænsede.', 'warning')
        return
    end

    -- Gem kun det oprindelige outfit én gang pr. aktivering.
    if not savedAppearance then
        savedAppearance = saveAppearance(ped)
    end

    for component, data in pairs(components) do
        SetPedComponentVariation(ped, component, data.drawable, data.texture or 0, data.palette or 0)
    end
end

local function createAttachedGearObject(ped, config)
    if not config or config.enabled == false or not config.model then return nil end

    local hash = loadModel(config.model)
    if not hash then
        print(('[sb_diving] Kunne ikke indlæse udstyrsmodel: %s'):format(config.model))
        return nil
    end

    local coords = GetEntityCoords(ped)
    local object = CreateObject(hash, coords.x, coords.y, coords.z, true, true, false)
    if not DoesEntityExist(object) then return nil end

    SetEntityCollision(object, false, false)
    AttachEntityToEntity(
        object,
        ped,
        GetPedBoneIndex(ped, config.bone),
        config.offset.x, config.offset.y, config.offset.z,
        config.rotation.x, config.rotation.y, config.rotation.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(hash)
    return object
end

local function applyVisibleGear(ped)
    deleteGearObjects()
    applyDivingOutfit(ped)

    local props = Config.Diving.props or {}
    gearObjects.tank = createAttachedGearObject(ped, props.tank)
    gearObjects.mask = createAttachedGearObject(ped, props.mask)
    gearPed = ped
end

local function removeVisibleGear(ped)
    deleteGearObjects()
    restoreAppearance(ped)
    gearPed = nil
end

local function updateOxygenUi()
    local percent = 0
    if Config.Diving.oxygenSeconds > 0 then
        percent = math.max(0, math.min(100, math.floor((oxygenRemaining / Config.Diving.oxygenSeconds) * 100)))
    end

    SendNUIMessage({
        action = 'oxygen',
        visible = gearEnabled,
        remaining = math.max(0, math.ceil(oxygenRemaining)),
        percent = percent,
        underwater = IsPedSwimmingUnderWater(PlayerPedId())
    })
end

local function setGear(enabled, silent)
    local ped = PlayerPedId()

    if enabled == gearEnabled then return end
    gearEnabled = enabled

    if enabled then
        oxygenRemaining = Config.Diving.oxygenSeconds + 0.0
        oxygenWarningsShown = {}
        oxygenStartedAt = GetGameTimer()
        applyVisibleGear(ped)
        SetEnableScuba(ped, true)
        SetPedMaxTimeUnderwater(ped, 99999.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), Config.Diving.swimMultiplier)
        updateOxygenUi()
        if not silent then notify('Dykkerudstyret er taget på. Iltflasken er fuld.', 'success') end
    else
        SetEnableScuba(ped, false)
        SetPedMaxTimeUnderwater(ped, 10.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        oxygenStartedAt = 0
        oxygenRemaining = 0
        oxygenWarningsShown = {}
        removeVisibleGear(ped)
        SendNUIMessage({ action = 'oxygen', visible = false })
        if not silent then notify('Dykkerudstyret er taget af.', 'inform') end
    end
end

RegisterNetEvent('sb_diving:client:setGear', function(hasGear)
    local now = GetGameTimer()

    -- ox_inventory og ESX compatibility kan begge affyre use-handleren.
    -- Ignorér dubletkald, så ét klik kun toggler udstyret én gang.
    if now - lastGearToggleAt < 1000 then
        return
    end

    lastGearToggleAt = now

    if not hasGear then
        if gearEnabled then setGear(false, true) end
        return notify('Du ejer ikke dykkerudstyr.', 'error')
    end

    setGear(not gearEnabled)
end)

local function getSearchPropModel(pointIndex)
    local models = Config.Search.props or { 'prop_box_wood02a_pu' }
    if #models == 0 then return nil end
    return models[((pointIndex - 1) % #models) + 1]
end

local function addMissionZone(pointIndex, coords)
    local model = getSearchPropModel(pointIndex)
    local hash = model and loadModel(model)

    if not hash then
        print(('[sb_diving] Kunne ikke indlæse mission-prop ved punkt %s.'):format(pointIndex))
        return
    end

    local object = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
    if not DoesEntityExist(object) then
        print(('[sb_diving] Kunne ikke oprette mission-prop ved punkt %s.'):format(pointIndex))
        SetModelAsNoLongerNeeded(hash)
        return
    end

    SetEntityAsMissionEntity(object, true, true)
    SetEntityHeading(object, math.random(0, 359) + 0.0)
    FreezeEntityPosition(object, true)
    SetEntityCollision(object, true, true)
    SetModelAsNoLongerNeeded(hash)

    local targetName = ('sb_diving_search_%s_%s'):format(activeMission.id, pointIndex)
    missionObjects[pointIndex] = {
        entity = object,
        targetName = targetName,
        coords = coords
    }

    exports.ox_target:addLocalEntity(object, {
        {
            name = targetName,
            icon = Config.Search.targetIcon,
            label = Config.Search.targetLabel,
            distance = Config.Search.distance + 1.0,
            canInteract = function(entity)
                return activeMission ~= nil
                    and missionObjects[pointIndex] ~= nil
                    and entity == missionObjects[pointIndex].entity
                    and gearEnabled
                    and IsPedSwimmingUnderWater(PlayerPedId())
            end,
            onSelect = function()
                if not activeMission or not missionObjects[pointIndex] then return end

                local completed = lib.progressCircle({
                    duration = Config.Search.duration,
                    label = 'Undersøger fundet...',
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'amb@world_human_bum_wash@male@high@idle_a', clip = 'idle_a' }
                })
                if not completed then return end

                local result = lib.callback.await('sb_diving:server:searchPoint', false, activeMission.id, pointIndex)
                if not result or not result.success then
                    if result and result.expired then
                        activeMission = nil
                        clearMissionZones()
                    end
                    return notify(result and result.message or 'Fundet kunne ikke undersøges.', 'error')
                end

                removeMissionObject(pointIndex)
                notify(('Du fandt %dx %s. (%d/%d)'):format(result.amount, result.label, result.completed, result.required), 'success')
                SendNUIMessage({ action = 'missionProgress', completed = result.completed, required = result.required })

                if result.finished then
                    notify(('Mission fuldført! Du modtog %s kr. inkl. depositum.'):format(result.bonus), 'success')
                    activeMission = nil
                    clearMissionZones()
                end
            end
        }
    })
end

local function beginMission(mission)
    clearMissionZones()
    activeMission = mission

    areaBlip = AddBlipForRadius(mission.area.center.x, mission.area.center.y, mission.area.center.z, mission.area.radius)
    SetBlipColour(areaBlip, 3)
    SetBlipAlpha(areaBlip, 85)

    missionBlip = AddBlipForCoord(mission.area.center.x, mission.area.center.y, mission.area.center.z)
    SetBlipSprite(missionBlip, 597)
    SetBlipColour(missionBlip, 3)
    SetBlipRoute(missionBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(mission.label)
    EndTextCommandSetBlipName(missionBlip)

    for i = 1, #mission.points do
        local pointIndex = mission.points[i]
        addMissionZone(pointIndex, mission.searchPoints[pointIndex])
    end
end

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb(true)
end)

RegisterNUICallback('changeView', function(data, cb)
    local uiData = lib.callback.await('sb_diving:server:getUiData', false, currentLocation)
    cb({ success = uiData ~= nil, data = uiData })
end)

RegisterNUICallback('buyItem', function(data, cb)
    local result = lib.callback.await('sb_diving:server:buyItem', false, data.item)
    if result then notify(result.message, result.success and 'success' or 'error') end
    cb(result or { success = false })
end)

RegisterNUICallback('toggleGear', function(_, cb)
    TriggerServerEvent('sb_diving:server:validateGear')
    cb({ success = true })
end)

RegisterNUICallback('startMission', function(data, cb)
    local result = lib.callback.await('sb_diving:server:startMission', false, data.missionId)
    if result and result.success then
        beginMission(result.mission)
        closeUi()
        notify(result.message, 'success')
    elseif result then
        notify(result.message, 'error')
    end
    cb(result or { success = false })
end)

RegisterNUICallback('cancelMission', function(_, cb)
    local result = lib.callback.await('sb_diving:server:cancelMission', false)
    if result and result.success then
        activeMission = nil
        clearMissionZones()
        closeUi()
    end
    if result then notify(result.message, result.success and 'inform' or 'error') end
    cb(result or { success = false })
end)

RegisterNUICallback('sellItem', function(data, cb)
    local result = lib.callback.await('sb_diving:server:sellItem', false, data.item, data.amount)
    if result then notify(result.message, result.success and 'success' or 'error') end
    if result and result.success then
        result.data = lib.callback.await('sb_diving:server:getUiData', false, currentLocation)
    end
    cb(result or { success = false })
end)

RegisterNUICallback('sellAll', function(_, cb)
    local result = lib.callback.await('sb_diving:server:sellAll', false)
    if result then notify(result.message, result.success and 'success' or 'error') end
    if result and result.success then
        result.data = lib.callback.await('sb_diving:server:getUiData', false, currentLocation)
    end
    cb(result or { success = false })
end)

CreateThread(function()
    for i = 1, #Config.Locations do
        local location = Config.Locations[i]
        local hash = loadModel(location.ped.model)
        if hash then
            local c = location.ped.coords
            local ped = CreatePed(0, hash, c.x, c.y, c.z - 1.0, c.w, false, false)
            SetEntityInvincible(ped, true)
            FreezeEntityPosition(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            if location.ped.scenario then TaskStartScenarioInPlace(ped, location.ped.scenario, 0, true) end
            SetModelAsNoLongerNeeded(hash)
            spawnedPeds[#spawnedPeds + 1] = ped

            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'sb_diving_shop_' .. location.id,
                    icon = 'fa-solid fa-store',
                    label = 'Åbn dykkerbutik',
                    distance = Config.InteractionDistance,
                    onSelect = function() openUi('shop', location.id) end
                },
                {
                    name = 'sb_diving_missions_' .. location.id,
                    icon = 'fa-solid fa-list-check',
                    label = 'Se dykkermissioner',
                    distance = Config.InteractionDistance,
                    onSelect = function() openUi('missions', location.id) end
                },
                {
                    name = 'sb_diving_sell_' .. location.id,
                    icon = 'fa-solid fa-sack-dollar',
                    label = 'Sælg dykkerfund',
                    distance = Config.InteractionDistance,
                    onSelect = function() openUi('sell', location.id) end
                }
            })
        end

        if location.blip and location.blip.enabled then
            local c = location.ped.coords
            local blip = AddBlipForCoord(c.x, c.y, c.z)
            SetBlipSprite(blip, location.blip.sprite)
            SetBlipColour(blip, location.blip.colour)
            SetBlipScale(blip, location.blip.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(location.blip.label)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
    end
end)

CreateThread(function()
    while true do
        if not activeMission or not next(missionObjects) then
            Wait(500)
        else
            Wait(0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local marker = Config.Search.marker or {}
            local drawDistance = marker.drawDistance or 45.0

            for _, entry in pairs(missionObjects) do
                if entry.entity and DoesEntityExist(entry.entity) then
                    local coords = GetEntityCoords(entry.entity)
                    if #(playerCoords - coords) <= drawDistance then
                        DrawMarker(
                            marker.type or 2,
                            coords.x, coords.y, coords.z + (marker.height or 1.15),
                            0.0, 0.0, 0.0,
                            180.0, 0.0, 0.0,
                            marker.scale and marker.scale.x or 0.28,
                            marker.scale and marker.scale.y or 0.28,
                            marker.scale and marker.scale.z or 0.28,
                            marker.color and marker.color.r or 82,
                            marker.color and marker.color.g or 255,
                            marker.color and marker.color.b or 170,
                            marker.color and marker.color.a or 210,
                            false, true, 2, false, nil, nil, false
                        )
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    local lastTick = GetGameTimer()

    while true do
        if not gearEnabled then
            Wait(750)
            lastTick = GetGameTimer()
        else
            Wait(250)

            local ped = PlayerPedId()
            local now = GetGameTimer()
            local elapsed = math.max(0, (now - lastTick) / 1000.0)
            lastTick = now

            -- Hvis karaktermodellen ændres, bliver udstyret sat korrekt på den nye ped.
            if gearPed ~= ped then
                deleteGearObjects()
                savedAppearance = nil
                applyVisibleGear(ped)
                SetEnableScuba(ped, true)
                SetPedMaxTimeUnderwater(ped, 99999.0)
            end

            if IsPedSwimmingUnderWater(ped) then
                oxygenRemaining = math.max(0.0, oxygenRemaining - elapsed)

                local percent = (oxygenRemaining / Config.Diving.oxygenSeconds) * 100.0
                for _, threshold in ipairs(Config.Diving.lowOxygenWarnings or {}) do
                    if percent <= threshold and not oxygenWarningsShown[threshold] then
                        oxygenWarningsShown[threshold] = true
                        notify(('Iltflasken er nede på %d%%.'):format(threshold), threshold <= 10 and 'error' or 'warning')
                    end
                end

                if oxygenRemaining <= 0.0 then
                    SetEnableScuba(ped, false)
                    SetPedMaxTimeUnderwater(ped, 5.0)
                    notify('Iltflasken er tom! Gå straks mod overfladen.', 'error')
                else
                    SetEnableScuba(ped, true)
                    SetPedMaxTimeUnderwater(ped, 99999.0)
                end
            end

            updateOxygenUi()

            if Config.Diving.removeGearOnDeath and IsEntityDead(ped) then
                setGear(false, true)
            end
        end
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUi()
    clearMissionZones()
    if gearEnabled then setGear(false, true) end
    SetEnableScuba(PlayerPedId(), false)
    SetPedMaxTimeUnderwater(PlayerPedId(), 10.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    deleteGearObjects()
    for i = 1, #spawnedPeds do
        if DoesEntityExist(spawnedPeds[i]) then DeleteEntity(spawnedPeds[i]) end
    end
    for i = 1, #blips do RemoveBlip(blips[i]) end
end)
