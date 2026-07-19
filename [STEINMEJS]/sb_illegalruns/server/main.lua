local ESX = exports.es_extended:getSharedObject()
local activeRuns = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sb_illegalruns_cooldowns` (
            `identifier` VARCHAR(80) NOT NULL,
            `expires_at` BIGINT NOT NULL DEFAULT 0,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
end)

local function normalizePlate(plate)
    return (plate or ''):gsub('%s+', ''):upper()
end

local function getIdentifier(xPlayer)
    return xPlayer.getIdentifier()
end

local function getCooldown(identifier)
    local expiresAt = MySQL.scalar.await('SELECT expires_at FROM sb_illegalruns_cooldowns WHERE identifier = ?', { identifier }) or 0
    return math.max(0, tonumber(expiresAt) - os.time())
end

local function playerNearEntity(source, entity, distance)
    local ped = GetPlayerPed(source)
    if ped == 0 or entity == 0 or not DoesEntityExist(entity) then return false end
    return #(GetEntityCoords(ped) - GetEntityCoords(entity)) <= distance
end

lib.callback.register('sb_illegalruns:getMenuData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local remaining = getCooldown(getIdentifier(xPlayer))
    local runs = {}

    for key, run in pairs(Config.Runs) do
        runs[#runs + 1] = {
            id = key,
            label = run.label,
            description = run.description,
            icon = run.icon,
            rewardMin = run.reward.min,
            rewardMax = run.reward.max
        }
    end

    table.sort(runs, function(a, b) return a.label < b.label end)

    return {
        runs = runs,
        cooldown = remaining,
        activeRun = activeRuns[source] and activeRuns[source].id or nil,
        cooldownMinutes = Config.CooldownMinutes
    }
end)

lib.callback.register('sb_illegalruns:startRun', function(source, runId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local run = Config.Runs[runId]
    if not xPlayer or not run then return false, 'Runnet findes ikke.' end

    if Config.OneActiveRun and activeRuns[source] then
        return false, 'Du har allerede et aktivt run.'
    end

    local remaining = getCooldown(getIdentifier(xPlayer))
    if remaining > 0 then
        return false, ('Du kan tage et nyt run om %d minutter.'):format(math.ceil(remaining / 60))
    end

    activeRuns[source] = { id = runId, stage = 'vehicle_pending' }
    return true
end)

lib.callback.register('sb_illegalruns:cancelRun', function(source, runId)
    local active = activeRuns[source]
    if active and active.id == runId and active.stage == 'vehicle_pending' then
        activeRuns[source] = nil
        return true
    end
    return false
end)

lib.callback.register('sb_illegalruns:registerVehicle', function(source, runId, netId, plate)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'vehicle_pending' then return false, 'Runnet er ikke aktivt.' end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 then return false, 'Bisonen kunne ikke registreres.' end

    local cleanPlate = normalizePlate(plate)
    if cleanPlate == '' then return false, 'Nummerpladen kunne ikke læses.' end

    active.vehicleNetId = netId
    active.plate = cleanPlate
    active.stage = 'pickup'

    local ok, err = pcall(function()
        exports['Renewed-Vehiclekeys']:addKey(source, cleanPlate)
    end)

    if not ok then
        print(('[sb_illegalruns] Kunne ikke give nøgler via Renewed-Vehiclekeys: %s'):format(err))
        activeRuns[source] = nil
        return false, 'Kunne ikke give dig nøgler til Bisonen.'
    end

    return true
end)

lib.callback.register('sb_illegalruns:loadPickupIntoVehicle', function(source, runId, netId, plate)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'pickup' then return false end
    if active.vehicleNetId ~= netId or active.plate ~= normalizePlate(plate) then return false end

    local run = Config.Runs[runId]
    local ped = GetPlayerPed(source)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not run or ped == 0 or vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local pickupCoords = vec3(run.pickup.x, run.pickup.y, run.pickup.z)
    if #(GetEntityCoords(ped) - pickupCoords) > 5.0 then return false end
    if #(GetEntityCoords(vehicle) - pickupCoords) > (Config.PickupVehicleDistance + 3.0) then return false end

    active.stage = 'in_vehicle'
    return true
end)

lib.callback.register('sb_illegalruns:pickup', function(source, runId)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'pickup' then return false end

    local run = Config.Runs[runId]
    local ped = GetPlayerPed(source)
    if not run or ped == 0 then return false end

    local coords = GetEntityCoords(ped)
    local target = vec3(run.pickup.x, run.pickup.y, run.pickup.z)
    if #(coords - target) > 5.0 then return false end

    active.stage = 'carrying'
    return true
end)

lib.callback.register('sb_illegalruns:storePackage', function(source, runId, netId, plate)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'carrying' then return false end
    if active.vehicleNetId ~= netId or active.plate ~= normalizePlate(plate) then return false end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not playerNearEntity(source, vehicle, 7.0) then return false end

    active.stage = 'in_vehicle'
    return true
end)

lib.callback.register('sb_illegalruns:unloadCargo', function(source, runId, netId, plate)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'in_vehicle' then return false end
    if active.vehicleNetId ~= netId or active.plate ~= normalizePlate(plate) then return false end

    local run = Config.Runs[runId]
    local ped = GetPlayerPed(source)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not run or ped == 0 or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return false end

    local deliveryCoords = vec3(run.delivery.x, run.delivery.y, run.delivery.z)
    if #(GetEntityCoords(vehicle) - deliveryCoords) > (Config.DeliveryZone.radius + 2.0) then return false end

    active.stage = 'return_vehicle'
    return true
end)

lib.callback.register('sb_illegalruns:takePackage', function(source, runId, netId, plate)
    local active = activeRuns[source]
    if not active or active.id ~= runId or active.stage ~= 'in_vehicle' then return false end
    if active.vehicleNetId ~= netId or active.plate ~= normalizePlate(plate) then return false end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not playerNearEntity(source, vehicle, 7.0) then return false end

    active.stage = 'carrying_delivery'
    return true
end)

lib.callback.register('sb_illegalruns:complete', function(source, runId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local active = activeRuns[source]
    local run = Config.Runs[runId]
    if not xPlayer or not active or active.id ~= runId or active.stage ~= 'carrying_delivery' or not run then return false end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local target = vec3(run.delivery.x, run.delivery.y, run.delivery.z)
    if #(coords - target) > 5.0 then return false end

    local reward = math.random(run.reward.min, run.reward.max)
    xPlayer.addAccountMoney(Config.PaymentAccount, reward, ('Illegal run: %s'):format(run.label))

    local expiresAt = os.time() + (Config.CooldownMinutes * 60)
    MySQL.query.await([[
        INSERT INTO sb_illegalruns_cooldowns (identifier, expires_at)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at)
    ]], { getIdentifier(xPlayer), expiresAt })

    if active.plate then
        pcall(function()
            exports['Renewed-Vehiclekeys']:removeKey(source, active.plate)
        end)
    end

    activeRuns[source] = nil
    return true, reward
end)

lib.callback.register('sb_illegalruns:completeReturn', function(source, runId, netId, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    local active = activeRuns[source]
    local run = Config.Runs[runId]
    if not xPlayer or not active or active.id ~= runId or active.stage ~= 'return_vehicle' or not run then
        return false
    end

    if active.vehicleNetId ~= netId or active.plate ~= normalizePlate(plate) then return false end

    local ped = GetPlayerPed(source)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if ped == 0 or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return false end

    local returnCoords = Config.VehicleReturn.coords
    if #(GetEntityCoords(vehicle) - returnCoords) > (Config.VehicleReturn.radius + 2.0) then return false end

    local reward = math.random(run.reward.min, run.reward.max)
    xPlayer.addAccountMoney(Config.PaymentAccount, reward, ('Illegal run: %s'):format(run.label))

    local expiresAt = os.time() + (Config.CooldownMinutes * 60)
    MySQL.query.await([[
        INSERT INTO sb_illegalruns_cooldowns (identifier, expires_at)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at)
    ]], { getIdentifier(xPlayer), expiresAt })

    if active.plate then
        pcall(function()
            exports['Renewed-Vehiclekeys']:removeKey(source, active.plate)
        end)
    end

    activeRuns[source] = nil
    return true, reward
end)

AddEventHandler('playerDropped', function()
    activeRuns[source] = nil
end)
