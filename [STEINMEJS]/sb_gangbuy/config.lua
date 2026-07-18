Config = {}

Config.Debug = false
Config.UseOxInventory = true
Config.PaymentAccount = 'black_money' -- money, bank eller black_money
Config.ProgressPerCharacter = true
Config.InteractionDistance = 2.0
Config.OrderPickupDuration = 6500
Config.MissionPickupDuration = 5500
Config.OrderExpireMinutes = 45
Config.MissionCooldownMinutes = 10
Config.MaxActiveOrders = 1

Config.Npc = {
    model = `g_m_y_mexgoon_02`,
    coords = vector4(1240.63, -3176.04, 7.09, 271.58),
    scenario = 'WORLD_HUMAN_SMOKING',
    targetLabel = 'Tal med forbindelsen',
    targetIcon = 'fa-solid fa-user-secret'
}

-- Tilføj jeres faktiske bandejobs her.
-- minimumGrade styrer adgang til NPC'en. Hvert produkt/mission kan kræve en højere grade.
Config.AllowedGangs = {
    ambulance = { label = 'Test Bande', minimumGrade = 0 },
    unemployed = { label = 'Test Bande 2', minimumGrade = 0 }
}

Config.Levels = {
    [1] = { xp = 0 },
    [2] = { xp = 200 },
    [3] = { xp = 500 },
    [4] = { xp = 950 },
    [5] = { xp = 1550 },
    [6] = { xp = 2300 },
    [7] = { xp = 3200 },
    [8] = { xp = 4300 },
    [9] = { xp = 5600 },
    [10] = { xp = 7200 }
}

-- Varerne er eksempler, som allerede findes i den medsendte database.
-- Skift item-navne, priser, levels og grades frit.
Config.Products = {
    radio = {
        label = 'Krypteret radio',
        description = 'En diskret radio til intern kommunikation.',
        item = 'radio',
        amount = 1,
        price = 2500,
        requiredLevel = 1,
        requiredGrade = 0,
        deliveryMinutes = { min = 2, max = 4 },
        icon = 'fa-solid fa-walkie-talkie'
    },
    rope = {
        label = 'Kraftigt reb',
        description = 'Udstyr til opgaver, hvor almindeligt værktøj ikke rækker.',
        item = 'pl_rope',
        amount = 1,
        price = 4500,
        requiredLevel = 2,
        requiredGrade = 1,
        deliveryMinutes = { min = 3, max = 5 },
        icon = 'fa-solid fa-link'
    },
    drill = {
        label = 'Industriboremaskine',
        description = 'Kraftigt udstyr leveret uden spørgsmål.',
        item = 'pl_drill',
        amount = 1,
        price = 11000,
        requiredLevel = 4,
        requiredGrade = 2,
        deliveryMinutes = { min = 4, max = 7 },
        icon = 'fa-solid fa-screwdriver-wrench'
    },
    hackingdevice = {
        label = 'Hacking-enhed',
        description = 'Specialudstyr til avancerede opgaver.',
        item = 'pl_hackingdevice',
        amount = 1,
        price = 22000,
        requiredLevel = 6,
        requiredGrade = 3,
        deliveryMinutes = { min = 6, max = 10 },
        icon = 'fa-solid fa-microchip'
    }
}

Config.Missions = {
    first_contact = {
        label = 'Første kontakt',
        description = 'Hent en mindre pakke og bring forbindelsen ro i sindet.',
        requiredLevel = 1,
        requiredGrade = 0,
        xp = 120,
        money = 1000,
        waitSeconds = { min = 20, max = 45 },
        icon = 'fa-solid fa-box'
    },
    dead_drop = {
        label = 'Død postkasse',
        description = 'Find en skjult forsendelse, før andre får øje på den.',
        requiredLevel = 3,
        requiredGrade = 1,
        xp = 240,
        money = 2500,
        waitSeconds = { min = 30, max = 60 },
        icon = 'fa-solid fa-location-dot'
    },
    sensitive_cargo = {
        label = 'Følsom last',
        description = 'Hent en værdifuld pakke fra en risikabel kontakt.',
        requiredLevel = 5,
        requiredGrade = 2,
        xp = 420,
        money = 5000,
        waitSeconds = { min = 45, max = 80 },
        icon = 'fa-solid fa-briefcase'
    }
}

Config.DeliveryLocations = {
    vector4(1004.63, -2528.71, 28.30, 173.48),
    vector4(728.40, -1065.19, 22.17, 92.26),
    vector4(1210.11, -3114.38, 5.54, 355.12),
    vector4(-316.73, -2698.60, 6.00, 314.72),
    vector4(-1153.74, -1567.72, 4.36, 124.02),
    vector4(153.34, -3077.04, 6.74, 267.62)
}

Config.Pickup = {
    prop = `prop_cs_cardbox_01`,
    targetIcon = 'fa-solid fa-box-open'
}

Config.Blip = {
    sprite = 478,
    colour = 2,
    scale = 0.82,
    routeColour = 2,
    labelOrder = 'Afhent levering',
    labelMission = 'Missionens afhentning'
}
