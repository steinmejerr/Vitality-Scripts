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
local playerIdsEnabled = false
local invisibleVehicle = nil
local returnPosition = nil
local playerDetailsReturnIndex = 1
local playerNotesReturnIndex = 1
local activeTab = 'menu'
local adminChatMessages = {}
local chatTyping = false
local chatMouseEnabled = false
local adminChatTypingActive = false
local myPermissions = {}
local adminChatSoundEnabled = GetResourceKvpString('sb_admin:adminChatSound')
if adminChatSoundEnabled == nil then
    adminChatSoundEnabled = not (Config.AdminChat and Config.AdminChat.soundDefault == false)
else
    adminChatSoundEnabled = adminChatSoundEnabled == 'true'
end


local function notify(description, notifyType)
    lib.notify({
        title = 'Vitality Admin',
        description = description,
        type = notifyType or 'inform',
        position = Config.Notify.position,
        duration = Config.Notify.duration
    })
end

local function can(permission)
    return myPermissions and myPermissions[permission] == true
end

local function filterPermittedItems(items)
    local result = {}
    for _, item in ipairs(items) do
        if not item.permission or can(item.permission) then result[#result+1] = item end
    end
    return result
end

local function getMainMenuItems()
    local items = {
        {
            action = 'players',
            permission = 'players_view',
            label = 'Spillere',
            description = 'Se alle spillere, der er online på serveren.',
            icon = 'players'
        },
        {
            action = 'announcement',
            permission = 'announcement',
            label = 'Announcement',
            description = 'Send en servermeddelelse til alle online spillere.',
            icon = 'announcement'
        },
        {
            action = 'toggleNoclip',
            permission = 'noclip',
            label = noclipEnabled and 'Deaktivér noclip' or 'Aktivér noclip',
            description = noclipEnabled
                and 'Slå fri bevægelse fra og vend tilbage til normal styring.'
                or 'Flyv frit i den retning, kameraet peger.',
            icon = 'noclip'
        },
        {
            action = 'toggleGodmode',
            permission = 'godmode',
            label = godmodeEnabled and 'Deaktivér godmode' or 'Aktivér godmode',
            description = godmodeEnabled
                and 'Slå usårlighed fra og modtag skade normalt igen.'
                or 'Gør din karakter usårlig over for skade.',
            icon = 'godmode'
        },
        {
            action = 'toggleInvisibility',
            permission = 'invisibility',
            label = invisibilityEnabled and 'Deaktivér usynlighed' or 'Aktivér usynlighed',
            description = invisibilityEnabled
                and 'Gør din karakter og dit køretøj synligt igen.'
                or 'Skjul din karakter og dit nuværende køretøj.',
            icon = 'invisibility'
        },
        {
            action = 'togglePlayerIds',
            permission = 'player_ids',
            label = playerIdsEnabled and 'Deaktivér spiller-ID’er' or 'Aktivér spiller-ID’er',
            description = playerIdsEnabled
                and 'Skjul navne og server-ID’er over spillerne igen.'
                or 'Vis navn og server-ID over spillere i nærheden.',
            icon = 'playerids'
        },
        {
            action = 'deleteVehicle',
            permission = 'vehicle_delete',
            label = 'Slet køretøj',
            description = 'Fjern køretøjet, du sidder i eller står tæt på.',
            icon = 'deletevehicle'
        },
        {
            action = 'repairVehicle',
            permission = 'vehicle_repair',
            label = 'Reparér køretøj',
            description = 'Reparér køretøjet, du sidder i eller står tæt på.',
            icon = 'repairvehicle'
        },
        {
            action = 'flipVehicle',
            permission = 'vehicle_flip',
            label = 'Vend køretøj',
            description = 'Vend køretøjet korrekt tilbage på hjulene.',
            icon = 'flipvehicle'
        },
        {
            action = 'spawnVehicle',
            permission = 'vehicle_spawn',
            label = 'Spawn køretøj',
            description = 'Indtast et modelnavn og spawn et køretøj.',
            icon = 'spawnvehicle'
        },
        {
            action = 'teleportWaypoint',
            permission = 'teleport_waypoint',
            label = 'Teleportér til waypoint',
            description = 'Teleportér til din markering på kortet.',
            icon = 'waypoint'
        },
        {
            action = 'teleportCoordinates',
            permission = 'teleport_coordinates',
            label = 'Teleportér til koordinater',
            description = 'Indtast X, Y, Z og valgfri heading.',
            icon = 'coordinates'
        },
        {
            action = 'copyCoordinates',
            permission = 'copy_coordinates',
            label = 'Kopiér koordinater',
            description = 'Kopiér din aktuelle position i det ønskede format.',
            icon = 'copycoordinates'
        },
        {
            action = 'returnPosition',
            permission = 'return_position',
            label = 'Returnér',
            description = returnPosition
                and 'Teleportér tilbage til din senest gemte position.'
                or 'Der er endnu ikke gemt en tidligere position.',
            icon = 'return'
        }
    }

    return filterPermittedItems(items)
end

local function getMenuTitle()
    if currentMenu == 'admins' then
        return 'Admins'
    end

    if currentMenu == 'adminEdit' then
        return 'Adminrettigheder'
    end

    if currentMenu == 'players' then
        return 'Spillere'
    end

    if currentMenu == 'playerDetails' then
        return selectedPlayerName or 'Spilleroplysninger'
    end

    if currentMenu == 'playerInventory' then
        return selectedPlayerName and ('Inventory - %s'):format(selectedPlayerName) or 'Inventory'
    end

    return 'Adminmenu'
end

local function sendMenuState()
    SendNUIMessage({
        action = 'setMenu',
        visible = menuOpen,
        title = getMenuTitle(),
        selectedIndex = selectedIndex,
        items = menuItems,
        activeTab = activeTab,
        chatMessages = adminChatMessages,
        chatSoundEnabled = adminChatSoundEnabled,
        canManageAdmins = can('manage_admins')
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

local setOwnAdminChatTyping

local function closeMenu()
    if not menuOpen then
        return
    end

    setOwnAdminChatTyping(false)
    menuOpen = false
    activeTab = 'menu'
    chatTyping = false
    chatMouseEnabled = false
    currentMenu = 'main'
    selectedIndex = 1
    menuItems = {}
    playerRefreshToken = playerRefreshToken + 1
    selectedPlayerId = nil
    selectedPlayerName = nil
    selectedPlayerListIndex = 1

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = 'setChatMouse',
        enabled = false
    })

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
local openPlayerDetails

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
            action = 'viewPlayerNotes',
            playerId = player.id,
            label = ('Spillernoter (%s)'):format(player.noteCount or 0),
            description = player.noteCount and player.noteCount > 0
                and 'Se noter og opmærksomhedspunkter på spilleren.'
                or 'Der er ingen aktive noter på spilleren.',
            icon = 'note'
        },
        {
            action = 'giveVehicle',
            playerId = player.id,
            label = 'Giv køretøj',
            description = 'Gem et permanent køretøj på den valgte spiller.',
            icon = 'givevehicle'
        },
        {
            action = 'viewInventory',
            playerId = player.id,
            label = 'Se inventory',
            description = 'Se hvilke items den valgte spiller har på sig.',
            icon = 'inventory'
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

local function buildInventoryItems(inventory)
    local items = {}

    for _, entry in ipairs(inventory or {}) do
        local description = ('Antal: %s'):format(entry.count or 0)

        if entry.slot then
            description = ('%s | Slot: %s'):format(description, entry.slot)
        end

        items[#items + 1] = {
            action = 'removeInventoryItem',
            playerId = selectedPlayerId,
            itemName = entry.name,
            itemLabel = entry.label or entry.name or 'Ukendt item',
            itemCount = tonumber(entry.count) or 0,
            itemSlot = entry.slot,
            label = entry.label or entry.name or 'Ukendt item',
            description = description,
            icon = 'item'
        }
    end

    if #items == 0 then
        items[1] = {
            label = 'Tomt inventory',
            description = 'Spilleren har ingen items på sig.',
            icon = 'inventory',
            readonly = true
        }
    end

    return items
end

local function openPlayerInventory(playerId, returnIndex, preferredIndex)
    playerDetailsReturnIndex = returnIndex or selectedIndex
    selectedPlayerId = playerId

    setMenu('playerInventory', {
        {
            label = 'Indlæser inventory...',
            description = 'Vent et øjeblik.',
            icon = 'inventory',
            disabled = true
        }
    })

    local result = lib.callback.await('sb_admin:server:getPlayerInventory', false, playerId)

    if not result then
        notify('Inventory kunne ikke hentes, eller spilleren er ikke længere online.', 'error')
        openPlayerDetails(playerId, selectedPlayerListIndex, playerDetailsReturnIndex)
        return
    end

    selectedPlayerName = ('[%s] %s'):format(result.id, result.name)
    setMenu('playerInventory', buildInventoryItems(result.items), preferredIndex or 1)
end

openPlayerDetails = function(playerId, listIndex, preferredDetailIndex)
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
    setMenu('playerDetails', buildPlayerDetailItems(player), preferredDetailIndex or 1)
end


local function formatPlayerNoteDate(value)
    local text = tostring(value or '')

    if text == '' then
        return 'Ukendt tidspunkt'
    end

    local y, m, d, h, min = text:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)[ T](%d%d):(%d%d)')
    if y then
        return ('%s/%s/%s %s:%s'):format(d, m, y, h, min)
    end

    return text
end

local function openPlayerNotes(playerId, returnIndex, preferredIndex)
    playerNotesReturnIndex = returnIndex or selectedIndex
    setMenu('playerNotes', {
        {
            label = 'Indlæser noter...',
            description = 'Vent et øjeblik.',
            icon = 'note',
            disabled = true
        }
    })

    local result = lib.callback.await('sb_admin:server:getPlayerNotes', false, playerId)
    if not result then
        notify('Noterne kunne ikke hentes, eller spilleren er ikke længere online.', 'error')
        openPlayerDetails(playerId, selectedPlayerListIndex, playerNotesReturnIndex)
        return
    end

    local items = {
        {
            action = 'addPlayerNote',
            playerId = playerId,
            label = 'Tilføj note',
            description = 'Opret et nyt opmærksomhedspunkt på spilleren.',
            icon = 'noteadd'
        }
    }

    for _, note in ipairs(result.notes or {}) do
        items[#items + 1] = {
            action = 'deletePlayerNote',
            playerId = playerId,
            noteId = note.id,
            label = ('Note #%s • %s'):format(note.id, note.source == 'discord' and 'Discord' or 'FiveM'),
            description = ('%s — %s • %s'):format(
                tostring(note.note or ''),
                tostring(note.created_by_name or 'Ukendt staff'),
                formatPlayerNoteDate(note.created_at_display or note.created_at)
            ),
            icon = 'note'
        }
    end

    if #(result.notes or {}) == 0 then
        items[#items + 1] = {
            label = 'Ingen noter',
            description = 'Der er endnu ingen aktive noter på spilleren.',
            icon = 'note',
            disabled = true
        }
    end

    setMenu('playerNotes', items, preferredIndex or 1)
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


setOwnAdminChatTyping = function(isTyping)
    isTyping = isTyping == true

    if adminChatTypingActive == isTyping then
        return
    end

    adminChatTypingActive = isTyping
    TriggerServerEvent('sb_admin:server:setAdminChatTyping', isTyping)
end

local function refreshAdminChat()
    local messages = lib.callback.await('sb_admin:server:getAdminChatMessages', false)

    if not messages then
        notify('Du har ikke længere adgang til adminchatten.', 'error')
        return false
    end

    adminChatMessages = messages

    SendNUIMessage({
        action = 'setChatMessages',
        messages = adminChatMessages
    })

    return true
end

local function buildPermissionDefinitions()
    local definitions = {}
    for key, label in pairs(Config.AdminPermissions or {}) do
        if key ~= 'access_menu' then
            definitions[#definitions + 1] = { key = key, label = label }
        end
    end
    table.sort(definitions, function(a, b) return a.label < b.label end)
    return definitions
end

local function refreshAdminsTab()
    if not can('manage_admins') then
        return false
    end

    local admins = lib.callback.await('sb_admin:server:getAdmins', false)
    local candidates = lib.callback.await('sb_admin:server:getOnlineAdminCandidates', false)

    if not admins or not candidates then
        notify('Adminlisten kunne ikke hentes.', 'error')
        return false
    end

    SendNUIMessage({
        action = 'setAdminsData',
        admins = admins,
        candidates = candidates,
        permissions = buildPermissionDefinitions()
    })

    return true
end

local function setActiveTab(tabName)
    if tabName ~= 'menu' and tabName ~= 'chat' and tabName ~= 'admins' then
        return
    end

    if tabName == 'admins' and not can('manage_admins') then
        tabName = 'menu'
    end

    if chatTyping or chatMouseEnabled then
        setOwnAdminChatTyping(false)
        chatTyping = false
        chatMouseEnabled = false
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)

        SendNUIMessage({
            action = 'setChatMouse',
            enabled = false
        })
    end

    activeTab = tabName

    if activeTab == 'chat' then
        refreshAdminChat()
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    elseif activeTab == 'admins' then
        refreshAdminsTab()
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(false)
    else
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end

    SendNUIMessage({
        action = 'setActiveTab',
        tab = activeTab,
        canManageAdmins = can('manage_admins')
    })
end

local function toggleActiveTab()
    if activeTab == 'menu' then
        setActiveTab('chat')
    elseif activeTab == 'chat' and can('manage_admins') then
        setActiveTab('admins')
    else
        setActiveTab('menu')
    end
end

local function updateAdminChatSoundUi()
    SendNUIMessage({
        action = 'setChatSound',
        enabled = adminChatSoundEnabled
    })
end

local function toggleAdminChatSound()
    adminChatSoundEnabled = not adminChatSoundEnabled
    SetResourceKvp('sb_admin:adminChatSound', adminChatSoundEnabled and 'true' or 'false')
    updateAdminChatSoundUi()

    notify(
        adminChatSoundEnabled and 'Lyd for adminchat er slået til.' or 'Lyd for adminchat er slået fra.',
        adminChatSoundEnabled and 'success' or 'inform'
    )
end

local function setAdminChatMouse(enabled)
    if activeTab ~= 'chat' then
        enabled = false
    end

    setOwnAdminChatTyping(false)
    chatMouseEnabled = enabled == true
    chatTyping = false

    SetNuiFocus(chatMouseEnabled, chatMouseEnabled)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = 'setChatMouse',
        enabled = chatMouseEnabled
    })
end

local function toggleAdminChatMouse()
    setAdminChatMouse(not chatMouseEnabled)
end

local function beginChatInput()
    if activeTab ~= 'chat' or chatTyping then
        return
    end

    chatTyping = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = 'focusChatInput'
    })
end

local function openMenu()
    if menuOpen then
        closeMenu()
        return
    end

    local permissions = lib.callback.await('sb_admin:server:getMyPermissions', false)

    if not permissions then
        notify('Du har ikke adgang til adminmenuen.', 'error')
        return
    end

    myPermissions = permissions
    menuOpen = true
    activeTab = 'menu'
    chatTyping = false
    chatMouseEnabled = false
    currentMenu = 'main'
    selectedIndex = 1
    menuItems = getMainMenuItems()

    SetNuiFocus(false, false)
    sendMenuState()
    refreshAdminChat()
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

local function drawPlayerIdText(coords, text)
    local visible, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)

    if not visible then
        return
    end

    SetTextScale(0.0, 0.31)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 235)
    SetTextCentre(true)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(screenX, screenY)
end

local function togglePlayerIds()
    playerIdsEnabled = not playerIdsEnabled

    if playerIdsEnabled then
        notify('Spiller-ID’er blev aktiveret.', 'success')
    else
        notify('Spiller-ID’er blev deaktiveret.', 'inform')
    end
end

CreateThread(function()
    while true do
        if not playerIdsEnabled then
            Wait(500)
        else
            Wait(0)

            local ownPed = PlayerPedId()
            local ownCoords = GetEntityCoords(ownPed)
            local maxDistance = (Config.PlayerIds and Config.PlayerIds.distance) or 75.0

            for _, player in ipairs(GetActivePlayers()) do
                if player ~= PlayerId() and NetworkIsPlayerActive(player) then
                    local targetPed = GetPlayerPed(player)

                    if targetPed ~= 0 and DoesEntityExist(targetPed) then
                        local targetCoords = GetEntityCoords(targetPed)
                        local distance = #(ownCoords - targetCoords)

                        if distance <= maxDistance then
                            local headCoords = GetPedBoneCoords(targetPed, 0x796E, 0.0, 0.0, 0.35)
                            local serverId = GetPlayerServerId(player)
                            local playerName = GetPlayerName(player) or 'Ukendt'
                            drawPlayerIdText(headCoords, ('[%s] %s'):format(serverId, playerName))
                        end
                    end
                end
            end
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


local function getClosestVehicleWithinDistance(maxDistance)
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        local currentVehicle = GetVehiclePedIsIn(ped, false)

        if currentVehicle ~= 0 and DoesEntityExist(currentVehicle) then
            return currentVehicle
        end
    end

    local pedCoords = GetEntityCoords(ped)
    local closestVehicle = 0
    local closestDistance = maxDistance + 0.01

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        if DoesEntityExist(vehicle) then
            local distance = #(pedCoords - GetEntityCoords(vehicle))

            if distance < closestDistance then
                closestVehicle = vehicle
                closestDistance = distance
            end
        end
    end

    return closestVehicle
end

local function requestEntityControl(entity, timeoutMs)
    if entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end

    local networkId = NetworkGetNetworkIdFromEntity(entity)
    SetNetworkIdCanMigrate(networkId, true)
    NetworkRequestControlOfEntity(entity)

    local timeout = GetGameTimer() + (timeoutMs or 1500)

    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

local function deleteNearbyVehicle()
    local maxDistance = (Config.DeleteVehicle and Config.DeleteVehicle.distance) or 6.0
    local vehicle = getClosestVehicleWithinDistance(maxDistance)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(('Der blev ikke fundet et køretøj inden for %.0f meter.'):format(maxDistance), 'error')
        return false
    end

    if not requestEntityControl(vehicle, 2000) then
        notify('Køretøjet kunne ikke overtages og blev derfor ikke slettet.', 'error')
        return false
    end

    local ped = PlayerPedId()

    if IsPedInVehicle(ped, vehicle, false) then
        TaskLeaveVehicle(ped, vehicle, 16)

        local leaveTimeout = GetGameTimer() + 1000
        while IsPedInVehicle(ped, vehicle, false) and GetGameTimer() < leaveTimeout do
            Wait(0)
        end
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    if DoesEntityExist(vehicle) then
        notify('Køretøjet kunne ikke slettes.', 'error')
        return false
    end

    if invisibleVehicle == vehicle then
        invisibleVehicle = nil
    end

    if noclipEntity == vehicle then
        noclipEntity = nil
    end

    notify('Køretøjet blev slettet.', 'success')
    return true
end

local function repairNearbyVehicle()
    local maxDistance = (Config.RepairVehicle and Config.RepairVehicle.distance)
        or (Config.DeleteVehicle and Config.DeleteVehicle.distance)
        or 6.0
    local vehicle = getClosestVehicleWithinDistance(maxDistance)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(('Der blev ikke fundet et køretøj inden for %.0f meter.'):format(maxDistance), 'error')
        return false
    end

    if not requestEntityControl(vehicle, 2000) then
        notify('Køretøjet kunne ikke overtages og blev derfor ikke repareret.', 'error')
        return false
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleDirtLevel(vehicle, 0.0)

    for tyreIndex = 0, 7 do
        SetVehicleTyreFixed(vehicle, tyreIndex)
    end

    notify('Køretøjet blev repareret.', 'success')
    return true
end

local function flipNearbyVehicle()
    local maxDistance = (Config.FlipVehicle and Config.FlipVehicle.distance)
        or (Config.RepairVehicle and Config.RepairVehicle.distance)
        or (Config.DeleteVehicle and Config.DeleteVehicle.distance)
        or 6.0
    local vehicle = getClosestVehicleWithinDistance(maxDistance)

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(('Der blev ikke fundet et køretøj inden for %.0f meter.'):format(maxDistance), 'error')
        return false
    end

    if not requestEntityControl(vehicle, 2000) then
        notify('Køretøjet kunne ikke overtages og blev derfor ikke vendt.', 'error')
        return false
    end

    local heading = GetEntityHeading(vehicle)
    local coords = GetEntityCoords(vehicle)

    SetEntityAsMissionEntity(vehicle, true, true)
    FreezeEntityPosition(vehicle, true)
    SetEntityVelocity(vehicle, 0.0, 0.0, 0.0)
    SetEntityRotation(vehicle, 0.0, 0.0, heading, 2, true)
    SetEntityCoordsNoOffset(vehicle, coords.x, coords.y, coords.z + 0.35, false, false, false)
    SetVehicleOnGroundProperly(vehicle)
    FreezeEntityPosition(vehicle, false)
    SetVehicleUndriveable(vehicle, false)

    notify('Køretøjet blev vendt korrekt på hjulene.', 'success')
    return true
end

local function spawnAdminVehicle()
    local input = lib.inputDialog('Spawn køretøj', {
        {
            type = 'input',
            label = 'Modelnavn',
            description = 'Eksempel: adder, sultan eller police',
            placeholder = 'adder',
            required = true,
            min = 1,
            max = 50
        }
    })

    if not input or not input[1] then
        return false
    end

    local modelName = tostring(input[1]):lower():gsub('^%s+', ''):gsub('%s+$', '')

    if modelName == '' then
        notify('Du skal indtaste et modelnavn.', 'error')
        return false
    end

    local model = joaat(modelName)

    if not IsModelInCdimage(model) or not IsModelValid(model) or not IsModelAVehicle(model) then
        notify(('Køretøjsmodellen "%s" findes ikke.'):format(modelName), 'error')
        return false
    end

    RequestModel(model)

    local timeout = GetGameTimer() + ((Config.SpawnVehicle and Config.SpawnVehicle.loadTimeout) or 5000)

    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(model) then
        notify('Køretøjsmodellen kunne ikke indlæses.', 'error')
        SetModelAsNoLongerNeeded(model)
        return false
    end

    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    local distance = (Config.SpawnVehicle and Config.SpawnVehicle.distance) or 4.0
    local spawnCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, distance, 0.5)

    RequestCollisionAtCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)

    local vehicle = CreateVehicle(
        model,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        heading,
        true,
        true
    )

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        notify('Køretøjet kunne ikke spawnes.', 'error')
        SetModelAsNoLongerNeeded(model)
        return false
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleRadioEnabled(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetVehicleNumberPlateText(vehicle, 'SBADMIN')

    local networkId = NetworkGetNetworkIdFromEntity(vehicle)

    if networkId and networkId ~= 0 then
        SetNetworkIdExistsOnAllMachines(networkId, true)
        SetNetworkIdCanMigrate(networkId, true)
    end

    SetPedIntoVehicle(ped, vehicle, -1)
    SetModelAsNoLongerNeeded(model)

    notify(('Køretøjet %s blev spawnet.'):format(modelName), 'success')
    return true
end

local function teleportToCoordinates()
    local ped = PlayerPedId()

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        notify('Din karakter kunne ikke findes.', 'error')
        return false
    end

    local currentCoords = GetEntityCoords(ped)
    local currentHeading = GetEntityHeading(ped)

    local input = lib.inputDialog('Teleportér til koordinater', {
        {
            type = 'number',
            label = 'X',
            description = 'X-koordinaten for destinationen.',
            default = tonumber(('%0.3f'):format(currentCoords.x)),
            required = true
        },
        {
            type = 'number',
            label = 'Y',
            description = 'Y-koordinaten for destinationen.',
            default = tonumber(('%0.3f'):format(currentCoords.y)),
            required = true
        },
        {
            type = 'number',
            label = 'Z',
            description = 'Z-koordinaten for destinationen.',
            default = tonumber(('%0.3f'):format(currentCoords.z)),
            required = true
        },
        {
            type = 'number',
            label = 'Heading',
            description = 'Valgfri retning fra 0 til 360 grader.',
            default = tonumber(('%0.2f'):format(currentHeading)),
            min = 0,
            max = 360,
            required = false
        }
    })

    if not input then
        return false
    end

    local x = tonumber(input[1])
    local y = tonumber(input[2])
    local z = tonumber(input[3])
    local heading = tonumber(input[4]) or currentHeading

    local function isFinite(value)
        return value ~= nil
            and value == value
            and value ~= math.huge
            and value ~= -math.huge
    end

    if not isFinite(x) or not isFinite(y) or not isFinite(z) or not isFinite(heading) then
        notify('Koordinaterne indeholder en ugyldig værdi.', 'error')
        return false
    end

    local settings = Config.TeleportCoordinates or {}
    local xyLimit = tonumber(settings.xyLimit) or 8000.0
    local minZ = tonumber(settings.minZ) or -250.0
    local maxZ = tonumber(settings.maxZ) or 2500.0

    if math.abs(x) > xyLimit or math.abs(y) > xyLimit then
        notify(('X og Y skal være mellem -%s og %s.'):format(xyLimit, xyLimit), 'error')
        return false
    end

    if z < minZ or z > maxZ then
        notify(('Z skal være mellem %s og %s.'):format(minZ, maxZ), 'error')
        return false
    end

    local entity = ped
    if IsPedInAnyVehicle(ped, false) then
        entity = GetVehiclePedIsIn(ped, false)
    end

    saveReturnPosition(entity)

    TriggerServerEvent(
        'sb_admin:server:teleportToCoordinates',
        x + 0.0,
        y + 0.0,
        z + 0.0,
        (heading % 360.0) + 0.0
    )

    return true
end

RegisterNetEvent('sb_admin:client:teleportToCoordinates', function(x, y, z, heading)
    x = tonumber(x)
    y = tonumber(y)
    z = tonumber(z)
    heading = tonumber(heading) or 0.0

    if not x or not y or not z then
        notify('Teleporteringen modtog ugyldige koordinater.', 'error')
        return
    end

    local ped = PlayerPedId()
    if not ped or ped == 0 or not DoesEntityExist(ped) then
        notify('Din karakter kunne ikke findes.', 'error')
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    local hasVehicle = vehicle and vehicle ~= 0 and DoesEntityExist(vehicle)

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    SetPedCoordsKeepVehicle(ped, x, y, 100.0)

    if hasVehicle then
        FreezeEntityPosition(vehicle, true)
    else
        FreezeEntityPosition(ped, true)
    end

    local collisionDeadline = GetGameTimer()
        + ((Config.TeleportCoordinates and Config.TeleportCoordinates.collisionTimeout) or 10000)

    while IsEntityWaitingForWorldCollision(ped)
        and GetGameTimer() < collisionDeadline do
        Wait(100)
    end

    ped = PlayerPedId()
    SetPedCoordsKeepVehicle(ped, x, y, z)
    SetEntityHeading(ped, heading)

    if hasVehicle then
        vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
            SetEntityAlpha(vehicle, 125, false)
            SetEntityCoords(vehicle, x, y, z + 0.5, false, false, false, false)
            SetEntityHeading(vehicle, heading)
            SetPedIntoVehicle(ped, vehicle, -1)
            SetVehicleOnGroundProperly(vehicle)
            SetEntityCollision(vehicle, true, true)
            FreezeEntityPosition(vehicle, false)

            CreateThread(function()
                Wait(2000)
                if DoesEntityExist(vehicle) then
                    ResetEntityAlpha(vehicle)
                end
            end)
        end
    else
        FreezeEntityPosition(ped, false)
    end

    SetGameplayCamRelativeHeading(0.0)
    DoScreenFadeIn(500)

    notify(('Teleporteret til %.2f, %.2f, %.2f.'):format(x, y, z), 'success')
end)

local function copyCurrentCoordinates()
    local ped = PlayerPedId()

    if not ped or ped == 0 or not DoesEntityExist(ped) then
        notify('Din karakter kunne ikke findes.', 'error')
        return false
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local decimals = (Config.CopyCoordinates and Config.CopyCoordinates.decimals) or 2

    decimals = math.min(math.max(math.floor(tonumber(decimals) or 2), 0), 6)

    local input = lib.inputDialog('Kopiér koordinater', {
        {
            type = 'select',
            label = 'Format',
            description = 'Vælg hvordan koordinaterne skal kopieres.',
            required = true,
            default = 'vector4',
            options = {
                { value = 'vector3', label = 'vector3(x, y, z)' },
                { value = 'vector4', label = 'vector4(x, y, z, heading)' },
                { value = 'plain', label = 'x, y, z' },
                { value = 'table', label = '{ x = ..., y = ..., z = ..., w = ... }' }
            }
        }
    })

    if not input or not input[1] then
        return false
    end

    local format = tostring(input[1])
    local numberFormat = '%.' .. decimals .. 'f'
    local x = numberFormat:format(coords.x)
    local y = numberFormat:format(coords.y)
    local z = numberFormat:format(coords.z)
    local h = numberFormat:format(heading)
    local clipboardText

    if format == 'vector3' then
        clipboardText = ('vector3(%s, %s, %s)'):format(x, y, z)
    elseif format == 'plain' then
        clipboardText = ('%s, %s, %s'):format(x, y, z)
    elseif format == 'table' then
        clipboardText = ('{ x = %s, y = %s, z = %s, w = %s }'):format(x, y, z, h)
    else
        clipboardText = ('vector4(%s, %s, %s, %s)'):format(x, y, z, h)
    end

    SendNUIMessage({
        action = 'copyToClipboard',
        text = clipboardText
    })

    return true
end


RegisterNetEvent('sb_admin:client:adminChatMessage', function(message)
    if type(message) ~= 'table' then
        return
    end

    adminChatMessages[#adminChatMessages + 1] = message

    local maxMessages = (Config.AdminChat and Config.AdminChat.historyLimit) or 75
    while #adminChatMessages > maxMessages do
        table.remove(adminChatMessages, 1)
    end

    SendNUIMessage({
        action = 'addChatMessage',
        message = message
    })

    local ownServerId = GetPlayerServerId(PlayerId())
    if tonumber(message.senderId) == ownServerId then
        return
    end

    lib.notify({
        title = 'Admin live chat',
        description = ('%s har skrevet noget i admin live chatten.'):format(message.senderName or 'En admin'),
        type = 'inform',
        position = Config.Notify.position,
        duration = (Config.AdminChat and Config.AdminChat.notifyDuration) or 5000
    })

    if adminChatSoundEnabled then
        PlaySoundFrontend(
            -1,
            (Config.AdminChat and Config.AdminChat.soundName) or 'ATM_WINDOW',
            (Config.AdminChat and Config.AdminChat.soundSet) or 'HUD_FRONTEND_DEFAULT_SOUNDSET',
            true
        )
    end
end)

RegisterNetEvent('sb_admin:client:adminChatTypingUsers', function(users)
    local ownServerId = GetPlayerServerId(PlayerId())
    local visibleUsers = {}

    for _, user in ipairs(type(users) == 'table' and users or {}) do
        if tonumber(user.id) ~= ownServerId then
            visibleUsers[#visibleUsers + 1] = user
        end
    end

    SendNUIMessage({
        action = 'setChatTypingUsers',
        users = visibleUsers
    })
end)

RegisterNetEvent('sb_admin:client:adminChatError', function(message)
    notify(message or 'Beskeden kunne ikke sendes.', 'error')
end)

RegisterNUICallback('adminChatTyping', function(data, cb)
    local isTyping = data and data.typing == true
    setOwnAdminChatTyping(isTyping)
    cb({ ok = true })
end)

RegisterNUICallback('adminChatSubmit', function(data, cb)
    local message = tostring(data and data.message or '')

    setOwnAdminChatTyping(false)
    chatTyping = false
    SetNuiFocus(chatMouseEnabled, chatMouseEnabled)
    TriggerServerEvent('sb_admin:server:sendAdminChatMessage', message)

    cb({ ok = true })
end)

RegisterNUICallback('adminChatCancel', function(_, cb)
    setOwnAdminChatTyping(false)
    chatTyping = false
    SetNuiFocus(chatMouseEnabled, chatMouseEnabled)
    cb({ ok = true })
end)

RegisterNUICallback('adminChatMouseToggle', function(_, cb)
    toggleAdminChatMouse()
    cb({ ok = true, enabled = chatMouseEnabled })
end)

RegisterNUICallback('adminChatSwitchTab', function(_, cb)
    setOwnAdminChatTyping(false)
    chatTyping = false
    setAdminChatMouse(false)
    setActiveTab('menu')
    cb({ ok = true })
end)

RegisterNUICallback('clipboardResult', function(data, cb)
    if data and data.success then
        notify('Koordinaterne blev kopieret til udklipsholderen.', 'success')
    else
        notify('Koordinaterne kunne ikke kopieres automatisk.', 'error')
    end

    cb({ ok = true })
end)


RegisterNUICallback('adminsRefresh', function(_, cb)
    local ok = refreshAdminsTab()
    cb({ ok = ok })
end)

RegisterNUICallback('adminsSave', function(data, cb)
    if not can('manage_admins') or type(data) ~= 'table' then
        cb({ success = false, message = 'Ingen adgang.' })
        return
    end

    local payload = {
        id = data.id,
        name = data.name,
        license = data.license,
        discord = data.discord,
        permissions = data.permissions or {}
    }

    local result = lib.callback.await('sb_admin:server:saveAdmin', false, payload)
    if result and result.success then
        myPermissions = lib.callback.await('sb_admin:server:getMyPermissions', false) or myPermissions
        refreshAdminsTab()
        notify(result.message or 'Adminen blev gemt.', 'success')
    else
        notify(result and result.message or 'Adminen kunne ikke gemmes.', 'error')
    end
    cb(result or { success = false })
end)

RegisterNUICallback('adminsDelete', function(data, cb)
    if not can('manage_admins') then
        cb({ success = false })
        return
    end

    local deleted = lib.callback.await('sb_admin:server:deleteAdmin', false, tonumber(data and data.id))
    if deleted then
        refreshAdminsTab()
        notify('Adminen blev fjernet.', 'success')
    else
        notify('Adminen kunne ikke fjernes.', 'error')
    end
    cb({ success = deleted == true })
end)

RegisterNUICallback('adminsSwitchTab', function(_, cb)
    toggleActiveTab()
    cb({ ok = true })
end)

local function permissionOptions(selected)
    local options, defaults = {}, {}
    for key, label in pairs(Config.AdminPermissions or {}) do
        if key ~= 'access_menu' then
            options[#options+1] = { value=key, label=label }
            if selected and selected[key] == true then defaults[#defaults+1] = key end
        end
    end
    table.sort(options,function(a,b) return a.label < b.label end)
    return options, defaults
end

local function openAdminsMenu()
    setMenu('admins', {{label='Indlæser admins...',description='Vent et øjeblik.',icon='shield',disabled=true}})
    local admins=lib.callback.await('sb_admin:server:getAdmins',false)
    if not admins then notify('Du har ikke adgang til at administrere admins.','error'); setMenu('main',getMainMenuItems(),1); return end
    local items={{action='addAdmin',label='Tilføj admin',description='Tilføj en online spiller og vælg rettigheder.',icon='shield'}}
    for _,a in ipairs(admins) do items[#items+1]={action='editAdmin',admin=a,label=a.display_name,description=tostring(a.discord_identifier or a.license_identifier or 'Intet ID'),icon='shield'} end
    setMenu('admins',items,1)
end

local function editAdminDialog(admin)
    local candidates=lib.callback.await('sb_admin:server:getOnlineAdminCandidates',false) or {}
    local playerOptions={}
    for _,p in ipairs(candidates) do playerOptions[#playerOptions+1]={value=tostring(p.id),label=('[%s] %s'):format(p.id,p.name)} end
    local permOptions, permDefaults = permissionOptions(admin and admin.permissions or nil)
    local input=lib.inputDialog(admin and 'Redigér admin' or 'Tilføj admin',{
        {type='select',label='Online spiller',options=playerOptions,required=not admin,searchable=true},
        {type='input',label='Navn',default=admin and admin.display_name or '',required=admin~=nil},
        {type='multi-select',label='Rettigheder',options=permOptions,default=permDefaults,required=true}
    })
    if not input then openAdminsMenu(); return end
    local license=admin and admin.license_identifier or nil; local discord=admin and admin.discord_identifier or nil; local name=input[2]
    if not admin then
        local sid=tonumber(input[1]); for _,p in ipairs(candidates) do if p.id==sid then license=p.license; discord=p.discord; name=(name and name~='' and name) or p.name break end end
    end
    local perms={}; for _,key in ipairs(input[3] or {}) do perms[key]=true end
    local result=lib.callback.await('sb_admin:server:saveAdmin',false,{id=admin and admin.id or nil,name=name,license=license,discord=discord,permissions=perms})
    notify(result and result.success and 'Adminen blev gemt.' or (result and result.message or 'Adminen kunne ikke gemmes.'),result and result.success and 'success' or 'error')
    openAdminsMenu()
end

local function activateSelectedItem()
    local item = menuItems[selectedIndex]

    if not item or item.disabled then
        return
    end

    if currentMenu == 'main' and item.action == 'admins' then
        openAdminsMenu()
        return
    end

    if currentMenu == 'admins' and item.action == 'addAdmin' then
        editAdminDialog(nil)
        return
    end

    if currentMenu == 'admins' and item.action == 'editAdmin' then
        setMenu('adminEdit', {
            {action='editAdminPermissions', admin=item.admin, label='Redigér rettigheder', description='Vælg præcis hvilke funktioner adminen må bruge.', icon='shield'},
            {action='deleteAdmin', admin=item.admin, label='Fjern admin', description='Fjern personens adgang til adminmenuen.', icon='deletevehicle'}
        }, 1)
        return
    end

    if currentMenu == 'adminEdit' and item.action == 'editAdminPermissions' then
        editAdminDialog(item.admin)
        return
    end

    if currentMenu == 'adminEdit' and item.action == 'deleteAdmin' then
        local result=lib.alertDialog({header='Fjern admin',content=('Er du sikker på, at %s skal miste adgang?'):format(item.admin.display_name),centered=true,cancel=true,labels={confirm='Fjern',cancel='Annullér'}})
        if result=='confirm' then
            local deleted=lib.callback.await('sb_admin:server:deleteAdmin',false,item.admin.id)
            notify(deleted and 'Adminen blev fjernet.' or 'Adminen kunne ikke fjernes.',deleted and 'success' or 'error')
            openAdminsMenu()
        end
        return
    end

    if currentMenu == 'main' and item.action == 'players' then
        openPlayerMenu()
        return
    end

    if currentMenu == 'main' and item.action == 'announcement' then
        local input = lib.inputDialog('Servermeddelelse', {
            {
                type = 'textarea',
                label = 'Besked',
                description = 'Beskeden bliver vist til alle online spillere.',
                placeholder = 'Skriv servermeddelelsen her...',
                required = true,
                min = 1,
                max = (Config.Announcement and Config.Announcement.maxLength) or 300
            }
        })

        if not input or not input[1] then
            setMenu('main', getMainMenuItems(), selectedIndex)
            return
        end

        local result = lib.callback.await('sb_admin:server:sendAnnouncement', false, input[1])

        if not result then
            notify('Meddelelsen kunne ikke sendes, eller du har mistet adgang.', 'error')
            return
        end

        notify('Servermeddelelsen blev sendt.', 'success')
        setMenu('main', getMainMenuItems(), selectedIndex)
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

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'togglePlayerIds' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        togglePlayerIds()

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'deleteVehicle' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        deleteNearbyVehicle()

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'repairVehicle' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        repairNearbyVehicle()

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'flipVehicle' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        flipNearbyVehicle()

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'spawnVehicle' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        spawnAdminVehicle()

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

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'teleportCoordinates' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        teleportToCoordinates()

        setMenu('main', getMainMenuItems(), selectedIndex)
        return
    end

    if currentMenu == 'main' and item.action == 'copyCoordinates' then
        local allowed = lib.callback.await('sb_admin:server:hasPermission', false)

        if not allowed then
            notify('Du har ikke længere adgang til adminmenuen.', 'error')
            closeMenu()
            return
        end

        copyCurrentCoordinates()

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

        notify(('Du blev teleporteret til %s.'):format(result.name or 'spilleren'), 'success')
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'bringPlayer' then
        local result = lib.callback.await('sb_admin:server:bringPlayer', false, item.playerId)

        if not result then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

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

        openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
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


    if currentMenu == 'playerDetails' and item.action == 'viewPlayerNotes' then
        openPlayerNotes(item.playerId, selectedIndex, 1)
        return
    end

    if currentMenu == 'playerNotes' and item.action == 'addPlayerNote' then
        local input = lib.inputDialog('Tilføj spillernote', {
            {
                type = 'textarea',
                label = 'Note',
                description = 'Skriv hvad staff skal være opmærksom på.',
                required = true,
                min = 1,
                max = (Config.PlayerNotes and Config.PlayerNotes.maxLength) or 500
            }
        })

        if not input or not input[1] then
            openPlayerNotes(item.playerId, playerNotesReturnIndex, selectedIndex)
            return
        end

        local result = lib.callback.await('sb_admin:server:addPlayerNote', false, item.playerId, input[1])
        notify(result and result.message or 'Noten kunne ikke tilføjes.', result and result.success and 'success' or 'error')
        openPlayerNotes(item.playerId, playerNotesReturnIndex, 1)
        return
    end

    if currentMenu == 'playerNotes' and item.action == 'deletePlayerNote' then
        local confirm = lib.alertDialog({
            header = ('Slet note #%s?'):format(item.noteId),
            content = 'Noten bliver skjult både i FiveM-adminmenuen og Discord-botten.',
            centered = true,
            cancel = true,
            labels = { confirm = 'Slet', cancel = 'Annuller' }
        })

        if confirm == 'confirm' then
            local result = lib.callback.await('sb_admin:server:deletePlayerNote', false, item.noteId)
            notify(result and result.message or 'Noten kunne ikke slettes.', result and result.success and 'success' or 'error')
        end

        openPlayerNotes(item.playerId, playerNotesReturnIndex, selectedIndex)
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'viewInventory' then
        openPlayerInventory(item.playerId, selectedIndex)
        return
    end

    if currentMenu == 'playerInventory' and item.action == 'removeInventoryItem' then
        local maxAmount = math.max(tonumber(item.itemCount) or 0, 1)
        local input = lib.inputDialog('Fjern item', {
            {
                type = 'number',
                label = 'Antal',
                description = ('Fjern %s fra %s. Spilleren har %s.'):format(
                    item.itemLabel or item.itemName or 'item',
                    selectedPlayerName or 'spilleren',
                    maxAmount
                ),
                default = 1,
                required = true,
                min = 1,
                max = maxAmount
            }
        })

        if not input or not input[1] then
            setMenu('playerInventory', menuItems, selectedIndex)
            return
        end

        local amount = math.floor(tonumber(input[1]) or 0)
        local result = lib.callback.await(
            'sb_admin:server:removePlayerInventoryItem',
            false,
            item.playerId or selectedPlayerId,
            item.itemName,
            amount,
            item.itemSlot
        )

        if not result or not result.success then
            notify(result and result.message or 'Itemet kunne ikke fjernes.', 'error')
            openPlayerInventory(selectedPlayerId, playerDetailsReturnIndex, selectedIndex)
            return
        end

        notify(result.message or 'Itemet blev fjernet.', 'success')
        openPlayerInventory(selectedPlayerId, playerDetailsReturnIndex, selectedIndex)
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'giveVehicle' then
        local garageResult = lib.callback.await('sb_admin:server:getGiveVehicleGarages', false)

        if not garageResult or not garageResult.success or type(garageResult.garages) ~= 'table' then
            notify(
                garageResult and garageResult.message or 'Garagerne kunne ikke hentes fra OP Garages.',
                'error'
            )
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
            return
        end

        local garageOptions = garageResult.garages

        local input = lib.inputDialog('Giv køretøj', {
            {
                type = 'input',
                label = 'Modelnavn',
                description = 'Eksempel: adder, sultan eller police.',
                placeholder = 'adder',
                required = true,
                min = 1,
                max = 50
            },
            {
                type = 'input',
                label = 'Nummerplade',
                description = 'Valgfrit. Efterlad tomt for automatisk nummerplade.',
                placeholder = 'Automatisk',
                required = false,
                max = 8
            },
            {
                type = 'select',
                label = 'Garage',
                description = 'Vælg den garage, køretøjet skal placeres i.',
                required = true,
                searchable = true,
                options = garageOptions
            }
        })

        if not input or not input[1] then
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
            return
        end

        local modelName = tostring(input[1]):lower():gsub('^%s+', ''):gsub('%s+$', '')
        local modelHash = joaat(modelName)

        if modelName == '' or not IsModelInCdimage(modelHash) or not IsModelAVehicle(modelHash) then
            notify('Køretøjsmodellen findes ikke eller er ikke et køretøj.', 'error')
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
            return
        end

        local selectedGarageId = tostring(input[3] or '')
        local result = lib.callback.await('sb_admin:server:giveVehicle', false, item.playerId, {
            model = modelHash,
            modelName = modelName,
            plate = input[2] or '',
            garageId = selectedGarageId,
            garageLabel = garageLabels and garageLabels[selectedGarageId] or ('Garage #' .. selectedGarageId)
        })

        if not result or not result.success then
            notify(result and result.message or 'Køretøjet kunne ikke gives.', 'error')
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
            return
        end

        notify(
            ('%s modtog %s med nummerpladen %s.'):format(
                result.name or 'Spilleren',
                result.modelName or modelName,
                result.plate or 'ukendt'
            ),
            'success'
        )

        openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
        return
    end

    if currentMenu == 'playerDetails' and item.action == 'spectatePlayer' then
        if spectating and spectateTargetId == tonumber(item.playerId) then
            restoreSpectateState(true)
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
            return
        end

        local result = lib.callback.await('sb_admin:server:getSpectateTarget', false, item.playerId)

        if not result or not result.coords then
            notify('Spilleren er ikke længere online, eller du har mistet adgang.', 'error')
            return
        end

        if startSpectate(item.playerId, result.name, result.coords) then
            openPlayerDetails(item.playerId, selectedPlayerListIndex, selectedIndex)
        end

        return
    end

end

RegisterNetEvent('sb_admin:client:vehicleReceived', function(data)
    if type(data) ~= 'table' then
        return
    end

    notify(
        ('Du har modtaget køretøjet %s med nummerpladen %s. Det kan findes i din garage.'):format(
            tostring(data.modelName or 'ukendt'),
            tostring(data.plate or 'ukendt')
        ),
        'success'
    )
end)

RegisterNetEvent('sb_admin:client:showAnnouncement', function(data)
    if type(data) ~= 'table' then
        return
    end

    local message = tostring(data.message or '')

    if message == '' then
        return
    end

    lib.notify({
        title = 'Servermeddelelse',
        description = message,
        type = 'inform',
        position = (Config.Announcement and Config.Announcement.position) or 'top',
        duration = (Config.Announcement and Config.Announcement.duration) or 10000
    })
end)

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

    FreezeEntityPosition(ped, false)

    if IsPedInAnyVehicle(ped, false) then
        FreezeEntityPosition(GetVehiclePedIsIn(ped, false), false)
    end

    notify(('Du blev genoplivet af %s.'):format(adminName or 'en administrator'), 'success')
end)

RegisterNetEvent('sb_admin:client:inventoryItemRemoved', function(data)
    data = type(data) == 'table' and data or {}

    notify(
        ('%s x %s blev fjernet fra dit inventory af %s.'):format(
            tonumber(data.amount) or 0,
            data.label or data.name or 'item',
            data.adminName or 'en administrator'
        ),
        'inform'
    )
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
    if currentMenu == 'playerNotes' then
        openPlayerDetails(selectedPlayerId, selectedPlayerListIndex, playerNotesReturnIndex)
        return
    end

    if currentMenu == 'playerInventory' then
        openPlayerDetails(selectedPlayerId, selectedPlayerListIndex, playerDetailsReturnIndex)
        return
    end

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

    if currentMenu == 'admins' or currentMenu == 'adminEdit' then
        setMenu('main', getMainMenuItems(), 1)
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
    'Åbn Vitality Admin',
    'keyboard',
    Config.DefaultKey
)

CreateThread(function()
    while true do
        if not menuOpen then
            Wait(500)
        elseif chatTyping or chatMouseEnabled or activeTab == 'admins' then
            Wait(100)
        else
            Wait(0)

            DisableControlAction(0, 37, true)  -- Tab
            DisableControlAction(0, 182, true) -- L (adminchat-lyd)
            DisableControlAction(0, 244, true) -- M (frigiv mus)
            DisableControlAction(0, 172, true) -- Arrow Up
            DisableControlAction(0, 173, true) -- Arrow Down
            DisableControlAction(0, 174, true) -- Arrow Left
            DisableControlAction(0, 175, true) -- Arrow Right
            DisableControlAction(0, 191, true) -- Enter
            DisableControlAction(0, 201, true) -- Enter
            DisableControlAction(0, 177, true) -- Backspace
            DisableControlAction(0, 200, true) -- Escape/Pause

            if IsDisabledControlJustPressed(0, 37) then
                toggleActiveTab()
            elseif activeTab == 'chat' then
                if IsDisabledControlJustPressed(0, 244) then
                    toggleAdminChatMouse()
                elseif IsDisabledControlJustPressed(0, 182) then
                    toggleAdminChatSound()
                elseif IsDisabledControlJustPressed(0, 191)
                    or IsDisabledControlJustPressed(0, 201) then
                    beginChatInput()
                elseif IsDisabledControlJustPressed(0, 177) then
                    setActiveTab('menu')
                elseif IsDisabledControlJustPressed(0, 200) then
                    closeMenu()
                end
            else
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
    playerIdsEnabled = false
    setOwnAdminChatTyping(false)
    chatTyping = false
    applyInvisibilityState()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
end)
