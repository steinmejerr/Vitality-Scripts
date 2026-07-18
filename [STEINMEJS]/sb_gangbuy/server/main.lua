local ESX = exports.es_extended:getSharedObject()
local activeMissions = {}
local activeOrders = {}
local actionLocks = {}

local function notify(source, description, type)
    TriggerClientEvent('ox_lib:notify', source, {
        title = 'Kontakten',
        description = description,
        type = type or 'inform'
    })
end

local function getCharacterIdentifier(xPlayer)
    if Config.ProgressPerCharacter then
        return xPlayer.identifier
    end

    local license = GetPlayerIdentifierByType(xPlayer.source, 'license')
    return license or xPlayer.identifier
end

local function getGangAccess(xPlayer)
    if not xPlayer or not xPlayer.job then return false end
    local gang = Config.AllowedGangs[xPlayer.job.name]
    if not gang then return false end

    local grade = tonumber(xPlayer.job.grade) or 0
    if grade < (gang.minimumGrade or 0) then return false end

    return true, gang, grade
end

local function getLevelFromXp(xp)
    local level = 1
    for lvl, data in pairs(Config.Levels) do
        if xp >= data.xp and lvl > level then level = lvl end
    end
    return level
end

local function getProgress(identifier)
    local row = MySQL.single.await('SELECT xp, completed_missions FROM sb_gangbuy_progress WHERE identifier = ?', { identifier })
    if not row then
        MySQL.insert.await('INSERT INTO sb_gangbuy_progress (identifier, xp, completed_missions) VALUES (?, 0, 0)', { identifier })
        return { xp = 0, completed_missions = 0, level = 1 }
    end

    row.xp = tonumber(row.xp) or 0
    row.completed_missions = tonumber(row.completed_missions) or 0
    row.level = getLevelFromXp(row.xp)
    return row
end

local function getNextLevel(level)
    return Config.Levels[level + 1] and Config.Levels[level + 1].xp or nil
end

local function serializeProducts(level, grade)
    local result = {}
    for key, product in pairs(Config.Products) do
        result[#result + 1] = {
            id = key,
            label = product.label,
            description = product.description,
            amount = product.amount,
            price = product.price,
            requiredLevel = product.requiredLevel,
            requiredGrade = product.requiredGrade,
            deliveryMin = product.deliveryMinutes.min,
            deliveryMax = product.deliveryMinutes.max,
            icon = product.icon,
            unlocked = level >= product.requiredLevel and grade >= product.requiredGrade
        }
    end
    table.sort(result, function(a, b) return a.requiredLevel < b.requiredLevel end)
    return result
end

local function serializeMissions(level, grade)
    local result = {}
    for key, mission in pairs(Config.Missions) do
        result[#result + 1] = {
            id = key,
            label = mission.label,
            description = mission.description,
            requiredLevel = mission.requiredLevel,
            requiredGrade = mission.requiredGrade,
            xp = mission.xp,
            money = mission.money,
            icon = mission.icon,
            unlocked = level >= mission.requiredLevel and grade >= mission.requiredGrade
        }
    end
    table.sort(result, function(a, b) return a.requiredLevel < b.requiredLevel end)
    return result
end

local function orderForClient(order)
    if not order then return nil end
    return {
        id = order.id,
        productId = order.productId,
        label = order.label,
        amount = order.amount,
        readyAt = order.readyAt,
        expiresAt = order.expiresAt,
        status = order.status,
        coords = order.status == 'ready' and order.coords or nil
    }
end

lib.callback.register('sb_gangbuy:server:getMenuData', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed, gang, grade = getGangAccess(xPlayer)
    if not allowed then return { allowed = false } end

    local identifier = getCharacterIdentifier(xPlayer)
    local progress = getProgress(identifier)
    local mission = activeMissions[source]
    local order = activeOrders[source]

    if order and order.status == 'waiting' and os.time() >= order.readyAt then
        order.status = 'ready'
        TriggerClientEvent('sb_gangbuy:client:orderReady', source, orderForClient(order))
    end

    return {
        allowed = true,
        player = {
            name = xPlayer.getName(),
            gang = gang.label or xPlayer.job.label,
            gradeLabel = xPlayer.job.grade_label or tostring(grade),
            grade = grade,
            xp = progress.xp,
            level = progress.level,
            nextLevelXp = getNextLevel(progress.level),
            completedMissions = progress.completed_missions
        },
        products = serializeProducts(progress.level, grade),
        missions = serializeMissions(progress.level, grade),
        activeMission = mission and {
            id = mission.id,
            label = mission.label,
            status = mission.status,
            readyAt = mission.readyAt,
            coords = mission.status == 'ready' and mission.coords or nil
        } or nil,
        activeOrder = orderForClient(order),
        missionCooldown = math.max(0, (Player(source).state.sbGangbuyMissionCooldown or 0) - os.time())
    }
end)

lib.callback.register('sb_gangbuy:server:buyProduct', function(source, productId)
    if actionLocks[source] then return { success = false, message = 'Vent et øjeblik.' } end
    actionLocks[source] = true

    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed, _, grade = getGangAccess(xPlayer)
    local product = Config.Products[productId]

    if not allowed or not product then
        actionLocks[source] = nil
        return { success = false, message = 'Du har ikke adgang.' }
    end

    if activeOrders[source] then
        actionLocks[source] = nil
        return { success = false, message = 'Du har allerede en aktiv ordre.' }
    end

    local progress = getProgress(getCharacterIdentifier(xPlayer))
    if progress.level < product.requiredLevel or grade < product.requiredGrade then
        actionLocks[source] = nil
        return { success = false, message = 'Dit level eller din rang er for lav.' }
    end

    local account = xPlayer.getAccount(Config.PaymentAccount)
    if not account or account.money < product.price then
        actionLocks[source] = nil
        return { success = false, message = 'Du har ikke råd.' }
    end

    xPlayer.removeAccountMoney(Config.PaymentAccount, product.price, 'Gangbuy ordre')

    local minutes = math.random(product.deliveryMinutes.min, product.deliveryMinutes.max)
    local readyAt = os.time() + (minutes * 60)
    local coords = Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]
    local orderId = MySQL.insert.await([[
        INSERT INTO sb_gangbuy_orders
            (identifier, gang_job, product_id, item_name, amount, price, status, ready_at, expires_at)
        VALUES (?, ?, ?, ?, ?, ?, 'waiting', FROM_UNIXTIME(?), FROM_UNIXTIME(?))
    ]], {
        getCharacterIdentifier(xPlayer), xPlayer.job.name, productId, product.item,
        product.amount, product.price, readyAt, readyAt + (Config.OrderExpireMinutes * 60)
    })

    activeOrders[source] = {
        id = orderId,
        productId = productId,
        label = product.label,
        item = product.item,
        amount = product.amount,
        price = product.price,
        readyAt = readyAt,
        expiresAt = readyAt + (Config.OrderExpireMinutes * 60),
        coords = coords,
        status = 'waiting'
    }

    actionLocks[source] = nil
    return { success = true, order = orderForClient(activeOrders[source]), message = ('Ordren er klar om cirka %s minutter.'):format(minutes) }
end)

lib.callback.register('sb_gangbuy:server:startMission', function(source, missionId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed, _, grade = getGangAccess(xPlayer)
    local mission = Config.Missions[missionId]
    if not allowed or not mission then return { success = false, message = 'Du har ikke adgang.' } end
    if activeMissions[source] then return { success = false, message = 'Du har allerede en aktiv opgave.' } end

    local cooldown = Player(source).state.sbGangbuyMissionCooldown or 0
    if cooldown > os.time() then
        return { success = false, message = ('Du kan tage en ny opgave om %s minutter.'):format(math.ceil((cooldown - os.time()) / 60)) }
    end

    local progress = getProgress(getCharacterIdentifier(xPlayer))
    if progress.level < mission.requiredLevel or grade < mission.requiredGrade then
        return { success = false, message = 'Dit level eller din rang er for lav.' }
    end

    local wait = math.random(mission.waitSeconds.min, mission.waitSeconds.max)
    local coords = Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]
    activeMissions[source] = {
        id = missionId,
        label = mission.label,
        xp = mission.xp,
        money = mission.money,
        status = 'waiting',
        readyAt = os.time() + wait,
        coords = coords
    }

    return {
        success = true,
        mission = {
            id = missionId,
            label = mission.label,
            status = 'waiting',
            readyAt = os.time() + wait
        },
        message = 'Pakken bliver gjort klar. Du får GPS, når den er klar.'
    }
end)

lib.callback.register('sb_gangbuy:server:collectOrder', function(source, orderId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed = getGangAccess(xPlayer)
    local order = activeOrders[source]
    if not allowed or not order or order.id ~= tonumber(orderId) then return { success = false, message = 'Ordren blev ikke fundet.' } end
    if os.time() < order.readyAt then return { success = false, message = 'Ordren er ikke klar endnu.' } end
    if os.time() > order.expiresAt then
        MySQL.update.await("UPDATE sb_gangbuy_orders SET status = 'expired' WHERE id = ?", { order.id })
        activeOrders[source] = nil
        return { success = false, message = 'Ordren er udløbet.' }
    end

    local canCarry = true
    if Config.UseOxInventory then
        canCarry = exports.ox_inventory:CanCarryItem(source, order.item, order.amount)
    end
    if not canCarry then return { success = false, message = 'Du har ikke plads i inventory.' } end

    if Config.UseOxInventory then
        exports.ox_inventory:AddItem(source, order.item, order.amount)
    else
        xPlayer.addInventoryItem(order.item, order.amount)
    end

    MySQL.update.await("UPDATE sb_gangbuy_orders SET status = 'collected', collected_at = NOW() WHERE id = ?", { order.id })
    activeOrders[source] = nil
    return { success = true, message = ('Du fik %sx %s.'):format(order.amount, order.label) }
end)

lib.callback.register('sb_gangbuy:server:collectMission', function(source, missionId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local allowed = getGangAccess(xPlayer)
    local mission = activeMissions[source]
    if not allowed or not mission or mission.id ~= missionId then return { success = false, message = 'Opgaven blev ikke fundet.' } end
    if os.time() < mission.readyAt then return { success = false, message = 'Pakken er ikke klar endnu.' } end

    local identifier = getCharacterIdentifier(xPlayer)
    MySQL.update.await([[
        UPDATE sb_gangbuy_progress
        SET xp = xp + ?, completed_missions = completed_missions + 1, updated_at = NOW()
        WHERE identifier = ?
    ]], { mission.xp, identifier })

    xPlayer.addAccountMoney(Config.PaymentAccount, mission.money, 'Gangbuy mission')
    MySQL.insert.await([[
        INSERT INTO sb_gangbuy_mission_history (identifier, gang_job, mission_id, xp_reward, money_reward)
        VALUES (?, ?, ?, ?, ?)
    ]], { identifier, xPlayer.job.name, mission.id, mission.xp, mission.money })

    activeMissions[source] = nil
    Player(source).state:set('sbGangbuyMissionCooldown', os.time() + (Config.MissionCooldownMinutes * 60), true)

    local progress = getProgress(identifier)
    return {
        success = true,
        message = ('Opgave klaret: +%s XP og $%s.'):format(mission.xp, mission.money),
        level = progress.level,
        xp = progress.xp,
        nextLevelXp = getNextLevel(progress.level)
    }
end)

RegisterNetEvent('sb_gangbuy:server:checkReady', function()
    local source = source
    local mission = activeMissions[source]
    if mission and mission.status == 'waiting' and os.time() >= mission.readyAt then
        mission.status = 'ready'
        TriggerClientEvent('sb_gangbuy:client:missionReady', source, {
            id = mission.id, label = mission.label, coords = mission.coords
        })
    end

    local order = activeOrders[source]
    if order and order.status == 'waiting' and os.time() >= order.readyAt then
        order.status = 'ready'
        TriggerClientEvent('sb_gangbuy:client:orderReady', source, orderForClient(order))
    end
end)

AddEventHandler('playerDropped', function()
    activeMissions[source] = nil
    activeOrders[source] = nil
    actionLocks[source] = nil
end)
