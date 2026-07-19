local ESX = exports.es_extended:getSharedObject()
local npc, pickupObject, pickupZone, pickupBlip
local menuOpen = false
local currentPickup

local function notify(description, type)
    lib.notify({ title = 'Kontakten', description = description, type = type or 'inform' })
end

local function loadModel(model)
    if not IsModelInCdimage(model) then return false end
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end
    return true
end

local function closeMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openMenu()
    local data = lib.callback.await('sb_gangbuy:server:getMenuData', false)
    if not data or not data.allowed then
        return notify((data and data.message) or 'Du har ikke adgang.', 'error')
    end

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end

local function clearPickup()
    if pickupZone then exports.ox_target:removeZone(pickupZone) pickupZone = nil end
    if pickupObject and DoesEntityExist(pickupObject) then DeleteEntity(pickupObject) pickupObject = nil end
    if pickupBlip and DoesBlipExist(pickupBlip) then RemoveBlip(pickupBlip) pickupBlip = nil end
    currentPickup = nil
end

local function createPickup(kind, payload)
    clearPickup()
    local coords = payload.coords
    if not coords then return end

    local model = Config.Pickup.prop
    if loadModel(model) then
        pickupObject = CreateObject(model, coords.x, coords.y, coords.z - 1.0, false, false, false)
        SetEntityHeading(pickupObject, coords.w or 0.0)
        PlaceObjectOnGroundProperly(pickupObject)
        FreezeEntityPosition(pickupObject, true)
        SetModelAsNoLongerNeeded(model)
    end

    pickupBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(pickupBlip, Config.Blip.sprite)
    SetBlipColour(pickupBlip, Config.Blip.colour)
    SetBlipScale(pickupBlip, Config.Blip.scale)
    SetBlipRoute(pickupBlip, true)
    SetBlipRouteColour(pickupBlip, Config.Blip.routeColour)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(kind == 'order' and Config.Blip.labelOrder or Config.Blip.labelMission)
    EndTextCommandSetBlipName(pickupBlip)

    currentPickup = { kind = kind, payload = payload }
    pickupZone = exports.ox_target:addSphereZone({
        coords = vec3(coords.x, coords.y, coords.z),
        radius = 1.5,
        debug = Config.Debug,
        options = {{
            name = 'sb_gangbuy_pickup',
            icon = Config.Pickup.targetIcon,
            label = kind == 'order' and 'Hent levering' or 'Hent missionens pakke',
            distance = Config.InteractionDistance,
            onSelect = function()
                if not currentPickup then return end
                local duration = kind == 'order' and Config.OrderPickupDuration or Config.MissionPickupDuration
                local completed = lib.progressCircle({
                    duration = duration,
                    position = 'bottom',
                    label = kind == 'order' and 'Henter levering...' or 'Sikrer pakken...',
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'anim@heists@box_carry@', clip = 'idle' }
                })
                if not completed then return end

                local result
                if kind == 'order' then
                    result = lib.callback.await('sb_gangbuy:server:collectOrder', false, payload.id)
                else
                    result = lib.callback.await('sb_gangbuy:server:collectMission', false, payload.id)
                end

                if result and result.success then
                    notify(result.message, 'success')
                    clearPickup()
                    SendNUIMessage({ action = 'refreshRequested' })
                else
                    notify(result and result.message or 'Noget gik galt.', 'error')
                end
            end
        }}
    })

    SetNewWaypoint(coords.x, coords.y)
end

CreateThread(function()
    if not loadModel(Config.Npc.model) then return end
    local c = Config.Npc.coords
    npc = CreatePed(0, Config.Npc.model, c.x, c.y, c.z - 1.0, c.w, false, false)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
    if Config.Npc.scenario then TaskStartScenarioInPlace(npc, Config.Npc.scenario, 0, true) end
    SetModelAsNoLongerNeeded(Config.Npc.model)

    exports.ox_target:addLocalEntity(npc, {{
        name = 'sb_gangbuy_open',
        icon = Config.Npc.targetIcon,
        label = Config.Npc.targetLabel,
        distance = Config.InteractionDistance,
        onSelect = openMenu
    }})
end)

CreateThread(function()
    while true do
        Wait(5000)
        TriggerServerEvent('sb_gangbuy:server:checkReady')
    end
end)

RegisterNetEvent('sb_gangbuy:client:orderReady', function(order)
    notify('Din ordre er klar. GPS er sendt.', 'success')
    createPickup('order', order)
    SendNUIMessage({ action = 'orderReady', order = order })
end)

RegisterNetEvent('sb_gangbuy:client:missionReady', function(mission)
    notify('GPS til opgaven er sendt.', 'success')
    createPickup('mission', mission)
    SendNUIMessage({ action = 'missionReady', mission = mission })
end)

RegisterNUICallback('close', function(_, cb) closeMenu() cb(true) end)

RegisterNUICallback('refresh', function(_, cb)
    local data = lib.callback.await('sb_gangbuy:server:getMenuData', false)
    cb(data or {})
end)

RegisterNUICallback('buyProduct', function(data, cb)
    local result = lib.callback.await('sb_gangbuy:server:buyProduct', false, data.id)
    if result and result.message then notify(result.message, result.success and 'success' or 'error') end
    cb(result or { success = false })
end)

RegisterNUICallback('startMission', function(data, cb)
    local result = lib.callback.await('sb_gangbuy:server:startMission', false, data.id)
    if result and result.message then notify(result.message, result.success and 'success' or 'error') end
    cb(result or { success = false })
end)

RegisterNUICallback('setGps', function(data, cb)
    if data.coords then
        SetNewWaypoint(data.coords.x + 0.0, data.coords.y + 0.0)
        notify('GPS er sat.', 'success')
    end
    cb(true)
end)

RegisterNetEvent('esx:setJob', function()
    if not menuOpen then return end

    CreateThread(function()
        Wait(250)
        local data = lib.callback.await('sb_gangbuy:server:getMenuData', false)
        if not data or not data.allowed then
            closeMenu()
        end
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    clearPickup()
    if npc and DoesEntityExist(npc) then DeleteEntity(npc) end
    SetNuiFocus(false, false)
end)

RegisterNetEvent('sb_gangbuy:client:openAdmin', function()
    local data = lib.callback.await('sb_gangbuy:server:getAdminData', false)
    if not data or not data.allowed then
        return notify('Du har ikke adgang.', 'error')
    end

    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openAdmin', data = data })
end)

RegisterNUICallback('adminSave', function(data, cb)
    local result = lib.callback.await('sb_gangbuy:server:adminSave', false, data)
    if result and result.message then notify(result.message, result.success and 'success' or 'error') end
    cb(result or { success = false })
end)

RegisterNUICallback('adminDelete', function(data, cb)
    local ok, result = pcall(function()
        return lib.callback.await('sb_gangbuy:server:adminDelete', false, data)
    end)

    if not ok then
        result = { success = false, message = 'Banden kunne ikke slettes.' }
        print(('[sb_gangbuy] adminDelete callback failed: %s'):format(tostring(result)))
    end

    if result and result.message then
        notify(result.message, result.success and 'success' or 'error')
    end

    cb(result or { success = false, message = 'Der skete en ukendt fejl.' })
end)

RegisterNUICallback('adminRefresh', function(_, cb)
    local data = lib.callback.await('sb_gangbuy:server:getAdminData', false)
    cb(data or {})
end)
