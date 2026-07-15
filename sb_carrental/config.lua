Config = {}

Config.Debug = false
Config.Currency = 'kr.'
Config.PaymentAccounts = {
    cash = 'money',
    bank = 'bank'
}

Config.Rental = {
    maxActivePerPlayer = 1,
    platePrefix = 'LEJ',
    plateLength = 8,
    warpIntoVehicle = true,
    engineOn = true,
    fuel = 100.0,
    deleteOnReturn = true,
    expiryCheckInterval = 30000,

    -- Prisen på køretøjerne nedenfor er grundprisen for 1 time.
    durations = {
        { id = '30m', label = '30 minutter', minutes = 30, multiplier = 0.60 },
        { id = '1h',  label = '1 time',      minutes = 60, multiplier = 1.00 },
        { id = '2h',  label = '2 timer',     minutes = 120, multiplier = 1.75 },
        { id = '4h',  label = '4 timer',     minutes = 240, multiplier = 3.25 }
    }
}

Config.Locations = {
    {
        label = 'Biludlejning',
        npc = {
            model = 'a_m_y_business_03',
            coords = vec4(-1034.65, -2733.70, 20.17, 150.0),
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        },
        spawn = vec4(-1030.26, -2724.03, 20.10, 240.0),
        returnRadius = 18.0,
        blip = {
            enabled = true,
            sprite = 225,
            colour = 2,
            scale = 0.75,
            name = 'Biludlejning'
        },
        vehicles = {
            {
                model = 'blista',
                label = 'Blista',
                category = 'Kompakt',
                price = 1250,
                image = 'images/blista.webp'
            },
            {
                model = 'asea',
                label = 'Asea',
                category = 'Sedan',
                price = 1600,
                image = 'images/asea.webp'
            },
            {
                model = 'faggio',
                label = 'Faggio',
                category = 'Scooter',
                price = 500,
                image = 'images/faggio.webp'
            }
        }
    }
}
