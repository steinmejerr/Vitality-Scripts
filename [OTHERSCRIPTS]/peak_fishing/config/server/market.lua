return {
    enabled = true,

    currency = 'money',

    stocks = {
        initial = 100,

        minimum = 0,
        maximum = 500,
        
        targetLevel = 250,
        
        recoveryRate = {
            min = 1,
            max = 3
        }
    },
    
    prices = {
        salesImpact = {
            divisor = 20,
            maxEffect = 0.7
        },
        
        salesRecovery = 3
    },
    
    updateInterval = 1,
}