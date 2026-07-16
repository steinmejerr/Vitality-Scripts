local ESX = exports['es_extended']:getSharedObject()

local targets = {}
local targetSequence = 0

local function getInventoryCount(source, item)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:Search(source, 'count', item) or 0
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return 0 end
    local inventoryItem = xPlayer.getInventoryItem(item)
    return inventoryItem and inventoryItem.count or 0
end

local function addItem(source, item, amount)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(source, item, amount)
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    xPlayer.addInventoryItem(item, amount)
    return true
end

local function removeItem(source, item, amount)
    if Config.UseOxInventory and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(source, item, amount)
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    xPlayer.removeInventoryItem(item, amount)
    return true
end

local function addMoney(xPlayer, amount)
    if Config.PaymentAccount == 'bank' then
        xPlayer.addAccountMoney('bank', amount)
    else
        xPlayer.addMoney(amount)
    end
end

local function removeMoney(xPlayer, amount)
    if Config.PaymentAccount == 'bank' then
        local account = xPlayer.getAccount('bank')
        if not account or account.money < amount then return false end
        xPlayer.removeAccountMoney('bank', amount)
        return true
    end

    if xPlayer.getMoney() < amount then return false end
    xPlayer.removeMoney(amount)
    return true
end

local function distance2D(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt((dx * dx) + (dy * dy))
end

local function weightedFind()
    local total = 0
    for _, data in pairs(Config.Finds) do total += data.weight end
    local roll = math.random(1, total)
    local cumulative = 0

    for key, data in pairs(Config.Finds) do
        cumulative += data.weight
        if roll <= cumulative then return key, data end
    end
end

local function getZoneById(zoneId)
    for _, zone in ipairs(Config.Zones) do
        if zone.id == zoneId then
            return zone
        end
    end
end

local function createZoneTarget(zone)
    targetSequence += 1
    local angle = math.random() * math.pi * 2
    local radius = math.sqrt(math.random()) * math.max(1.0, zone.radius - 3.0)

    return {
        id = ('%s:%s'):format(zone.id, targetSequence),
        x = zone.center.x + math.cos(angle) * radius,
        y = zone.center.y + math.sin(angle) * radius,
        z = zone.center.z,
        zone = zone.id,
        claimed = false
    }
end

local function fillZoneTargets(zone)
    targets[zone.id] = targets[zone.id] or {}
    local wanted = zone.findCount or Config.Search.activeFindsPerZone or 10

    while #targets[zone.id] < wanted do
        targets[zone.id][#targets[zone.id] + 1] = createZoneTarget(zone)
    end
end

local function generateTargets()
    for _, zone in ipairs(Config.Zones) do
        targets[zone.id] = {}
        fillZoneTargets(zone)
    end
end

generateTargets()

lib.callback.register('sb_metaldetecting:server:hasDetector', function(source)
    return getInventoryCount(source, Config.Detector.item) > 0
end)

lib.callback.register('sb_metaldetecting:server:getShopData', function(source)
    local inventory = {}
    for key, data in pairs(Config.Finds) do
        inventory[#inventory + 1] = {
            key = key,
            item = data.item,
            label = data.label,
            count = getInventoryCount(source, data.item),
            price = data.sellPrice
        }
    end

    table.sort(inventory, function(a, b) return a.label < b.label end)

    return {
        detector = {
            label = Config.Detector.label,
            price = Config.Detector.price,
            owned = getInventoryCount(source, Config.Detector.item) > 0
        },
        inventory = inventory
    }
end)

lib.callback.register('sb_metaldetecting:server:buyDetector', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren blev ikke fundet.' } end

    if getInventoryCount(source, Config.Detector.item) > 0 then
        return { success = false, message = 'Du ejer allerede en metaldetektor.' }
    end

    if not removeMoney(xPlayer, Config.Detector.price) then
        return { success = false, message = 'Du har ikke råd til metaldetektoren.' }
    end

    local added = addItem(source, Config.Detector.item, 1)
    if not added then
        addMoney(xPlayer, Config.Detector.price)
        return { success = false, message = 'Du har ikke plads i dit inventory.' }
    end

    return { success = true, message = 'Du købte en metaldetektor.' }
end)

lib.callback.register('sb_metaldetecting:server:getTarget', function(source, coords)
    if getInventoryCount(source, Config.Detector.item) < 1 then return nil end

    local playerCoords = vector3(coords.x, coords.y, coords.z)
    local selectedZone

    for _, zone in ipairs(Config.Zones) do
        if distance2D(playerCoords, zone.center) <= zone.radius and playerCoords.z >= zone.minZ and playerCoords.z <= zone.maxZ then
            selectedZone = zone
            break
        end
    end

    if not selectedZone then return nil end

    fillZoneTargets(selectedZone)

    local nearest
    local nearestDistance

    for _, target in ipairs(targets[selectedZone.id]) do
        if not target.claimed then
            local targetDistance = distance2D(playerCoords, vector3(target.x, target.y, target.z))
            if not nearestDistance or targetDistance < nearestDistance then
                nearest = target
                nearestDistance = targetDistance
            end
        end
    end

    if not nearest then return nil end

    return {
        id = nearest.id,
        x = nearest.x,
        y = nearest.y,
        z = nearest.z,
        zone = nearest.zone
    }
end)

lib.callback.register('sb_metaldetecting:server:collectTarget', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local zone = getZoneById(data.zone)
    if not xPlayer or not zone then
        return { success = false, message = 'Fundet findes ikke længere.' }
    end

    local zoneTargets = targets[zone.id] or {}
    local targetIndex
    local target

    for index, entry in ipairs(zoneTargets) do
        if entry.id == data.id then
            targetIndex = index
            target = entry
            break
        end
    end

    if not target or target.claimed then
        return { success = false, message = 'Fundet er allerede blevet gravet op.' }
    end

    if math.abs(target.x - data.x) > 0.1 or math.abs(target.y - data.y) > 0.1 then
        return { success = false, message = 'Ugyldigt fund.' }
    end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    if distance2D(coords, vector3(target.x, target.y, target.z)) > 3.0 then
        return { success = false, message = 'Du er for langt væk fra fundet.' }
    end

    target.claimed = true

    local key, find = weightedFind()
    local amount = math.random(find.amount.min, find.amount.max)
    if not addItem(source, find.item, amount) then
        target.claimed = false
        return { success = false, message = 'Du har ikke plads i dit inventory.' }
    end

    table.remove(zoneTargets, targetIndex)
    zoneTargets[#zoneTargets + 1] = createZoneTarget(zone)

    return {
        success = true,
        key = key,
        label = find.label,
        amount = amount,
        remaining = #zoneTargets
    }
end)

lib.callback.register('sb_metaldetecting:server:sellItem', function(source, key)
    local xPlayer = ESX.GetPlayerFromId(source)
    local find = Config.Finds[key]
    if not xPlayer or not find then return { success = false, message = 'Ugyldigt fund.' } end

    local count = getInventoryCount(source, find.item)
    if count < 1 then return { success = false, message = 'Du har ingen af dette fund.' } end

    if not removeItem(source, find.item, count) then
        return { success = false, message = 'Fundet kunne ikke fjernes.' }
    end

    local total = count * find.sellPrice
    addMoney(xPlayer, total)
    return { success = true, message = ('Du solgte %sx %s for $%s.'):format(count, find.label, total), count = 0 }
end)

lib.callback.register('sb_metaldetecting:server:sellAll', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return { success = false, message = 'Spilleren blev ikke fundet.' } end

    local total = 0
    local sold = 0
    for _, find in pairs(Config.Finds) do
        local count = getInventoryCount(source, find.item)
        if count > 0 and removeItem(source, find.item, count) then
            total += count * find.sellPrice
            sold += count
        end
    end

    if sold == 0 then return { success = false, message = 'Du har ingen fund at sælge.' } end
    addMoney(xPlayer, total)
    return { success = true, message = ('Du solgte %s fund for $%s.'):format(sold, total), clear = true }
end)



ESX.RegisterUsableItem(Config.Detector.item, function(source)
    TriggerClientEvent('sb_metaldetecting:client:useDetector', source)
end)
