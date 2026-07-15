local playerWeapons = {}

RegisterNetEvent('sb_weaponsback:server:updateWeapons', function(weapons)
    local source = source

    if type(weapons) ~= 'table' then
        return
    end

    local cleaned = {}
    local count = 0

    for _, weaponHash in ipairs(weapons) do
        weaponHash = tonumber(weaponHash)

        if weaponHash and Config.Weapons[weaponHash] and count < Config.MaxVisibleWeapons then
            count += 1
            cleaned[count] = weaponHash
        end
    end

    playerWeapons[source] = cleaned
    TriggerClientEvent('sb_weaponsback:client:updatePlayerWeapons', -1, source, cleaned)
end)

RegisterNetEvent('sb_weaponsback:server:requestSync', function()
    TriggerClientEvent('sb_weaponsback:client:fullSync', source, playerWeapons)
end)

AddEventHandler('playerDropped', function()
    local source = source
    playerWeapons[source] = nil
    TriggerClientEvent('sb_weaponsback:client:removePlayer', -1, source)
end)
