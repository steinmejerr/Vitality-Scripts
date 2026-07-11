local ESX = exports['es_extended']:getSharedObject()

lib.callback.register('sb_admin:server:hasPermission', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return false
    end

    local group = xPlayer.getGroup and xPlayer.getGroup() or xPlayer.group

    return Config.AllowedGroups[group] == true, group
end)
