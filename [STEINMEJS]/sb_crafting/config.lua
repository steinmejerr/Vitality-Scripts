Config = {}

Config.Debug = false
Config.Locale = 'da'

Config.StationItem = 'crafting_station'
Config.StationProp = `gr_prop_gr_bench_04b`
Config.MaxStationsPerPlayer = 3
Config.InteractDistance = 2.2
Config.PickupDistance = 3.0

Config.Shop = {
    price = 7500,
    account = 'money', -- money, bank eller black_money
    npc = {
        model = `s_m_m_dockwork_01`,
        coords = vector4(1207.21, -3114.02, 5.54, 89.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    blip = {
        enabled = false,
        sprite = 566,
        colour = 2,
        scale = 0.75,
        label = 'Crafting-forhandler'
    }
}

Config.Placement = {
    maxDistance = 5.0,
    rotationStep = 5.0,
    heightStep = 0.03,
    controls = {
        confirm = 38,      -- E
        cancel = 177,      -- BACKSPACE
        rotateLeft = 174,  -- LEFT
        rotateRight = 175, -- RIGHT
        heightUp = 172,    -- UP
        heightDown = 173   -- DOWN
    }
}

Config.Categories = {
    tools = { label = 'Værktøj', icon = 'fa-solid fa-screwdriver-wrench' },
    utility = { label = 'Udstyr', icon = 'fa-solid fa-toolbox' },
    materials = { label = 'Materialer', icon = 'fa-solid fa-cubes-stacked' }
}

-- Item-navne skal eksistere i ox_inventory.
Config.Recipes = {
    {
        id = 'lockpick',
        label = 'Lockpick',
        description = 'Et simpelt værktøj til låse.',
        category = 'tools',
        icon = 'fa-solid fa-key',
        duration = 8000,
        output = { item = 'lockpick', count = 1 },
        ingredients = {
            { item = 'metalscrap', label = 'Metalskrot', count = 4 },
            { item = 'plastic', label = 'Plastik', count = 2 }
        }
    },
    {
        id = 'repairkit',
        label = 'Reparationssæt',
        description = 'Til mindre reparationer på køretøjer.',
        category = 'utility',
        icon = 'fa-solid fa-screwdriver-wrench',
        duration = 12000,
        output = { item = 'repairkit', count = 1 },
        ingredients = {
            { item = 'metalscrap', label = 'Metalskrot', count = 8 },
            { item = 'steel', label = 'Stål', count = 4 },
            { item = 'rubber', label = 'Gummi', count = 2 }
        }
    },
    {
        id = 'steel',
        label = 'Forarbejdet stål',
        description = 'Smelt metalskrot om til brugbart stål.',
        category = 'materials',
        icon = 'fa-solid fa-layer-group',
        duration = 6500,
        output = { item = 'steel', count = 2 },
        ingredients = {
            { item = 'metalscrap', label = 'Metalskrot', count = 5 }
        }
    }
}
