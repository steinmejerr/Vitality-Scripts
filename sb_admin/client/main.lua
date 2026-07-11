local menuOpen = false
local selectedIndex = 1

local menuItems = {
    {
        label = 'Adminmenu',
        description = 'Menuens fundament er installeret og virker.',
        icon = 'shield',
        disabled = true
    }
}

local function notify(description, notifyType)
    lib.notify({
        title = 'SB Admin',
        description = description,
        type = notifyType or 'inform',
        position = Config.Notify.position,
        duration = Config.Notify.duration
    })
end

local function sendMenuState()
    SendNUIMessage({
        action = 'setMenu',
        visible = menuOpen,
        selectedIndex = selectedIndex,
        items = menuItems
    })
end

local function closeMenu()
    if not menuOpen then
        return
    end

    menuOpen = false
    selectedIndex = 1

    SendNUIMessage({
        action = 'close'
    })
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
    selectedIndex = 1

    -- NUI får ikke tastatur- eller musefokus.
    -- Spilleren kan derfor stadig bevæge sig rundt.
    SetNuiFocus(false, false)
    sendMenuState()
end

local function moveSelection(direction)
    if #menuItems == 0 then
        return
    end

    local newIndex = selectedIndex

    repeat
        newIndex = newIndex + direction

        if newIndex > #menuItems then
            newIndex = 1
        elseif newIndex < 1 then
            newIndex = #menuItems
        end

        if newIndex == selectedIndex then
            break
        end
    until not menuItems[newIndex].disabled

    selectedIndex = newIndex

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

    -- De første rigtige adminfunktioner tilføjes her senere.
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

            -- Piletaster
            DisableControlAction(0, 172, true) -- Arrow Up
            DisableControlAction(0, 173, true) -- Arrow Down
            DisableControlAction(0, 174, true) -- Arrow Left
            DisableControlAction(0, 175, true) -- Arrow Right

            -- Enter, Backspace og Pause/Escape
            DisableControlAction(0, 191, true)
            DisableControlAction(0, 201, true)
            DisableControlAction(0, 177, true)
            DisableControlAction(0, 200, true)

            if IsDisabledControlJustPressed(0, 172) then
                moveSelection(-1)
            elseif IsDisabledControlJustPressed(0, 173) then
                moveSelection(1)
            elseif IsDisabledControlJustPressed(0, 191)
                or IsDisabledControlJustPressed(0, 201) then
                activateSelectedItem()
            elseif IsDisabledControlJustPressed(0, 177)
                or IsDisabledControlJustPressed(0, 200) then
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
