if Config.Framework ~= 'esx' then return end

ESX = exports["es_extended"]:getSharedObject()

RegisterCallback = ESX.RegisterServerCallback
CreateUsableItem = ESX.RegisterUsableItem

function ShowNotification(src, text, notifyType)
    TriggerClientEvent('esx:showNotification', src, text)
end

function GetPlayerFromId(playerId)
    return ESX.GetPlayerFromId(playerId)
end

function GetPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function GetSource(xPlayer)
    return xPlayer.source
end

function GetIdentifier(xPlayer)
    return xPlayer.identifier
end

function GetCorePlayers()
    return ESX.GetPlayers()
end

function IsAdmin(playerId)
    local xPlayer = GetPlayerFromId(playerId)
    local group = xPlayer.getGroup()
    return Config.AdminGroups[group]
end

function GetCharName(identifier)
    local xTarget = GetPlayerFromIdentifier(identifier)
    if xTarget then return xTarget.getName() end

	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users where identifier = ?', {identifier})
    local name = ('%s %s'):format(result?[1]?.firstname, result?[1]?.lastname)

    return name
end

function GetJob(xPlayer)
    return xPlayer?.job
end

function GetJobName(xPlayer)
    return xPlayer?.job?.name
end

function GetJobGrade(xPlayer)
    return xPlayer?.job?.grade
end

function SetJob(xPlayer, job, grade)
    xPlayer.setJob(job, grade)
end

function GetAccountMoney(xPlayer, account)
    return xPlayer.getAccount(account).money
end

function AddAccountMoney(xPlayer, account, amount)
    xPlayer.addAccountMoney(account, amount)
end

function RemoveAccountMoney(xPlayer, account, amount)
    xPlayer.removeAccountMoney(account, amount)
end

function GetItemAmount(xPlayer, item)
    if item == 'money' then
        return GetAccountMoney(xPlayer, item)
    end

    if Config.Inventory == 'default' and string.upper(string.sub(item, 0, 7)) == 'WEAPON_' then
        local has = xPlayer.getWeapon(item)
        return has
    end

    local xItem = xPlayer.getInventoryItem(item)
    return xItem?.count or xItem?.amount or 0
end

function AddItem(xPlayer, item, amount, metadata)
    if item == 'money' then
        AddAccountMoney(xPlayer, item, amount)
        return
    end

    if Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(GetSource(xPlayer), item, amount, metadata)
        return
    end

    if Config.Inventory == 'quasar' then
        exports['qs-inventory']:AddItem(GetSource(xPlayer), item, amount, nil, metadata)
        return
    end

    if Config.Inventory == 'default' and string.upper(string.sub(item, 0, 7)) == 'WEAPON_' then
        xPlayer.addWeapon(item, amount)
        return
    end

    xPlayer.addInventoryItem(item, amount)
end

function RemoveItem(xPlayer, item, amount)
    if item == 'money' then
        RemoveAccountMoney(xPlayer, item, amount)
        return
    end

    if Config.Inventory == 'default' and string.upper(string.sub(item, 0, 7)) == 'WEAPON_' then
        xPlayer.removeWeapon(item, amount)
        return
    end

    xPlayer.removeInventoryItem(item, amount)
end

function GetItemLabel(item)
    if Config.Inventory == 'default' and string.upper(string.sub(item, 0, 7)) == 'WEAPON_' then
        return ESX.GetWeaponLabel(item) or item
    end

    return ESX.GetItemLabel(item) or item
end

function GetPlayerInventory(playerId)
    local xPlayer = GetPlayerFromId(playerId)
    local inventory = {}

    local playerItems = Config.Inventory == 'quasar' and exports['qs-inventory']:GetInventory(playerId) or xPlayer.inventory

    for _,v in pairs(playerItems) do
        local amount = v.count or v.amount or 0
        if amount > 0 then
            inventory[#inventory+1] = {name = v.name, label = GetItemLabel(v.name), amount = amount, metadata = v.metadata or v.info}
        end
    end

    if Config.Inventory ~= 'default' then return inventory end

    for _,v in pairs(xPlayer.loadout) do
        inventory[#inventory+1] = {name = v.name, amount = v.ammo}
    end

    return inventory
end

function GetPlayerJailItems(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_items FROM users where identifier = ?', {identifier})

    return json.decode(result[1]?.jail_items) or {}
end

function UpdatePlayerJailItems(identifier, items)
    items = items and json.encode(items) or nil
    local data = MySQL.Sync.fetchAll('UPDATE users SET jail_items = ? where identifier = ?', {items, identifier})
    return type(data) == 'table' and data.affectedRows > 0
end

function UpdatePlayerJailTime(identifier, jailTime, jailType, unjail)
    if Config.DebugMode then print('UpdatePlayerJailTime', identifier, jailTime, jailType, unjail) end
    local query = (unjail or jailType) and 'UPDATE users SET jail_time = ?, jail_type = ? WHERE identifier = ?' or 'UPDATE users SET jail_time = ? WHERE identifier = ?'
    if Config.DebugMode then print('UpdatePlayerJailTime', query) end
    local values = (unjail or jailType) and {jailTime, jailType, identifier} or {jailTime, identifier}
    if Config.DebugMode then print('UpdatePlayerJailTime', json.encode(values)) end
    MySQL.Async.execute(query, values)
end

function GetJailedPlayers()
	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname, identifier, jail_time, jail_type, jail_cell FROM users WHERE jail_type IS NOT NULL', {})
    return result
end

function GetPlayerJailTime(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_type, jail_time FROM users WHERE identifier = ?', {identifier})
    return result[1]
end

function GetPlayerJailCell(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_cell FROM users WHERE identifier = ?', {identifier})
    return result[1]?.jail_cell
end

function SetPlayerJailCell(identifier, cellIndex)
	MySQL.Sync.fetchAll('UPDATE users SET jail_cell = ? WHERE identifier = ?', {cellIndex, identifier})
end

function GetPlayerJailCellItems(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_cell_items FROM users where identifier = ?', {identifier})

    if not result[1]?.jail_cell_items then return {} end

    local items = {}
    local data = json.decode(result[1].jail_cell_items)

    for _,v in pairs(data) do
        local label = v.name == 'money' and _U('money') or v.name == 'black_money' and _U('black_money') or GetItemLabel(v.name)
        items[#items+1] = {label = label, name = v.name, amount = v.amount}
    end

    return items
end

function SetPlayerJailCellItems(identifier, items)
    items = items and json.encode(items) or nil
	MySQL.Sync.fetchAll('UPDATE users SET jail_cell_items = ? WHERE identifier = ?', {items, identifier})
end

RegisterCallback('tk_jail:getItemLabel', function(src, cb, item)
	cb(GetItemLabel(item))
end)

RegisterNetEvent('esx:playerLogout', function(playerId)
    PlayerLogout(playerId)
end)

CreateThread(function()
    repeat Wait(100) until ESX

    frameworkLoaded = true
end)