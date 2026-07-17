local ESX = exports['es_extended']:getSharedObject()
local activeMissions = {}
local rockLocks = {}
local invites = {}
local equippedPickaxes = {}
local rockOreTypes = {}

MySQL.ready(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `sb_mining_players` (
            `identifier` varchar(80) NOT NULL,
            `xp` int NOT NULL DEFAULT 0,
            `level` int NOT NULL DEFAULT 1,
            `completed_missions` int NOT NULL DEFAULT 0,
            `cooldown_until` datetime DEFAULT NULL,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end)

local function getIdentifier(xPlayer)
    return xPlayer and xPlayer.identifier
end

local function calculateLevel(xp)
    local level = 1
    for index, data in pairs(Config.Levels) do
        if xp >= data.xp and index > level then
            level = index
        end
    end
    return level
end


local function getXpData(xp)
    xp = tonumber(xp) or 0
    local level = calculateLevel(xp)
    local currentLevelXp = Config.Levels[level] and Config.Levels[level].xp or 0
    local nextLevelData = Config.Levels[level + 1]
    local nextLevelXp = nextLevelData and nextLevelData.xp or currentLevelXp
    local progressXp = math.max(0, xp - currentLevelXp)
    local requiredXp = nextLevelData and math.max(1, nextLevelXp - currentLevelXp) or 0
    local remainingXp = nextLevelData and math.max(0, nextLevelXp - xp) or 0

    return {
        xp = xp,
        level = level,
        currentLevelXp = currentLevelXp,
        nextLevelXp = nextLevelXp,
        progressXp = progressXp,
        requiredXp = requiredXp,
        remainingXp = remainingXp,
        maxLevel = nextLevelData == nil
    }
end


local function getProfile(identifier)
    local row = MySQL.single.await('SELECT xp, level, completed_missions FROM sb_mining_players WHERE identifier = ?', { identifier })
    if not row then
        MySQL.insert.await('INSERT INTO sb_mining_players (identifier, xp, level, completed_missions) VALUES (?, 0, 1, 0)', { identifier })
        return { xp = 0, level = 1, completed_missions = 0 }
    end
    row.level = calculateLevel(row.xp or 0)
    return row
end

local function saveXP(identifier, amount)
    local profile = getProfile(identifier)
    local xp = (profile.xp or 0) + amount
    local level = calculateLevel(xp)
    MySQL.update.await('UPDATE sb_mining_players SET xp = ?, level = ? WHERE identifier = ?', { xp, level, identifier })
    return xp, level
end

local function countItem(source, item)
    if Config.UseOxInventory then
        return exports.ox_inventory:Search(source, 'count', item) or 0
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventoryItem = xPlayer and xPlayer.getInventoryItem(item)
    return inventoryItem and inventoryItem.count or 0
end

local function addItem(source, item, amount)
    if Config.UseOxInventory then
        return exports.ox_inventory:AddItem(source, item, amount)
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    xPlayer.addInventoryItem(item, amount)
    return true
end

local function removeItem(source, item, amount)
    if Config.UseOxInventory then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

local function weightedOre(level)
    local pool = {}
    local total = 0
    for key, ore in pairs(Config.Ores) do
        if level >= ore.minLevel then
            total = total + ore.weight
            pool[#pool + 1] = { key = key, ore = ore, max = total }
        end
    end
    local roll = math.random(1, math.max(total, 1))
    for _, entry in ipairs(pool) do
        if roll <= entry.max then
            return entry.key, entry.ore
        end
    end
end

local function getPickaxeByItem(itemName)
    for key, pickaxe in pairs(Config.Pickaxes) do
        if pickaxe.item == itemName then
            return key, pickaxe
        end
    end
end

local function getEquippedPickaxe(source, level)
    local key = equippedPickaxes[source]
    local pickaxe = key and Config.Pickaxes[key]

    if not pickaxe then
        return nil
    end

    if level < pickaxe.requiredLevel or countItem(source, pickaxe.item) < 1 then
        equippedPickaxes[source] = nil
        return nil
    end

    return { key = key, data = pickaxe }
end

local function missionForPlayer(source)
    for leader, mission in pairs(activeMissions) do
        for _, member in ipairs(mission.members) do
            if member == source then
                return leader, mission
            end
        end
    end
end

local function rockStateKey(zoneKey, rockIndex, nodeIndex)
    return ('%s:%s:%s'):format(zoneKey, rockIndex, nodeIndex)
end

local function chooseZoneOre(zoneKey)
    local zone = Config.Zones[zoneKey]
    local pool = zone and zone.orePool or {}
    if #pool < 1 then return 'coal' end

    local available = {}
    for _, oreKey in ipairs(pool) do
        if Config.Ores[oreKey] then
            available[#available + 1] = oreKey
        end
    end

    if #available < 1 then
        return 'coal'
    end

    return available[math.random(1, #available)]
end

local function ensureRockOres(zoneKey, rockIndex)
    rockOreTypes[zoneKey] = rockOreTypes[zoneKey] or {}
    rockOreTypes[zoneKey][rockIndex] = rockOreTypes[zoneKey][rockIndex] or {}

    for nodeIndex = 1, Config.Rock.oresPerStone do
        if not rockOreTypes[zoneKey][rockIndex][nodeIndex] then
            rockOreTypes[zoneKey][rockIndex][nodeIndex] = chooseZoneOre(zoneKey)
        end
    end

    return rockOreTypes[zoneKey][rockIndex]
end

local function getRockVisualState()
    local payload = {}
    for zoneKey, zone in pairs(Config.Zones) do
        payload[zoneKey] = {}
        for rockIndex = 1, #zone.rocks do
            payload[zoneKey][rockIndex] = ensureRockOres(zoneKey, rockIndex)
        end
    end
    return payload
end

lib.callback.register('sb_mining:server:equipPickaxe', function(source, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false, 'Spilleren kunne ikke findes.'
    end

    local key, pickaxe = getPickaxeByItem(itemName)
    if not key or not pickaxe then
        return false, 'Denne hakke kan ikke bruges.'
    end

    local profile = getProfile(getIdentifier(xPlayer))
    if profile.level < pickaxe.requiredLevel then
        return false, ('Hakken kræver mining-level %s.'):format(pickaxe.requiredLevel)
    end

    if countItem(source, pickaxe.item) < 1 then
        return false, 'Du har ikke denne hakke.'
    end

    if equippedPickaxes[source] == key then
        equippedPickaxes[source] = nil
        return true, ('Du pakkede %s væk.'):format(pickaxe.label), 'unequipped'
    end

    equippedPickaxes[source] = key
    return true, ('Du tog %s frem.'):format(pickaxe.label), 'equipped', key, pickaxe.label
end)

lib.callback.register('sb_mining:server:unequipPickaxe', function(source)
    equippedPickaxes[source] = nil
    return true
end)

lib.callback.register('sb_mining:server:getEquippedPickaxe', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil, 'Spilleren kunne ikke findes.'
    end

    local profile = getProfile(getIdentifier(xPlayer))
    local equipped = getEquippedPickaxe(source, profile.level)
    if not equipped then
        return nil, 'Brug en hakke fra dit inventory først.'
    end

    return {
        key = equipped.key,
        label = equipped.data.label,
        speedMultiplier = equipped.data.speedMultiplier or 1.0
    }
end)


lib.callback.register('sb_mining:server:getXpData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil
    end

    local profile = getProfile(getIdentifier(xPlayer))
    return getXpData(profile.xp)
end)

lib.callback.register('sb_mining:server:getRockVisuals', function(source)
    return getRockVisualState()
end)

lib.callback.register('sb_mining:server:getRockState', function(source)
    return getRockVisualState()
end)

lib.callback.register('sb_mining:server:getMenuData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return nil, 'Spilleren kunne ikke findes.'
    end

    local success, result = pcall(function()
        local profile = getProfile(getIdentifier(xPlayer))
        local inventory = {}

        for key, ore in pairs(Config.Ores) do
            inventory[key] = countItem(source, ore.item)
        end

        local _, mission = missionForPlayer(source)

        return {
            profile = {
                xp = tonumber(profile.xp) or 0,
                level = tonumber(profile.level) or 1,
                completed_missions = tonumber(profile.completed_missions) or 0
            },
            pickaxes = Config.Pickaxes,
            missions = Config.Missions,
            ores = Config.Ores,
            inventory = inventory,
            activeMission = mission
        }
    end)

    if not success then
        print(('[sb_mining] Kunne ikke hente NUI-data: %s'):format(result))
        return nil, 'Minebutikken kunne ikke indlæses. Se serverkonsollen.'
    end

    return result
end)

lib.callback.register('sb_mining:server:buyPickaxe', function(source, pickaxeKey)
    local xPlayer = ESX.GetPlayerFromId(source)
    local pickaxe = Config.Pickaxes[pickaxeKey]
    if not xPlayer or not pickaxe then return false, 'Ugyldig hakke.' end
    local profile = getProfile(getIdentifier(xPlayer))
    if profile.level < pickaxe.requiredLevel then return false, ('Kræver level %s.'):format(pickaxe.requiredLevel) end
    if countItem(source, pickaxe.item) > 0 then return false, 'Du har allerede denne hakke.' end
    local account = Config.PaymentAccount == 'bank' and xPlayer.getAccount('bank').money or xPlayer.getMoney()
    if account < pickaxe.price then return false, 'Du har ikke råd.' end
    if Config.PaymentAccount == 'bank' then xPlayer.removeAccountMoney('bank', pickaxe.price) else xPlayer.removeMoney(pickaxe.price) end
    if not addItem(source, pickaxe.item, 1) then
        if Config.PaymentAccount == 'bank' then xPlayer.addAccountMoney('bank', pickaxe.price) else xPlayer.addMoney(pickaxe.price) end
        return false, 'Hakken kunne ikke gives.'
    end
    return true, ('Du købte %s.'):format(pickaxe.label)
end)

lib.callback.register('sb_mining:server:startMission', function(source, missionKey, memberIds)
    local xPlayer = ESX.GetPlayerFromId(source)
    local mission = Config.Missions[missionKey]
    if not xPlayer or not mission then return false, 'Ugyldig mission.' end
    if missionForPlayer(source) then return false, 'Du er allerede i en mission.' end
    local identifier = getIdentifier(xPlayer)
    local profile = getProfile(identifier)
    if profile.level < mission.requiredLevel then return false, ('Kræver level %s.'):format(mission.requiredLevel) end
    local cooldown = MySQL.scalar.await('SELECT UNIX_TIMESTAMP(cooldown_until) FROM sb_mining_players WHERE identifier = ?', { identifier })
    if cooldown and cooldown > os.time() then return false, 'Du skal vente før du kan starte en ny mission.' end
    local members = { source }
    if mission.multiplayer and type(memberIds) == 'table' then
        for _, id in ipairs(memberIds) do
            id = tonumber(id)
            if id and id ~= source and #members < Config.MaxPartySize and ESX.GetPlayerFromId(id) and not missionForPlayer(id) then
                members[#members + 1] = id
            end
        end
    end
    activeMissions[source] = {
        key = missionKey,
        label = mission.label,
        zone = mission.zone,
        rocks = mission.rocks,
        mined = 0,
        ores = {},
        members = members,
        leader = source
    }
    for _, member in ipairs(members) do
        TriggerClientEvent('sb_mining:client:missionStarted', member, activeMissions[source])
    end
    return true, ('Mission startet med %s spiller(e).'):format(#members)
end)

lib.callback.register('sb_mining:server:mineRock', function(source, zoneKey, rockIndex, nodeIndex)
    local zone = Config.Zones[zoneKey]
    rockIndex = tonumber(rockIndex)
    nodeIndex = tonumber(nodeIndex)

    if not zone or not rockIndex or not nodeIndex or not zone.rocks[rockIndex] or nodeIndex < 1 or nodeIndex > (Config.Rock.oresPerStone or 1) then
        return false, 'Ugyldig mineåre.'
    end

    local lockKey = rockStateKey(zoneKey, rockIndex, nodeIndex)
    local now = os.time()
    if rockLocks[lockKey] and rockLocks[lockKey] > now then
        return false, 'Denne ore er ved at respawne.'
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    local profile = xPlayer and getProfile(getIdentifier(xPlayer))
    if not profile then return false, 'Spilleren kunne ikke findes.' end

    if zone.minLevel and profile.level < zone.minLevel then
        return false, ('Dette mineområde kræver mindst mining-level %s.'):format(zone.minLevel)
    end
    if zone.maxLevel and profile.level > zone.maxLevel then
        return false, ('Dette mineområde er kun til og med mining-level %s.'):format(zone.maxLevel)
    end

    local pickaxe = getEquippedPickaxe(source, profile.level)
    if not pickaxe then return false, 'Brug en hakke fra dit inventory først.' end

    local rockOres = ensureRockOres(zoneKey, rockIndex)
    local oreKey = rockOres[nodeIndex]
    local ore = Config.Ores[oreKey]
    if not ore then return false, 'Denne malmåre kunne ikke findes.' end
    if profile.level < ore.minLevel then
        return false, ('Denne malmåre kræver mining-level %s.'):format(ore.minLevel)
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local rockCoords = zone.rocks[rockIndex]
    if #(playerCoords - vec3(rockCoords.x, rockCoords.y, rockCoords.z)) > (Config.Rock.interactionDistance + 3.0) then
        return false, 'Du er for langt væk fra malmåren.'
    end

    if not addItem(source, ore.item, Config.OresPerRock) then
        return false, 'Du har ikke plads til malmen.'
    end

    rockLocks[lockKey] = now + Config.Rock.respawnSeconds
    local xp, level = saveXP(getIdentifier(xPlayer), Config.XPPerRock)
    local leader, mission = missionForPlayer(source)

    if mission and mission.zone == zoneKey then
        mission.ores[oreKey] = (mission.ores[oreKey] or 0) + Config.OresPerRock
        mission.mined = mission.mined + 1
        for _, member in ipairs(mission.members) do
            TriggerClientEvent('sb_mining:client:missionProgress', member, mission)
        end

        local configMission = Config.Missions[mission.key]
        local complete = mission.mined >= configMission.rocks
        if configMission.requiredOre then
            complete = complete and (mission.ores[configMission.requiredOre] or 0) >= configMission.requiredOreAmount
        end

        if complete then
            for _, member in ipairs(mission.members) do
                local memberPlayer = ESX.GetPlayerFromId(member)
                if memberPlayer then
                    memberPlayer.addMoney(configMission.moneyBonus)
                    local memberIdentifier = getIdentifier(memberPlayer)
                    saveXP(memberIdentifier, configMission.xpBonus)
                    MySQL.update.await('UPDATE sb_mining_players SET completed_missions = completed_missions + 1, cooldown_until = DATE_ADD(NOW(), INTERVAL ? SECOND) WHERE identifier = ?', { Config.MissionCooldownSeconds, memberIdentifier })
                    TriggerClientEvent('sb_mining:client:missionComplete', member, configMission.moneyBonus, configMission.xpBonus)
                end
            end
            activeMissions[leader] = nil
        end
    end

    local nextOreKey = chooseZoneOre(zoneKey)
    rockOreTypes[zoneKey][rockIndex][nodeIndex] = nextOreKey

    TriggerClientEvent('sb_mining:client:oreDepleted', -1, zoneKey, rockIndex, nodeIndex)
    TriggerClientEvent('sb_mining:client:rockRespawn', -1, zoneKey, rockIndex, nodeIndex, Config.Rock.respawnSeconds, nextOreKey)

    return true, ('%sx %s'):format(Config.OresPerRock, ore.label), pickaxe.data.speedMultiplier, xp, level, Config.XPPerRock, getXpData(xp)
end)

lib.callback.register('sb_mining:server:sellOre', function(source, oreKey, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local ore = Config.Ores[oreKey]
    amount = math.floor(tonumber(amount) or 0)
    if not xPlayer or not ore or amount < 1 then return false, 'Ugyldigt salg.' end
    local owned = countItem(source, ore.item)
    if owned < amount then return false, 'Du har ikke nok.' end
    local profile = getProfile(getIdentifier(xPlayer))
    local multiplier = (Config.Levels[profile.level] and Config.Levels[profile.level].sellMultiplier) or 1.0
    local payout = math.floor(ore.sellPrice * amount * multiplier)
    if not removeItem(source, ore.item, amount) then return false, 'Malmen kunne ikke fjernes.' end
    xPlayer.addMoney(payout)
    return true, ('Du solgte %sx %s for %s kr.'):format(amount, ore.label, payout)
end)

lib.callback.register('sb_mining:server:sellAll', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, 'Spilleren kunne ikke findes.' end
    local profile = getProfile(getIdentifier(xPlayer))
    local multiplier = (Config.Levels[profile.level] and Config.Levels[profile.level].sellMultiplier) or 1.0
    local payout = 0
    local sold = 0
    for _, ore in pairs(Config.Ores) do
        local amount = countItem(source, ore.item)
        if amount > 0 and removeItem(source, ore.item, amount) then
            payout = payout + math.floor(ore.sellPrice * amount * multiplier)
            sold = sold + amount
        end
    end
    if sold < 1 then return false, 'Du har ingen malm at sælge.' end
    xPlayer.addMoney(payout)
    return true, ('Du solgte %s enheder for %s kr.'):format(sold, payout)
end)

AddEventHandler('playerDropped', function()
    local source = source
    local leader, mission = missionForPlayer(source)
    if leader and mission then
        if leader == source then
            for _, member in ipairs(mission.members) do
                if member ~= source then TriggerClientEvent('sb_mining:client:missionCancelled', member) end
            end
            activeMissions[leader] = nil
        else
            for index, member in ipairs(mission.members) do
                if member == source then table.remove(mission.members, index) break end
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    equippedPickaxes[source] = nil
end)
