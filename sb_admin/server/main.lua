local ESX = exports['es_extended']:getSharedObject()

local function getPlayerGroup(xPlayer)
    if not xPlayer then
        return nil
    end

    if xPlayer.getGroup then
        return xPlayer.getGroup()
    end

    return xPlayer.group
end

local function hasPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local group = getPlayerGroup(xPlayer)

    return xPlayer ~= nil and Config.AllowedGroups[group] == true, group
end

lib.callback.register('sb_admin:server:hasPermission', function(source)
    return hasPermission(source)
end)

lib.callback.register('sb_admin:server:getPlayers', function(source)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        local serverId = tonumber(playerId)
        local xPlayer = ESX.GetPlayerFromId(serverId)

        if xPlayer then
            local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job or {}
            local group = getPlayerGroup(xPlayer) or 'user'
            local playerName = xPlayer.getName and xPlayer.getName() or GetPlayerName(serverId)

            players[#players + 1] = {
                id = serverId,
                name = playerName or GetPlayerName(serverId) or ('Spiller %s'):format(serverId),
                ping = GetPlayerPing(serverId),
                job = job.label or job.name or 'Ukendt',
                jobGrade = job.grade_label or tostring(job.grade or 0),
                group = group
            }
        end
    end

    table.sort(players, function(a, b)
        return a.id < b.id
    end)

    return players
end)


lib.callback.register('sb_admin:server:getPlayerDetails', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local xPlayer = ESX.GetPlayerFromId(targetId)

    if not xPlayer then
        return nil
    end

    local job = xPlayer.getJob and xPlayer.getJob() or xPlayer.job or {}
    local group = getPlayerGroup(xPlayer) or 'user'
    local playerName = xPlayer.getName and xPlayer.getName() or GetPlayerName(targetId)

    return {
        id = targetId,
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        ping = GetPlayerPing(targetId),
        job = job.label or job.name or 'Ukendt',
        jobGrade = job.grade_label or tostring(job.grade or 0),
        group = group
    }
end)
