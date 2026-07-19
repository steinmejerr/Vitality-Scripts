Config = {}

Config.Debug = false

-- Cooldown skrives direkte i minutter.
Config.CooldownMinutes = 1
Config.InteractionDistance = 2.0
Config.PickupDuration = 5000
Config.PickupVehicleDistance = 8.0 -- Hvor tæt Bisonen skal være på kassen
Config.DeliveryDuration = 5000
Config.PaymentAccount = 'black_money'
Config.OneActiveRun = true

Config.Npc = {
    model = `g_m_y_mexgoon_02`,
    coords = vector4(1200.49, -1276.98, 35.37, 350.33),
    scenario = 'WORLD_HUMAN_SMOKING',
    targetLabel = 'Se tilgængelige runs',
    targetIcon = 'fa-solid fa-route'
}

Config.PackageProp = `prop_cs_cardbox_01`



-- Bisonen er det eneste køretøj i runnet. Spilleren spawner i den og kører til kassen.
Config.RunVehicle = {
    model = `bison`,
    spawn = vector4(1204.49, -1266.77, 35.23, 190.15),
    deleteOnComplete = true
}

-- Kassen der står ved afhentningsstedet og senere vises på Bisonens lad.
Config.CargoVisuals = {
    prop = `xm3_prop_xm3_box_wood03a`,
    -- Lokalt offset på Bisonens lad. Justér her, hvis kassen skal flyttes.
    position = { x = 0.0, y = -1.35, z = 0.48, rx = 0.0, ry = 0.0, rz = 0.0 }
}

Config.Blip = {
    sprite = 478,
    colour = 2,
    scale = 0.82,
    routeColour = 2
}

-- Alle fem runs kan ændres frit her.
Config.Runs = {
    coke = {
        label = 'Coke run',
        description = 'Hent varen og aflever den ved den markerede lokation.',
        icon = 'fa-solid fa-snowflake',
        reward = { min = 8000, max = 12000 },
        pickup = vector4(153.34, -3077.04, 6.74, 267.62),
        delivery = vector4(-1165.11, -1566.91, 4.39, 125.0)
    },
    meth = {
        label = 'Meth run',
        description = 'Hent pakken og få den sikkert frem.',
        icon = 'fa-solid fa-flask',
        reward = { min = 7000, max = 10500 },
        pickup = vector4(1004.63, -2528.71, 28.30, 173.48),
        delivery = vector4(1390.42, 3604.34, 38.94, 198.0)
    },
    weed = {
        label = 'Weed run',
        description = 'Saml leveringen op og aflever den til kontakten.',
        icon = 'fa-solid fa-cannabis',
        reward = { min = 5500, max = 8500 },
        pickup = vector4(2224.61, 5577.15, 53.84, 102.0),
        delivery = vector4(-1551.12, -421.35, 41.99, 229.0)
    },
    pills = {
        label = 'Pille run',
        description = 'Find pakken og aflever den uden problemer.',
        icon = 'fa-solid fa-pills',
        reward = { min = 6000, max = 9000 },
        pickup = vector4(728.40, -1065.19, 22.17, 92.26),
        delivery = vector4(1135.62, -982.18, 46.42, 278.0)
    },
    opium = {
        label = 'Opium run',
        description = 'Hent leveringen og kør den til afleveringsstedet.',
        icon = 'fa-solid fa-box',
        reward = { min = 7500, max = 11000 },
        pickup = vector4(-316.73, -2698.60, 6.00, 314.72),
        delivery = vector4(287.21, -1812.94, 27.10, 53.0)
    }
}
