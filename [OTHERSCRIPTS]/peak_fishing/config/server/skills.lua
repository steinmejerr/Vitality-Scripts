return {
    baseXp = 120,
    multiplier = 1.0,
    maxLevel = 100,

    fishing = {
        enabled = true,
        
        baseXp = 50,
        
        rarityMultipliers = {
            common = 1.0,     
            uncommon = 1.5,   
            rare = 2.5,       
            epic = 4.0,       
            legendary = 6.0,  
            treasure = 3.0    
        },
        
        weightBonus = {
            enabled = true,

            multiplierCap = 2.0,

            divisor = 2.0
        },
        
        rodBonus = {
            enabled = true,
        },
        
        levelBonus = {
            enabled = true,
            
            xpPerLevel = 2
        }
    },

    levelRewards = {
        enabled = true,

        rewards = {
            [5] = {
                money = 1000,

                items = {
                    { name = 'earthworm', amount = 5 }
                }
            },

            [10] = {
                money = 2500,

                items = {
                    { name = 'earthworm', amount = 5 },
                    { name = 'bobber', amount = 1 }
                }
            },

            [25] = {
                money = 5000,

                items = {
                    { name = 'bait_minnow', amount = 5 },
                    { name = 'spinner', amount = 1 }
                }
            },

            [50] = {
                money = 10000,

                items = {
                    { name = 'corn', amount = 5 },
                    { name = 'sinker_set', amount = 1 }
                }
            },

            [100] = {
                money = 25000,
                
                items = {
                    { name = 'bloodworm', amount = 5 },
                    { name = 'premium_tackle', amount = 1 }
                }
            }
        }
    },

    commands = {
        enabled = true,
        
        addxp = {
            enabled = true,
            command = 'addxp',
            help = 'Add XP to a player',
            restricted = 'group.admin'
        },
        
        removexp = {
            enabled = true,
            command = 'removexp',
            help = 'Remove XP from a player',
            restricted = 'group.admin'
        },
        
        setlevel = {
            enabled = true,
            command = 'setlevel',
            help = 'Set a player\'s level directly',
            restricted = 'group.admin'
        }
    },
}