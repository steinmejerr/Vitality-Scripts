local bridge = {}

local ESX = exports.es_extended:getSharedObject()

---@param source integer
---@return table
function bridge.getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

---@param player table
---@return string
function bridge.getPlayerIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return integer | false
function bridge.getSourceFromIdentifier(identifier)
    local player = ESX.GetPlayerFromIdentifier(identifier)

    return player and player.source or false
end

---@param player table
---@return string
function bridge.getPlayerName(player)
    return player.getName()
end

---@param player number
RegisterNetEvent('esx:playerLoaded', function(player)
    OnPlayerLoaded(player)
end)

return bridge