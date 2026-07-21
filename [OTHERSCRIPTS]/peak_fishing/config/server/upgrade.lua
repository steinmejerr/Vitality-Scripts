return {
    enabled = true,
    
    merchant = {
        model = 'cs_old_man2',

        coords = vec4(1662.91, 35.41, 170.68, 276.22),
        scenario = 'WORLD_HUMAN_SMOKING',

        blip = {
            enabled = true,
            sprite = 356,
            color = 3,
            scale = 0.8,
            label = 'Rod Upgrade Shop'
        }
    },
    
    basePrice = 5000,
    
    priceMultiplier = {
        [1] = 1.0,
        [2] = 2.0,
        [3] = 3.0,
        [4] = 4.0,
    },
    
    upgradeDuration = {
        [1] = 8000,
        [2] = 12000,
        [3] = 16000,
        [4] = 20000,
    }
}
