Config = {}

Config.UseOxInventory = true
Config.PropResource = 'bzzz_mine_props'
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
    iron = { item = 'mining_iron', label = 'Jernmalm', minLevel = 1, weight = 22, sellPrice = 165 },
    silver = { item = 'mining_silver', label = 'Sølvmalm', minLevel = 3, weight = 14, sellPrice = 280 },
    gold = { item = 'mining_gold', label = 'Guldmalm', minLevel = 3, weight = 8, sellPrice = 520 },
    diamond = { item = 'mining_diamond', label = 'Rå diamant', minLevel = 6, weight = 2, sellPrice = 1450 }
}


Config.MiningProps = {
    coal = { model = `bzzz_prop_mine_coal_big` },
    iron = { model = `bzzz_prop_mine_iron_big` },
    silver = { model = `bzzz_prop_mine_silver_big` },
    gold = { model = `bzzz_prop_mine_gold_big` },
    diamond = { model = `bzzz_prop_mine_diamond_big` }
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
        zone = 'level_1_3'
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
        zone = 'level_3_6'
    },
    deep_vein = {
        label = 'Den dybe åre',
        description = 'Bryd 20 sten i den dybe mine.',
        requiredLevel = 7,
        rocks = 20,
        xpBonus = 520,
        moneyBonus = 5200,
        multiplayer = true,
        zone = 'level_6_10'
    }
}

Config.Zones = {
    level_1_3 = {
        label = 'Mineområde level 1 - 3',
        center = vec3(2945.20, 2781.25, 39.80),
        radius = 24.0,
        minLevel = 1,
        maxLevel = 3,
        orePool = { 'coal', 'iron' },
        rocks = {
            vector4(2951.54, 2774.65, 39.23, 285.59),
            vector4(2949.70, 2783.26, 40.20, 18.30),
            vector4(2947.33, 2790.86, 40.57, 17.22),
            vector4(2938.56, 2789.91, 40.14, 96.19),
            vector4(2940.76, 2780.58, 39.42, 194.55),
            vector4(2943.53, 2771.49, 39.26, 181.66)
        }
    },
    level_3_6 = {
        label = 'Mineområde level 3 - 6',
        center = vec3(2939.50, 2804.20, 41.55),
        radius = 24.0,
        minLevel = 3,
        maxLevel = 6,
        orePool = { 'iron', 'silver', 'gold' },
        rocks = {
            vector4(2927.98, 2799.61, 41.27, 313.97),
            vector4(2935.60, 2806.75, 41.99, 313.45),
            vector4(2941.95, 2812.07, 42.32, 306.84),
            vector4(2950.60, 2806.71, 41.60, 207.74),
            vector4(2945.48, 2801.26, 41.15, 132.82),
            vector4(2935.51, 2798.76, 40.99, 97.63)
        }
    },
    level_6_10 = {
        label = 'Mineområde level 6 - 10',
        center = vec3(2965.15, 2791.05, 40.25),
        radius = 24.0,
        minLevel = 6,
        maxLevel = 10,
        orePool = { 'silver', 'gold', 'diamond' },
        rocks = {
            vector4(2971.69, 2780.48, 38.78, 260.56),
            vector4(2970.83, 2788.80, 39.81, 5.63),
            vector4(2968.91, 2798.18, 41.13, 12.96),
            vector4(2959.23, 2801.79, 41.60, 81.06),
            vector4(2961.28, 2791.42, 40.44, 265.79),
            vector4(2959.01, 2784.60, 40.73, 148.57)
        }
    }
}

Config.BlockedVehicles = {
    enabled = true,
    models = { `dump` },
    checkInterval = 2000,
    extraRadius = 20.0
}

Config.Rock = {
    oresPerStone = 3,
    respawnSeconds = 90,

    -- Separate ox_target-punkter for de tre synlige ores på den store stenmodel.
    targetNodes = {
        { offset = vec3(0.34, 0.12, 0.48), radius = 0.34 },
        { offset = vec3(-0.30, 0.06, 0.40), radius = 0.34 },
        { offset = vec3(0.04, -0.32, 0.62), radius = 0.34 }
    },

    -- Stenene beholder X/Y og heading fra zonens vector4, men sættes fysisk ned på terrænet.
    groundPlacement = {
        spawnHeight = 5.0,
        attempts = 8,
        attemptDelay = 50,
        zOffset = 0.0
    },
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
