local ESX = exports.es_extended:getSharedObject()
local transactionLocks = {}
local sessions = {}

local function formatNumber(value)
    local formatted = tostring(math.floor(value or 0))
    local result = formatted

    while true do
        local updated, count = result:gsub('^(-?%d+)(%d%d%d)', '%1.%2')
        result = updated
        if count == 0 then break end
    end

    return result
end

local function randomToken()
    return ('%s:%s:%s'):format(math.random(100000, 999999), os.time(), math.random(100000, 999999))
end

local function getBlackMoney(xPlayer)
    local account = xPlayer.getAccount('black_money')
    return account and account.money or 0
end

local function getPlayerCoords(source)
    local ped = GetPlayerPed(source)
    if ped <= 0 then return nil end
    return GetEntityCoords(ped)
end

local function validateNpcRequest(source, request)
    if type(request) ~= 'table' or type(request.coords) ~= 'table' then return nil end

    local playerCoords = getPlayerCoords(source)
    if not playerCoords then return nil end

    local coords = vector3(
        tonumber(request.coords.x) or 0.0,
        tonumber(request.coords.y) or 0.0,
        tonumber(request.coords.z) or 0.0
    )

    if #(playerCoords - coords) > (Config.TargetDistance + 2.0) then return nil end

    local netId = tonumber(request.netId) or 0
    if netId > 0 then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if entity == 0 or not DoesEntityExist(entity) or GetEntityType(entity) ~= 1 then return nil end
        if IsPedAPlayer(entity) or IsEntityDead(entity) then return nil end

        local entityCoords = GetEntityCoords(entity)
        if #(entityCoords - coords) > 3.0 then return nil end
        coords = entityCoords
    end

    return coords
end

lib.callback.register('sb_moneylaundering:getData', function(source, request)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local npcCoords = validateNpcRequest(source, request)
    if not npcCoords then return nil end

    local token = randomToken()
    sessions[source] = {
        token = token,
        coords = npcCoords,
        expires = os.time() + Config.SessionDurationSeconds
    }

    local balance = getBlackMoney(xPlayer)
    local payoutPercent = 100 - Config.FeePercent

    return {
        session = token,
        blackMoney = balance,
        blackMoneyFormatted = formatNumber(balance),
        feePercent = Config.FeePercent,
        payoutPercent = payoutPercent,
        minimumAmount = Config.MinimumAmount,
        maximumAmount = Config.MaximumAmount
    }
end)

lib.callback.register('sb_moneylaundering:launder', function(source, token, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return { success = false, close = true, message = 'Spilleren kunne ikke findes.' }
    end

    local session = sessions[source]
    if not session or session.token ~= token or session.expires < os.time() then
        sessions[source] = nil
        return { success = false, close = true, message = 'Handlen er udløbet.' }
    end

    local playerCoords = getPlayerCoords(source)
    if not playerCoords or #(playerCoords - session.coords) > (Config.TargetDistance + 3.0) then
        sessions[source] = nil
        return { success = false, close = true, message = 'Du står for langt væk fra personen.' }
    end

    local now = os.time()
    if transactionLocks[source] and transactionLocks[source] > now then
        return { success = false, message = 'Vent et øjeblik, før du prøver igen.' }
    end

    amount = math.floor(tonumber(amount) or 0)

    if amount < Config.MinimumAmount then
        return {
            success = false,
            message = ('Du skal mindst sælge %s kr.'):format(formatNumber(Config.MinimumAmount))
        }
    end

    if amount > Config.MaximumAmount then
        return {
            success = false,
            message = ('Du kan højst sælge %s kr. ad gangen.'):format(formatNumber(Config.MaximumAmount))
        }
    end

    local blackMoney = getBlackMoney(xPlayer)
    if blackMoney < amount then
        return { success = false, message = 'Du har ikke nok sorte penge.' }
    end

    local fee = math.floor(amount * (Config.FeePercent / 100))
    local payout = amount - fee

    if payout <= 0 then
        return { success = false, message = 'Beløbet er for lavt.' }
    end

    transactionLocks[source] = now + Config.TransactionCooldownSeconds

    xPlayer.removeAccountMoney('black_money', amount, 'Money laundering')
    xPlayer.addMoney(payout, 'Money laundering payout')

    return {
        success = true,
        amount = amount,
        fee = fee,
        payout = payout,
        amountFormatted = formatNumber(amount),
        feeFormatted = formatNumber(fee),
        payoutFormatted = formatNumber(payout),
        remainingBlackMoney = blackMoney - amount,
        remainingBlackMoneyFormatted = formatNumber(blackMoney - amount)
    }
end)

AddEventHandler('playerDropped', function()
    transactionLocks[source] = nil
    sessions[source] = nil
end)
