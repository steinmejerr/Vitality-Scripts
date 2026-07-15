Config = {}

Config.UseOxInventory = true
Config.PaymentAccount = 'money'

Config.Shop = {
    ped = {
        model = `a_m_m_hillbilly_01`,
        coords = vec4(-1603.64, 5256.72, 2.08, 25.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    blip = {
        enabled = true,
        sprite = 587,
        colour = 5,
        scale = 0.75,
        label = 'Metaldetektor'
    }
}

Config.Detector = {
    item = 'metal_detector',
    label = 'Metaldetektor',
    price = 2500,
    model = `w_am_metaldetector`,
    bone = 28422,
    offset = vec3(0.15, 0.02, -0.02),
    rotation = vec3(-80.0, 5.0, -15.0),
    toggleCommand = 'metaldetector',
    toggleKey = 'J'
}

Config.Search = {
    minFindDistance = 1.45,
    maxSignalDistance = 18.0,
    interactKey = 38, -- E
    digDuration = 5000,
    respawnSeconds = 180,
    maxActiveFindsPerPlayer = 1,
    signalSound = {
        name = 'NAV_UP_DOWN',
        set = 'HUD_FRONTEND_DEFAULT_SOUNDSET'
    }
}

Config.Zones = {
    {
        id = 'vespucci_beach',
        label = 'Vespucci Beach',
        center = vec3(-1484.0, -1232.0, 1.0),
        radius = 240.0,
        minZ = -3.0,
        maxZ = 8.0,
        findCount = 35
    },
    {
        id = 'del_perro_beach',
        label = 'Del Perro Beach',
        center = vec3(-1785.0, -879.0, 6.0),
        radius = 170.0,
        minZ = -2.0,
        maxZ = 12.0,
        findCount = 24
    }
}

Config.Finds = {
    scrap_metal = {
        item = 'md_scrap_metal',
        label = 'Metalskrot',
        weight = 38,
        amount = { min = 1, max = 3 },
        sellPrice = 85
    },
    old_coin = {
        item = 'md_old_coin',
        label = 'Gammel mønt',
        weight = 28,
        amount = { min = 1, max = 2 },
        sellPrice = 175
    },
    silver_ring = {
        item = 'md_silver_ring',
        label = 'Sølvring',
        weight = 18,
        amount = { min = 1, max = 1 },
        sellPrice = 450
    },
    gold_chain = {
        item = 'md_gold_chain',
        label = 'Guldkæde',
        weight = 10,
        amount = { min = 1, max = 1 },
        sellPrice = 850
    },
    antique_watch = {
        item = 'md_antique_watch',
        label = 'Antikt ur',
        weight = 5,
        amount = { min = 1, max = 1 },
        sellPrice = 1450
    },
    treasure_token = {
        item = 'md_treasure_token',
        label = 'Sjælden medaljon',
        weight = 1,
        amount = { min = 1, max = 1 },
        sellPrice = 3500
    }
}
