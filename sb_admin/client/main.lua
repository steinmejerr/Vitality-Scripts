local function locale(key)
    local selectedLocale = Locales[Config.Locale] or Locales.da or Locales.en
    return selectedLocale[key] or key
end

local function notify(notificationType, title, description)
    lib.notify({
        type = notificationType,
        title = title,
        description = description
    })
end

local function registerAdminMenu()
    lib.registerContext({
        id = 'sb_admin_main_menu',
        title = locale('menu_title'),
        options = {
            {
                title = locale('welcome_title'),
                description = locale('welcome_description'),
                icon = 'shield-halved',
                disabled = true
            }
        }
    })
end

local function openAdminMenu()
    local success, isAllowed = pcall(function()
        return lib.callback.await('sb_admin:server:hasPermission', false)
    end)

    if not success then
        notify('error', locale('callback_error_title'), locale('callback_error_description'))
        return
    end

    if not isAllowed then
        notify('error', locale('no_permission_title'), locale('no_permission_description'))
        return
    end

    lib.showContext('sb_admin_main_menu')
end

CreateThread(registerAdminMenu)

RegisterCommand(Config.Command, openAdminMenu, false)

lib.addKeybind({
    name = 'sb_admin_open_menu',
    description = locale('menu_description'),
    defaultKey = Config.Keybind,
    onPressed = openAdminMenu
})
