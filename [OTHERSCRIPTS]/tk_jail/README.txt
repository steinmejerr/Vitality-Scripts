Hey! Thanks for purchasing my script. Remember:
   - You are not allowed to resell or release my scripts

Requirements:
   - es_extended / qb-core

Installing the script:
   1. Download the file and extract "tk_jail" into your resources folder
   2. Add "start tk_jail" into your server.cfg file
   3. Import the SQL file(s) into your server's database
   4. Edit config.lua to your liking
   5. Restart your server

Items (ox_inventory):
	["ankle_monitor"] = {
		label = "Ankle Monitor",
		weight = 500,
		stack = true,
		close = true,
	},

	["power_saw"] = {
		label = "Power Saw",
		weight = 5000,
		stack = true,
		close = true,
	},

	["prisunflower"] = {
		label = "Prisunflower",
		weight = 50,
		stack = true,
		close = false,
	},

	["prisunflower_seed"] = {
		label = "Prisunflower seed",
		weight = 10,
		stack = true,
		close = true,
	},

	["watering_can"] = {
		label = "Watering Can",
		weight = 2500,
		stack = true,
		close = false,
	},

	["jail_chemicals"] = {
		label = "Chemicals",
		weight = 10,
		stack = true,
		close = false,
	},

	["slammer"] = {
		label = "Slammer",
		weight = 10,
		stack = true,
		close = false,
	},

	["jail_lab_tools"] = {
		label = "Laboratory Equipment",
		weight = 100,
		stack = true,
		close = false,
	},

	["jail_cigarette"] = {
		label = "Cigarette",
		weight = 10,
		stack = true,
		close = false,
	},

	["jail_lighter"] = {
		label = "Handmade lighter",
		weight = 50,
		stack = true,
		close = true,
	},

	["jail_explosive"] = {
		label = "Handmade explosive",
		weight = 500,
		stack = true,
		close = true,
	},

	["plastic_knife"] = {
		label = "Plastic knife",
		weight = 5,
		stack = true,
		close = false,
	},

	["plastic_spoon"] = {
		label = "Plastic spoon",
		weight = 5,
		stack = true,
		close = false,
	},

	["plastic_fork"] = {
		label = "Plastic fork",
		weight = 5,
		stack = true,
		close = false,
	},

	["sharpened_plastic_knife"] = {
		label = "Sharpened plastic knife",
		weight = 5,
		stack = true,
		close = true,
	},

	["sharpened_plastic_spoon"] = {
		label = "Sharpened plastic spoon",
		weight = 5,
		stack = true,
		close = true,
	},

	["sharpened_plastic_fork"] = {
		label = "Sharpened plastic fork",
		weight = 5,
		stack = true,
		close = true,
	},

	["freedom_chip"] = {
		label = "A32 Freedom Chip",
		weight = 10,
		stack = true,
		close = true,
	},

	["fence_cutters"] = {
		label = "Fence cutters",
		weight = 1000,
		stack = true,
		close = true,
	},

	["jail_shovel"] = {
		label = "Handmade shovel",
		weight = 3000,
		stack = true,
		close = true,
	},

	["jail_security_card"] = {
		label = "Prison security card",
		weight = 50,
		stack = true,
		close = false,
	},

	["battery"] = {
		label = "Battery",
		weight = 250,
		stack = true,
		close = false,
	},

	["metal_scrap"] = {
		label = "Metal scrap",
		weight = 10,
		stack = true,
		close = false,
	},

	["electronic_scrap"] = {
		label = "Electronic scrap",
		weight = 10,
		stack = true,
		close = false,
	},

	["plastic_scrap"] = {
		label = "Plastic scrap",
		weight = 10,
		stack = true,
		close = false,
	},

	["tape"] = {
		label = "Tape",
		weight = 10,
		stack = true,
		close = false,
	},

	["electric_cable"] = {
		label = "Electric cable",
		weight = 10,
		stack = true,
		close = false,
	},

	["metal_pipe"] = {
		label = "Metal pipe",
		weight = 10,
		stack = true,
		close = false,
	},

	["tin_foil"] = {
		label = "Tin foil",
		weight = 10,
		stack = true,
		close = false,
	},

	["gunpowder"] = {
		label = "Gunpowder",
		weight = 10,
		stack = true,
		close = false,
	},

	["prison_mdt"] = {
		label = "Prison MDT",
		weight = 100,
		stack = true,
		close = true,
	},

	["ifak"] = {
		label = "IFAK",
		weight = 50,
		stack = true,
		close = true,
	},

Items (qb-inventory):
	ankle_monitor                = { name = 'ankle_monitor', label = 'Ankle Monitor', weight = 500, type = 'item', image = 'ankle_monitor.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Ankle monitor' },
    power_saw                    = { name = 'power_saw', label = 'Power Saw', weight = 5000, type = 'item', image = 'power_saw.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Power Saw' },
    prisunflower                 = { name = 'prisunflower', label = 'Prisunflower', weight = 50, type = 'item', image = 'prisunflower.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Prisunflower' },
    prisunflower_seed            = { name = 'prisunflower_seed', label = 'Prisunflower Seed', weight = 10, type = 'item', image = 'prisunflower_seed.png', unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Prisunflower Seed' },
    watering_can                 = { name = 'watering_can', label = 'Watering Can', weight = 2500, type = 'item', image = 'watering_can.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Watering Can' },
    jail_chemicals               = { name = 'jail_chemicals', label = 'Chemicals', weight = 10, type = 'item', image = 'jail_chemicals.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Chemicals' },
	slammer                      = { name = 'slammer', label = 'Slammer', weight = 10, type = 'item', image = 'slammer.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Slammer' },
    jail_lab_tools               = { name = 'jail_lab_tools', label = 'Laboratory Equipment', weight = 100, type = 'item', image = 'jail_lab_tools.png', unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Laboratory Equipment' },
    jail_cigarette               = { name = 'jail_cigarette', label = 'Cigarette', weight = 10, type = 'item', image = 'jail_cigarette.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Cigarette' },
    jail_lighter                 = { name = 'jail_lighter', label = 'Handmade lighter', weight = 50, type = 'item', image = 'jail_lighter.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Handmade lighter' },
    jail_explosive               = { name = 'jail_explosive', label = 'Handmade explosive', weight = 500, type = 'item', image = 'jail_explosive.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Handmade explosive' },
    plastic_knife                = { name = 'plastic_knife', label = 'Plastic knife', weight = 5, type = 'item', image = 'plastic_knife.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Plastic knife' },
    plastic_spoon                = { name = 'plastic_spoon', label = 'Plastic spoon', weight = 5, type = 'item', image = 'plastic_spoon.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Plastic spoon' },
    plastic_fork                 = { name = 'plastic_fork', label = 'Plastic fork', weight = 5, type = 'item', image = 'plastic_fork.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Plastic fork' },
    sharpened_plastic_knife      = { name = 'sharpened_plastic_knife', label = 'Sharpened plastic knife', weight = 5, type = 'item', image = 'sharpened_plastic_knife.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Sharpened plastic knife' },
    sharpened_plastic_spoon      = { name = 'sharpened_plastic_spoon', label = 'Sharpened plastic spoon', weight = 5, type = 'item', image = 'sharpened_plastic_spoon.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Sharpened plastic spoon' },
	sharpened_plastic_fork       = { name = 'sharpened_plastic_fork', label = 'Sharpened plastic fork', weight = 5, type = 'item', image = 'sharpened_plastic_fork.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'sharpened_plastic_fork' },
    freedom_chip                 = { name = 'freedom_chip', label = 'A32 Freedom Chip', weight = 10, type = 'item', image = 'freedom_chip.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'A32 Freedom Chip' },
	fence_cutters                = { name = 'fence_cutters', label = 'Fence cutters', weight = 1000, type = 'item', image = 'fence_cutters.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Fence cutters' },
    jail_shovel                  = { name = 'jail_shovel', label = 'Handmade shovel', weight = 3000, type = 'item', image = 'jail_shovel.png', unique = true, useable = true, shouldClose = true, combinable = nil, description = 'Handmade shovel' },
    jail_security_card           = { name = 'jail_security_card', label = 'Prison security card', weight = 50, type = 'item', image = 'jail_security_card.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Prison security card' },
    battery                      = { name = 'battery', label = 'Battery', weight = 250, type = 'item', image = 'battery.png', unique = true, useable = true, shouldClose = false, combinable = nil, description = 'Battery' },
    metal_scrap                  = { name = 'metal_scrap', label = 'Metal scrap', weight = 10, type = 'item', image = 'metal_scrap.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Metal scrap' },
    electronic_scrap             = { name = 'electronic_scrap', label = 'Electronic scrap', weight = 10, type = 'item', image = 'electronic_scrap.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Electronic scrap' },
    plastic_scrap                = { name = 'plastic_scrap', label = 'Plastic scrap', weight = 10, type = 'item', image = 'plastic_scrap.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Plastic scrap' },
    tape                         = { name = 'tape', label = 'Tape', weight = 10, type = 'item', image = 'tape.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Tape' },
	electric_cable               = { name = 'electric_cable', label = 'Electric cable', weight = 10, type = 'item', image = 'electric_cable.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Electric cable' },
    metal_pipe                   = { name = 'metal_pipe', label = 'Metal pipe', weight = 10, type = 'item', image = 'metal_pipe.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Metal pipe' },
	tin_foil                     = { name = 'tin_foil', label = 'Tin foil', weight = 10, type = 'item', image = 'tin_foil.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Tin foil' },
    gunpowder                    = { name = 'gunpowder', label = 'Gunpowder', weight = 10, type = 'item', image = 'gunpowder.png', unique = false, useable = true, shouldClose = false, combinable = nil, description = 'Gunpowder' },
    prison_mdt                   = { name = 'prison_mdt', label = 'Prison MDT', weight = 100, type = 'item', image = 'prison_mdt.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'Prison MDT' },
    ifak                         = { name = 'ifak', label = 'IFAK', weight = 50, type = 'item', image = 'ifak.png', unique = false, useable = true, shouldClose = true, combinable = nil, description = 'IFAK' }

More questions?
   - Join our Discord and open a ticket: https://discord.gg/YndnF9tkqu