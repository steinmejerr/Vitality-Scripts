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

local function findDuration(durationId)
    durationId = tostring(durationId or '')
    for _, duration in ipairs(Config.Rental.durations or {}) do
        if tostring(duration.id) == durationId then
            local minutes = math.floor(tonumber(duration.minutes) or 0)
            local multiplier = tonumber(duration.multiplier) or 0
            if minutes > 0 and multiplier > 0 then
                return duration, minutes, multiplier
            end
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

local function deleteRentalRow(owner, plate)
    MySQL.update.await('DELETE FROM rented_vehicles WHERE owner = ? AND plate = ?', { owner, plate })
end

CreateThread(function()
    MySQL.query.await('ALTER TABLE rented_vehicles ADD COLUMN IF NOT EXISTS rental_started_at DATETIME NULL')
    MySQL.query.await('ALTER TABLE rented_vehicles ADD COLUMN IF NOT EXISTS rental_expires_at DATETIME NULL')
    MySQL.query.await('ALTER TABLE rented_vehicles ADD COLUMN IF NOT EXISTS rental_duration_minutes INT NULL')
    MySQL.query.await('ALTER TABLE rented_vehicles ADD COLUMN IF NOT EXISTS rental_payment_method VARCHAR(16) NULL')
    MySQL.query.await('ALTER TABLE rented_vehicles ADD COLUMN IF NOT EXISTS rental_location VARCHAR(64) NULL')
end)

lib.callback.register('sb_carrental:server:requestRental', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren kunne ikke findes.' } end
    if pendingRentals[source] then return { success = false, message = 'Din tidligere anmodning behandles stadig.' } end

    local vehicle, location = findVehicle(data.locationIndex, data.model)
    if not vehicle or not location then
        return { success = false, message = 'Det valgte køretøj findes ikke.' }
    end

    local duration, durationMinutes, durationMultiplier = findDuration(data.durationId)
    if not duration then
        return { success = false, message = 'Den valgte lejeperiode er ugyldig.' }
    end

    if activeRentals[source] then
        return { success = false, message = 'Du har allerede en aktiv lejebil.' }
    end

    MySQL.update.await([[
        DELETE FROM rented_vehicles
        WHERE owner = ? AND rental_expires_at IS NOT NULL AND rental_expires_at <= NOW()
    ]], { xPlayer.identifier })

    local existing = MySQL.single.await('SELECT plate, vehicle FROM rented_vehicles WHERE owner = ? LIMIT 1', {
        xPlayer.identifier
    })
    if existing then
        return { success = false, message = 'Du har allerede en registreret lejebil. Aflever den først.' }
    end

    local totalPrice = math.ceil((tonumber(vehicle.price) or 0) * durationMultiplier)
    if totalPrice <= 0 then
        return { success = false, message = 'Prisen på køretøjet er ugyldig.' }
    end

    pendingRentals[source] = true
    local paid, paymentError = removeMoney(xPlayer, data.paymentMethod, totalPrice)
    if not paid then
        pendingRentals[source] = nil
        return { success = false, message = paymentError }
    end

    local plate = generatePlate()
    if not plate then
        refundMoney(xPlayer, data.paymentMethod, totalPrice)
        pendingRentals[source] = nil
        return { success = false, message = 'Kunne ikke generere en nummerplade. Prøv igen.' }
    end

    local inserted = MySQL.insert.await([[
        INSERT INTO rented_vehicles (
            vehicle, plate, player_name, base_price, rent_price, owner,
            rental_started_at, rental_expires_at, rental_duration_minutes, rental_payment_method, rental_location
        )
        VALUES (?, ?, ?, ?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? MINUTE), ?, ?, ?)
    ]], {
        vehicle.model,
        plate,
        getPlayerName(xPlayer),
        vehicle.price,
        totalPrice,
        xPlayer.identifier,
        durationMinutes,
        durationMinutes,
        data.paymentMethod,
        tostring(location.id or data.locationIndex)
    })

    if not inserted then
        refundMoney(xPlayer, data.paymentMethod, totalPrice)
        pendingRentals[source] = nil
        return { success = false, message = 'Køretøjet kunne ikke registreres i databasen.' }
    end

    local token = ('%s:%s:%s'):format(source, plate, math.random(100000, 999999))
    activeRentals[source] = {
        plate = plate,
        model = vehicle.model,
        locationIndex = tonumber(data.locationIndex),
        locationId = tostring(location.id or data.locationIndex),
        company = location.company or location.label or 'SB Biludlejning',
        paymentMethod = data.paymentMethod,
        price = totalPrice,
        token = token,
        durationMinutes = durationMinutes,
        durationLabel = duration.label,
        vehicleLabel = vehicle.label or vehicle.model,
        playerName = getPlayerName(xPlayer),
        expiresAt = os.time() + (durationMinutes * 60)
    }
    pendingRentals[source] = nil

    return {
        success = true,
        token = token,
        plate = plate,
        model = vehicle.model,
        durationLabel = duration.label,
        price = totalPrice,
        paymentMethod = data.paymentMethod,
        locationIndex = tonumber(data.locationIndex)
    }
end)

RegisterNetEvent('sb_carrental:server:spawnFailed', function(token)
    local source = source
    local rental = activeRentals[source]
    if not rental or rental.token ~= token then return end

    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then deleteRentalRow(xPlayer.identifier, rental.plate) end
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

    local row = MySQL.single.await([[
        SELECT vehicle, plate
        FROM rented_vehicles
        WHERE owner = ? AND (rental_expires_at IS NULL OR rental_expires_at > NOW())
        LIMIT 1
    ]], { xPlayer.identifier })
    if not row then return nil end
    return { plate = row.plate, model = row.vehicle }
end)

lib.callback.register('sb_carrental:server:getRentalPapers', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local rental = activeRentals[source]
    if rental then
        return {
            company = rental.company or 'SB Biludlejning',
            vehicleLabel = rental.vehicleLabel or rental.model,
            model = rental.model,
            plate = rental.plate,
            durationLabel = rental.durationLabel,
            paymentMethod = rental.paymentMethod,
            paymentLabel = rental.paymentMethod == 'cash' and 'Kontant' or 'Bank',
            price = rental.price,
            startedAt = os.date('%d/%m/%Y %H:%M', rental.expiresAt - (rental.durationMinutes * 60)),
            expiresAt = os.date('%d/%m/%Y %H:%M', rental.expiresAt)
        }
    end

    local row = MySQL.single.await([[
        SELECT vehicle, plate, rent_price, rental_duration_minutes, rental_payment_method, rental_location,
               DATE_FORMAT(rental_started_at, '%d/%m/%Y %H:%i') AS started_at_formatted,
               DATE_FORMAT(rental_expires_at, '%d/%m/%Y %H:%i') AS expires_at_formatted
        FROM rented_vehicles
        WHERE owner = ? AND (rental_expires_at IS NULL OR rental_expires_at > NOW())
        LIMIT 1
    ]], { xPlayer.identifier })

    if not row then return nil end

    local durationLabel = ('%s minutter'):format(tonumber(row.rental_duration_minutes) or 0)
    for _, duration in ipairs(Config.Rental.durations or {}) do
        if tonumber(duration.minutes) == tonumber(row.rental_duration_minutes) then
            durationLabel = duration.label
            break
        end
    end

    local company = 'SB Biludlejning'
    for index, location in ipairs(Config.Locations or {}) do
        if tostring(location.id or index) == tostring(row.rental_location or '') then
            company = location.company or location.label or company
            break
        end
    end

    return {
        company = company,
        vehicleLabel = row.vehicle,
        model = row.vehicle,
        plate = row.plate,
        durationLabel = durationLabel,
        paymentMethod = row.rental_payment_method,
        paymentLabel = row.rental_payment_method == 'cash' and 'Kontant' or 'Bank',
        price = row.rent_price,
        startedAt = row.started_at_formatted,
        expiresAt = row.expires_at_formatted
    }
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

    deleteRentalRow(xPlayer.identifier, plate)
    activeRentals[source] = nil

    return { success = true, message = 'Lejebilen er afleveret. Tak for denne gang.' }
end)

CreateThread(function()
    while true do
        Wait(Config.Rental.expiryCheckInterval or 30000)
        local now = os.time()

        for playerId, rental in pairs(activeRentals) do
            if rental.expiresAt and rental.expiresAt <= now then
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer then
                    deleteRentalRow(xPlayer.identifier, rental.plate)
                    TriggerClientEvent('sb_carrental:client:rentalExpired', playerId, rental.plate)
                end
                activeRentals[playerId] = nil
            end
        end

        MySQL.update.await('DELETE FROM rented_vehicles WHERE rental_expires_at IS NOT NULL AND rental_expires_at <= NOW()')
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    pendingRentals[source] = nil
    activeRentals[source] = nil
end)
