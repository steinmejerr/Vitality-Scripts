return {
    list = {
        bobber = {
            label = 'Basic Bobber',
            description = 'Improves bite detection and helps stabilize your fishing line.',
            tier = 1,
            
            minigameModifiers = {
                rodSpeed = 1.05,
                catchThreshold = 1.1,
                catchDuration = 0.95,
                progressDecay = 0.95,
                totalTime = 1.05
            }
        },
        
        spinner = {
            label = 'Spinner Lure',
            description = 'Attracts predatory fish with its flashing movements.',
            tier = 2,
            
            minigameModifiers = {
                rodSpeed = 1.0,
                catchThreshold = 1.0,
                catchDuration = 0.9,
                progressDecay = 0.9,
                totalTime = 1.05,
                catchRate = 1.1
            },
            
            rarityModifier = {
                common = 0.9,
                uncommon = 1.1,
                rare = 1.1,
                epic = 1.0,
                legendary = 1.0,
                treasure = 0.8
            }
        },
        
        sinker_set = {
            label = 'Professional Sinker Set',
            description = 'High-quality weights for precise depth control and better stability in currents.',
            tier = 3,
            
            minigameModifiers = {
                catchDuration = 0.9,
                progressDecay = 0.85,
                totalTime = 1.1,
                catchRate = 1.1
            },
            
            rarityModifier = {
                common = 0.9,
                uncommon = 1.0,
                rare = 1.1,
                epic = 1.15,
                legendary = 1.0,
                treasure = 1.2
            }
        },
        
        premium_tackle = {
            label = 'Premium Tackle Kit',
            description = 'High-quality line and hooks for better control and reduced chance of losing fish.',
            tier = 3,
            
            minigameModifiers = {
                rodSpeed = 1.15,
                catchThreshold = 1.1,
                catchDuration = 0.85,
                progressDecay = 0.8,
                totalTime = 1.15
            },

            rarityModifier = {
                common = 0.9,
                uncommon = 1.0,
                rare = 1.15,
                epic = 1.1,
                legendary = 1.1,
                treasure = 1.0
            }
        },
    }
}