-- All Qbox related code is here, callbacks, database, everything...
while not Core do Wait(1) end
if Config.Framework ~= "qbox" then return end
print("^2Qbox Framework^7")

-- Returns character identifier
function GetIdentifier(source)
    local Player = exports['qbx_core']:GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return false
end

-- Add item to player
function AddItem(source, name, amount, metadata)
    dbug("AddItem(source, item, amount, metadata)", source, name, amount, json.encode(metadata))
    local Player = exports['qbx_core']:GetPlayer(source)
    if Player then
        Player.Functions.AddItem(name, amount, false, metadata)
    end
end

-- Returns a table with character vehicles
function GetMyVehicles(source)
    local Player = exports['qbx_core']:GetPlayer(source)
    local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    return result
end

-- Fetch player characters
function GetCharacters(identifier, source)
    dbug("GetCharacters() qbox")
    local characters = {}
    local result = MySQL.query.await('SELECT * FROM players WHERE license = ?', {identifier})
    if result and next(result) then
        for i = 1, #result, 1 do
            local data = {}
            local charinfo = result[i]['charinfo'] and json.decode(result[i]['charinfo']) or {}
            local job = result[i]['job'] and json.decode(result[i]['job']) or {}
            data.identifier = result[i]['citizenid']
            data.firstname = charinfo['firstname']
            data.lastname = charinfo['lastname']
            data.job = job and job['label'] or "N/A"
            data.vehicle = GetVehicle(result[i]['citizenid'])
            data.slot = result[i]['cid']
            characters[i] = data
        end
    end
    return characters
end

-- Returns character skin using default qb-clothing format
function GetPlayerSkin(identifier)
    dbug("GetPlayerSkin(identifier)", identifier)
    local data = nil
    local result = MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {identifier, 1})
    if result then
        local model = result['model']
        local hash = tonumber(model) or GetHashKey(model) or Config.DefaultPed
        local skin = result['skin'] and json.decode(result['skin']) or {}
        dbug("Player Model", hash)
        data = {model = hash, skin = skin}
    end
    return data
end

-- Returns the vehicle model and mods
function GetVehicleMods(identifier,plates)
    local data = nil
    local result = MySQL.single.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {identifier, plates})
    if result then
        local mods = result['mods'] and json.decode(result['mods']) or {}
        data = {model = result['hash'], mods = mods}
    end
    return data
end

function Login(source, data)
    local src = source
    if exports.qbx_core:Login(src, data.citizenid) then
        Init(src)
        local Player = exports['qbx_core']:GetPlayer(src)
        if Player and Player.PlayerData then
            data['coords'] = Player.PlayerData.position
        end
        TriggerClientEvent('av_multicharacter:defaultSpawn', src, false, data)
    end
end

function DeleteCharacter(source, data)
    dbug("qbox DeleteCharacter(source, data)", source, data and data['citizenid'] or "null")
    exports['qbx_core']:DeleteCharacter(data.citizenid)
    Wait(1000)
    TriggerClientEvent('av_multicharacter:init',source)
end

function RegisterCharacter(source,data)
    local src = source
    local newData = {}
    data['gender'] = tonumber(data['sex'])
    data['sex'] = nil
    newData.cid = data.slot
    newData.charinfo = data
    if exports['qbx_core']:Login(src, false, newData) then
        GiveStarterItems(src)
        TriggerClientEvent('av_multicharacter:defaultSpawn', src, true, data)
    end
end

function Relog(source)
    exports['qbx_core']:Logout(source)
end

RegisterServerEvent('qbx_core:server:playerLoggedOut', function(source)
    TriggerClientEvent('av_multicharacter:init', source)
end)