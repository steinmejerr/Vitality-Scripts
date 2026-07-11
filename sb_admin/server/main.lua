local ESX = exports['es_extended']:getSharedObject()
local frozenPlayers = {}

local function getPlayerGroup(xPlayer)
    if not xPlayer then
        return nil
    end

    if xPlayer.getGroup then
        return xPlayer.getGroup()
    end

    return xPlayer.group
end

local function hasPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = getPlayerGroup(xPlayer)

    return xPlayer ~= nil and Config.AllowedGroups[group] == true, group
end

lib.callback.register('sb_admin:server:hasPermission', function(source)
    return hasPermission(source)
end)

lib.callback.register('sb_admin:server:sendAnnouncement', function(source, message)
    local allowed = hasPermission(source)

    if not allowed then
        return false
    end

    message = tostring(message or '')
    message = message:gsub('^%s+', ''):gsub('%s+$', '')

    local maxLength = (Config.Announcement and Config.Announcement.maxLength) or 300

    if message == '' or #message > maxLength then
        return false
    end

    TriggerClientEvent('sb_admin:client:showAnnouncement', -1, {
        message = message
    })

    return true
end)

lib.callback.register('sb_admin:server:getPlayers', function(source)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local serverId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(serverId)

        if xPlayer then
            local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job or {}
            local group = getPlayerGroup(xPlayer) or 'user'
            local playerName = xPlayer.getName and xPlayer.getName() or GetPlayerName(serverId)

            players[#players + 1] = {
                id = serverId,
                name = playerName or GetPlayerName(serverId) or ('Spiller %s'):format(serverId),
                ping = GetPlayerPing(serverId),
                job = job.label or job.name or 'Ukendt',
                jobGrade = job.grade_label or tostring(job.grade or 0),
                group = group
            }
        end
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    return players
end)


lib.callback.register('sb_admin:server:getPlayerDetails', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local xPlayer = ESX.GetPlayerFromId(targetId)

    if not xPlayer then
        return nil
    end

    local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job or {}
    local group = getPlayerGroup(xPlayer) or 'user'
    local playerName = xPlayer.getName and xPlayer.getName() or GetPlayerName(targetId)

    return {
        id = targetId,
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        ping = GetPlayerPing(targetId),
        job = job.label or job.name or 'Ukendt',
        jobGrade = job.grade_label or tostring(job.grade or 0),
        group = group,
        frozen = frozenPlayers[targetId] == true
    }
end)


lib.callback.register('sb_admin:server:gotoPlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not targetPlayer then
        return nil
    end

    local targetPed = GetPlayerPed(targetId)

    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        return nil
    end

    local coords = GetEntityCoords(targetPed)
    local heading = GetEntityHeading(targetPed)
    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    return {
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading
    }
end)

lib.callback.register('sb_admin:server:bringPlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local adminPed = GetPlayerPed(source)

    if not adminPed or adminPed == 0 or not DoesEntityExist(adminPed) then
        return nil
    end

    local coords = GetEntityCoords(adminPed)
    local heading = GetEntityHeading(adminPed)
    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    TriggerClientEvent('sb_admin:client:bringToAdmin', targetId, {
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading,
        adminName = adminName or GetPlayerName(source) or 'en administrator'
    })

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId)
    }
end)

lib.callback.register('sb_admin:server:revivePlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    frozenPlayers[targetId] = nil

    -- Piotreq Ambulance Job v2 har sin egen death-state.
    -- Derfor skal revive gå gennem ambulancejobbets officielle client-event.
    TriggerClientEvent('p_ambulancejob/client/death/revive', targetId)

    -- Vores egen event bruges kun til beskeden og til at sikre,
    -- at en eventuel admin-freeze bliver fjernet.
    TriggerClientEvent('sb_admin:client:reviveNotification', targetId, adminName or 'en administrator')

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId)
    }
end)

lib.callback.register('sb_admin:server:toggleFreezePlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local frozen = frozenPlayers[targetId] ~= true
    frozenPlayers[targetId] = frozen or nil

    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    TriggerClientEvent('sb_admin:client:setFrozen', targetId, frozen, adminName or 'en administrator')

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        frozen = frozen
    }
end)


lib.callback.register('sb_admin:server:getSpectateTarget', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or targetId == source or not GetPlayerName(targetId) then
        return nil
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    local targetPed = GetPlayerPed(targetId)

    if not targetPlayer or not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        return nil
    end

    local coords = GetEntityCoords(targetPed)
    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    return {
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    }
end)


local function validSqlIdentifier(value)
    return type(value) == 'string' and value:match('^[%a_][%w_]*$') ~= nil
end

local function getPlayerIdentifier(xPlayer)
    if not xPlayer then
        return nil
    end

    if xPlayer.getIdentifier then
        return xPlayer.getIdentifier()
    end

    return xPlayer.identifier
end

local function normalizePlate(value, maxLength)
    value = tostring(value or ''):upper()
    value = value:gsub('[^A-Z0-9]', '')
    return value:sub(1, maxLength)
end

local function generatePlate(prefix, maxLength)
    prefix = normalizePlate(prefix or 'SB', maxLength)
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local remaining = math.max(maxLength - #prefix, 1)
    local result = prefix

    for _ = 1, remaining do
        local index = math.random(1, #chars)
        result = result .. chars:sub(index, index)
    end

    return result:sub(1, maxLength)
end

local function getTableColumns(tableName)
    if not validSqlIdentifier(tableName) then
        return nil
    end

    local rows = MySQL.query.await(('SHOW COLUMNS FROM `%s`'):format(tableName))
    local columns = {}

    for _, row in ipairs(rows or {}) do
        columns[row.Field] = true
    end

    return columns
end

local function unwrapGarageData(value, fallbackId)
    if type(value) ~= 'table' then
        return nil
    end

    -- Nogle OP Garages-versioner returnerer { ["35"] = { ... } }
    -- fra getGarageByIndex i stedet for selve garage-tabellen.
    if value.Index or value.Type or value.Label or value.CenterOfZone or value.onespawn then
        value.__sbGarageId = tostring(value.Index or fallbackId or '')
        return value
    end

    for key, garage in pairs(value) do
        if type(garage) == 'table' then
            garage.__sbGarageId = tostring(garage.Index or key or fallbackId or '')
            return garage
        end
    end

    return nil
end

local function getGaragePosition(garage)
    garage = unwrapGarageData(garage)

    if not garage then
        return nil
    end

    local coords = garage.CenterOfZone or garage.onespawn or garage.Coords or garage.AccessPoint

    if type(coords) ~= 'table' then
        return nil
    end

    local x = tonumber(coords.x or coords[1])
    local y = tonumber(coords.y or coords[2])
    local z = tonumber(coords.z or coords[3])

    if not x or not y or not z then
        return nil
    end

    return vector3(x, y, z)
end

local function getOpGaragesFromExport()
    local config = Config.GiveVehicle or {}
    local resourceName = config.resource or 'op-garages'

    if GetResourceState(resourceName) ~= 'started' then
        return nil, ('Resource %s er ikke startet.'):format(resourceName)
    end

    local ok, garages = pcall(function()
        return exports[resourceName]:getAllGarages()
    end)

    if ok and type(garages) == 'table' then
        return garages
    end

    return nil, ('Export getAllGarages er ikke tilgængelig i %s.'):format(resourceName)
end

local function findColumn(columns, candidates)
    for _, wanted in ipairs(candidates) do
        for actual in pairs(columns) do
            if actual:lower() == wanted:lower() then
                return actual
            end
        end
    end
end

local function getGarageOptionsFromDatabase()
    local config = Config.GiveVehicle or {}
    local configuredTable = config.garageTable
    local tables = {}

    if configuredTable and configuredTable ~= '' then
        if not validSqlIdentifier(configuredTable) then
            return nil, 'Config.GiveVehicle.garageTable er ugyldig.'
        end
        tables[1] = configuredTable
    else
        local rows = MySQL.query.await([[SELECT TABLE_NAME
            FROM information_schema.TABLES
            WHERE TABLE_SCHEMA = DATABASE()
              AND LOWER(TABLE_NAME) LIKE '%garage%'
            ORDER BY TABLE_NAME]])

        for _, row in ipairs(rows or {}) do
            local name = row.TABLE_NAME or row.table_name
            if name and name ~= (config.table or 'owned_vehicles') then
                tables[#tables + 1] = name
            end
        end
    end

    local checked = {}

    for _, tableName in ipairs(tables) do
        if validSqlIdentifier(tableName) then
            checked[#checked + 1] = tableName
            local columns = getTableColumns(tableName) or {}
            local idColumn = findColumn(columns, { 'Index', 'id', 'garageId', 'garage_id' })
            local labelColumn = findColumn(columns, { 'Label', 'label', 'name', 'garageName', 'garage_name' })
            local typeColumn = findColumn(columns, { 'Type', 'type', 'garageType', 'garage_type' })

            if idColumn and labelColumn then
                local selectParts = {
                    ('`%s` AS garage_id'):format(idColumn),
                    ('`%s` AS garage_label'):format(labelColumn)
                }

                if typeColumn then
                    selectParts[#selectParts + 1] = ('`%s` AS garage_type'):format(typeColumn)
                else
                    selectParts[#selectParts + 1] = "'car' AS garage_type"
                end

                local ok, rows = pcall(MySQL.query.await, ('SELECT %s FROM `%s`'):format(
                    table.concat(selectParts, ', '),
                    tableName
                ))

                if ok and type(rows) == 'table' then
                    local options = {}

                    for _, row in ipairs(rows) do
                        local garageId = tostring(row.garage_id or '')
                        local label = tostring(row.garage_label or ('Garage #' .. garageId))
                        local garageType = tostring(row.garage_type or 'car'):lower()

                        if garageId ~= '' and (garageType == 'car' or garageType == 'vehicle') then
                            options[#options + 1] = {
                                value = garageId,
                                label = ('%s (#%s)'):format(label, garageId)
                            }
                        end
                    end

                    if #options > 0 then
                        print(('[sb_admin] Hentede %s bilgarager fra databasen: %s'):format(#options, tableName))
                        return options
                    end
                end
            end
        end
    end

    return nil, ('Ingen kompatibel garagetabel blev fundet. Kontrollerede: %s'):format(
        #checked > 0 and table.concat(checked, ', ') or 'ingen tabeller med "garage" i navnet'
    )
end

local function garageOptionsFromExport(garages)
    local options = {}

    for key, value in pairs(garages or {}) do
        local garage = unwrapGarageData(value, key)

        if garage then
            local garageType = tostring(garage.Type or garage.type or 'car'):lower()
            local garageId = tostring(garage.Index or garage.__sbGarageId or key)

            if garageId ~= '' and (garageType == 'car' or garageType == 'vehicle') then
                options[#options + 1] = {
                    value = garageId,
                    label = ('%s (#%s)'):format(
                        tostring(garage.Label or garage.label or ('Garage #' .. garageId)),
                        garageId
                    )
                }
            end
        end
    end

    return options
end

lib.callback.register('sb_admin:server:getGiveVehicleGarages', function(source)
    if not hasPermission(source) then
        return { success = false, message = 'Du har ikke adgang til funktionen.' }
    end

    local options = {}
    local garages, exportError = getOpGaragesFromExport()

    if garages then
        options = garageOptionsFromExport(garages)
    end

    if #options == 0 then
        local databaseOptions, databaseError = getGarageOptionsFromDatabase()

        if databaseOptions then
            options = databaseOptions
        else
            print(('[sb_admin] OP Garages export-fejl: %s'):format(exportError or 'ukendt'))
            print(('[sb_admin] Garage database-fejl: %s'):format(databaseError or 'ukendt'))

            return {
                success = false,
                message = 'Garagerne kunne ikke findes automatisk. Se serverkonsollen for den fundne garagetabel.'
            }
        end
    end

    table.sort(options, function(a, b)
        return a.label:lower() < b.label:lower()
    end)

    return { success = true, garages = options }
end)

local function normalizeInventoryItems(rawItems)
    local items = {}

    for key, item in pairs(rawItems or {}) do
        if type(item) == 'table' then
            local count = tonumber(item.count or item.amount or item.quantity) or 0
            local name = tostring(item.name or key or 'unknown')

            if count > 0 then
                items[#items + 1] = {
                    name = name,
                    label = tostring(item.label or name),
                    count = count,
                    slot = tonumber(item.slot)
                }
            end
        end
    end

    table.sort(items, function(a, b)
        local left = (a.label or a.name):lower()
        local right = (b.label or b.name):lower()

        if left == right then
            return (a.slot or 0) < (b.slot or 0)
        end

        return left < right
    end)

    return items
end

lib.callback.register('sb_admin:server:getPlayerInventory', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)
    local targetPlayer = targetId and ESX.GetPlayerFromId(targetId)

    if not targetPlayer or not GetPlayerName(targetId) then
        return nil
    end

    local rawItems

    -- Brug ox_inventory, når det er aktivt. Kaldet er beskyttet, så
    -- standard ESX inventory stadig fungerer, hvis exporten ikke findes.
    if GetResourceState('ox_inventory') == 'started' then
        local ok, result = pcall(function()
            return exports.ox_inventory:GetInventoryItems(targetId)
        end)

        if ok and type(result) == 'table' then
            rawItems = result
        end
    end

    if type(rawItems) ~= 'table' then
        if targetPlayer.getInventory then
            rawItems = targetPlayer.getInventory()
        else
            rawItems = targetPlayer.inventory or {}
        end
    end

    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    return {
        id = targetId,
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        items = normalizeInventoryItems(rawItems)
    }
end)

lib.callback.register('sb_admin:server:removePlayerInventoryItem', function(source, targetId, itemName, amount, slot)
    if not hasPermission(source) then
        return { success = false, message = 'Du har ikke adgang til funktionen.' }
    end

    targetId = tonumber(targetId)
    amount = math.floor(tonumber(amount) or 0)
    slot = tonumber(slot)
    itemName = type(itemName) == 'string' and itemName or nil

    if not targetId or not itemName or itemName == '' or amount < 1 then
        return { success = false, message = 'Item eller antal er ugyldigt.' }
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not targetPlayer or not GetPlayerName(targetId) then
        return { success = false, message = 'Spilleren er ikke længere online.' }
    end

    local removed = false
    local itemLabel = itemName

    if GetResourceState('ox_inventory') == 'started' then
        local ok, inventoryItems = pcall(function()
            return exports.ox_inventory:GetInventoryItems(targetId)
        end)

        if not ok or type(inventoryItems) ~= 'table' then
            return { success = false, message = 'Spillerens inventory kunne ikke læses.' }
        end

        local available = 0
        local matchedSlot

        for key, inventoryItem in pairs(inventoryItems) do
            if type(inventoryItem) == 'table' then
                local currentSlot = tonumber(inventoryItem.slot or key)
                local currentName = tostring(inventoryItem.name or '')

                if currentName == itemName and (not slot or currentSlot == slot) then
                    available = tonumber(inventoryItem.count) or 0
                    matchedSlot = currentSlot
                    itemLabel = tostring(inventoryItem.label or itemName)
                    break
                end
            end
        end

        if available < amount then
            return {
                success = false,
                message = ('Spilleren har kun %s x %s.'):format(available, itemLabel)
            }
        end

        local removeOk, success, response = pcall(function()
            return exports.ox_inventory:RemoveItem(
                targetId,
                itemName,
                amount,
                nil,
                matchedSlot,
                false,
                true
            )
        end)

        removed = removeOk and success == true

        if not removed then
            return {
                success = false,
                message = type(response) == 'string' and response or 'Itemet kunne ikke fjernes fra ox_inventory.'
            }
        end
    else
        local inventoryItem = targetPlayer.getInventoryItem and targetPlayer.getInventoryItem(itemName)
        local available = inventoryItem and tonumber(inventoryItem.count) or 0
        itemLabel = inventoryItem and tostring(inventoryItem.label or itemName) or itemName

        if available < amount then
            return {
                success = false,
                message = ('Spilleren har kun %s x %s.'):format(available, itemLabel)
            }
        end

        if not targetPlayer.removeInventoryItem then
            return { success = false, message = 'ESX inventory understøtter ikke fjernelse af items.' }
        end

        targetPlayer.removeInventoryItem(itemName, amount)
        removed = true
    end

    if not removed then
        return { success = false, message = 'Itemet kunne ikke fjernes.' }
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local adminName = adminPlayer and adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source) or 'en administrator'

    TriggerClientEvent('sb_admin:client:inventoryItemRemoved', targetId, {
        name = itemName,
        label = itemLabel,
        amount = amount,
        adminName = adminName
    })

    return {
        success = true,
        message = ('Fjernede %s x %s fra %s.'):format(
            amount,
            itemLabel,
            targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId) or ('spiller %s'):format(targetId)
        )
    }
end)

lib.callback.register('sb_admin:server:giveVehicle', function(source, targetId, vehicleData)
    local allowed = hasPermission(source)

    if not allowed or type(vehicleData) ~= 'table' then
        return { success = false, message = 'Du har ikke adgang til funktionen.' }
    end

    targetId = tonumber(targetId)
    local targetPlayer = targetId and ESX.GetPlayerFromId(targetId)

    if not targetPlayer or not GetPlayerName(targetId) then
        return { success = false, message = 'Spilleren er ikke længere online.' }
    end

    local config = Config.GiveVehicle or {}
    local tableName = config.table or 'owned_vehicles'

    if not validSqlIdentifier(tableName) then
        return { success = false, message = 'Databaseopsætningen i config.lua er ugyldig.' }
    end

    local model = tonumber(vehicleData.model)
    local modelName = tostring(vehicleData.modelName or ''):lower():gsub('[^%w_]', '')

    if not model or model == 0 or modelName == '' then
        return { success = false, message = 'Køretøjsmodellen er ugyldig.' }
    end

    local owner = getPlayerIdentifier(targetPlayer)

    if not owner or owner == '' then
        return { success = false, message = 'Spillerens identifier kunne ikke findes.' }
    end

    local tableColumns = getTableColumns(tableName)

    if not tableColumns or not tableColumns.owner or not tableColumns.plate or not tableColumns.vehicle then
        return {
            success = false,
            message = 'owned_vehicles mangler en af kolonnerne owner, plate eller vehicle.'
        }
    end

    local garageId = tostring(vehicleData.garageId or config.defaultGarageId or '')

    if garageId == '' then
        return { success = false, message = 'Der blev ikke valgt en garage.' }
    end

    -- Garage-listen kommer fra OP Garages V3's client-export. Nogle builds
    -- eksponerer ikke getAllGarages/getGarageByIndex på serversiden, så serveren
    -- validerer i stedet inputformatet og gemmer garage-ID'et direkte.
    if not garageId:match('^%d+$') then
        return { success = false, message = 'Det valgte garage-ID er ugyldigt.' }
    end

    local plateLength = math.min(math.max(tonumber(config.plateLength) or 8, 1), 8)
    local requestedPlate = normalizePlate(vehicleData.plate, plateLength)
    local plate = requestedPlate
    local checkQuery = ('SELECT 1 FROM `%s` WHERE `plate` = ? LIMIT 1'):format(tableName)

    if plate ~= '' then
        local exists = MySQL.scalar.await(checkQuery, { plate })

        if exists then
            return { success = false, message = 'Nummerpladen findes allerede i databasen.' }
        end
    else
        for _ = 1, 25 do
            local candidate = generatePlate(config.platePrefix or 'SB', plateLength)
            local exists = MySQL.scalar.await(checkQuery, { candidate })

            if not exists then
                plate = candidate
                break
            end
        end

        if plate == '' then
            return { success = false, message = 'Der kunne ikke genereres en ledig nummerplade.' }
        end
    end

    local vehicleProperties = {
        model = model,
        plate = plate,
        fuelLevel = 100.0,
        fuel = 100.0,
        engineHealth = 1000.0,
        bodyHealth = 1000.0
    }

    local insertData = {
        owner = owner,
        plate = plate,
        vehicle = json.encode(vehicleProperties)
    }

    -- OP Garages bruger 0 som "i garage" og 1 som "ude".
    if tableColumns.stored then
        insertData.stored = 0
    end

    if tableColumns.vehicleGarage then
        insertData.vehicleGarage = tonumber(garageId) or garageId
    end

    if tableColumns.isTowedOut then
        insertData.isTowedOut = 0
    end

    if tableColumns.vehicleImpound then
        insertData.vehicleImpound = 0
    end

    if tableColumns.type then
        insertData.type = 'car'
    end

    if type(config.extraColumns) == 'table' then
        for column, value in pairs(config.extraColumns) do
            if not validSqlIdentifier(column) then
                return { success = false, message = ('Ugyldig ekstra databasekolonne: %s'):format(tostring(column)) }
            end

            if tableColumns[column] then
                insertData[column] = value
            end
        end
    end

    local columns, placeholders, values = {}, {}, {}

    for column, value in pairs(insertData) do
        columns[#columns + 1] = ('`%s`'):format(column)
        placeholders[#placeholders + 1] = '?'
        values[#values + 1] = value
    end

    local insertQuery = ('INSERT INTO `%s` (%s) VALUES (%s)'):format(
        tableName,
        table.concat(columns, ', '),
        table.concat(placeholders, ', ')
    )

    local ok, insertId = pcall(MySQL.insert.await, insertQuery, values)

    if not ok or not insertId then
        print(('[sb_admin] OP Garages vehicle insert failed for %s: %s'):format(owner, tostring(insertId)))
        return {
            success = false,
            message = 'Køretøjet kunne ikke gemmes i OP Garages. Se serverkonsollen.'
        }
    end

    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)
    local garageLabel = tostring(vehicleData.garageLabel or ('Garage #' .. garageId))
    garageLabel = garageLabel:sub(1, 100)

    TriggerClientEvent('sb_admin:client:vehicleReceived', targetId, {
        modelName = modelName,
        plate = plate,
        garage = garageLabel
    })

    return {
        success = true,
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        modelName = modelName,
        plate = plate,
        garage = garageLabel
    }
end)


AddEventHandler('playerDropped', function()
    frozenPlayers[source] = nil
end)



RegisterNetEvent('sb_admin:server:teleportToCoordinates', function(x, y, z, heading)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    if Config.AllowedGroups[group] ~= true then
        return
    end

    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)
    heading = tonumber(heading) or 0.0

    if not x or not y or not z then
        return
    end

    local settings = Config.TeleportCoordinates or {}
    local xyLimit = tonumber(settings.xyLimit) or 8000.0
    local minZ = tonumber(settings.minZ) or -250.0
    local maxZ = tonumber(settings.maxZ) or 2500.0

    if math.abs(x) > xyLimit or math.abs(y) > xyLimit then
        return
    end

    if z < minZ or z > maxZ then
        return
    end

    TriggerClientEvent('sb_admin:client:teleportToCoordinates', source, x, y, z, heading % 360.0)
end)
