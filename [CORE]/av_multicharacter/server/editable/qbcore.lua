-- All QBCore related code is here, callbacks, database, everything...
while not Core do Wait(1) end
if Config.Framework ~= "qb" then return end
print("^2Framework: ^7"..Config.Framework)

local hasDonePreloading = {}

-- Returns character identifier
function GetIdentifier(source)
    local Player = Core.Functions.GetPlayer(source)
    if Player then
        return Player.PlayerData.citizenid
    end
    return false
end

-- Add item to player
function AddItem(source, name, amount, metadata)
    dbug("AddItem(source, item, amount, metadata)", source, item, amount, json.encode(metadata))
    local Player = Core.Functions.GetPlayer(source)
    if Player then
        Player.Functions.AddItem(name, amount, false, metadata)
    end
end

-- Fetch player characters
function GetCharacters(identifier, source)
    dbug("GetCharacters() qb-core")
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
    local data = false
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

-- Returns a table with character vehicles
function GetMyVehicles(source)
    local Player = Core.Functions.GetPlayer(source)
    local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE citizenid = ?', {Player.PlayerData.citizenid})
    return result
end

-- Returns the vehicle model and mods
function GetVehicleMods(identifier,plates)
    dbug('GetVehicleMods(identifier,plates)', identifier, plates)
    local data = false
    local result = MySQL.single.await('SELECT * FROM player_vehicles WHERE citizenid = ? AND plate = ?', {identifier, plates})
    if result then
        local mods = result['mods'] and json.decode(result['mods']) or {}
        data = {model = result['hash'], mods = mods}
    end
    return data
end

-- Triggered when a character is selected
function Login(source, data)
    local src = source
    dbug("qb-core Login(source)", source)
    if Core.Player.Login(src, data.citizenid) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        print('^2[qb-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..data.citizenid..') has succesfully loaded!')
        dbug("Player loaded...")
        Core.Commands.Refresh(src)
        if Config.QBCoreApartments and not Config.PSHousing then
            dbug("Triggering apartments:client:setupSpawnUI")
            TriggerClientEvent('apartments:client:setupSpawnUI', src, data)
        else
            if Config.PSHousing then
                dbug("Triggering ps-housing:client:setupSpawnUI...")
                TriggerClientEvent('ps-housing:client:setupSpawnUI', src, data)
            else
                dbug("Triggering av_multicharacter:defaultSpawn")
                TriggerClientEvent('av_multicharacter:defaultSpawn', src, false, data)
            end
        end
        Init(src)
    end
end

function DeleteCharacter(source, data)
    dbug("qb-core DeleteCharacter(source, data)", source, data and data['citizenid'] or "null")
    if data and data['citizenid'] then
        dbug("Trigger qb-core DeleteCharacter...")
        Core.Player.DeleteCharacter(source, data['citizenid'])
    else
        warn("PlayerId", source, "tried to delete a character but data parameter is null(?)")
    end
end

function RegisterCharacter(source,data)
    local src = source
    local newData = {}
    data['gender'] = tonumber(data['sex'])
    data['sex'] = nil
    newData.cid = data.slot
    newData.charinfo = data
    if Core.Player.Login(src, false, newData) then
        repeat
            Wait(10)
        until hasDonePreloading[src]
        if Config.QBCoreApartments and not Config.PSHousing then
            local randbucket = math.random(1,999)
            SetPlayerRoutingBucket(src, randbucket)
            print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            Core.Commands.Refresh(src)
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        else
            print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            Core.Commands.Refresh(src)
            if Config.PSHousing then
                newData.citizenid = Core.Functions.GetPlayer(src).PlayerData.citizenid
                TriggerClientEvent('ps-housing:client:setupSpawnUI', src, newData)
            else
                TriggerClientEvent('av_multicharacter:defaultSpawn', src, true, data)
            end
        end
        GiveStarterItems(src)
    end
end

function Relog(source)
    Core.Player.Logout(source)
    TriggerClientEvent('av_multicharacter:init', source)
end

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
    Wait(1000)
    hasDonePreloading[Player.PlayerData.source] = true
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    hasDonePreloading[src] = false
end)