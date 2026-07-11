local menuOpen = false
local selectedIndex = 1
local currentMenu = 'main'
local menuItems = {}
local playerRefreshToken = 0
local selectedPlayerId = nil
local selectedPlayerListIndex = 1
local selectedPlayerName = nil

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

local function activateSelectedItem()
    local item = menuItems[selectedIndex]

    if not item or item.disabled then
        return
    end

    if currentMenu == 'main' and item.action == 'players' then
        openPlayerMenu()
        return
    end

    if currentMenu == 'players' and item.action == 'player' then
        openPlayerDetails(item.playerId, selectedIndex)
        return
    end
end

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

    SetNuiFocus(false, false)
end)
