-- All ESX related code is here, callbacks, database, everything...
while not Core do Wait(1) end
if Config.Framework ~= "esx" then return end
print("^2Framework: ^7"..Config.Framework)

local allJobs = Core.GetJobs()

-- Returns player license number without prefix license:
function GetLicense(source)
    local toRemove = 'license:'
    local license = GetPlayerIdentifierByType(source, 'license')
    return string.gsub(license, toRemove, '')
end

-- Add item to player
function AddItem(source, name, amount, metadata)
    dbug("AddItem(source, item, amount, metadata)", source, item, amount, json.encode(metadata))
    local Player = Core.GetPlayerFromId(source)
    if Player then
        Player.addInventoryItem(name, amount)
    end
end

-- Returns character identifier
function GetIdentifier(source)
    local Player = Core.GetPlayerFromId(source)
    if Player then
        return Player.getIdentifier()
    end
    return false
end

-- Returns a table with character vehicles
function GetMyVehicles(source)
    local Player = Core.GetPlayerFromId(source)
    local identifier = Player.getIdentifier()
    local result = MySQL.query.await('SELECT * FROM owned_vehicles WHERE owner = ?', { identifier })
    local vehicles = {}
    if result and next(result) then
        for k, v in pairs(result) do
            local mods = v['vehicle'] and json.decode(v['vehicle']) or {}
            if mods and mods['model'] then
                vehicles[#vehicles + 1] = {
                    vehicle = mods['model'],
                    plate = v['plate']
                }
            end
        end
    end
    return vehicles
end

-- Fetch player characters
function GetCharacters(_, source)
    local identifier = GetLicense(source)
    Core.Players[identifier] = true
    local characters = {}
    local maxSlots = Config.Slots and Config.Slots['max'] or 5
    local prefix = Config.ESXPrefix or "char"
    for i = 1, maxSlots do
        local license = prefix..''..i..':'..identifier
        local result = MySQL.single.await('SELECT * FROM `users` WHERE `identifier` = ?', { license })
        if result then
            local data = {}
            data.identifier = license
            data.firstname = result['firstname']
            data.lastname = result['lastname']
            data.job = GetJobLabel(result['job'])
            data.vehicle = GetVehicle(license)
            data.slot = i
            characters[#characters + 1] = data
        end
    end
    return characters
end

-- Returns character skin using default qb-clothing format
function GetPlayerSkin(identifier)
    local data = false
    local result = MySQL.single.await('SELECT * FROM users WHERE identifier = ?', { identifier })
    if result then
        local skin = {}
        if result['skin'] then
            skin = result['skin'] and json.decode(result['skin']) or {}
        end
        local model = skin['model'] or 'mp_m_freemode_01'
        local hash = tonumber(model) or GetHashKey(model) or Config.DefaultPed
        if skin['sex'] and tonumber(skin['sex']) == 1 then
            model = 'mp_f_freemode_01'
        end
        data = { model = hash, skin = skin }
    end
    return data
end

-- Returns the vehicle model and mods
function GetVehicleMods(identifier,plates)
    local data = false
    local result = MySQL.single.await('SELECT * FROM owned_vehicles WHERE owner = ? AND plate = ?', { identifier, plates })
    if result then
        local mods = result['vehicle'] and json.decode(result['vehicle']) or {}
        local model = mods['model'] and tonumber(mods['model']) or `coquette4`
        return { model = model, mods = mods }
    end
    return data
end

-- Triggered when a character is selected
function Login(source, data)
    Init(source)
    TriggerEvent('esx:onPlayerJoined', source, Config.ESXPrefix .. data.slot)
    Core.Players[GetLicense(source)] = true
end

function DeleteCharacter(source, data)
    local src = source
    local identifier = GetLicense(src)
    identifier = Config.ESXPrefix .. data.slot .. ':' .. identifier
    local query = 'DELETE FROM %s WHERE %s = ?'
    local queries = {}
    for table, column in pairs(Config.DeleteTables) do
        queries[#queries+1] = { query = query:format(table, column), values = { identifier } }
    end
    MySQL.transaction(queries, function(result)
        if result then
            print(('[^2INFO^7] Player ^5%s %s^7 has deleted a character ^5(%s)^7'):format(GetPlayerName(src), src, identifier))
            Wait(50)
            TriggerClientEvent('av_multicharacter:init', src)
        else
            error('\n^1Transaction failed while trying to delete ' .. identifier .. '^0')
        end
    end)
end

function RegisterCharacter(source,data)
    local sex = "m"
    if data.sex and tonumber(data.sex) == 1 then sex = "f" end
    data.dateofbirth = FormatDate(data.birthdate)
    data.sex = sex
    data.height = "180" -- No one uses height (?)
    TriggerEvent('esx:onPlayerJoined', source, Config.ESXPrefix .. data.slot, data)
    Wait(1000)
    TriggerClientEvent('av_multicharacter:defaultSpawn', source, data)
    Init(source)
    GiveStarterItems(source)
end

function Relog(source)
    TriggerEvent("esx:playerLogout", source)
    Wait(1000)
    TriggerClientEvent("av_multicharacter:init", source)
end

function FormatDate(birthdate)
    dbug("FormatDate(birthdate)", birthdate)
    local year, month, day = birthdate:match("(%d%d%d%d)-(%d%d)-(%d%d)")
    if year and month and day then
        local res = day .. "/" .. month .. "/" .. year
        dbug("Result", res)
        return res
    else
        warn("Invalid date format")
    end
    return birthdate
end

function GetJobLabel(name)
    if not Core then
        Core = exports['es_extended']:getSharedObject()
        return name
    end
    local jobInfo = allJobs and allJobs[name] or false
    if not jobInfo then
        allJobs = Core.GetJobs()
        jobInfo = allJobs and allJobs[name] or false
    end
    if jobInfo and jobInfo['label'] then
        return jobInfo['label']
    end
    return name
end