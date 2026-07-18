RegisterNetEvent('av_multicharacter:defaultSpawn', function(isNew, data, blockSpawn)
    if Config.Framework == "esx" then return end -- use esx:playerLoaded
    dbug('defaultSpawn(isNew, blockSpawn?)', isNew, blockSpawn)
    DoScreenFadeOut(500)
    Wait(2000)
    if Config.Framework == "qbox" then
        qboxStart(isNew, data, blockSpawn)
        return
    end
    if Config.Framework == "qb" then
        Weather(false)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
        TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
        dbug('qbcore events triggered')
        SetEntityVisible(PlayerPedId(), true, false)
        FreezeEntityPosition(PlayerPedId(),false)
        Wait(2000)
        if isNew then
            dbug('qb isNew')
            SetEntityCoords(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, true, false, false, true)
            SetEntityHeading(PlayerPedId(), Config.DefaultSpawn.heading)
            TriggerEvent('qb-clothes:client:CreateFirstCharacter')
        else
            dbug('qb not new')
            if Config.CustomSpawn then
                CustomSpawn(data)
            else
                TriggerServerEvent('av_realestate:spawn')
                Core.Functions.GetPlayerData(function(pd)
                    Wait(1000)
                    SetEntityCoords(PlayerPedId(), pd.position.x, pd.position.y, pd.position.z, true, false, false, true)
                    dbug('SetCoords:',pd.position.x, pd.position.y, pd.position.z)
                end)
            end
        end
        Wait(2000)
        DoScreenFadeIn(250)
        dbug('Player spawned')
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData, isNew, skin)
    dbug('esx:playerLoaded')
    FreezeEntityPosition(PlayerPedId(),false)
    SetEntityVisible(PlayerPedId(), true, false)
    Weather(false)
    if isNew or not skin or #skin == 1 then
        dbug('ESX isNew')
        local finished = false
        dbug('playerData.sex', playerData.sex)
        skin = DefaultSkin[playerData.sex]
        skin.sex = playerData.sex == "m" and 0 or 1
        local model = skin.sex == 0 and `mp_m_freemode_01` or `mp_f_freemode_01`
        dbug('model', model)
        lib.requestModel(model, 30000)
        dbug('model loaded')
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
        dbug("SetEntityCoords(x,y,z,heading)", Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, Config.DefaultSpawn.heading)
        RequestCollisionAtCoord(Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z)
        SetEntityCoordsNoOffset(PlayerPedId(), Config.DefaultSpawn.x, Config.DefaultSpawn.y, Config.DefaultSpawn.z, true, true, false)
        SetEntityHeading(PlayerPedId(), Config.DefaultSpawn.heading)
        Wait(1000)
        if IsScreenFadedOut() then
            DoScreenFadeIn(250)
        end
        TriggerEvent('skinchanger:loadSkin', skin, function()
            dbug('skinchanger:loadSkin')
            SetPedAoBlobRendering(cache.ped, true)
            ResetEntityAlpha(cache.ped)
            TriggerEvent('esx_skin:openSaveableMenu', function()
                finished = true end, function() finished = true
            end)
        end)
        repeat Wait(200) until finished
    end
    FreezeEntityPosition(cache.ped, false)
    if not isNew then
        local spawn = playerData and playerData.coords or Config.DefaultSpawn
        RequestCollisionAtCoord(spawn.x, spawn.y, spawn.z)
        SetEntityCoordsNoOffset(cache.ped, spawn.x, spawn.y, spawn.z, true, true, false)
        SetEntityHeading(cache.ped, spawn.heading)
        TriggerEvent('skinchanger:loadSkin', skin or charactersList[currentSlot]['clothes']['skin']) 
    end
    Wait(400)
    if IsScreenFadedOut() then
        DoScreenFadeIn(250)
    end
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned')
    TriggerEvent('esx:restoreLoadout')
    dbug('esx:playerLoaded finished')
end)

--Here you can trigger your custom spawn script, this example is for qb-spawn only
function CustomSpawn(data)
    dbug("CustomSpawn()")
--    TriggerEvent('qb-spawn:client:openUI',true)
end