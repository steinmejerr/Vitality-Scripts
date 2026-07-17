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

    durations = {
        { id = '30m', label = '30 minutter', minutes = 30, multiplier = 0.60 },
        { id = '1h',  label = '1 time',      minutes = 60, multiplier = 1.00 },
        { id = '2h',  label = '2 timer',     minutes = 120, multiplier = 1.75 },
        { id = '4h',  label = '4 timer',     minutes = 240, multiplier = 3.25 }
    }
}

Config.Locations = {
    {
        id = 'airport',
        label = 'Biludlejning – Lufthavnen',
        company = 'SB Biludlejning – Lufthavnen',

        npc = {
            model = 'a_m_y_business_03',
            coords = vec4(-1034.65, -2733.70, 20.17, 150.0),
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        },
        spawns = {
            vec4(-1030.26, -2724.03, 20.10, 240.0),
            vec4(-1026.85, -2721.83, 20.10, 240.0)
        },

        returnRadius = 22.0,

        target = {
            open = 'Se lejebiler',
            papers = 'Se køretøjspapirer',
            returnVehicle = 'Aflever lejebil',
            distance = 2.5
        },

        blip = {
            enabled = true,
            sprite = 225,
            colour = 2,
            scale = 0.75,
            name = 'Biludlejning – Lufthavnen'
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
    },

    {
        id = 'city',
        label = 'Biludlejning – Byen',
        company = 'SB Biludlejning – Byen',

        npc = {
            model = 'a_m_y_business_03',
            coords = vec4(-10.74, -1081.78, 26.67, 160.0),
            scenario = 'WORLD_HUMAN_CLIPBOARD'
        },

        spawns = {
            vec4(-15.48, -1078.18, 26.67, 160.0),
            vec4(-19.25, -1076.68, 26.67, 160.0)
        },

        returnRadius = 22.0,

        target = {
            open = 'Se lejebiler',
            papers = 'Se køretøjspapirer',
            returnVehicle = 'Aflever lejebil',
            distance = 2.5
        },

        blip = {
            enabled = true,
            sprite = 225,
            colour = 2,
            scale = 0.75,
            name = 'Biludlejning – Byen'
        },

        vehicles = {
            {
                model = 'blista',
                label = 'Blista',
                category = 'Kompakt',
                price = 1350,
                image = 'images/blista.webp'
            },
            {
                model = 'asea',
                label = 'Asea',
                category = 'Sedan',
                price = 1700,
                image = 'images/asea.webp'
            }
        }
    }
}
