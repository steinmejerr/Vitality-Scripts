return {
    autoFishing = {
        enabled = false
    },

    commands = {
        givefish = {
            enabled = true,
            name = 'givefish',
            help = 'Give a fish item to a player',
            restricted = 'group.admin',
            params = {
                {
                    name = 'target',
                    type = 'playerId',
                    help = 'Target player ID'
                },
                {
                    name = 'fishName',
                    type = 'string',
                    help = 'Name of the fish'
                },
                {
                    name = 'amount',
                    type = 'number',
                    help = 'Amount of fish',
                    optional = true,
                    default = 1
                }
            }
        },
        
        givefishingrod = {
            enabled = true,
            name = 'givefishingrod',
            help = 'Give a fishing rod with specified tier',
            restricted = 'group.admin',
            params = {
                {
                    name = 'tier',
                    type = 'number',
                    help = 'Rod tier (0-4)',
                    optional = true
                },
                {
                    name = 'target',
                    type = 'playerId',
                    help = 'Target player ID',
                    optional = true
                }
            }
        }
    }
}

