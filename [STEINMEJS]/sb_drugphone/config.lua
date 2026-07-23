Config = {}

Config.PhoneItem = 'drug_phone'
Config.MoneyAccount = 'money' -- ESX account: money, bank eller black_money
Config.DealProgress = 6500
Config.CustomerLifetime = 180000
Config.MaxDealDistance = 5.0
Config.NextOfferDelay = { min = 35, max = 75 } -- sekunder
Config.OfferExpiry = 90 -- sekunder
Config.DealCooldown = 1 -- sekunder mellem server-events

Config.Messages = {
    intro = {
        'Yo, har du noget på lager?',
        'Hey, kan du levere noget hurtigt?',
        'Hvad har du til salg i dag?',
        'Jeg mangler noget. Kan du hjælpe?'
    },
    request = {
        'Hey, kan jeg købe %sx %s?',
        'Jeg tager gerne %sx %s. Er du frisk?',
        'Kan du skaffe %sx %s til mig?',
        'Jeg skal bruge %sx %s. Deal?'
    },
    accepted = {
        'Ja da, g! Send lokationen.',
        'Det kan vi godt. Hvor mødes vi?',
        'Jeg er klar. Smid en lokation.',
        'Deal. Jeg kommer nu.'
    },
    location = {
        'Perfekt. Jeg venter ved den markerede lokation.',
        'Kom alene. Jeg står ved lokationen.',
        'Jeg er på vej til stedet. Skynd dig.',
        'Lokationen er sendt. Vi ses der.'
    }
}

Config.Products = {
    weed = {
        label = 'Weed',
        item = 'weed',
        icon = 'cannabis',
        minAmount = 10,
        maxAmount = 100,
        minPrice = 75,
        maxPrice = 105
    },
    coke = {
        label = 'Kokain',
        item = 'burger',
        icon = 'snowflake',
        minAmount = 5,
        maxAmount = 50,
        minPrice = 180,
        maxPrice = 240
    },
    meth = {
        label = 'Meth',
        item = 'meth_pooch',
        icon = 'flask',
        minAmount = 5,
        maxAmount = 45,
        minPrice = 150,
        maxPrice = 210
    }
}

Config.CustomerModels = {
    `a_m_m_business_01`,
    `a_m_y_business_02`,
    `a_m_y_hipster_01`,
    `a_m_y_stbla_02`,
    `a_m_m_eastsa_02`,
    `a_f_y_business_02`,
    `a_f_y_hipster_02`
}

Config.DealLocations = {
    vector4(-1172.68, -1572.84, 4.66, 126.0),
    vector4(-1338.42, -1278.57, 4.87, 93.0),
    vector4(-705.12, -913.89, 19.22, 87.0),
    vector4(113.16, -1961.07, 21.33, 198.0),
    vector4(341.73, -2028.57, 21.12, 139.0),
    vector4(1245.55, -1626.78, 53.28, 31.0),
    vector4(981.62, -1805.45, 31.16, 83.0),
    vector4(1392.28, -2080.44, 52.00, 117.0),
    vector4(1693.49, 3757.94, 34.71, 218.0),
    vector4(1963.44, 3742.18, 32.34, 118.0),
    vector4(2677.62, 3280.95, 55.24, 151.0),
    vector4(-111.42, 6469.19, 31.63, 225.0),
    vector4(-315.35, 6194.18, 31.49, 43.0),
    vector4(-1501.26, 1515.12, 115.29, 265.0),
    vector4(-2554.84, 2322.66, 33.06, 93.0)
}
