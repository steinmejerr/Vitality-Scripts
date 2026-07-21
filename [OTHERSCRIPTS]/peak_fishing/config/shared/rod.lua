return {
    list = {
        [0] = {
            label = 'Basic Bamboo Rod',
            description = 'A simple bamboo fishing rod. Perfect for catching common fish in shallow waters. No bait compartment.',

            durabilityLoss = {
                min = 0.3,
                max = 0.7
            },
            
            image = 'fishing_rod_t0',
        
            level = {
                required = true,
                min = 1
            },
        
            bait = {
                allowed = false,
                tier = { 0 },
                stashWeight = 500
            },
        
            tackle = {
                allowed = false,
                amount = 0,
                stashWeight = 500
            },
        
            minigameModifiers = {
                rodSpeed = 1.0,
        
                fishSpeed = 1.0,
                dashSpeed = 1.0,
                dashFrequency = 1.0,
                
                catchZone = 1.0,
                catchTime = 1.0,
                progressDecay = 1.0,
                totalTime = 1.0
            },
        
            rarityModifier = {
                common = 1.5,
                uncommon = 0.5,
                rare = 0.2,
                epic = 0.1,
                legendary = 0.05,
                treasure = 0.3
            }
        },        

        [1] = {
            label = 'Standard Fishing Rod',
            description = 'A reliable fiberglass rod with basic bait storage. Good for both freshwater and saltwater fishing.',

            durabilityLoss = {
                min = 0.2,
                max = 0.6
            },
            
            image = 'fishing_rod_t1',
        
            level = {
                required = true,
                min = 5
            },
        
            bait = {
                allowed = true,

                tier = { 0, 1 },

                stashWeight = 1000
            },
        
            tackle = {
                allowed = false,

                amount = 0,

                stashWeight = 1000
            },

            minigameModifiers = {
                rodSpeed = 1.1,
        
                fishSpeed = 0.95,
                dashSpeed = 0.95,
                dashFrequency = 0.95,
                
                catchZone = 1.0,
                catchTime = 0.15,
                progressDecay = 0.95,
                totalTime = 1.05
            },
        
            rarityModifier = {
                common = 1.2,
                uncommon = 0.8,
                rare = 0.4,
                epic = 0.2,
                legendary = 0.1,
                treasure = 0.6
            }
        },

        [2] = {
            label = 'Professional Carbon Rod',
            description = 'High-quality carbon fiber construction. Enhanced sensitivity for detecting bites and improved casting distance.',

            durabilityLoss = {
                min = 0.15,
                max = 0.45
            },

            image = 'fishing_rod_t2',
        
            level = {
                required = true,
                min = 10
            },
        
            bait = {
                allowed = true,

                tier = { 0, 1, 2 },

                stashWeight = 2000
            },
        
            tackle = {
                allowed = true,

                tier = { 1, 2 },

                stashWeight = 2000
            },
        
            minigameModifiers = {
                rodSpeed = 1.2,
        
                fishSpeed = 0.9,
                dashSpeed = 0.9,
                dashFrequency = 0.8,
                
                catchZone = 1.0,
                catchTime = 0.8,
                progressDecay = 0.9,
                totalTime = 1.1
            },
        
            rarityModifier = {
                common = 1.0,
                uncommon = 1.0,
                rare = 0.6,
                epic = 0.3,
                legendary = 0.2,
                treasure = 1.0
            }
        },

        [3] = {
            label = 'Master Angler Rod',
            description = 'Premium composite rod with advanced bait systems. Exceptional performance for catching rare species.',

            durabilityLoss = {
                min = 0.1,
                max = 0.3
            },

            image = 'fishing_rod_t3',
        
            level = {
                required = true,
                min = 20
            },
        
            bait = {
                allowed = true,

                tier = { 0, 1, 2, 3 },

                stashWeight = 5000
            },
        
            tackle = {
                allowed = true,
                
                tier = { 1, 2, 3 },

                stashWeight = 5000
            },

            minigameModifiers = {
                rodSpeed = 1.3,
        
                fishSpeed = 0.85,
                dashSpeed = 0.85,
                dashFrequency = 0.85,
                
                catchZone = 1.0,
                catchTime = 0.7,
                progressDecay = 0.85,
                totalTime = 1.15
            },
        
            rarityModifier = {
                common = 0.8,
                uncommon = 1.0,
                rare = 1.2,
                epic = 0.6,
                legendary = 0.3,
                treasure = 1.5
            }
        },
        
        [4] = {
            label = 'Deep Sea Hunter',
            description = 'Military-grade materials with custom modifications. Unmatched strength for the biggest catches.',

            durabilityLoss = {
                min = 0.05,
                max = 0.15
            },

            image = 'fishing_rod_t4',
        
            level = {
                required = true,
                min = 50
            },
        
            bait = {
                allowed = true,

                tier = { 0, 1, 2, 3, 4 },
                
                stashWeight = 10000
            },
        
            tackle = {
                allowed = true,

                tier = { 1, 2, 3, 4 },

                stashWeight = 10000
            },
        
            minigameModifiers = {
                rodSpeed = 1.4,
        
                fishSpeed = 0.8,
                dashSpeed = 0.8,
                dashFrequency = 0.6,
                
                catchZone = 1.0,
                catchTime = 0.6,
                progressDecay = 0.8,
                totalTime = 1.2
            },
        
            rarityModifier = {
                common = 0.6,
                uncommon = 0.9,
                rare = 1.1,
                epic = 1.0,
                legendary = 0.6,
                treasure = 2.0
            }
        },
    }
}