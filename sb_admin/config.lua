Config = {}

-- Kommandoen, der åbner adminmenuen.
Config.Command = 'admin'

-- Standardtast til at åbne menuen.
-- Spilleren kan selv ændre den under FiveM key bindings.
Config.DefaultKey = 'F10'

-- ESX-grupper, der må åbne adminmenuen.
Config.AllowedGroups = {
    admin = true,
    superadmin = true
}

Config.Notify = {
    position = 'top-right',
    duration = 3500
}


-- Revive-integrationen bruger Piotreq Ambulance Job v2's officielle event.
-- Resource-navnet er normalt p_ambulancejob.
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
    -- Afstand i meter, når administratoren ikke sidder i et køretøj.
    distance = 6.0
}


Config.RepairVehicle = {
    -- Afstand i meter, når administratoren ikke sidder i et køretøj.
    distance = 6.0
}


Config.SpawnVehicle = {
    -- Hvor langt foran administratoren køretøjet spawnes.
    distance = 4.0,

    -- Maksimal ventetid på indlæsning af køretøjsmodellen.
    loadTimeout = 5000
}


Config.FlipVehicle = {
    -- Afstand i meter, når administratoren ikke sidder i et køretøj.
    distance = 6.0
}


Config.Announcement = {
    -- Maksimalt antal tegn i en servermeddelelse.
    maxLength = 300,

    -- Hvor længe meddelelsen vises hos spillerne.
    duration = 10000,

    -- Placering af ox_lib-meddelelsen.
    position = 'top'
}


Config.TeleportCoordinates = {
    -- GTA V-kortets sikre område for X og Y.
    xyLimit = 8000.0,

    -- Sikre grænser for højden.
    minZ = -250.0,
    maxZ = 2500.0,

    -- Maksimal ventetid på GTA's indbyggede teleport-system.
    teleportTimeout = 5000
}


Config.CopyCoordinates = {
    -- Antal decimaler i de kopierede koordinater.
    decimals = 2
}


-- Permanent køretøjstildeling til OP Garages V3.
Config.GiveVehicle = {
    -- Resource-mappen skal normalt hedde præcis 'op-garages'.
    resource = 'op-garages',
    table = 'owned_vehicles',

    -- Lad være nil for automatisk registrering. Hvis det fejler, skriv navnet på
    -- OP Garages-tabellen her, fx 'op_garages'.
    garageTable = nil,

    -- Valgfri fallback. Normalt vælger adminen garage i dropdown-menuen.
    defaultGarageId = nil,

    plateLength = 8,
    platePrefix = 'SB',

    -- Kun eksisterende kolonner bliver tilføjet.
    extraColumns = {}
}


Config.AdminChat = {
    -- Om chatlyd er slået til som standard for nye admins.
    soundDefault = true,

    -- ox_lib-notifikation ved nye beskeder fra andre admins.
    notifyDuration = 5000,

    -- GTA frontend-lyd. Kan ændres til en anden lyd, hvis ønsket.
    soundName = 'ATM_WINDOW',
    soundSet = 'HUD_FRONTEND_DEFAULT_SOUNDSET',

    -- Maksimalt antal tegn i én besked.
    maxLength = 250,

    -- Antal beskeder, der beholdes i hukommelsen, mens resource kører.
    historyLimit = 75,

    -- Minimumstid mellem beskeder fra samme admin.
    cooldownMs = 750,

    -- Hvor længe en skriveindikator må stå uden nyt heartbeat.
    typingTimeoutMs = 5000
}
