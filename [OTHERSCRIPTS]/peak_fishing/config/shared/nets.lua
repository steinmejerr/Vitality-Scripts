return {
    model = 'ep_fishing_net', 

    placement = {
        maxDistance = 10.0,
        minWaterDepth = -0.3,
    },

    durability = {
        initial = 100,

        lossPerCatch = {
            amount = {
                min = 0.1,
                max = 0.3
            },
        }
    },
    
    stash = {
        bait = {
            slots = 1,
            maxWeight = 1000,
            label = 'Net Bait Storage'
        },

        fish = {
            slots = 20,
            maxWeight = 100000,
            label = 'Net Fish Storage'
        }
    },
    
    catching = {
        catchRate = {
            min = 0.3,
            max = 0.9
        },

        fishPerCatch = {
            min = 1,
            max = 3
        },
        
        rarityWeights = {
            common = 0.6,
            uncommon = 0.25,
            rare = 0.1,
            epic = 0.04,
            legendary = 0.01
        },
        
        distanceCheck = {
            enabled = true,
            
            distance = 100.0,
            
            notificationDistance = 30.0
        }
    },
    
    operation = {
        requireOwnerOnline = true,

        maxNetsPerPlayer = 3,
        
        checkInterval = 1
    }
} 