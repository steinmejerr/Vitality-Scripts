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
    deleteOnReturn = true
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
                image = ''
            },
            {
                model = 'asea',
                label = 'Asea',
                category = 'Sedan',
                price = 1600,
                image = ''
            },
            {
                model = 'faggio',
                label = 'Faggio',
                category = 'Scooter',
                price = 500,
                image = ''
            }
        }
    }
}
