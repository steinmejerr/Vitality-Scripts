local ESX = exports.es_extended:getSharedObject()
local Stations = {}
local PendingCrafts = {}

local function notify(source, description, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Crafting',
        description = description,
        type = type or 'inform'
    })
end

local function getIdentifier(xPlayer)
    return xPlayer and xPlayer.identifier
end

local function loadStations()
    local rows = MySQL.query.await('SELECT id, owner, x, y, z, heading FROM sb_crafting_stations') or {}
    Stations = {}
    for i = 1, #rows do
        local row = rows[i]
        Stations[row.id] = {
            id = row.id,
            owner = row.owner,
            coords = { x = row.x, y = row.y, z = row.z },
            heading = row.heading
        }
    end
end

MySQL.ready(loadStations)

lib.callback.register('sb_crafting:getStations', function(source)
    local result = {}
    for _, station in pairs(Stations) do
        result[#result + 1] = station
    end
    return result
end)

lib.callback.register('sb_crafting:getShopData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end
    return {
        price = Config.Shop.price,
        account = Config.Shop.account,
        item = Config.StationItem
    }
end)

RegisterNetEvent('sb_crafting:buyStation', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local price = tonumber(Config.Shop.price) or 0
    local account = Config.Shop.account
    local balance

    if account == 'money' then
        balance = xPlayer.getMoney()
    else
        local accountData = xPlayer.getAccount(account)
        balance = accountData and accountData.money or 0
    end

    if balance < price then
        return notify(source, 'Du har ikke råd til en crafting station.', 'error')
    end

    if not exports.ox_inventory:CanCarryItem(source, Config.StationItem, 1) then
        return notify(source, 'Du har ikke plads i dit inventory.', 'error')
    end

    if account == 'money' then
        xPlayer.removeMoney(price, 'Crafting station')
    else
        xPlayer.removeAccountMoney(account, price, 'Crafting station')
    end

    exports.ox_inventory:AddItem(source, Config.StationItem, 1)
    notify(source, 'Du købte en crafting station.', 'success')
end)

ESX.RegisterUsableItem(Config.StationItem, function(source)
    TriggerClientEvent('sb_crafting:startPlacement', source)
end)

RegisterNetEvent('sb_crafting:placeStation', function(coords, heading)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer or type(coords) ~= 'table' then return end

    local identifier = getIdentifier(xPlayer)
    local count = MySQL.scalar.await('SELECT COUNT(*) FROM sb_crafting_stations WHERE owner = ?', { identifier }) or 0
    if count >= Config.MaxStationsPerPlayer then
        return notify(source, ('Du må højst have %s stationer placeret.'):format(Config.MaxStationsPerPlayer), 'error')
    end

    if exports.ox_inventory:Search(source, 'count', Config.StationItem) < 1 then
        return notify(source, 'Du har ikke en crafting station.', 'error')
    end

    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local placement = vector3(tonumber(coords.x) or 0, tonumber(coords.y) or 0, tonumber(coords.z) or 0)
    if #(playerCoords - placement) > (Config.Placement.maxDistance + 2.0) then
        return notify(source, 'Placeringen er for langt væk.', 'error')
    end

    local removed = exports.ox_inventory:RemoveItem(source, Config.StationItem, 1)
    if not removed then return end

    local id = MySQL.insert.await([[
        INSERT INTO sb_crafting_stations (owner, x, y, z, heading)
        VALUES (?, ?, ?, ?, ?)
    ]], { identifier, placement.x, placement.y, placement.z, tonumber(heading) or 0.0 })

    if not id then
        exports.ox_inventory:AddItem(source, Config.StationItem, 1)
        return notify(source, 'Stationen kunne ikke gemmes.', 'error')
    end

    local station = {
        id = id,
        owner = identifier,
        coords = { x = placement.x, y = placement.y, z = placement.z },
        heading = tonumber(heading) or 0.0
    }
    Stations[id] = station
    TriggerClientEvent('sb_crafting:addStation', -1, station)
    notify(source, 'Crafting stationen er placeret.', 'success')
end)

lib.callback.register('sb_crafting:canPickup', function(source, stationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local station = Stations[tonumber(stationId)]
    return xPlayer and station and station.owner == getIdentifier(xPlayer) or false
end)

RegisterNetEvent('sb_crafting:pickupStation', function(stationId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    stationId = tonumber(stationId)
    local station = Stations[stationId]
    if not xPlayer or not station then return end

    if station.owner ~= getIdentifier(xPlayer) then
        return notify(source, 'Det er ikke din crafting station.', 'error')
    end

    local ped = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(ped)
    local stationCoords = vector3(station.coords.x, station.coords.y, station.coords.z)
    if #(playerCoords - stationCoords) > Config.PickupDistance then
        return notify(source, 'Du står for langt væk.', 'error')
    end

    if not exports.ox_inventory:CanCarryItem(source, Config.StationItem, 1) then
        return notify(source, 'Du har ikke plads i dit inventory.', 'error')
    end

    local deleted = MySQL.update.await('DELETE FROM sb_crafting_stations WHERE id = ? AND owner = ?', {
        stationId, getIdentifier(xPlayer)
    })
    if not deleted or deleted < 1 then return end

    Stations[stationId] = nil
    exports.ox_inventory:AddItem(source, Config.StationItem, 1)
    TriggerClientEvent('sb_crafting:removeStation', -1, stationId)
    notify(source, 'Crafting stationen er taget op.', 'success')
end)

local function getRecipe(recipeId)
    for i = 1, #Config.Recipes do
        if Config.Recipes[i].id == recipeId then return Config.Recipes[i] end
    end
end

lib.callback.register('sb_crafting:getCraftingData', function(source)
    local inventory = {}
    for i = 1, #Config.Recipes do
        local recipe = Config.Recipes[i]
        for j = 1, #recipe.ingredients do
            local item = recipe.ingredients[j].item
            if inventory[item] == nil then
                inventory[item] = exports.ox_inventory:Search(source, 'count', item) or 0
            end
        end
    end
    return {
        recipes = Config.Recipes,
        categories = Config.Categories,
        inventory = inventory
    }
end)

lib.callback.register('sb_crafting:startCraft', function(source, recipeId, amount)
    local recipe = getRecipe(recipeId)
    amount = math.floor(tonumber(amount) or 1)
    if not recipe or amount < 1 or amount > 100 then
        return { success = false, message = 'Ugyldig opskrift eller antal.' }
    end
    if PendingCrafts[source] then
        return { success = false, message = 'Du er allerede i gang med at crafte.' }
    end

    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        local required = ingredient.count * amount
        local count = exports.ox_inventory:Search(source, 'count', ingredient.item) or 0
        if count < required then
            return { success = false, message = ('Du mangler %sx %s.'):format(required - count, ingredient.label or ingredient.item) }
        end
    end

    local outputCount = recipe.output.count * amount
    if not exports.ox_inventory:CanCarryItem(source, recipe.output.item, outputCount) then
        return { success = false, message = 'Du har ikke plads til resultatet.' }
    end

    for i = 1, #recipe.ingredients do
        local ingredient = recipe.ingredients[i]
        local removed = exports.ox_inventory:RemoveItem(source, ingredient.item, ingredient.count * amount)
        if not removed then
            return { success = false, message = 'Ingredienserne kunne ikke fjernes.' }
        end
    end

    local token = ('%s:%s:%s'):format(source, os.time(), math.random(100000, 999999))
    PendingCrafts[source] = {
        token = token,
        recipeId = recipeId,
        amount = amount,
        readyAt = os.time() + math.ceil((recipe.duration * amount) / 1000)
    }

    return {
        success = true,
        token = token,
        duration = recipe.duration * amount,
        label = recipe.label
    }
end)

RegisterNetEvent('sb_crafting:finishCraft', function(token)
    local source = source
    local pending = PendingCrafts[source]
    if not pending or pending.token ~= token then return end
    if os.time() + 1 < pending.readyAt then return end

    local recipe = getRecipe(pending.recipeId)
    if not recipe then
        PendingCrafts[source] = nil
        return
    end

    local outputCount = recipe.output.count * pending.amount
    if not exports.ox_inventory:CanCarryItem(source, recipe.output.item, outputCount) then
        return notify(source, 'Du har ikke længere plads til resultatet.', 'error')
    end

    exports.ox_inventory:AddItem(source, recipe.output.item, outputCount)
    PendingCrafts[source] = nil
    notify(source, ('Du lavede %sx %s.'):format(outputCount, recipe.label), 'success')
end)

AddEventHandler('playerDropped', function()
    PendingCrafts[source] = nil
end)
