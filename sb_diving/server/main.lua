local ESX = exports['es_extended']:getSharedObject()
local gearUseCooldowns = {}
local activeMissions = {}
local missionCooldowns = {}
local chestOpenCooldowns = {}

local function getPlayerIdentifier(xPlayer)
    if not xPlayer then return nil end
    return xPlayer.identifier or (xPlayer.getIdentifier and xPlayer.getIdentifier())
end

local function formatCooldown(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))
    local hours = math.floor(seconds / 3600)
    local minutes = math.ceil((seconds % 3600) / 60)

    if hours > 0 and minutes > 0 then
        return ('%d time%s og %d minut%s'):format(
            hours, hours == 1 and '' or 'r',
            minutes, minutes == 1 and '' or 'ter'
        )
    elseif hours > 0 then
        return ('%d time%s'):format(hours, hours == 1 and '' or 'r')
    end

    return ('%d minut%s'):format(minutes, minutes == 1 and '' or 'ter')
end

local function getCompletedMissionCooldown(identifier)
    if not identifier then return 0 end

    local expiresAt = MySQL.scalar.await(
        'SELECT UNIX_TIMESTAMP(expires_at) FROM sb_diving_cooldowns WHERE identifier = ? LIMIT 1',
        { identifier }
    )

    return tonumber(expiresAt) or 0
end

local function setCompletedMissionCooldown(identifier)
    if not identifier then return end

    local cooldownSeconds = math.max(0, tonumber(Config.MissionCooldownSeconds) or 7200)

    MySQL.prepare.await([[
        INSERT INTO sb_diving_cooldowns (identifier, expires_at)
        VALUES (?, DATE_ADD(NOW(), INTERVAL ? SECOND))
        ON DUPLICATE KEY UPDATE expires_at = VALUES(expires_at)
    ]], { identifier, cooldownSeconds })
end

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

local function getChest(chestId)
    return Config.Chests and Config.Chests[chestId]
end

local function getChestByItem(itemName)
    for chestId, chest in pairs(Config.Chests or {}) do
        if chest.item == itemName then
            return chestId, chest
        end
    end
end

local function weightedChoice(entries)
    local total = 0
    for _, weight in pairs(entries or {}) do
        total = total + math.max(0, tonumber(weight) or 0)
    end
    if total <= 0 then return nil end

    local roll = math.random() * total
    local running = 0
    for key, weight in pairs(entries) do
        running = running + math.max(0, tonumber(weight) or 0)
        if roll <= running then return key end
    end
end

local function chooseMissionChest(mission)
    local pool = mission.chestPool or {}
    local chestId = weightedChoice(pool)

    if chestId and getChest(chestId) then return chestId end

    local fallback = {}
    for id, chest in pairs(Config.Chests or {}) do
        fallback[id] = chest.weight or 1
    end
    return weightedChoice(fallback)
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

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sb_diving_cooldowns` (
            `identifier` VARCHAR(80) NOT NULL,
            `expires_at` DATETIME NOT NULL,
            `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`),
            INDEX `idx_expires_at` (`expires_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])

    MySQL.update.await('DELETE FROM sb_diving_cooldowns WHERE expires_at <= NOW()')
end)

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
    local identifier = getPlayerIdentifier(xPlayer)
    local persistentCooldown = getCompletedMissionCooldown(identifier)

    if persistentCooldown > now then
        return {
            success = false,
            message = ('Du skal vente %s, før du kan starte en ny dykkermission.'):format(
                formatCooldown(persistentCooldown - now)
            )
        }
    end

    local shortCooldown = missionCooldowns[source] or 0
    if shortCooldown > now then
        return { success = false, message = ('Vent %d sekunder før du prøver igen.'):format(shortCooldown - now) }
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

    local selectedChests = {}
    for i = 1, #selected do
        local pointIndex = selected[i]
        selectedChests[pointIndex] = chooseMissionChest(mission)
    end

    activeMissions[source] = {
        id = mission.id,
        completed = 0,
        required = #selected,
        points = selected,
        chests = selectedChests,
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

lib.callback.register('sb_diving:server:collectChest', function(source, missionId, pointIndex)
    local state = activeMissions[source]
    local mission = getMission(missionId)
    pointIndex = tonumber(pointIndex)

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
        return { success = false, message = 'Kisten er allerede samlet op.' }
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local target = mission.searchPoints[pointIndex]
    local horizontalDistance = #(vec2(coords.x, coords.y) - vec2(target.x, target.y))
    if horizontalDistance > 8.0 then
        return { success = false, message = 'Du er for langt væk fra kisten.' }
    end

    local chestId = state.chests and state.chests[pointIndex]
    local chest = chestId and getChest(chestId)
    if not chest then
        return { success = false, message = 'Kistetypen kunne ikke findes.' }
    end

    local added, reason = addItem(source, chest.item, 1)
    if not added then return { success = false, message = reason or 'Du kunne ikke bære kisten.' } end

    state.searched[pointIndex] = true
    state.completed = state.completed + 1
    local finished = state.completed >= state.required
    local completed = state.completed
    local required = state.required
    local bonus = 0

    if finished then
        local xPlayer = ESX.GetPlayerFromId(source)
        bonus = mission.rewardBonus + state.deposit
        if xPlayer then
            giveMoney(xPlayer, bonus)
            setCompletedMissionCooldown(getPlayerIdentifier(xPlayer))
        end
        activeMissions[source] = nil
        missionCooldowns[source] = nil
    end

    return {
        success = true,
        chestId = chestId,
        item = chest.item,
        label = chest.label,
        completed = completed,
        required = required,
        finished = finished,
        bonus = bonus
    }
end)

local function chooseChestLoot(chest)
    local rewards = {}
    local rolls = math.random(chest.rolls.min or 1, chest.rolls.max or 1)

    for _ = 1, rolls do
        local weights = {}
        for itemName, entry in pairs(chest.loot or {}) do
            weights[itemName] = entry.weight or 1
        end

        local itemName = weightedChoice(weights)
        local entry = itemName and chest.loot[itemName]
        if itemName and entry then
            rewards[itemName] = (rewards[itemName] or 0) + math.random(entry.min or 1, entry.max or 1)
        end
    end

    return rewards
end

local function formatRewards(rewards)
    local labels = {}
    for itemName, amount in pairs(rewards) do
        local item = Config.Items.finds[itemName]
        labels[#labels + 1] = ('%dx %s'):format(amount, item and item.label or itemName)
    end
    table.sort(labels)
    return table.concat(labels, ', ')
end

RegisterNetEvent('sb_diving:server:openChest', function(itemName, slot)
    local source = source
    local now = GetGameTimer()
    if chestOpenCooldowns[source] and now - chestOpenCooldowns[source] < 1000 then return end
    chestOpenCooldowns[source] = now

    local _, chest = getChestByItem(itemName)
    if not chest or not hasItem(source, itemName, 1) then
        return notify(source, 'Du har ikke denne dykkerkiste.', 'error')
    end

    local rewards = chooseChestLoot(chest)
    if not next(rewards) then
        return notify(source, 'Kisten kunne ikke åbnes.', 'error')
    end

    -- Fjern først kisten, så dens vægt frigives. Hvis et fund ikke kan gives,
    -- rulles hele handlingen tilbage og kisten gives tilbage.
    local removed = false

    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        local slotId = tonumber(slot)

        -- Brug den konkrete slot, når den er gyldig. Det sikrer korrekt
        -- variant, hvis samme item senere får metadata.
        if slotId then
            local slotData = exports.ox_inventory:GetSlot(source, slotId)

            if slotData and slotData.name == itemName and (slotData.count or 0) >= 1 then
                local success = exports.ox_inventory:RemoveItem(
                    source,
                    itemName,
                    1,
                    slotData.metadata,
                    slotId
                )
                removed = success == true
            end
        end

        -- Fallback til itemnavnet. Dette håndterer ox_inventory-builds,
        -- hvor client-exporten ikke leverer slotnummeret som forventet.
        if not removed then
            local success = exports.ox_inventory:RemoveItem(source, itemName, 1)
            removed = success == true
        end
    else
        removed = removeItem(source, itemName, 1)
    end

    if not removed then
        print(('[sb_diving] Kunne ikke fjerne kiste %s fra spiller %s (slot: %s)')
            :format(tostring(itemName), tostring(source), tostring(slot)))
        return notify(source, 'Kisten kunne ikke fjernes fra dit inventory.', 'error')
    end

    local given = {}
    for rewardName, amount in pairs(rewards) do
        local success = addItem(source, rewardName, amount)
        if not success then
            for rollbackName, rollbackAmount in pairs(given) do
                removeItem(source, rollbackName, rollbackAmount)
            end
            addItem(source, itemName, 1)
            return notify(source, 'Du har ikke plads til kistens indhold.', 'error')
        end
        given[rewardName] = amount
    end

    notify(source, ('Du åbnede %s og fandt: %s.'):format(chest.label, formatRewards(rewards)), 'success')
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
    local now = GetGameTimer()

    if gearUseCooldowns[source] and now - gearUseCooldowns[source] < 1000 then
        return
    end

    gearUseCooldowns[source] = now
    TriggerClientEvent('sb_diving:client:setGear', source, hasItem(source, Config.Items.gear, 1))
end)

AddEventHandler('playerDropped', function()
    activeMissions[source] = nil
    missionCooldowns[source] = nil
    gearUseCooldowns[source] = nil
    chestOpenCooldowns[source] = nil
end)


-- ESX-inventory fallback. ox_inventory bruger client-exporten useDivingGear.
ESX.RegisterUsableItem(Config.Items.gear, function(source)
    local now = GetGameTimer()

    if gearUseCooldowns[source] and now - gearUseCooldowns[source] < 1000 then
        return
    end

    gearUseCooldowns[source] = now
    TriggerClientEvent('sb_diving:client:setGear', source, hasItem(source, Config.Items.gear, 1))
end)


-- ESX fallback for dykkerkister. ox_inventory bruger client-exporten useDivingChest.
for _, chest in pairs(Config.Chests or {}) do
    local itemName = chest.item
    ESX.RegisterUsableItem(itemName, function(source)
        TriggerClientEvent('sb_diving:client:openChest', source, itemName)
    end)
end
