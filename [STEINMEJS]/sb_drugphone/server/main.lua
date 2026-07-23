local ESX = exports.es_extended:getSharedObject()
local activeDeals = {}
local playerCooldowns = {}
local dealCounter = 0

local function getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

local function isRateLimited(source)
    local now = os.time()
    if playerCooldowns[source] and playerCooldowns[source] > now then return true end
    playerCooldowns[source] = now + Config.DealCooldown
    return false
end

local function countItem(source, item)
    return exports.ox_inventory:Search(source, 'count', item) or 0
end

local function addMoney(xPlayer, amount)
    if Config.MoneyAccount == 'money' then
        xPlayer.addMoney(amount)
    else
        xPlayer.addAccountMoney(Config.MoneyAccount, amount)
    end
end

RegisterNetEvent('sb_drugphone:server:createDeal', function(data)
    local source = source
    if isRateLimited(source) then return end
    if type(data) ~= 'table' then return end

    local product = Config.Products[data.productId]
    local amount = math.floor(tonumber(data.amount) or 0)
    local unitPrice = math.floor(tonumber(data.unitPrice) or 0)
    local locationIndex = math.floor(tonumber(data.locationIndex) or 0)

    if not product then return end
    if amount < product.minAmount or amount > product.maxAmount then return end
    if unitPrice < product.minPrice or unitPrice > product.maxPrice then return end
    if not Config.DealLocations[locationIndex] then return end
    if activeDeals[source] then
        TriggerClientEvent('sb_drugphone:client:dealCancelled', source, 'Du har allerede en aktiv handel.')
        return
    end

    dealCounter = dealCounter + 1
    local dealId = ('%s:%s:%s'):format(source, os.time(), dealCounter)
    activeDeals[source] = {
        id = dealId,
        productId = data.productId,
        amount = amount,
        unitPrice = unitPrice,
        locationIndex = locationIndex,
        expires = os.time() + math.floor(Config.CustomerLifetime / 1000) + 30
    }

    TriggerClientEvent('sb_drugphone:client:dealCreated', source, dealId, locationIndex)
end)

RegisterNetEvent('sb_drugphone:server:completeDeal', function(dealId)
    local source = source
    if isRateLimited(source) then return end

    local deal = activeDeals[source]
    if not deal or deal.id ~= dealId then
        TriggerClientEvent('sb_drugphone:client:dealResult', source, false, 'Handlen er ikke længere gyldig.')
        return
    end

    if deal.expires < os.time() then
        activeDeals[source] = nil
        TriggerClientEvent('sb_drugphone:client:dealResult', source, false, 'Kunden er ikke længere interesseret.')
        return
    end

    local product = Config.Products[deal.productId]
    local xPlayer = getPlayer(source)
    if not product or not xPlayer then return end

    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local location = Config.DealLocations[deal.locationIndex]
    local locationCoords = vector3(location.x, location.y, location.z)
    if #(playerCoords - locationCoords) > 15.0 then
        TriggerClientEvent('sb_drugphone:client:dealResult', source, false, 'Du er ikke ved den aftalte lokation.')
        return
    end

    if countItem(source, product.item) < deal.amount then
        TriggerClientEvent('sb_drugphone:client:dealResult', source, false, ('Du mangler %sx %s.'):format(deal.amount, product.label))
        return
    end

    local removed = exports.ox_inventory:RemoveItem(source, product.item, deal.amount)
    if not removed then
        TriggerClientEvent('sb_drugphone:client:dealResult', source, false, 'Varerne kunne ikke fjernes fra dit inventory.')
        return
    end

    local payout = deal.amount * deal.unitPrice
    addMoney(xPlayer, payout)
    activeDeals[source] = nil

    TriggerClientEvent('sb_drugphone:client:dealResult', source, true,
        ('Du solgte %sx %s og modtog %s kr.'):format(deal.amount, product.label, ESX.Math.GroupDigits(payout)))
end)

AddEventHandler('playerDropped', function()
    activeDeals[source] = nil
    playerCooldowns[source] = nil
end)

CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        for source, deal in pairs(activeDeals) do
            if deal.expires < now then
                activeDeals[source] = nil
                TriggerClientEvent('sb_drugphone:client:dealCancelled', source, 'Kunden er ikke længere interesseret.')
            end
        end
    end
end)
