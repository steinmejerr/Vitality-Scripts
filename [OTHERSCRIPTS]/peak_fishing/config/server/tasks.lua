return {
    enabled = true,

    activeTasks = {
        min = 1,
        max = 5
    },

    resetTime = '00:00',

    commands = {
        tasks = {
            enabled = true,
            command = 'fishingtasks',
            help = 'View fishing tasks'
        }
    },
    
    types = {
        CATCH_SPECIES = 'catch_species',
        CATCH_TYPE = 'catch_type',
        CATCH_SPECIFIC = 'catch_specific',
        TOTAL_WEIGHT = 'total_weight'
    },
    
    list = {
        catch_variety = {
            type = 'catch_species',
            label = 'Variety Fisher',
            description = 'Catch %d different species of fish',

            target = 10,

            rewards = {
                money = 5000,
                items = {
                    { name = 'bread', amount = 5 }
                }
            }
        },
        
        catch_common = {
            type = 'catch_type',
            params = { type = 'common' },
            label = 'Common Catcher',
            description = 'Catch %d common fish',

            target = 10,

            rewards = {
                money = 2000,
                items = {
                    { name = 'bread', amount = 3 }
                }
            }
        },

        catch_uncommon = {
            type = 'catch_type',
            params = { type = 'uncommon' },
            label = 'Uncommon Hunter',
            description = 'Catch %d uncommon fish',

            target = 5,

            rewards = {
                money = 3000
            }
        },

        catch_rare = {
            type = 'catch_type',
            params = { type = 'rare' },
            label = 'Rare Hunter',
            description = 'Catch %d rare fish',

            target = 3,

            rewards = {
                money = 10000
            }
        },

        catch_epic = {
            type = 'catch_type',
            params = { type = 'epic' },
            label = 'Epic Hunter',
            description = 'Catch %d epic fish',

            target = 2,

            rewards = {
                money = 20000
            }
        },

        catch_legendary = {
            type = 'catch_type',
            params = { type = 'legendary' },
            label = 'Legend Hunter',
            description = 'Catch %d legendary fish',

            target = 1,

            rewards = {
                money = 50000
            }
        },

        catch_shark = {
            type = 'catch_specific',
            params = { fish = 'shark', fishList = { 'saw_shark', 'hammerhead_shark', 'whale_shark', 'great_white_shark' } },
            label = 'Shark Hunter',
            description = 'Catch %d sharks',

            target = 1,

            rewards = {
                money = 15000
            }
        },

        total_weight = {
            type = 'total_weight',
            label = 'Heavy Lifter',
            description = 'Catch %d kg worth of fish',
            
            target = 10,

            rewards = {
                money = 7500
            }
        }
    }
}
