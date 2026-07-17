Config = {}

Config.Command = 'admin'

Config.DefaultKey = 'F10'

Config.AllowedGroups = {
    admin = true,
    superadmin = true
}

Config.Notify = {
    position = 'top-right',
    duration = 3500
}


Config.AmbulanceResource = 'p_ambulancejob'


Config.Noclip = {
    speed = 0.65,
    fastSpeed = 2.5,
    slowSpeed = 0.2
}

Config.PlayerIds = {
    distance = 75.0
}


Config.DeleteVehicle = {
    distance = 6.0
}


Config.RepairVehicle = {
    distance = 6.0
}


Config.SpawnVehicle = {
    distance = 4.0,

    loadTimeout = 5000
}


Config.FlipVehicle = {
    distance = 6.0
}


Config.Announcement = {
    maxLength = 300,

    duration = 10000,

    position = 'top'
}


Config.TeleportCoordinates = {
    xyLimit = 8000.0,

    minZ = -250.0,
    maxZ = 2500.0,

    teleportTimeout = 5000
}


Config.CopyCoordinates = {
    decimals = 2
}


Config.GiveVehicle = {
    resource = 'op-garages',
    table = 'owned_vehicles',

    garageTable = nil,

    defaultGarageId = nil,

    plateLength = 8,
    platePrefix = 'SB',

    extraColumns = {}
}


Config.AdminChat = {
    soundDefault = true,

    notifyDuration = 5000,

    soundName = 'ATM_WINDOW',
    soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET',

    maxLength = 250,

    historyLimit = 75,

    cooldownMs = 750,

    typingTimeoutMs = 5000
}


Config.PlayerNotes = {
    maxLength = 500
}


Config.AdminPermissions = {
    access_menu = 'Åbn adminmenu',
    manage_admins = 'Administrér admins',
    admin_chat = 'Live adminchat',
    players_view = 'Se spillere',
    announcement = 'Send announcements',
    noclip = 'Noclip',
    godmode = 'Godmode',
    invisibility = 'Usynlighed',
    player_ids = 'Vis spiller-ID’er',
    vehicle_delete = 'Slet køretøj',
    vehicle_repair = 'Reparér køretøj',
    vehicle_flip = 'Vend køretøj',
    vehicle_spawn = 'Spawn køretøj',
    teleport_waypoint = 'Teleportér til waypoint',
    teleport_coordinates = 'Teleportér til koordinater',
    copy_coordinates = 'Kopiér koordinater',
    return_position = 'Returnér til position',
    player_goto = 'Gå til spiller',
    player_bring = 'Bring spiller',
    player_freeze = 'Frys spiller',
    player_revive = 'Genopliv spiller',
    player_spectate = 'Spectate spiller',
    player_notes_view = 'Se spillernoter',
    player_notes_manage = 'Opret/slet spillernoter',
    inventory_view = 'Se inventory',
    inventory_remove = 'Fjern items',
    vehicle_give = 'Giv permanent køretøj'
}
