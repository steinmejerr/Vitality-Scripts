Config = {}
Config.Debug = false -- Prints some info in F8 and server console, useful to find possible bugs or report something
Config.Identifier = "license" -- Identifier type ID you wanna use for players, https://docs.fivem.net/docs/scripting-reference/runtimes/lua/functions/GetPlayerIdentifiers/
Config.SettingsCommand = "multicharacter" -- Command used to open the multicharacter menu, let your players to select their preferred scene and/or vehicle
Config.EditorCommand = "multi:editor" -- Opens the scene editor
Config.CoordsCommand = "multi:copy" -- Copy your current ped coords
Config.AdminGroup = {"group.admin", "group.god"} -- Groups allowed to use editor command
Config.ESXPrefix = "char" -- Only for ESX, prefix used for player identifier (prefix + slot, e.g. char1:licensexxxxx, char2:licensexxxxxx)
Config.RelogCommand = "logout" -- or false to disable it
Config.RelogGroups = {"group.admin", "group.god"} -- ACE Groups allowed to use relogcommand
Config.DefaultSpawn = {x = -1037.74, y = -2738.25, z = 20.17, heading = 329.14} -- x, y, z, heading... default spawn after character register

-- Character slots config
Config.Slots = {
    default = 2, -- The default character slots a player can own by default
    max = 3, -- Max slots a player can own, no matter if he bought them or is using VIP or whatever, X is the limit
}

-- Only for ESX, tables to wipe when a character is deleted
Config.DeleteTables = {
    --['table_name'] = "identifier_column_name",
    ['users'] = "identifier",
    ['owned_vehicles'] = "owner",
}

-- Used for debug prints, don't modify anything from here...
function dbug(...)
    if Config.Debug then print('^3[DEBUG]^7', ...) end
end

function warn(...)
    print('^1[WARNING]^7', ...)
end