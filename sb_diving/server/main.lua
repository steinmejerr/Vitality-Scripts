local ESX = exports['es_extended']:getSharedObject()
local activeMissions = {}
local missionCooldowns = {}

local function notify(source, description, notifyType)
    TriggerClientEvent('sb_diving:client:notify', source, description, notifyType or 'inform')
end

local function getMission(id)
    for i = 1, #Config.Missions do
        if Config.Missions[i].id == id then
            return Config.Missions[i]
        end
    end
end

local function getLocation(id)
    for i = 1, #Config.Locations do
        if Config.Locations[i].id == id then
            return Config.Locations[i]
        end
    end
end

local function hasItem(source, itemName, amount)
    amount = amount or 1
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        return (exports.ox_inventory:Search(source, 'count', itemName) or 0) >= amount
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer and xPlayer.getInventoryItem(itemName)
    return item and (item.count or 0) >= amount
end

local function addItem(source, itemName, amount)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        if not exports.ox_inventory:CanCarryItem(source, itemName, amount) then
            return false, 'Du har ikke plads i dit inventory.'
        end
        local success, response = exports.ox_inventory:AddItem(source, itemName, amount)
        return success == true, response
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, 'Spilleren blev ikke fundet.' end
    if xPlayer.canCarryItem and not xPlayer.canCarryItem(itemName, amount) then
        return false, 'Du har ikke plads i dit inventory.'
    end
    xPlayer.addInventoryItem(itemName, amount)
    return true
end

local function removeItem(source, itemName, amount)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        local success = exports.ox_inventory:RemoveItem(source, itemName, amount)
        return success == true
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    local item = xPlayer.getInventoryItem(itemName)
    if not item or (item.count or 0) < amount then return false end
    xPlayer.removeInventoryItem(itemName, amount)
    return true
end

local function getItemCount(source, itemName)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:Search(source, 'count', itemName) or 0
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local item = xPlayer and xPlayer.getInventoryItem(itemName)
    return item and item.count or 0
end

local function takeMoney(xPlayer, amount)
    if Config.PaymentAccount == 'money' then
        if xPlayer.getMoney() < amount then return false end
        xPlayer.removeMoney(amount, 'sb_diving')
        return true
    end

    local account = xPlayer.getAccount(Config.PaymentAccount)
    if not account or account.money < amount then return false end
    xPlayer.removeAccountMoney(Config.PaymentAccount, amount, 'sb_diving')
    return true
end

local function giveMoney(xPlayer, amount)
    xPlayer.addAccountMoney(Config.PaymentAccount, amount, 'sb_diving')
end

lib.callback.register('sb_diving:server:getUiData', function(source, locationId)
    if not getLocation(locationId) then return nil end

    local finds = {}
    for name, data in pairs(Config.Items.finds) do
        finds[#finds + 1] = {
            name = name,
            label = data.label,
            price = data.sellPrice,
            count = getItemCount(source, name)
        }
    end
    table.sort(finds, function(a, b) return a.label < b.label end)

    local mission = activeMissions[source]
    local missionData
    if mission then
        local cfg = getMission(mission.id)
        missionData = {
            id = mission.id,
            label = cfg and cfg.label or mission.id,
            completed = mission.completed,
            required = mission.required,
            expiresAt = mission.expiresAt
        }
    end

    return {
        shop = Config.Shop,
        missions = Config.Missions,
        finds = finds,
        hasGear = hasItem(source, Config.Items.gear, 1),
        activeMission = missionData,
        paymentAccount = Config.PaymentAccount
    }
end)

lib.callback.register('sb_diving:server:buyItem', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren blev ikke fundet.' } end

    local shopItem
    for i = 1, #Config.Shop.items do
        if Config.Shop.items[i].name == itemName then shopItem = Config.Shop.items[i] break end
    end
    if not shopItem then return { success = false, message = 'Ugyldig vare.' } end

    if hasItem(source, itemName, 1) then
        return { success = false, message = 'Du ejer allerede dette udstyr.' }
    end

    if not takeMoney(xPlayer, shopItem.price) then
        return { success = false, message = 'Du har ikke råd til udstyret.' }
    end

    local added, reason = addItem(source, itemName, 1)
    if not added then
        giveMoney(xPlayer, shopItem.price)
        return { success = false, message = reason or 'Udstyret kunne ikke gives.' }
    end

    return { success = true, message = ('Du købte %s for %s kr.'):format(shopItem.label, shopItem.price) }
end)

lib.callback.register('sb_diving:server:startMission', function(source, missionId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local mission = getMission(missionId)
    if not xPlayer or not mission then return { success = false, message = 'Ugyldig mission.' } end
    if activeMissions[source] then return { success = false, message = 'Du har allerede en aktiv mission.' } end
    if not hasItem(source, Config.Items.gear, 1) then
        return { success = false, message = 'Du mangler dykkerudstyr.' }
    end

    local now = os.time()
    local cooldown = missionCooldowns[source] or 0
    if cooldown > now then
        return { success = false, message = ('Vent %d minutter før næste mission.'):format(math.ceil((cooldown - now) / 60)) }
    end

    if mission.deposit > 0 and not takeMoney(xPlayer, mission.deposit) then
        return { success = false, message = 'Du har ikke råd til missionens depositum.' }
    end

    local shuffled = {}
    for i = 1, #mission.searchPoints do shuffled[i] = i end
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    local selected = {}
    for i = 1, math.min(mission.requiredSearches, #shuffled) do
        selected[#selected + 1] = shuffled[i]
    end

    activeMissions[source] = {
        id = mission.id,
        completed = 0,
        required = #selected,
        points = selected,
        searched = {},
        expiresAt = now + (mission.duration * 60),
        deposit = mission.deposit
    }

    missionCooldowns[source] = now + 60

    return {
        success = true,
        message = ('Missionen “%s” er startet.'):format(mission.label),
        mission = {
            id = mission.id,
            label = mission.label,
            area = mission.area,
            points = selected,
            searchPoints = mission.searchPoints,
            required = #selected,
            expiresAt = activeMissions[source].expiresAt
        }
    }
end)

local function weightedLoot(lootTable)
    local pool = {}
    for name, range in pairs(lootTable) do
        local itemCfg = Config.Items.finds[name]
        local weight = itemCfg and itemCfg.weight or 1
        for _ = 1, weight do pool[#pool + 1] = name end
    end
    return pool[math.random(1, #pool)]
end

lib.callback.register('sb_diving:server:searchPoint', function(source, missionId, pointIndex)
    local state = activeMissions[source]
    local mission = getMission(missionId)
    if not state or not mission or state.id ~= missionId then
        return { success = false, message = 'Du har ikke denne mission aktiv.' }
    end
    if os.time() > state.expiresAt then
        activeMissions[source] = nil
        return { success = false, expired = true, message = 'Missionstiden er udløbet.' }
    end

    local allowed = false
    for i = 1, #state.points do
        if state.points[i] == pointIndex then allowed = true break end
    end
    if not allowed or state.searched[pointIndex] then
        return { success = false, message = 'Fundstedet er allerede undersøgt.' }
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local target = mission.searchPoints[pointIndex]
    if #(coords - target) > 8.0 then
        return { success = false, message = 'Du er for langt væk fra fundstedet.' }
    end

    local itemName = weightedLoot(mission.loot)
    local range = mission.loot[itemName]
    local amount = math.random(range.min, range.max)
    local added, reason = addItem(source, itemName, amount)
    if not added then return { success = false, message = reason or 'Du kunne ikke bære fundet.' } end

    state.searched[pointIndex] = true
    state.completed = state.completed + 1
    local finished = state.completed >= state.required

    if finished then
        local xPlayer = ESX.GetPlayerFromId(source)
        local totalBonus = mission.rewardBonus + state.deposit
        if xPlayer then giveMoney(xPlayer, totalBonus) end
        activeMissions[source] = nil
        missionCooldowns[source] = os.time() + 300
    end

    local itemCfg = Config.Items.finds[itemName]
    return {
        success = true,
        item = itemName,
        label = itemCfg.label,
        amount = amount,
        completed = state.completed,
        required = state.required,
        finished = finished,
        bonus = finished and (mission.rewardBonus + state.deposit) or 0
    }
end)

lib.callback.register('sb_diving:server:cancelMission', function(source)
    local state = activeMissions[source]
    if not state then return { success = false, message = 'Du har ingen aktiv mission.' } end
    activeMissions[source] = nil
    missionCooldowns[source] = os.time() + 120
    return { success = true, message = 'Missionen blev annulleret. Depositummet blev ikke tilbagebetalt.' }
end)

lib.callback.register('sb_diving:server:sellItem', function(source, itemName, requestedAmount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemCfg = Config.Items.finds[itemName]
    local amount = math.floor(tonumber(requestedAmount) or 0)
    if not xPlayer or not itemCfg or amount < 1 then
        return { success = false, message = 'Ugyldigt salg.' }
    end

    local owned = getItemCount(source, itemName)
    amount = math.min(amount, owned)
    if amount < 1 then return { success = false, message = 'Du har ikke dette fund.' } end
    if not removeItem(source, itemName, amount) then
        return { success = false, message = 'Fundet kunne ikke fjernes.' }
    end

    local total = amount * itemCfg.sellPrice
    giveMoney(xPlayer, total)
    return {
        success = true,
        message = ('Du solgte %dx %s for %s kr.'):format(amount, itemCfg.label, total),
        total = total
    }
end)

lib.callback.register('sb_diving:server:sellAll', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren blev ikke fundet.' } end

    local total, sold = 0, 0
    for name, cfg in pairs(Config.Items.finds) do
        local count = getItemCount(source, name)
        if count > 0 and removeItem(source, name, count) then
            total = total + (count * cfg.sellPrice)
            sold = sold + count
        end
    end

    if sold == 0 then return { success = false, message = 'Du har ingen fund at sælge.' } end
    giveMoney(xPlayer, total)
    return { success = true, message = ('Du solgte %d fund for %s kr.'):format(sold, total), total = total }
end)

RegisterNetEvent('sb_diving:server:validateGear', function()
    local source = source
    TriggerClientEvent('sb_diving:client:setGear', source, hasItem(source, Config.Items.gear, 1))
end)

AddEventHandler('playerDropped', function()
    activeMissions[source] = nil
    missionCooldowns[source] = nil
end)


-- ESX-inventory fallback. ox_inventory bruger client-exporten useDivingGear.
ESX.RegisterUsableItem(Config.Items.gear, function(source)
    TriggerClientEvent('sb_diving:client:setGear', source, hasItem(source, Config.Items.gear, 1))
end)
