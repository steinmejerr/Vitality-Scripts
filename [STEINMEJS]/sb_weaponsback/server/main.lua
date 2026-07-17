local playerWeapons = {}

local function cleanWeapons(weapons)
    local cleaned = {}
    local count = 0

    if type(weapons) ~= 'table' then
        return cleaned
    end

    for _, entry in ipairs(weapons) do
        local weaponHash
        local placement

        if type(entry) == 'table' then
            weaponHash = tonumber(entry.hash)
            placement = entry.placement == 'front' and 'front' or 'back'
        else
            weaponHash = tonumber(entry)
            placement = 'back'
        end

        if weaponHash and Config.Weapons[weaponHash] and count < Config.MaxVisibleWeapons then
            count += 1
            cleaned[count] = {
                hash = weaponHash,
                placement = placement
            }
        end
    end

    return cleaned
end

RegisterNetEvent('sb_weaponsback:server:updateWeapons', function(weapons)
    local source = source
    local cleaned = cleanWeapons(weapons)

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
