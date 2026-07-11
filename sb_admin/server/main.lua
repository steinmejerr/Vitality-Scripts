local function hasAdminPermission(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        return false
    end

    local group = xPlayer.getGroup()
    return Config.AdminGroups[group] == true
end

lib.callback.register('sb_admin:server:hasPermission', function(source)
    return hasAdminPermission(source)
end)
