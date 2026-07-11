local ESX = exports['es_extended']:getSharedObject()
local frozenPlayers = {}

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

lib.callback.register('sb_admin:server:sendAnnouncement', function(source, message)
    local allowed = hasPermission(source)

    if not allowed then
        return false
    end

    message = tostring(message or '')
    message = message:gsub('^%s+', ''):gsub('%s+$', '')

    local maxLength = (Config.Announcement and Config.Announcement.maxLength) or 300

    if message == '' or #message > maxLength then
        return false
    end

    TriggerClientEvent('sb_admin:client:showAnnouncement', -1, {
        message = message
    })

    return true
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
        group = group,
        frozen = frozenPlayers[targetId] == true
    }
end)


lib.callback.register('sb_admin:server:gotoPlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not targetPlayer then
        return nil
    end

    local targetPed = GetPlayerPed(targetId)

    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        return nil
    end

    local coords = GetEntityCoords(targetPed)
    local heading = GetEntityHeading(targetPed)
    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    return {
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading
    }
end)

lib.callback.register('sb_admin:server:bringPlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local adminPed = GetPlayerPed(source)

    if not adminPed or adminPed == 0 or not DoesEntityExist(adminPed) then
        return nil
    end

    local coords = GetEntityCoords(adminPed)
    local heading = GetEntityHeading(adminPed)
    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    TriggerClientEvent('sb_admin:client:bringToAdmin', targetId, {
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = heading,
        adminName = adminName or GetPlayerName(source) or 'en administrator'
    })

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId)
    }
end)

lib.callback.register('sb_admin:server:revivePlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    frozenPlayers[targetId] = nil

    -- Piotreq Ambulance Job v2 har sin egen death-state.
    -- Derfor skal revive gå gennem ambulancejobbets officielle client-event.
    TriggerClientEvent('p_ambulancejob/client/death/revive', targetId)

    -- Vores egen event bruges kun til beskeden og til at sikre,
    -- at en eventuel admin-freeze bliver fjernet.
    TriggerClientEvent('sb_admin:client:reviveNotification', targetId, adminName or 'en administrator')

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId)
    }
end)

lib.callback.register('sb_admin:server:toggleFreezePlayer', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or not GetPlayerName(targetId) then
        return nil
    end

    local adminPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = ESX.GetPlayerFromId(targetId)

    if not adminPlayer or not targetPlayer then
        return nil
    end

    local frozen = frozenPlayers[targetId] ~= true
    frozenPlayers[targetId] = frozen or nil

    local adminName = adminPlayer.getName and adminPlayer.getName() or GetPlayerName(source)
    local targetName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    TriggerClientEvent('sb_admin:client:setFrozen', targetId, frozen, adminName or 'en administrator')

    return {
        name = targetName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        frozen = frozen
    }
end)


lib.callback.register('sb_admin:server:getSpectateTarget', function(source, targetId)
    local allowed = hasPermission(source)

    if not allowed then
        return nil
    end

    targetId = tonumber(targetId)

    if not targetId or targetId == source or not GetPlayerName(targetId) then
        return nil
    end

    local targetPlayer = ESX.GetPlayerFromId(targetId)
    local targetPed = GetPlayerPed(targetId)

    if not targetPlayer or not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        return nil
    end

    local coords = GetEntityCoords(targetPed)
    local playerName = targetPlayer.getName and targetPlayer.getName() or GetPlayerName(targetId)

    return {
        name = playerName or GetPlayerName(targetId) or ('Spiller %s'):format(targetId),
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    }
end)


AddEventHandler('playerDropped', function()
    frozenPlayers[source] = nil
end)



RegisterNetEvent('sb_admin:server:teleportToCoordinates', function(x, y, z, heading)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return
    end

    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group
    if Config.AllowedGroups[group] ~= true then
        return
    end

    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)
    heading = tonumber(heading) or 0.0

    if not x or not y or not z then
        return
    end

    local settings = Config.TeleportCoordinates or {}
    local xyLimit = tonumber(settings.xyLimit) or 8000.0
    local minZ = tonumber(settings.minZ) or -250.0
    local maxZ = tonumber(settings.maxZ) or 2500.0

    if math.abs(x) > xyLimit or math.abs(y) > xyLimit then
        return
    end

    if z < minZ or z > maxZ then
        return
    end

    TriggerClientEvent('sb_admin:client:teleportToCoordinates', source, x, y, z, heading % 360.0)
end)
