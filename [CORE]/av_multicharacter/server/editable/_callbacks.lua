-- Retrieves player character list
lib.callback.register('av_multicharacter:getData', function(source)
    dbug("getData()")
    local src = source
    local identifier = GetPlayerIdentifierByType(source, Config.Identifier)
    if not identifier then
        dbug("Identifier not found for player source "..source..", kicking player from server.")
        DropPlayer(source, "We couldn't find your identifier ("..Config.Identifier.."), this is a problem on your side.")
        return {}
    end
    while not Config.Framework do Wait(5) end
    return GetCharacters(identifier, src)
end)

-- Triggered when a player registers a new character
RegisterServerEvent('av_multicharacter:register', function(data)
    local src = source
    dbug("registerCharacter", json.encode(data, { indent = true}))
    RegisterCharacter(src,data)
end)

-- Triggered when a player selects a character
RegisterServerEvent('av_multicharacter:play', function(data)
    Login(source, data)
end)

-- Triggered when a player deletes one of his characters
RegisterServerEvent('av_multicharacter:delete', function(data)
    dbug("av_multicharacter:delete")
    if not data then return end
    local src = source
    DeleteCharacter(src, data)
    Wait(1000)
    TriggerClientEvent('av_multicharacter:init',src)
end)

-- Retrieve character skin based on identifier
lib.callback.register("av_multicharacter:getSkin", function(source,identifier)
    dbug("getSkin(identifier)", identifier)
    if Config.ClothingScript == "rcore_clothing" then
        local data = exports["rcore_clothing"]:getSkinByIdentifier(identifier)
        print(json.encode(data, { indent = true}))
    end
    if Config.ClothingScript == "tgiann-clothing" then
        local result = MySQL.single.await('SELECT `model`, `skin` FROM `tgiann_skin` WHERE `citizenid` = ? LIMIT 1', {identifier})
        if result and result['model'] and result['skin'] then
            return {model = result['model'], skin = result['skin']}
        else
            return false
        end
    end
    local skin = GetPlayerSkin(identifier) or false
    return skin
end)

-- Retrieve the player slots
lib.callback.register('av_multicharacter:getSlots', function(source)
    dbug("getSlots()")
    local default = Config.Slots and Config.Slots['default'] or 3
    local extra = GetSlots(source) or 0
    dbug("slots:", default + extra)
    return (default + extra)
end)

-- Retrieve player vehicles list
lib.callback.register('av_multicharacter:getVehicleList', function(source)
    dbug("getVehicleList")
    local vehicles = GetMyVehicles(source)
    -- print(json.encode(vehicles))
    return vehicles
end)

-- Retrieve mods and model using vehicle plates
lib.callback.register('av_multicharacter:getVehicle', function(_,identifier,plates)
    dbug("getVehicleCB(identifier, plates)", identifier, plates)
    local mods = GetVehicleMods(identifier,plates)
    return mods
end)