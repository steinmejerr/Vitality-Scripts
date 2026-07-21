local Ox = require '@ox_core.lib.init'
local bridge = {}

---@param source integer
---@return table
function bridge.getPlayer(source)
    return Ox.GetPlayer(source)
end

---@param player table
---@return string
function bridge.getPlayerIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return integer | nil
function bridge.getSourceFromIdentifier(identifier)
    local player = Ox.GetPlayerFromFilter({ identifier = identifier })

    return player and player.source or nil
end

---@param player table
---@return string
function bridge.getPlayerName(player)
    return ('%s %s'):format(player.get('firstName'), player.get('lastName'))
end

---@param playerId integer
RegisterNetEvent('ox:playerLoaded', function(playerId)
    OnPlayerLoaded(playerId)
end)

return bridge