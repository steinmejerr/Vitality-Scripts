local menuOpen = false
local selectedIndex = 1
local currentMenu = 'main'
local menuItems = {}
local playerRefreshToken = 0
local selectedPlayerId = nil
local selectedPlayerListIndex = 1
local selectedPlayerName = nil
local spectating = false
local spectateTargetId = nil
local spectateReturn = nil
local noclipEnabled = false
local noclipEntity = nil
local godmodeEnabled = false
local invisibilityEnabled = false
local invisibleVehicle = nil
local returnPosition = nil

local function notify(description, notifyType)
    lib.notify({
        title = 'SB Admin',
        description = description,
        type = notifyType or 'inform',
        position = Config.Notify.position,
        duration = Config.Notify.duration
    })
end

local function getMainMenuItems()
    return {
        {
            action = 'players',
            label = 'Spillere',
            description = 'Se alle spillere, der er online på serveren.',
            icon = 'players'
        },
        {
            action = 'toggleNoclip',
            label = noclipEnabled and 'Deaktivér noclip' or 'Aktivér noclip',
            description = noclipEnabled
                and 'Slå fri bevægelse fra og vend tilbage til normal styring.'
                or 'Flyv frit i den retning, kameraet peger.',
            icon = 'noclip'
        },
        {
            action = 'toggleGodmode',
            label = godmodeEnabled and 'Deaktivér godmode' or 'Aktivér godmode',
            description = godmodeEnabled
                and 'Slå usårlighed fra og modtag skade normalt igen.'
                or 'Gør din karakter usårlig over for skade.',
            icon = 'godmode'
        },
        {
            action = 'toggleInvisibility',
            label = invisibilityEnabled and 'Deaktivér usynlighed' or 'Aktivér usynlighed',
            description = invisibilityEnabled
                and 'Gør din karakter og dit køretøj synligt igen.'
                or 'Skjul din karakter og dit nuværende køretøj.',
            icon = 'invisibility'
        },
        {
            action = 'teleportWaypoint',
            label = 'Teleportér til waypoint',
            description = 'Teleportér til din markering på kortet.',
            icon = 'waypoint'
        },
        {
            action = 'returnPosition',
            label = 'Returnér',
            description = returnPosition
                and 'Teleportér tilbage til din senest gemte position.'
                or 'Der er endnu ikke gemt en tidligere position.',
            icon = 'return'
        }
    }
end

local function getMenuTitle()
    if currentMenu == 'players' then
        return 'Spillere'
    end

    if currentMenu == 'playerDetails' then
        return selectedPlayerName or 'Spilleroplysninger'
    end

    return 'Adminmenu'
end

local function sendMenuState()
    SendNUIMessage({
        action = 'setMenu',
        visible = menuOpen,
        title = getMenuTitle(),
        selectedIndex = selectedIndex,
        items = menuItems
    })
end

local function setMenu(menuName, items, preferredIndex)
    currentMenu = menuName
    menuItems = items or {}

    if #menuItems == 0 then
        selectedIndex = 1
    else
        selectedIndex = math.min(math.max(preferredIndex or 1, 1), #menuItems)
    end

    sendMenuState()
end

local function closeMenu()
    if not menuOpen then
        return
    end

    menuOpen = false
    currentMenu = 'main'
    selectedIndex = 1
    menuItems = {}
    playerRefreshToken = playerRefreshToken + 1
    selectedPlayerId = nil
    selectedPlayerName = nil
    selectedPlayerListIndex = 1

    SendNUIMessage({
        action = 'close'
    })
end

local function buildPlayerItems(players)
    local items = {}

    for _, player in ipairs(players or {}) do
        items[#items + 1] = {
            action = 'player',
            playerId = player.id,
            label = ('[%s] %s'):format(player.id, player.name),
            description = ('%s - %s | %sms | %s'):format(
                player.job,
                player.jobGrade,
                player.ping,
                player.group
            ),
            icon = 'player'
        }
    end

    if #items == 0 then
        items[1] = {
            label = 'Ingen spillere online',
            description = 'Spillerlisten er tom.',
            icon = 'player',
            disabled = true
        }
    end

    return items
end

local function refreshPlayers(keepSelection)
    if not menuOpen or currentMenu ~= 'players' then
        return false
    end

    local players = lib.callback.await('sb_admin:server:getPlayers', false)

    if not players then
        notify('Du har ikke længere adgang til adminmenuen.', 'error')
        closeMenu()
        return false
    end

    local previousPlayerId
    local previousItem = menuItems[selectedIndex]

    if keepSelection and previousItem then
        previousPlayerId = previousItem.playerId
    end

    local newItems = buildPlayerItems(players)
    local newIndex = 1

    if previousPlayerId then
        for index, item in ipairs(newItems) do
            if item.playerId == previousPlayerId then
                newIndex = index
                break
            end
        end
    elseif keepSelection then
        newIndex = math.min(selectedIndex, #newItems)
    end

    setMenu('players', newItems, newIndex)
    return true
end


local openPlayerMenu

local function buildPlayerDetailItems(player)
    return {
        {
            action = 'gotoPlayer',
            playerId = player.id,
            label = 'Gå til spiller',
            description = 'Teleportér hen til den valgte spiller.',
            icon = 'location'
        },
        {
            action = 'bringPlayer',
            playerId = player.id,
            label = 'Bring spiller',
            description = 'Teleportér den valgte spiller hen til dig.',
            icon = 'bring'
        },
        {
            action = 'freezePlayer',
            playerId = player.id,
            label = player.frozen and 'Frigiv spiller' or 'Frys spiller',
            description = player.frozen and 'Tillad den valgte spiller at bevæge sig igen.' or 'Forhindr den valgte spiller i at bevæge sig.',
            icon = 'freeze'
        },
        {
            action = 'revivePlayer',
            playerId = player.id,
            label = 'Genopliv spiller',
            description = 'Genopliv den valgte spiller og gendan fuldt liv.',
            icon = 'revive'
        },
        {
            action = 'spectatePlayer',
            playerId = player.id,
            label = spectating and spectateTargetId == player.id and 'Stop spectate' or 'Spectate spiller',
            description = spectating and spectateTargetId == player.id
                and 'Stop overvågning og vend tilbage til din tidligere position.'
                or 'Overvåg den valgte spiller uden at teleportere permanent.',
            icon = 'spectate'
        },
        {
            label = 'Server-ID',
            description = tostring(player.id),
            icon = 'id',
            readonly = true
        },
        {
            label = 'Navn',
            description = player.name or 'Ukendt',
            icon = 'player',
            readonly = true
        },
        {
            label = 'Ping',
            description = ('%sms'):format(player.ping or 0),
            icon = 'ping',
            readonly = true
        },
        {
            label = 'Job',
            description = player.job or 'Ukendt',
            icon = 'job',
            readonly = true
        },
        {
            label = 'Jobgrad',
            description = player.jobGrade or 'Ukendt',
            icon = 'grade',
            readonly = true
        },
        {
            label = 'ESX-gruppe',
            description = player.group or 'user',
            icon = 'shield',
            readonly = true
        }
    }
end

local function openPlayerDetails(playerId, listIndex)
    selectedPlayerId = playerId
    selectedPlayerListIndex = listIndex or selectedIndex
    playerRefreshToken = playerRefreshToken + 1

    setMenu('playerDetails', {
        {
            label = 'Indlæser spilleroplysninger...',
            description = 'Vent et øjeblik.',
            icon = 'player',
            disabled = true
        }
    })

    local player = lib.callback.await('sb_admin:server:getPlayerDetails', false, playerId)

    if not player then
        notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
        selectedPlayerId = nil
        selectedPlayerName = nil
        openPlayerMenu()
        return
    end

    selectedPlayerName = ('[%s] %s'):format(player.id, player.name)
    setMenu('playerDetails', buildPlayerDetailItems(player), 1)
end

openPlayerMenu = function()
    setMenu('players', {
        {
            label = 'Indlæser spillere...',
            description = 'Vent et øjeblik.',
            icon = 'player',
            disabled = true
        }
    })

    if not refreshPlayers(false) then
        return
    end

    playerRefreshToken = playerRefreshToken + 1
    local token = playerRefreshToken

    CreateThread(function()
        while menuOpen and currentMenu == 'players' and token == playerRefreshToken do
            Wait(3000)

            if menuOpen and currentMenu == 'players' and token == playerRefreshToken then
                refreshPlayers(true)
            end
        end
    end)
end

local function openMenu()
    if menuOpen then
        closeMenu()
        return
    end

    local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

    if not allowed then
        notify('Du har ikke adgang til adminmenuen.', 'error')
        return
    end

    menuOpen = true
    currentMenu = 'main'
    selectedIndex = 1
    menuItems = getMainMenuItems()

    SetNuiFocus(false, false)
    sendMenuState()
end

local function moveSelection(direction)
    if #menuItems == 0 then
        return
    end

    local newIndex = selectedIndex
    local attempts = 0

    repeat
        newIndex = newIndex + direction
        attempts = attempts + 1

        if newIndex > #menuItems then
            newIndex = 1
        elseif newIndex < 1 then
            newIndex = #menuItems
        end

        if not menuItems[newIndex].disabled then
            selectedIndex = newIndex
            break
        end
    until attempts >= #menuItems

    SendNUIMessage({
        action = 'select',
        selectedIndex = selectedIndex
    })
end


local function restoreSpectateState(showNotification)
    if not spectating then
        return
    end

    local ped = PlayerPedId()

    NetworkSetInSpectatorMode(false, ped)
    SetEntityVisible(ped, not invisibilityEnabled, false)
    SetEntityAlpha(ped, invisibilityEnabled and 0 or 255, false)
    NetworkSetEntityInvisibleToNetwork(ped, invisibilityEnabled)
    SetEntityCollision(ped, true, true)
    SetEntityInvincible(ped, godmodeEnabled)
    SetPlayerInvincible(PlayerId(), godmodeEnabled)
    SetEntityProofs(ped, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled)
    FreezeEntityPosition(ped, false)

    if spectateReturn and spectateReturn.coords then
        local coords = spectateReturn.coords
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
        SetEntityHeading(ped, spectateReturn.heading or 0.0)
    end

    spectating = false
    spectateTargetId = nil
    spectateReturn = nil

    if showNotification then
        notify('Spectate blev stoppet.', 'inform')
    end
end

local function startSpectate(targetId, targetName, coords)
    targetId = tonumber(targetId)

    if not targetId or targetId == GetPlayerServerId(PlayerId()) then
        notify('Du kan ikke spectate dig selv.', 'error')
        return false
    end

    if spectating then
        restoreSpectateState(false)
        Wait(250)
    end

    local ped = PlayerPedId()
    local currentCoords = GetEntityCoords(ped)

    spectateReturn = {
        coords = {
            x = currentCoords.x,
            y = currentCoords.y,
            z = currentCoords.z
        },
        heading = GetEntityHeading(ped)
    }

    spectating = true
    spectateTargetId = targetId

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetEntityCollision(ped, false, false)
    SetEntityVisible(ped, false, false)

    if coords then
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z + 10.0, false, false, false)
    end

    local timeout = GetGameTimer() + 5000
    local targetPlayer = GetPlayerFromServerId(targetId)

    while targetPlayer == -1 and GetGameTimer() < timeout do
        Wait(100)
        targetPlayer = GetPlayerFromServerId(targetId)
    end

    if targetPlayer == -1 then
        restoreSpectateState(false)
        notify('Spilleren kunne ikke indlæses til spectate.', 'error')
        return false
    end

    local targetPed = GetPlayerPed(targetPlayer)

    if not targetPed or targetPed == 0 or not DoesEntityExist(targetPed) then
        restoreSpectateState(false)
        notify('Spilleren kunne ikke indlæses til spectate.', 'error')
        return false
    end

    NetworkSetInSpectatorMode(true, targetPed)
    notify(('Du spectater nu %s.'):format(targetName or 'spilleren'), 'success')

    CreateThread(function()
        local watchedTarget = targetId

        while spectating and spectateTargetId == watchedTarget do
            Wait(500)

            local player = GetPlayerFromServerId(watchedTarget)
            if player == -1 or not NetworkIsPlayerActive(player) then
                restoreSpectateState(false)
                notify('Spilleren forlod serveren. Spectate blev stoppet.', 'error')
                break
            end
        end
    end)

    return true
end

local function rotationToDirection(rotation)
    local pitch = math.rad(rotation.x)
    local yaw = math.rad(rotation.z)
    local cosPitch = math.cos(pitch)

    return vector3(
        -math.sin(yaw) * cosPitch,
        math.cos(yaw) * cosPitch,
        math.sin(pitch)
    )
end

local function getNoclipEntity()
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        return GetVehiclePedIsIn(ped, false)
    end

    return ped
end

local function disableNoclip(showNotification)
    if not noclipEnabled then
        return
    end

    local entity = noclipEntity

    if entity and entity ~= 0 and DoesEntityExist(entity) then
        FreezeEntityPosition(entity, false)
        SetEntityCollision(entity, true, true)
        SetEntityInvincible(entity, godmodeEnabled)
        SetEntityVisible(entity, not invisibilityEnabled, false)
        SetEntityAlpha(entity, invisibilityEnabled and 0 or 255, false)
        NetworkSetEntityInvisibleToNetwork(entity, invisibilityEnabled)
        SetEntityVelocity(entity, 0.0, 0.0, 0.0)
    end

    local ped = PlayerPedId()
    SetEntityCollision(ped, true, true)
    SetEntityInvincible(ped, godmodeEnabled)
    SetPlayerInvincible(PlayerId(), godmodeEnabled)
    SetEntityProofs(ped, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled, godmodeEnabled)
    SetEntityVisible(ped, not invisibilityEnabled, false)
    SetEntityAlpha(ped, invisibilityEnabled and 0 or 255, false)
    NetworkSetEntityInvisibleToNetwork(ped, invisibilityEnabled)
    FreezeEntityPosition(ped, false)

    noclipEnabled = false
    noclipEntity = nil

    if showNotification then
        notify('Noclip blev deaktiveret.', 'inform')
    end
end

local function enableNoclip()
    if spectating then
        notify('Stop spectate, før du aktiverer noclip.', 'error')
        return false
    end

    noclipEntity = getNoclipEntity()

    if not noclipEntity or noclipEntity == 0 or not DoesEntityExist(noclipEntity) then
        notify('Din karakter kunne ikke findes.', 'error')
        return false
    end

    noclipEnabled = true
    FreezeEntityPosition(noclipEntity, true)
    SetEntityCollision(noclipEntity, false, false)
    SetEntityInvincible(noclipEntity, true)
    SetEntityVisible(noclipEntity, false, false)
    SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)

    notify('Noclip blev aktiveret.', 'success')
    return true
end

local function toggleNoclip()
    if noclipEnabled then
        disableNoclip(true)
        return
    end

    enableNoclip()
end

local function setEntityInvisibleState(entity, invisible)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return
    end

    SetEntityVisible(entity, not invisible, false)
    SetEntityAlpha(entity, invisible and 0 or 255, false)
    NetworkSetEntityInvisibleToNetwork(entity, invisible)
end

local function applyInvisibilityState()
    local ped = PlayerPedId()
    local vehicle = 0

    if IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    end

    if invisibleVehicle and invisibleVehicle ~= 0 and invisibleVehicle ~= vehicle and DoesEntityExist(invisibleVehicle) then
        local keepHiddenForNoclip = noclipEnabled and noclipEntity == invisibleVehicle
        setEntityInvisibleState(invisibleVehicle, keepHiddenForNoclip)
        invisibleVehicle = nil
    end

    if invisibilityEnabled then
        setEntityInvisibleState(ped, true)

        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            setEntityInvisibleState(vehicle, true)
            invisibleVehicle = vehicle
        end
    else
        local keepPedHidden = spectating or (noclipEnabled and noclipEntity == ped)
        setEntityInvisibleState(ped, keepPedHidden)

        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            local keepVehicleHidden = noclipEnabled and noclipEntity == vehicle
            setEntityInvisibleState(vehicle, keepVehicleHidden)
        end

        if invisibleVehicle and invisibleVehicle ~= 0 and DoesEntityExist(invisibleVehicle) then
            local keepHiddenForNoclip = noclipEnabled and noclipEntity == invisibleVehicle
            setEntityInvisibleState(invisibleVehicle, keepHiddenForNoclip)
        end

        invisibleVehicle = nil
    end
end

local function toggleInvisibility()
    invisibilityEnabled = not invisibilityEnabled
    applyInvisibilityState()

    if invisibilityEnabled then
        notify('Usynlighed blev aktiveret.', 'success')
    else
        notify('Usynlighed blev deaktiveret.', 'inform')
    end
end

CreateThread(function()
    while true do
        if not invisibilityEnabled then
            Wait(500)
        else
            Wait(0)
            applyInvisibilityState()
        end
    end
end)

local function applyGodmodeState(enabled)
    local ped = PlayerPedId()

    SetPlayerInvincible(PlayerId(), enabled)
    SetEntityInvincible(ped, enabled or noclipEnabled)
    SetEntityProofs(
        ped,
        enabled, -- bullets
        enabled, -- fire
        enabled, -- explosions
        enabled, -- collision
        enabled, -- melee
        enabled, -- steam
        enabled, -- unknown proof
        enabled  -- drowning
    )

    if enabled then
        ClearPedBloodDamage(ped)
        ResetPedVisibleDamage(ped)
    end
end

local function disableGodmode(showNotification)
    if not godmodeEnabled then
        return
    end

    godmodeEnabled = false
    applyGodmodeState(false)

    if showNotification then
        notify('Godmode blev deaktiveret.', 'inform')
    end
end

local function enableGodmode()
    godmodeEnabled = true
    applyGodmodeState(true)
    notify('Godmode blev aktiveret.', 'success')
end

local function toggleGodmode()
    if godmodeEnabled then
        disableGodmode(true)
    else
        enableGodmode()
    end
end

-- Genanvend beskyttelsen løbende, da andre resources kan ændre ped-state.
CreateThread(function()
    while true do
        if not godmodeEnabled then
            Wait(500)
        else
            Wait(0)
            applyGodmodeState(true)
        end
    end
end)

CreateThread(function()
    while true do
        if not noclipEnabled then
            Wait(300)
        else
            Wait(0)

            local entity = noclipEntity

            if not entity or entity == 0 or not DoesEntityExist(entity) then
                disableNoclip(false)
            else
                DisableControlAction(0, 30, true) -- A/D
                DisableControlAction(0, 31, true) -- W/S
                DisableControlAction(0, 21, true) -- Shift
                DisableControlAction(0, 22, true) -- Space
                DisableControlAction(0, 36, true) -- Ctrl

                local camRotation = GetGameplayCamRot(2)
                local forward = rotationToDirection(camRotation)
                local yaw = math.rad(camRotation.z)
                local right = vector3(math.cos(yaw), math.sin(yaw), 0.0)
                local up = vector3(0.0, 0.0, 1.0)
                local movement = vector3(0.0, 0.0, 0.0)

                if IsDisabledControlPressed(0, 32) then -- W
                    movement = movement + forward
                end

                if IsDisabledControlPressed(0, 33) then -- S
                    movement = movement - forward
                end

                if IsDisabledControlPressed(0, 34) then -- A
                    movement = movement - right
                end

                if IsDisabledControlPressed(0, 35) then -- D
                    movement = movement + right
                end

                if IsDisabledControlPressed(0, 22) then -- Space
                    movement = movement + up
                end

                if IsDisabledControlPressed(0, 36) then -- Ctrl
                    movement = movement - up
                end

                local length = math.sqrt(
                    movement.x * movement.x
                    + movement.y * movement.y
                    + movement.z * movement.z
                )

                if length > 0.0 then
                    movement = movement / length

                    local speed = Config.Noclip.speed

                    if IsDisabledControlPressed(0, 21) then
                        speed = Config.Noclip.fastSpeed
                    elseif IsControlPressed(0, 19) then -- Left Alt
                        speed = Config.Noclip.slowSpeed
                    end

                    local coords = GetEntityCoords(entity)
                    local frameMultiplier = GetFrameTime() * 60.0
                    local nextCoords = coords + movement * speed * frameMultiplier

                    SetEntityCoordsNoOffset(
                        entity,
                        nextCoords.x,
                        nextCoords.y,
                        nextCoords.z,
                        true,
                        true,
                        true
                    )
                end

                SetEntityHeading(entity, camRotation.z)
                FreezeEntityPosition(entity, true)
                SetEntityCollision(entity, false, false)
                SetEntityInvincible(entity, true)
                SetEntityVisible(entity, false, false)
                SetEntityVelocity(entity, 0.0, 0.0, 0.0)
            end
        end
    end
end)

local function saveReturnPosition(entity)
    entity = entity or PlayerPedId()

    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    local coords = GetEntityCoords(entity)

    returnPosition = {
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        heading = GetEntityHeading(entity),
        wasInVehicle = IsEntityAVehicle(entity)
    }

    return true
end

local function returnToPreviousPosition()
    if not returnPosition or not returnPosition.coords then
        notify('Der er ikke gemt en tidligere position endnu.', 'error')
        return false
    end

    local ped = PlayerPedId()
    local entity = ped

    if IsPedInAnyVehicle(ped, false) then
        entity = GetVehiclePedIsIn(ped, false)
    end

    if not entity or entity == 0 or not DoesEntityExist(entity) then
        notify('Din karakter eller dit køretøj kunne ikke findes.', 'error')
        return false
    end

    local coords = returnPosition.coords
    local x = tonumber(coords.x)
    local y = tonumber(coords.y)
    local z = tonumber(coords.z)

    if not x or not y or not z then
        returnPosition = nil
        notify('Den gemte position var ugyldig og er blevet slettet.', 'error')
        return false
    end

    DoScreenFadeOut(200)

    local fadeTimeout = GetGameTimer() + 1200
    while not IsScreenFadedOut() and GetGameTimer() < fadeTimeout do
        Wait(0)
    end

    RequestCollisionAtCoord(x, y, z)
    SetEntityCoordsNoOffset(entity, x, y, z, false, false, false)
    SetEntityHeading(entity, tonumber(returnPosition.heading) or 0.0)
    SetEntityVelocity(entity, 0.0, 0.0, 0.0)

    local collisionTimeout = GetGameTimer() + 2000
    while not HasCollisionLoadedAroundEntity(entity) and GetGameTimer() < collisionTimeout do
        RequestCollisionAtCoord(x, y, z)
        Wait(50)
    end

    DoScreenFadeIn(200)
    notify('Du blev teleporteret tilbage til din tidligere position.', 'success')
    return true
end

local function teleportToWaypoint()
    local waypoint = GetFirstBlipInfoId(8)

    if not waypoint or waypoint == 0 or not DoesBlipExist(waypoint) then
        notify('Du har ikke sat et waypoint på kortet.', 'error')
        return false
    end

    local waypointCoords = GetBlipInfoIdCoord(waypoint)
    local x = waypointCoords.x
    local y = waypointCoords.y
    local ped = PlayerPedId()
    local entity = ped

    if IsPedInAnyVehicle(ped, false) then
        entity = GetVehiclePedIsIn(ped, false)
    end

    if not entity or entity == 0 or not DoesEntityExist(entity) then
        notify('Din karakter eller dit køretøj kunne ikke findes.', 'error')
        return false
    end

    saveReturnPosition(entity)
    DoScreenFadeOut(250)

    local fadeTimeout = GetGameTimer() + 1500
    while not IsScreenFadedOut() and GetGameTimer() < fadeTimeout do
        Wait(0)
    end

    local wasFrozenByNoclip = noclipEnabled and entity == noclipEntity

    if not wasFrozenByNoclip then
        FreezeEntityPosition(entity, true)
    end

    SetEntityCoordsNoOffset(entity, x, y, 1000.0, false, false, false)
    RequestCollisionAtCoord(x, y, 1000.0)

    local groundFound = false
    local groundZ = 0.0
    local searchHeights = {
        1000.0, 900.0, 800.0, 700.0, 600.0, 500.0,
        400.0, 300.0, 250.0, 200.0, 150.0, 100.0,
        75.0, 50.0, 25.0, 0.0
    }

    for _, height in ipairs(searchHeights) do
        SetEntityCoordsNoOffset(entity, x, y, height, false, false, false)
        RequestCollisionAtCoord(x, y, height)
        Wait(75)

        local found, z = GetGroundZFor_3dCoord(x, y, height, false)

        if found then
            groundFound = true
            groundZ = z
            break
        end
    end

    if groundFound then
        SetEntityCoordsNoOffset(entity, x, y, groundZ + 1.0, false, false, false)
        RequestCollisionAtCoord(x, y, groundZ)
    else
        -- Fallback, hvis området endnu ikke har leveret ground-data.
        SetEntityCoordsNoOffset(entity, x, y, 1000.0, false, false, false)
    end

    local collisionTimeout = GetGameTimer() + 2000
    while not HasCollisionLoadedAroundEntity(entity) and GetGameTimer() < collisionTimeout do
        RequestCollisionAtCoord(x, y, groundFound and groundZ or 1000.0)
        Wait(50)
    end

    if not wasFrozenByNoclip then
        FreezeEntityPosition(entity, false)
    end

    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
    DoScreenFadeIn(250)

    if not groundFound then
        notify('Waypointet blev fundet, men jorden kunne ikke indlæses. Du blev placeret over området.', 'warning')
    else
        notify('Du blev teleporteret til dit waypoint.', 'success')
    end

    return true
end

local function activateSelectedItem()
    local item = menuItems[selectedIndex]

    if not item or item.disabled then
        return
    end

    if currentMenu == 'main' and item.action == 'players' then
        openPlayerMenu()
        return
    end

    if currentMenu == 'main' and item.action == 'toggleNoclip' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        toggleNoclip()

        -- Behold menuen åben og opdatér teksten på noclip-punktet.
        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'toggleGodmode' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        toggleGodmode()

        -- Behold menuen åben og opdatér teksten på godmode-punktet.
        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'toggleInvisibility' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        toggleInvisibility()

        -- Behold menuen åben og opdatér teksten på usynlighedspunktet.
        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'teleportWaypoint' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        teleportToWaypoint()

        -- Menuen forbliver åben, og markeringen bliver på waypoint-punktet.
        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'returnPosition' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        returnToPreviousPosition()

        -- Menuen forbliver åben efter returnering.
        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'players' and item.action == 'player' then
        openPlayerDetails(item.playerId, selectedIndex)
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'gotoPlayer' then
        local result = lib.callback.await('sb_admin:server:gotoPlayer', false, item.playerId)

        if not result or not result.coords then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        local ped = PlayerPedId()
        local entity = ped

        if IsPedInAnyVehicle(ped, false) then
            entity = GetVehiclePedIsIn(ped, false)
        end

        local x = tonumber(result.coords.x)
        local y = tonumber(result.coords.y)
        local z = tonumber(result.coords.z)
        local heading = tonumber(result.heading) or 0.0

        if not x or not y or not z then
            notify('Spillerens position kunne ikke hentes.', 'error')
            return
        end

        saveReturnPosition(entity)
        RequestCollisionAtCoord(x, y, z)
        SetEntityCoordsNoOffset(entity, x + 1.0, y + 1.0, z, false, false, false)
        SetEntityHeading(entity, heading)

        closeMenu()
        notify(('Du blev teleporteret til %s.'):format(result.name or 'spilleren'), 'success')
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'bringPlayer' then
        local result = lib.callback.await('sb_admin:server:bringPlayer', false, item.playerId)

        if not result then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        closeMenu()
        notify(('%s blev teleporteret hen til dig.'):format(result.name or 'Spilleren'), 'success')
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'freezePlayer' then
        local result = lib.callback.await('sb_admin:server:toggleFreezePlayer', false, item.playerId)

        if not result then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        notify(
            result.frozen
                and ('%s er nu frosset.'):format(result.name or 'Spilleren')
                or ('%s er nu frigivet.'):format(result.name or 'Spilleren'),
            'success'
        )

        openPlayerDetails(item.playerId, selectedPlayerListIndex)
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'revivePlayer' then
        local result = lib.callback.await('sb_admin:server:revivePlayer', false, item.playerId)

        if not result then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        notify(('%s blev genoplivet.'):format(result.name or 'Spilleren'), 'success')
        return
    end


    if currentMenu == 'playerDetails' and item.action == 'spectatePlayer' then
        if spectating and spectateTargetId == tonumber(item.playerId) then
            restoreSpectateState(true)
            openPlayerDetails(item.playerId, selectedPlayerListIndex)
            return
        end

        local result = lib.callback.await('sb_admin:server:getSpectateTarget', false, item.playerId)

        if not result or not result.coords then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        if startSpectate(item.playerId, result.name, result.coords) then
            closeMenu()
        end

        return
    end

end

RegisterNetEvent('sb_admin:client:bringToAdmin', function(data)
    if type(data) ~= 'table' or type(data.coords) ~= 'table' then
        return
    end

    local x = tonumber(data.coords.x)
    local y = tonumber(data.coords.y)
    local z = tonumber(data.coords.z)
    local heading = tonumber(data.heading) or 0.0

    if not x or not y or not z then
        return
    end

    local ped = PlayerPedId()
    local entity = ped

    if IsPedInAnyVehicle(ped, false) then
        entity = GetVehiclePedIsIn(ped, false)
    end

    RequestCollisionAtCoord(x, y, z)
    SetEntityCoordsNoOffset(entity, x + 1.5, y + 1.5, z, false, false, false)
    SetEntityHeading(entity, heading)

    notify(('Du blev teleporteret til %s.'):format(data.adminName or 'en administrator'), 'inform')
end)

RegisterNetEvent('sb_admin:client:reviveNotification', function(adminName)
    local ped = PlayerPedId()

    -- Ambulancejobbet står selv for revive og nulstilling af death-state.
    -- Her fjerner vi kun en eventuel admin-freeze og viser beskeden.
    FreezeEntityPosition(ped, false)

    if IsPedInAnyVehicle(ped, false) then
        FreezeEntityPosition(GetVehiclePedIsIn(ped, false), false)
    end

    notify(('Du blev genoplivet af %s.'):format(adminName or 'en administrator'), 'success')
end)

RegisterNetEvent('sb_admin:client:setFrozen', function(frozen, adminName)
    frozen = frozen == true

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, frozen)

    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        FreezeEntityPosition(vehicle, frozen)
    end

    if frozen then
        notify(('Du er blevet frosset af %s.'):format(adminName or 'en administrator'), 'error')
    else
        notify(('Du er blevet frigivet af %s.'):format(adminName or 'en administrator'), 'inform')
    end
end)

local function goBack()
    if currentMenu == 'playerDetails' then
        selectedPlayerId = nil
        selectedPlayerName = nil
        openPlayerMenu()

        if #menuItems > 0 then
            selectedIndex = math.min(math.max(selectedPlayerListIndex, 1), #menuItems)
            SendNUIMessage({
                action = 'select',
                selectedIndex = selectedIndex
            })
        end

        return
    end

    if currentMenu == 'players' then
        playerRefreshToken = playerRefreshToken + 1
        setMenu('main', getMainMenuItems(), 1)
        return
    end

    closeMenu()
end

RegisterCommand(Config.Command, function()
    openMenu()
end, false)

RegisterKeyMapping(
    Config.Command,
    'Åbn SB Admin',
    'keyboard',
    Config.DefaultKey
)

CreateThread(function()
    while true do
        if not menuOpen then
            Wait(500)
        else
            Wait(0)

            DisableControlAction(0, 172, true) -- Arrow Up
            DisableControlAction(0, 173, true) -- Arrow Down
            DisableControlAction(0, 174, true) -- Arrow Left
            DisableControlAction(0, 175, true) -- Arrow Right
            DisableControlAction(0, 191, true) -- Enter
            DisableControlAction(0, 201, true) -- Enter
            DisableControlAction(0, 177, true) -- Backspace
            DisableControlAction(0, 200, true) -- Escape/Pause

            if IsDisabledControlJustPressed(0, 172) then
                moveSelection(-1)
            elseif IsDisabledControlJustPressed(0, 173) then
                moveSelection(1)
            elseif IsDisabledControlJustPressed(0, 191)
                or IsDisabledControlJustPressed(0, 201) then
                activateSelectedItem()
            elseif IsDisabledControlJustPressed(0, 177) then
                goBack()
            elseif IsDisabledControlJustPressed(0, 200) then
                closeMenu()
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    restoreSpectateState(false)
    disableNoclip(false)
    disableGodmode(false)
    invisibilityEnabled = false
    applyInvisibilityState()
    SetNuiFocus(false, false)
end)
