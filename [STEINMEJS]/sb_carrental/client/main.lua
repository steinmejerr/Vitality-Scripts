local ESX = exports['es_extended']:getSharedObject()
local rentalPeds = {}
local rentalVehicle = nil
local currentLocationIndex = nil
local menuOpen = false
local papersOpen = false

local function notify(description, notifyType)
    lib.notify({
        title = 'Biludlejning',
        description = description,
        type = notifyType or 'inform',
        position = 'top-right',
        duration = 4500
    })
end

RegisterNetEvent('sb_carrental:client:notify', function(description, notifyType)
    notify(description, notifyType)
end)

local function closeMenu()
    if not menuOpen and not papersOpen then return end
    menuOpen = false
    papersOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openMenu(locationIndex)
    local location = Config.Locations[locationIndex]
    if not location then return end

    currentLocationIndex = locationIndex
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        label = location.label,
        currency = Config.Currency,
        vehicles = location.vehicles,
        durations = Config.Rental.durations or {}
    })
end

local function requestModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then return nil end

    RequestModel(hash)
    local deadline = GetGameTimer() + 8000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(hash) then return nil end
    return hash
end

local function isSpawnClear(coords)
    return not IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0)
end

local function getAvailableSpawn(location)
    local spawns = location.spawns or (location.spawn and { location.spawn }) or {}

    for _, coords in ipairs(spawns) do
        if isSpawnClear(coords) then
            return coords
        end
    end

    return nil
end

local function spawnRental(data)
    local hash = requestModel(data.model)
    if not hash then
        TriggerServerEvent('sb_carrental:server:spawnFailed', data.token)
        return
    end

    local location = Config.Locations[tonumber(data.locationIndex)]
    local spawn = location and getAvailableSpawn(location) or nil

    if not spawn then
        SetModelAsNoLongerNeeded(hash)
        TriggerServerEvent('sb_carrental:server:spawnFailed', data.token)
        notify('Alle udlejningspladser ved denne lokation er optaget.', 'error')
        return
    end

    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, true)
    if not DoesEntityExist(vehicle) then
        SetModelAsNoLongerNeeded(hash)
        TriggerServerEvent('sb_carrental:server:spawnFailed', data.token)
        return
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleNumberPlateText(vehicle, data.plate)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleFuelLevel(vehicle, Config.Rental.fuel or 100.0)
    SetVehicleEngineOn(vehicle, Config.Rental.engineOn == true, true, false)
    SetVehicleDoorsLocked(vehicle, 1)

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdCanMigrate(netId, true)
    TriggerServerEvent('sb_carrental:server:spawned', data.token, netId)

    rentalVehicle = vehicle
    if Config.Rental.warpIntoVehicle then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end

    SetModelAsNoLongerNeeded(hash)
    notify(('Du har lejet en %s i %s med nummerpladen %s.'):format(data.model, data.durationLabel or 'den valgte periode', data.plate), 'success')
end

RegisterNetEvent('sb_carrental:client:rentalExpired', function(plate)
    plate = tostring(plate or ''):gsub('%s+', '')
    local vehicle = rentalVehicle

    if not vehicle or not DoesEntityExist(vehicle) or GetVehicleNumberPlateText(vehicle):gsub('%s+', '') ~= plate then
        local vehicles = GetGamePool('CVehicle')
        for _, candidate in ipairs(vehicles) do
            if GetVehicleNumberPlateText(candidate):gsub('%s+', '') == plate then
                vehicle = candidate
                break
            end
        end
    end

    if vehicle and DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local deadline = GetGameTimer() + 1500
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < deadline do
            Wait(0)
            NetworkRequestControlOfEntity(vehicle)
        end
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end

    rentalVehicle = nil
    notify('Din lejeperiode er udløbet, og køretøjet er blevet afleveret automatisk.', 'inform')
end)

local function findNearbyRentalVehicle(plate, radius)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local currentVehicle = GetVehiclePedIsIn(ped, false)

    if currentVehicle ~= 0 and GetVehicleNumberPlateText(currentVehicle):gsub('%s+', '') == plate:gsub('%s+', '') then
        return currentVehicle
    end

    local vehicles = GetGamePool('CVehicle')
    local nearest, nearestDistance
    for _, vehicle in ipairs(vehicles) do
        local vehiclePlate = GetVehicleNumberPlateText(vehicle):gsub('%s+', '')
        if vehiclePlate == plate:gsub('%s+', '') then
            local distance = #(coords - GetEntityCoords(vehicle))
            if distance <= radius and (not nearestDistance or distance < nearestDistance) then
                nearest = vehicle
                nearestDistance = distance
            end
        end
    end
    return nearest
end

local function returnRental(locationIndex)
    local location = Config.Locations[locationIndex]
    local rental = lib.callback.await('sb_carrental:server:getActiveRental', false)
    if not rental then
        notify('Du har ingen aktiv lejebil.', 'error')
        return
    end

    local vehicle = findNearbyRentalVehicle(rental.plate, location.returnRadius or 15.0)
    if not vehicle then
        notify(('Lejebilen med nummerpladen %s skal være i nærheden.'):format(rental.plate), 'error')
        return
    end

    local response = lib.callback.await('sb_carrental:server:returnRental', false, rental.plate)
    if not response or not response.success then
        notify(response and response.message or 'Lejebilen kunne ikke afleveres.', 'error')
        return
    end

    if Config.Rental.deleteOnReturn and DoesEntityExist(vehicle) then
        NetworkRequestControlOfEntity(vehicle)
        local deadline = GetGameTimer() + 1500
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < deadline do
            Wait(0)
            NetworkRequestControlOfEntity(vehicle)
        end
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
    end

    rentalVehicle = nil
    notify(response.message, 'success')
end

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb({ ok = true })
end)

RegisterNUICallback('rent', function(data, cb)
    if not currentLocationIndex then
        cb({ success = false, message = 'Udlejningsstedet kunne ikke findes.' })
        return
    end

    local response = lib.callback.await('sb_carrental:server:requestRental', false, {
        locationIndex = currentLocationIndex,
        model = data.model,
        paymentMethod = data.paymentMethod,
        durationId = data.durationId
    })

    cb(response or { success = false, message = 'Serveren svarede ikke.' })
    if response and response.success then
        closeMenu()
        spawnRental(response)
    end
end)

local function openActivePapers(locationIndex)
    local rental = lib.callback.await('sb_carrental:server:getRentalPapers', false)
    if not rental then
        notify('Du har ingen aktive køretøjspapirer.', 'error')
        return
    end

    currentLocationIndex = locationIndex
    papersOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPapers',
        currency = Config.Currency,
        rental = rental
    })
end

local function createBlip(location)
    if not location.blip or not location.blip.enabled then return end
    local blip = AddBlipForCoord(location.npc.coords.x, location.npc.coords.y, location.npc.coords.z)
    SetBlipSprite(blip, location.blip.sprite or 225)
    SetBlipColour(blip, location.blip.colour or 2)
    SetBlipScale(blip, location.blip.scale or 0.75)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(location.blip.name or location.label)
    EndTextCommandSetBlipName(blip)
end

CreateThread(function()
    for index, location in ipairs(Config.Locations) do
        local model = joaat(location.npc.model)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local coords = location.npc.coords
        local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        if location.npc.scenario then TaskStartScenarioInPlace(ped, location.npc.scenario, 0, true) end

        rentalPeds[#rentalPeds + 1] = ped
        local target = location.target or {}
        local targetDistance = tonumber(target.distance) or 2.5

        exports.ox_target:addLocalEntity(ped, {
            {
                name = ('sb_carrental_open_%s'):format(location.id or index),
                icon = 'fa-solid fa-car',
                label = target.open or 'Se lejebiler',
                distance = targetDistance,
                onSelect = function() openMenu(index) end
            },
            {
                name = ('sb_carrental_papers_%s'):format(location.id or index),
                icon = 'fa-solid fa-file-contract',
                label = target.papers or 'Se køretøjspapirer',
                distance = targetDistance,
                onSelect = function() openActivePapers(index) end
            },
            {
                name = ('sb_carrental_return_%s'):format(location.id or index),
                icon = 'fa-solid fa-rotate-left',
                label = target.returnVehicle or 'Aflever lejebil',
                distance = targetDistance,
                onSelect = function() returnRental(index) end
            }
        })

        createBlip(location)
        SetModelAsNoLongerNeeded(model)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
    for _, ped in ipairs(rentalPeds) do
        if DoesEntityExist(ped) then
            exports.ox_target:removeLocalEntity(ped)
            DeletePed(ped)
        end
    end
end)
