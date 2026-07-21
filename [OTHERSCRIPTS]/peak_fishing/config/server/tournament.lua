return {
    enabled = true,

    tournamentBlip = {
        sprite = 68,
        display = 4,
        scale = 1.0,
        color = 5,
        label = 'Fishing Tournament'
    },

    entryFee = 1000,

    timing = {
        duration = 60,
        announce = 30,
    },
    
    reconnectionTime = 10,

    scheduling = {
        enabled = true,
        
        timezoneOffset = 0,
        
        schedule = {
            [0] = { { 12, 00 }, { 18, 00 } },
            [1] = { { 12, 00 }, { 18, 00 } },
            [2] = { { 12, 00 }, { 18, 00 } },
            [3] = { { 12, 00 }, { 18, 00 } },
            [4] = { { 12, 00 }, { 18, 00 } },
            [5] = { { 12, 00 }, { 18, 00 } },
            [6] = { { 13, 00 }, { 18, 00 } },
        }
    },
    
    rarityMultipliers = {
        common = 1.0,
        uncommon = 1.25,
        rare = 1.5,
        epic = 1.75,
        legendary = 2.0
    },
    
    pointCalculation = {
        baseMultiplier = 15,

        logBase = 100,
        
        minimumPoints = 5
    },
    
    rewards = {
        prize = {
            enabled = true,

            type = 'money',

            base = 10000,

            addEntryFees = true,
            playerMultiplier = 2.0,

            amount = {
                min = 50,
                max = 10000
            }
        },
        
        bonus = {
            enabled = true,

            maxItems = 2,
            
            items = {
                { name = 'minnow', amount = { min = 1, max = 3 }, chance = 70 },
                { name = 'nightcrawler', amount = { min = 1, max = 5 }, chance = 50 },
            }
        }
    },
    
    ---@param playerId number
    ---@param message string
    notification = function(playerId, message)
        local utils = require 'modules.utils.server'

        utils.notify(playerId, message, 'inform')
    end,

    commands = {
        starttournament = {
            enabled = true,
            name = 'starttournament', 
            help = 'Start a fishing tournament',
            restricted = 'group.admin'
        },
        
        jointournament = {
            enabled = true,
            name = 'jointournament',
            help = 'Join a fishing tournament',
            restricted = 'group.admin'
        },
    },

    discord = {
        enabled = false,
        
        webhook = {
            url = 'https://discord.com/api/webhooks/941330087222063155/9Nxpd6hFWIVun6DgQzp3s6MQ4zQWcQMx0hZenAtGuf6FNBRkRFm-H0KZ-rsvY-Fg2SE4',
            username = 'Fishing Tournament',
            avatar_url = ''
        },
        
        announcements = {
            tournamentStarting = {
                enabled = true,
                title = '🎣 Fishing Tournament Starting Soon',
                description = 'A fishing tournament is about to begin! Join now to compete for prizes!',
                color = 0xffffff,
                fields = {
                    location = true,
                    entryFee = true,
                    timeUntilStart = true
                }
            },
            
            tournamentStarted = {
                enabled = true,
                title = '🏆 Fishing Tournament Started',
                description = 'The fishing tournament has officially begun! Good luck to all participants!',
                color = 0xffffff,
                fields = {
                    location = true,
                    participants = true,
                    duration = true
                }
            },
            
            tournamentEnded = {
                enabled = true,
                title = '🏁 Fishing Tournament Ended',
                description = 'The fishing tournament has concluded! Check the results below.',
                color = 0xffffff,
                fields = {
                    location = true,
                    winner = true,
                    participants = true,
                    totalPrize = true
                }
            }
        }
    }
}