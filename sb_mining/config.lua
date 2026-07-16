Config = {}

Config.UseOxInventory = true
Config.PaymentAccount = 'money'
Config.XPPerRock = 20
Config.OresPerRock = 4
Config.PartyInviteDistance = 15.0
Config.MaxPartySize = 4
Config.MissionCooldownSeconds = 300

Config.Shop = {
    ped = {
        model = `s_m_y_construct_01`,
        coords = vector4(2943.28, 2745.81, 43.29, 291.40),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    table = {
        model = `prop_table_03`,
        offset = vec3(0.0, 0.82, 0.0),
        headingOffset = 0.0
    },
    blip = {
        enabled = true,
        sprite = 618,
        colour = 5,
        scale = 0.8,
        label = 'Minearbejde'
    }
}

Config.Pickaxes = {
    basic = {
        item = 'mining_pickaxe_basic',
        label = 'Slidt hakke',
        price = 750,
        requiredLevel = 1,
        speedMultiplier = 1.0,
        durability = 40
    },
    iron = {
        item = 'mining_pickaxe_iron',
        label = 'Jernhakke',
        price = 2500,
        requiredLevel = 3,
        speedMultiplier = 0.85,
        durability = 80
    },
    steel = {
        item = 'mining_pickaxe_steel',
        label = 'Stålhakke',
        price = 6000,
        requiredLevel = 6,
        speedMultiplier = 0.70,
        durability = 140
    },
    industrial = {
        item = 'mining_pickaxe_industrial',
        label = 'Industriforstærket hakke',
        price = 14000,
        requiredLevel = 10,
        speedMultiplier = 0.55,
        durability = 240
    }
}

Config.Levels = {
    [1] = { xp = 0, sellMultiplier = 1.00 },
    [2] = { xp = 180, sellMultiplier = 1.05 },
    [3] = { xp = 420, sellMultiplier = 1.10 },
    [4] = { xp = 760, sellMultiplier = 1.15 },
    [5] = { xp = 1200, sellMultiplier = 1.20 },
    [6] = { xp = 1750, sellMultiplier = 1.28 },
    [7] = { xp = 2450, sellMultiplier = 1.36 },
    [8] = { xp = 3300, sellMultiplier = 1.45 },
    [9] = { xp = 4300, sellMultiplier = 1.55 },
    [10] = { xp = 5500, sellMultiplier = 1.70 }
}

Config.Ores = {
    stone = { item = 'mining_stone', label = 'Sten', minLevel = 1, weight = 50, sellPrice = 35 },
    coal = { item = 'mining_coal', label = 'Kul', minLevel = 1, weight = 30, sellPrice = 65 },
    copper = { item = 'mining_copper', label = 'Kobbermalm', minLevel = 2, weight = 25, sellPrice = 110 },
    iron = { item = 'mining_iron', label = 'Jernmalm', minLevel = 3, weight = 22, sellPrice = 165 },
    silver = { item = 'mining_silver', label = 'Sølvmalm', minLevel = 5, weight = 14, sellPrice = 280 },
    gold = { item = 'mining_gold', label = 'Guldmalm', minLevel = 7, weight = 8, sellPrice = 520 },
    diamond = { item = 'mining_diamond', label = 'Rå diamant', minLevel = 10, weight = 2, sellPrice = 1450 }
}

Config.Missions = {
    quarry_start = {
        label = 'Stenbruddets begyndelse',
        description = 'Bryd 8 sten i området.',
        requiredLevel = 1,
        rocks = 8,
        xpBonus = 120,
        moneyBonus = 900,
        multiplayer = true,
        zone = 'quarry'
    },
    iron_run = {
        label = 'Jernleverancen',
        description = 'Bryd 14 sten og find mindst 8 jernmalm.',
        requiredLevel = 3,
        rocks = 14,
        requiredOre = 'iron',
        requiredOreAmount = 8,
        xpBonus = 280,
        moneyBonus = 2200,
        multiplayer = true,
        zone = 'quarry'
    },
    deep_vein = {
        label = 'Den dybe åre',
        description = 'Bryd 20 sten i den dybe mine.',
        requiredLevel = 7,
        rocks = 20,
        xpBonus = 520,
        moneyBonus = 5200,
        multiplayer = true,
        zone = 'deep_mine'
    }
}

Config.Zones = {
    quarry = {
        label = 'Davis Quartz',
        center = vec3(2954.0, 2795.0, 41.5),
        radius = 120.0,
        rocks = {
            vec4(2963.8, 2775.4, 39.8, 20.0),
            vec4(2974.2, 2788.8, 40.3, 185.0),
            vec4(2984.6, 2802.7, 41.2, 95.0),
            vec4(2968.1, 2816.5, 42.2, 275.0),
            vec4(2948.3, 2824.0, 43.2, 160.0),
            vec4(2933.0, 2808.7, 42.5, 40.0),
            vec4(2928.6, 2788.4, 41.8, 220.0),
            vec4(2942.5, 2775.1, 40.9, 320.0),
            vec4(2993.4, 2791.5, 41.1, 80.0),
            vec4(3000.2, 2812.4, 42.0, 140.0)
        }
    },
    deep_mine = {
        label = 'Den dybe mine',
        center = vec3(2930.0, 2750.0, 43.0),
        radius = 100.0,
        rocks = {
            vec4(2918.8, 2752.5, 43.1, 10.0),
            vec4(2908.1, 2744.0, 43.0, 170.0),
            vec4(2924.0, 2737.5, 43.1, 260.0),
            vec4(2940.2, 2738.7, 43.0, 90.0),
            vec4(2951.4, 2752.3, 43.2, 310.0),
            vec4(2942.8, 2768.0, 43.1, 120.0)
        }
    }
}

Config.Rock = {
    model = `prop_rock_4_cl_2`,
    respawnSeconds = 90,
    interactionDistance = 2.0,
    mineDuration = 6500,
    animation = {
        dict = 'melee@large_wpn@streamed_core',
        clip = 'ground_attack_0',
        flag = 1
    },
    pickaxeProp = {
        model = `prop_tool_pickaxe`,
        bone = 57005,
        offset = vec3(0.09, -0.02, -0.02),
        rotation = vec3(-78.0, 13.0, 28.0)
    }
}
