function qboxStart(isNew,data,blockSpawn)
    dbug("qboxStart(isNew,data,blockSpawn?)", isNew, data and "yes" or "no", blockSpawn)
    Weather(false)
    SetEntityVisible(cache.ped, true, false)
    FreezeEntityPosition(cache.ped,false)
    if isNew and Config.StartingApartment and (GetResourceState('qbx_apartments'):find('start') or GetResourceState('qbx_properties'):find('start')) then
        dbug("qbx_apartments...")
        TriggerEvent('apartments:client:setupSpawnUI', data.citizenid)
    elseif GetResourceState('qbx_spawn'):find('start') then
        dbug("qbx_spawn...")
        TriggerEvent('qb-spawn:client:setupSpawns', data.citizenid)
        TriggerEvent('qb-spawn:client:openUI', true)
    else
        dbug("Using normal spawn")
        if isNew then
            SetEntityCoords(cache.ped, Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, true, false, false, true)
            SetEntityHeading(cache.ped, Config.DefaultSpawn.heading)
            Wait(500)
            DoScreenFadeIn(250)
            while not IsScreenFadedIn() do
                Wait(0)
            end
            dbug("Player is new, trigger qb-clothes:client:CreateFirstCharacter")
            if not blockSpawn then
                TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
                TriggerEvent('QBCore:Client:OnPlayerLoaded')
                TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
                TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
                TriggerEvent('qb-clothes:client:CreateFirstCharacter')
            else
                TriggerEvent('apartments:client:setupSpawnUI')
                dbug("Apartment selection should be rendered now")
            end
        else
            dbug("Player not new, load old position")
            pcall(function() exports.spawnmanager:spawnPlayer({
                x = data['coords'] and data['coords'].x or Config.DefaultSpawn.x,
                y = data['coords'] and data['coords'].y or Config.DefaultSpawn.y,
                z = data['coords'] and data['coords'].z or Config.DefaultSpawn.z,
                heading = data['coords'] and data['coords'].w or Config.DefaultSpawn.heading
            }) end)
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
            Wait(500)
            DoScreenFadeIn(250)
            while not IsScreenFadedIn() do
                Wait(0)
            end
        end
    end
end