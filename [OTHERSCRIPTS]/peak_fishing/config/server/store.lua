return {
    enabled = true,

    currency = 'money',

    categories = {
        {
            id = 'rods',
            label = 'Fishing Rods',
            icon = 'fish',
            items = {
                {
                    name = 'fishing_rod',
                    tier = 0,
                    price = 15000
                }
            }
        },
        {
            id = 'baits',
            label = 'Fishing Baits',
            icon = 'worm',

            items = {
                { name = 'earthworm', price = 5 },
                { name = 'bread', price = 5 },
                { name = 'corn', price = 8 },
                { name = 'maggots', price = 8 },
                { name = 'minnow', price = 12 },
                { name = 'nightcrawler', price = 15 },
                { name = 'bloodworm', price = 20 },
                { name = 'magnet', price = 50 }
            }
        },
        {
            id = 'tackle',
            label = 'Fishing Tackle',
            icon = 'fish-fins',
            items = {
                { name = 'bobber', price = 2000 },
                { name = 'spinner', price = 3500 },
                { name = 'sinker_set', price = 6000 },
                { name = 'premium_tackle', price = 8500 }
            }
        },
        {
            id = 'nets',
            label = 'Fishing Nets',
            icon = 'boxes',
            items = {
                { name = 'fishing_net', price = 20000 }
            }
        }
    },
}