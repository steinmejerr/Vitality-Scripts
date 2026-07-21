local bridge = {}

---@param source integer
---@return table
function bridge.getPlayer(source)
    return exports.ND_Core:getPlayer(source)
end

---@param player table
---@return string
function bridge.getPlayerIdentifier(player)
    return player.identifier
end

---@param identifier string
---@return integer | false
function bridge.getSourceFromIdentifier(identifier)
    local players = exports.NDCore:getPlayers()

    for _, info in pairs(players) do
        if info.id == identifier then
            return info.source
        end
    end

    return false
end

---@param player table
---@return string
function bridge.getPlayerName(player)
    return player.fullname
end


AddEventHandler('ND:characterLoaded', function(character)
    OnPlayerLoaded(character.source)
end)

return bridge