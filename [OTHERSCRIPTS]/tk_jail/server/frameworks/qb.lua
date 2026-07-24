if Config.Framework ~= 'qb' then return end

QBCore = exports['qb-core']:GetCoreObject()

RegisterCallback = QBCore.Functions.CreateCallback
CreateUsableItem = QBCore.Functions.CreateUseableItem

function ShowNotification(src, text, notifyType)
    if notifyType == 'inform' then notifyType = 'primary' end
    TriggerClientEvent('QBCore:Notify', src, text, notifyType)
end

function GetPlayerFromId(playerId)
    return QBCore.Functions.GetPlayer(playerId)
end

function GetPlayerFromIdentifier(identifier)
    return QBCore.Functions.GetPlayerByCitizenId(identifier)
end

function GetSource(player)
    return player.PlayerData.source
end

function GetIdentifier(player)
    return player.PlayerData.citizenid
end

function GetCorePlayers()
    return QBCore.Functions.GetQBPlayers()
end

function IsAdmin(playerId)
    if Config.DebugMode then print('checking if player is admin', playerId) end
    for k in pairs(Config.AdminGroups) do
        if Config.DebugMode then print('IsAdmin', k, QBCore.Functions.HasPermission(playerId, k)) end
        if QBCore.Functions.HasPermission(playerId, k) then
            if Config.DebugMode then print('player is an admin') end
            return true
        end
    end

    if Config.DebugMode then print('player is not an admin') end
    return
end

function GetCharName(identifier)
    local targetPlayer = GetPlayerFromIdentifier(identifier)
    if targetPlayer then
        local name = ('%s %s'):format(targetPlayer.PlayerData.charinfo.firstname, targetPlayer.PlayerData.charinfo.lastname)
        return name
    end

	local result = MySQL.Sync.fetchAll('SELECT charinfo FROM players where citizenid = ?', {identifier})
    local charinfo = json.decode(result?[1]?.charinfo)
    local name = ('%s %s'):format(charinfo?.firstname, charinfo?.lastname)

    return name
end

function GetJob(player)
    return player.PlayerData.job
end

function GetJobName(player)
    return player.PlayerData.job.name
end

function GetJobGrade(player)
    return player.PlayerData.job.grade.level
end

function SetJob(player, job, grade)
    player.Functions.SetJob(job, grade)
end

function GetAccountMoney(player, account)
    if account == 'money' then account = 'cash' end

    return player.Functions.GetMoney(account)
end

function AddAccountMoney(player, account, amount)
    if account == 'money' then account = 'cash' end

    player.Functions.AddMoney(account, amount)
end

function RemoveAccountMoney(player, account, amount)
    if account == 'money' then account = 'cash' end

    player.Functions.RemoveMoney(account, amount)
end

function GetItemAmount(player, item)
    if item == 'money' then
        return GetAccountMoney(player, item)
    end

    local invItem = player.Functions.GetItemByName(item)
    return invItem?.amount or invItem?.count or 0
end

function AddItem(player, item, amount, metadata)
    if item == 'money' then
        return AddAccountMoney(player, item, amount)
    end

    if Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(GetSource(player), item, amount, metadata)
        return
    end

    if Config.Inventory == 'quasar' then
        exports['qs-inventory']:AddItem(GetSource(player), item, amount, nil, metadata)
        return
    end

    player.Functions.AddItem(item, amount, nil, metadata)
    TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], 'add')
end

function RemoveItem(player, item, amount)
    if item == 'money' then
        return RemoveAccountMoney(player, item, amount)
    end

    player.Functions.RemoveItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', player.PlayerData.source, QBCore.Shared.Items[item], 'remove')
end

function GetItemLabel(item)
    return QBCore.Shared.Items?[string.lower(item)]?.label or item
end

function GetPlayerInventory(playerId)
    local player = GetPlayerFromId(playerId)
    local inventory = {}

    local playerItems = Config.Inventory == 'quasar' and exports['qs-inventory']:GetInventory(playerId) or player.PlayerData.items

    for _,v in pairs(playerItems) do
        local amount = v.count or v.amount or 0
        if amount > 0 then
            inventory[#inventory+1] = {name = v.name, label = GetItemLabel(v.name), amount = amount, metadata = v.metadata or v.info}
        end
    end

    return inventory
end

function GetPlayerJailItems(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_items FROM players where citizenid = ?', {identifier})

    return result[1]?.jail_items and json.decode(result[1]?.jail_items) or {}
end

function UpdatePlayerJailItems(identifier, items)
    items = items and json.encode(items) or nil
	local data = MySQL.Sync.fetchAll('UPDATE players SET jail_items = ? where citizenid = ?', {items, identifier})
    return type(data) == 'table' and data.affectedRows > 0
end

function UpdatePlayerJailTime(identifier, jailTime, jailType, unjail)
    if Config.DebugMode then print('UpdatePlayerJailTime', identifier, jailTime, jailType, unjail) end
    local query = (unjail or jailType) and 'UPDATE players SET jail_time = ?, jail_type = ? WHERE citizenid = ?' or 'UPDATE players SET jail_time = ? WHERE citizenid = ?'
    if Config.DebugMode then print('UpdatePlayerJailTime', query) end
    local values = (unjail or jailType) and {jailTime, jailType, identifier} or {jailTime, identifier}
    if Config.DebugMode then print('UpdatePlayerJailTime', json.encode(values)) end
    MySQL.Async.execute(query, values)
end

function GetJailedPlayers()
	local result = MySQL.Sync.fetchAll('SELECT citizenid, jail_time, jail_type, jail_cell FROM players WHERE jail_type IS NOT NULL', {})
    return result
end

function GetPlayerJailTime(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_type, jail_time FROM players WHERE citizenid = ?', {identifier})
    return result[1]
end

function GetPlayerJailCell(identifier)
	local result = MySQL.Sync.fetchAll('SELECT jail_cell FROM players WHERE citizenid = ?', {identifier})
    return result[1]?.jail_cell
end

function SetPlayerJailCell(identifier, cellIndex)
	MySQL.Sync.fetchAll('UPDATE players SET jail_cell = ? WHERE citizenid = ?', {cellIndex, identifier})
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(playerId)
    PlayerLogout(playerId)
end)

CreateThread(function()
    repeat Wait(100) until QBCore

    frameworkLoaded = true
end)