local ESX = exports['es_extended']:getSharedObject()
local spawnedPeds = {}
local blips = {}
local menuOpen = false
local currentLocation
local activeMission
local missionZones = {}
local missionBlip
local areaBlip
local gearEnabled = false
local oxygenStartedAt = 0

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

local function clearMissionZones()
    for i = 1, #missionZones do
        exports.ox_target:removeZone(missionZones[i])
    end
    missionZones = {}
    if missionBlip then RemoveBlip(missionBlip) missionBlip = nil end
    if areaBlip then RemoveBlip(areaBlip) areaBlip = nil end
end

local function setGear(enabled)
    local ped = PlayerPedId()
    gearEnabled = enabled
    if enabled then
        SetEnableScuba(ped, true)
        SetPedMaxTimeUnderwater(ped, Config.Diving.oxygenSeconds + 0.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), Config.Diving.swimMultiplier)
        oxygenStartedAt = GetGameTimer()
        notify('Dykkerudstyret er aktiveret.', 'success')
    else
        SetEnableScuba(ped, false)
        SetPedMaxTimeUnderwater(ped, 10.0)
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        oxygenStartedAt = 0
        notify('Dykkerudstyret er deaktiveret.', 'inform')
    end
end

RegisterNetEvent('sb_diving:client:setGear', function(hasGear)
    if not hasGear then
        gearEnabled = false
        SetEnableScuba(PlayerPedId(), false)
        return notify('Du ejer ikke dykkerudstyr.', 'error')
    end
    setGear(not gearEnabled)
end)

local function addMissionZone(pointIndex, coords)
    local zoneId = exports.ox_target:addSphereZone({
        coords = coords,
        radius = Config.Search.distance,
        debug = Config.Debug,
        options = {
            {
                name = ('sb_diving_search_%s_%s'):format(activeMission.id, pointIndex),
                icon = Config.Search.targetIcon,
                label = Config.Search.targetLabel,
                distance = Config.Search.distance + 1.0,
                canInteract = function()
                    return activeMission ~= nil and gearEnabled and IsPedSwimmingUnderWater(PlayerPedId())
                end,
                onSelect = function()
                    if not activeMission then return end
                    local completed = lib.progressCircle({
                        duration = Config.Search.duration,
                        label = 'Undersøger havbunden...',
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
                        return notify(result and result.message or 'Fundstedet kunne ikke undersøges.', 'error')
                    end

                    exports.ox_target:removeZone(zoneId)
                    for i = #missionZones, 1, -1 do
                        if missionZones[i] == zoneId then table.remove(missionZones, i) break end
                    end
                    notify(('Du fandt %dx %s. (%d/%d)'):format(result.amount, result.label, result.completed, result.required), 'success')
                    SendNUIMessage({ action = 'missionProgress', completed = result.completed, required = result.required })
                    if result.finished then
                        notify(('Mission fuldført! Du modtog %s kr. inkl. depositum.'):format(result.bonus), 'success')
                        activeMission = nil
                        clearMissionZones()
                    end
                end
            }
        }
    })
    missionZones[#missionZones + 1] = zoneId
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
        Wait(1000)
        -- Missionens udløb valideres server-side ved hvert fundsted.
        -- Klienten bruger bevidst ikke Lua os-biblioteket, som ikke findes i FiveM client scripts.
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    closeUi()
    clearMissionZones()
    SetEnableScuba(PlayerPedId(), false)
    SetPedMaxTimeUnderwater(PlayerPedId(), 10.0)
    SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    for i = 1, #spawnedPeds do
        if DoesEntityExist(spawnedPeds[i]) then DeleteEntity(spawnedPeds[i]) end
    end
    for i = 1, #blips do RemoveBlip(blips[i]) end
end)
