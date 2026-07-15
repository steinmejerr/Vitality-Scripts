Config = {}

Config.Locale = 'da'
Config.Debug = false

Config.InteractionDistance = 2.0
Config.PaymentAccount = 'bank'
Config.UseOxInventory = true

Config.MissionCooldownSeconds = 2 * 60 * 60

Config.Notify = {
    position = 'top-right',
    duration = 4500
}

Config.Shop = {
    title = 'Pacific Diving Supply',
    items = {
        {
            name = 'diving_gear',
            label = 'Komplet dykkerudstyr',
            description = 'Iltflaske, regulator, maske og finner.',
            price = 7500,
            icon = 'scuba'
        }
    }
}

Config.Items = {
    gear = 'diving_gear',
    finds = {
        old_coin = {
            label = 'Gammel mønt',
            sellPrice = 350,
            weight = 65
        },
        coral_fragment = {
            label = 'Koralfund',
            sellPrice = 525,
            weight = 45
        },
        antique_watch = {
            label = 'Antikt ur',
            sellPrice = 1100,
            weight = 24
        },
        pearl = {
            label = 'Perle',
            sellPrice = 1650,
            weight = 15
        },
        sealed_case = {
            label = 'Forseglet værdikasse',
            sellPrice = 2800,
            weight = 6
        }
    }
}


Config.Chests = {
    common = {
        item = 'diving_chest_common',
        label = 'Slidt dykkerkiste',
        weight = 60,
        rolls = { min = 1, max = 2 },
        loot = {
            old_coin = { weight = 60, min = 1, max = 3 },
            coral_fragment = { weight = 40, min = 1, max = 2 }
        }
    },
    uncommon = {
        item = 'diving_chest_uncommon',
        label = 'Forseglet dykkerkiste',
        weight = 30,
        rolls = { min = 2, max = 3 },
        loot = {
            old_coin = { weight = 35, min = 1, max = 3 },
            coral_fragment = { weight = 30, min = 1, max = 2 },
            antique_watch = { weight = 25, min = 1, max = 1 },
            pearl = { weight = 10, min = 1, max = 1 }
        }
    },
    rare = {
        item = 'diving_chest_rare',
        label = 'Sjælden dykkerkiste',
        weight = 10,
        rolls = { min = 2, max = 4 },
        loot = {
            antique_watch = { weight = 40, min = 1, max = 2 },
            pearl = { weight = 35, min = 1, max = 2 },
            sealed_case = { weight = 25, min = 1, max = 1 }
        }
    }
}

Config.Locations = {
    {
        id = 'vespucci',
        label = 'Vespucci Diving',
        ped = {
            model = 's_m_y_baywatch_01',
            coords = vec4(-1604.72, -1072.02, 13.02, 139.0),
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        },
        blip = {
            enabled = true,
            sprite = 597,
            colour = 3,
            scale = 0.78,
            label = 'Dykkercenter'
        }
    }
}

Config.Missions = {
    {
        id = 'coastal_recovery',
        label = 'Kystfund',
        difficulty = 'Let',
        description = 'Undersøg havbunden efter tabte dykkerkister.',
        duration = 15,
        deposit = 500,
        requiredSearches = 4,
        rewardBonus = 800,
        area = {
            center = vec3(-1825.08, -1268.06, -2.0),
            radius = 85.0
        },
        searchPoints = {
            vec3(-1818.49, -1241.62, -4.35),
            vec3(-1845.82, -1253.56, -7.25),
            vec3(-1861.01, -1289.26, -9.15),
            vec3(-1801.86, -1303.10, -6.40),
            vec3(-1779.45, -1273.92, -4.80),
            vec3(-1830.22, -1318.67, -10.10)
        },
        chestPool = { common = 70, uncommon = 25, rare = 5 }
    },
    {
        id = 'wreck_salvage',
        label = 'Vragbjærgning',
        difficulty = 'Mellem',
        description = 'Dyk ved et ældre vrag og bjærg kister fra havbunden.',
        duration = 22,
        deposit = 1200,
        requiredSearches = 5,
        rewardBonus = 1800,
        area = {
            center = vec3(-2835.60, -470.20, -23.0),
            radius = 110.0
        },
        searchPoints = {
            vec3(-2814.94, -446.18, -18.80),
            vec3(-2840.25, -435.92, -25.50),
            vec3(-2867.35, -468.61, -29.20),
            vec3(-2847.94, -500.37, -31.00),
            vec3(-2808.42, -505.85, -22.60),
            vec3(-2789.70, -475.42, -19.30),
            vec3(-2878.24, -430.55, -28.40)
        },
        chestPool = { common = 45, uncommon = 40, rare = 15 }
    },
    {
        id = 'deep_blue',
        label = 'Dybhavsfund',
        difficulty = 'Svær',
        description = 'En risikofyldt mission efter sjældne kister på dybt vand.',
        duration = 30,
        deposit = 2500,
        requiredSearches = 6,
        rewardBonus = 3500,
        area = {
            center = vec3(3194.24, -387.44, -42.0),
            radius = 135.0
        },
        searchPoints = {
            vec3(3167.30, -350.44, -38.50),
            vec3(3215.82, -349.29, -46.20),
            vec3(3250.08, -389.67, -52.40),
            vec3(3219.33, -434.06, -48.60),
            vec3(3167.47, -438.75, -43.90),
            vec3(3128.52, -398.01, -39.40),
            vec3(3262.10, -443.67, -55.00),
            vec3(3138.68, -326.51, -36.80)
        },
        chestPool = { common = 20, uncommon = 45, rare = 35 }
    }
}


Config.MissionHud = {
    enabled = true,
    position = 'left-center',
    guide = {
        'Tag dykkerudstyret på.',
        'Følg GPS-ruten til dykkerområdet.',
        'Dyk ned til kisten med den grønne pil.',
        'Tryk E tæt på kisten for at samle den op.',
        'Åbn kisterne fra dit inventory bagefter.'
    }
}

Config.Search = {
    pickupDuration = 3500,
    distance = 2.2,
    prompt = '[E] Saml dykkerkiste op',

    animation = {
        dict = 'pickup_object',
        clip = 'pickup_low',
        flag = 1
    },

    chestProp = 'prop_box_wood05a',
    headingRandom = true,

    placeOnSeabed = true,
    seabedProbeHeight = 5.0,
    seabedOffset = 0.05,
    collisionTimeout = 2500,

    marker = {
        type = 2,
        height = 0.75,
        drawDistance = 45.0,
        scale = vec3(0.24, 0.24, 0.24),
        color = { r = 82, g = 255, b = 170, a = 210 }
    }
}

Config.Diving = {
    oxygenSeconds = 900,
    swimMultiplier = 1.12,
    removeGearOnDeath = false,

    props = {
        tank = {
            enabled = false,
            model = 'p_s_scuba_tank_s',
            bone = 24818,
            offset = vec3(-0.02, -0.22, 0.02),
            rotation = vec3(180.0, 0.0, 0.0)
        },
        mask = {
            enabled = false,
            model = 'p_s_scuba_mask_s',
            bone = 12844,
            offset = vec3(0.0, 0.0, 0.0),
            rotation = vec3(0.0, 90.0, 180.0)
        }
    },

    outfit = {
        enabled = true,
        male = {
            [3] = { drawable = 17, texture = 0 },
            [4] = { drawable = 94, texture = 0 },
            [6] = { drawable = 67, texture = 0 },
            [8] = { drawable = 151, texture = 0 },
            [11] = { drawable = 243, texture = 0 }
        },
        female = {
            [3] = { drawable = 18, texture = 0 },
            [4] = { drawable = 97, texture = 0 },
            [6] = { drawable = 70, texture = 0 },
            [8] = { drawable = 187, texture = 0 },
            [11] = { drawable = 251, texture = 0 }
        }
    },

    lowOxygenWarnings = { 25, 10 }
}
