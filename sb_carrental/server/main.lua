local ESX = exports['es_extended']:getSharedObject()
local activeRentals = {}
local pendingRentals = {}

local function notify(playerId, description, notifyType)
    TriggerClientEvent('sb_carrental:client:notify', playerId, description, notifyType or 'inform')
end

local function trim(value)
    return type(value) == 'string' and value:match('^%s*(.-)%s*$') or value
end

local function findVehicle(locationIndex, model)
    local location = Config.Locations[tonumber(locationIndex)]
    if not location then return nil end

    model = string.lower(trim(model or ''))
    for _, vehicle in ipairs(location.vehicles or {}) do
        if string.lower(vehicle.model) == model then
            return vehicle, location
        end
    end
end

local function generatePlate()
    local prefix = string.upper(Config.Rental.platePrefix or 'LEJ')
    local length = math.max(#prefix + 2, Config.Rental.plateLength or 8)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

    for _ = 1, 30 do
        local plate = prefix
        while #plate < length do
            local index = math.random(1, #chars)
            plate = plate .. chars:sub(index, index)
        end

        local exists = MySQL.scalar.await('SELECT 1 FROM rented_vehicles WHERE plate = ? LIMIT 1', { plate })
        if not exists then return plate end
    end
end

local function getPlayerName(xPlayer)
    if xPlayer.getName then return xPlayer.getName() end
    return GetPlayerName(xPlayer.source) or 'Ukendt'
end

local function removeMoney(xPlayer, method, amount)
    local account = Config.PaymentAccounts[method]
    if not account then return false, 'Ugyldig betalingsmetode.' end

    if account == 'money' then
        local money = xPlayer.getMoney()
        if money < amount then return false, 'Du har ikke nok kontanter.' end
        xPlayer.removeMoney(amount, 'Vehicle rental')
        return true
    end

    local accountData = xPlayer.getAccount(account)
    if not accountData or accountData.money < amount then
        return false, 'Du har ikke nok penge på din bankkonto.'
    end

    xPlayer.removeAccountMoney(account, amount, 'Vehicle rental')
    return true
end

local function refundMoney(xPlayer, method, amount)
    local account = Config.PaymentAccounts[method]
    if not account then return end
    if account == 'money' then
        xPlayer.addMoney(amount, 'Vehicle rental refund')
    else
        xPlayer.addAccountMoney(account, amount, 'Vehicle rental refund')
    end
end

lib.callback.register('sb_carrental:server:requestRental', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren kunne ikke findes.' } end
    if pendingRentals[source] then return { success = false, message = 'Din tidligere anmodning behandles stadig.' } end

    local vehicle, location = findVehicle(data.locationIndex, data.model)
    if not vehicle or not location then
        return { success = false, message = 'Det valgte køretøj findes ikke.' }
    end

    if activeRentals[source] then
        return { success = false, message = 'Du har allerede en aktiv lejebil.' }
    end

    local existing = MySQL.single.await('SELECT plate, vehicle FROM rented_vehicles WHERE owner = ? LIMIT 1', {
        xPlayer.identifier
    })
    if existing then
        return { success = false, message = 'Du har allerede en registreret lejebil. Aflever den først.' }
    end

    pendingRentals[source] = true
    local paid, paymentError = removeMoney(xPlayer, data.paymentMethod, vehicle.price)
    if not paid then
        pendingRentals[source] = nil
        return { success = false, message = paymentError }
    end

    local plate = generatePlate()
    if not plate then
        refundMoney(xPlayer, data.paymentMethod, vehicle.price)
        pendingRentals[source] = nil
        return { success = false, message = 'Kunne ikke generere en nummerplade. Prøv igen.' }
    end

    local inserted = MySQL.insert.await([[
        INSERT INTO rented_vehicles (vehicle, plate, player_name, base_price, rent_price, owner)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        vehicle.model,
        plate,
        getPlayerName(xPlayer),
        vehicle.price,
        vehicle.price,
        xPlayer.identifier
    })

    if not inserted then
        refundMoney(xPlayer, data.paymentMethod, vehicle.price)
        pendingRentals[source] = nil
        return { success = false, message = 'Køretøjet kunne ikke registreres i databasen.' }
    end

    local token = ('%s:%s:%s'):format(source, plate, math.random(100000, 999999))
    activeRentals[source] = {
        plate = plate,
        model = vehicle.model,
        locationIndex = tonumber(data.locationIndex),
        paymentMethod = data.paymentMethod,
        price = vehicle.price,
        token = token
    }
    pendingRentals[source] = nil

    return {
        success = true,
        token = token,
        plate = plate,
        model = vehicle.model,
        spawn = {
            x = location.spawn.x,
            y = location.spawn.y,
            z = location.spawn.z,
            w = location.spawn.w
        }
    }
end)

RegisterNetEvent('sb_carrental:server:spawnFailed', function(token)
    local source = source
    local rental = activeRentals[source]
    if not rental or rental.token ~= token then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.update.await('DELETE FROM rented_vehicles WHERE owner = ? AND plate = ?', {
        xPlayer and xPlayer.identifier or '', rental.plate
    })

    if xPlayer then refundMoney(xPlayer, rental.paymentMethod, rental.price) end
    activeRentals[source] = nil
    notify(source, 'Køretøjet kunne ikke spawnes. Betalingen er refunderet.', 'error')
end)

RegisterNetEvent('sb_carrental:server:spawned', function(token, networkId)
    local source = source
    local rental = activeRentals[source]
    if not rental or rental.token ~= token then return end
    rental.networkId = tonumber(networkId)
end)

lib.callback.register('sb_carrental:server:getActiveRental', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local rental = activeRentals[source]
    if rental then
        return {
            plate = rental.plate,
            model = rental.model,
            networkId = rental.networkId
        }
    end

    local row = MySQL.single.await('SELECT vehicle, plate FROM rented_vehicles WHERE owner = ? LIMIT 1', {
        xPlayer.identifier
    })
    if not row then return nil end
    return { plate = row.plate, model = row.vehicle }
end)

lib.callback.register('sb_carrental:server:returnRental', function(source, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren kunne ikke findes.' } end

    plate = trim(plate or '')
    local row = MySQL.single.await('SELECT plate FROM rented_vehicles WHERE owner = ? AND plate = ? LIMIT 1', {
        xPlayer.identifier, plate
    })

    if not row then
        return { success = false, message = 'Dette er ikke din aktive lejebil.' }
    end

    MySQL.update.await('DELETE FROM rented_vehicles WHERE owner = ? AND plate = ?', {
        xPlayer.identifier, plate
    })
    activeRentals[source] = nil

    return { success = true, message = 'Lejebilen er afleveret. Tak for denne gang.' }
end)

AddEventHandler('playerDropped', function()
    local source = source
    pendingRentals[source] = nil
    activeRentals[source] = nil
end)
