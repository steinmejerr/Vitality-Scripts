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
