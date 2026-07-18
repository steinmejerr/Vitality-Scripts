return {
	Weapons = {

		-- Stik- slagvåben & throwables

		['WEAPON_BAT'] = {
		label = 'Jern bat',
			weight = 1134,
			durability = 0.1,
		},

		['WEAPON_BATTLEAXE'] = {
			label = 'Kamp økse',
			weight = 6500,
			durability = 0.1,
		},

		['WEAPON_BOTTLE'] = {
			label = 'Smadret flaske',
			weight = 350,
			durability = 0.1,
		},

		['WEAPON_CROWBAR'] = {
			label = 'Brækjern',
			weight = 2500,
			durability = 0.1,
		},

		['WEAPON_DAGGER'] = {
			label = 'Dagger',
			weight = 800,
			durability = 0.1,
		},

		['WEAPON_FIREEXTINGUISHER'] = {
			label = 'Brandslukker',
			weight = 8616,
            durability = 0.006
		},

		['WEAPON_FLASHLIGHT'] = {
			label = 'Lommelygte',
			weight = 125,
			durability = 0.1,
		},

		['WEAPON_GOLFCLUB'] = {
			label = 'Golfkølle',
			weight = 330,
			durability = 0.1,
		},

		['WEAPON_HAMMER'] = {
			label = 'Hammer',
			weight = 1200,
			durability = 0.1,
		},

		['WEAPON_METALDETECTOR'] = {
			label = 'Metaldetektor',
			weight = 1200,
		},

		['WEAPON_KNIFE'] = {
			label = 'Kniv',
			weight = 300,
			durability = 0.1,
		},

		['WEAPON_KNUCKLE'] = {
			label = 'Knojern',
			weight = 300,
			durability = 0.1,
		},

		['WEAPON_MACHETE'] = {
			label = 'Machete',
			weight = 1000,
			durability = 0.1,
		},

		['WEAPON_NIGHTSTICK'] = {
			label = 'Politistav',
			weight = 1000,
			durability = 0.1,
		},

		['WEAPON_PETROLCAN'] = {
			label = 'Benzindunk',
			weight = 4000,
		},

		['WEAPON_POOLCUE'] = {
			label = 'Pool kølle',
			weight = 146,
			durability = 0.1,
		},

		['WEAPON_SNOWBALL'] = {
			label = 'Snebold',
			weight = 5,
			throwable = true,
		},

		['WEAPON_MOLOTOV'] = {
			label = 'Molotov',
			weight = 1800,
			throwable = true,
		},

		['WEAPON_WRENCH'] = {
			label = 'Svensknøgle',
			weight = 2500,
			durability = 0.1,
		},

		['WEAPON_SWITCHBLADE'] = {
			label = 'Springkniv',
			weight = 300,
			durability = 0.1,
			anim = { 'anim@melee@switchblade@holster', 'unholster', 200, 'anim@melee@switchblade@holster', 'holster', 600 },
		},

		['WEAPON_BZGAS'] = {
			label = 'Tåregas',
			weight = 600,
			throwable = true,
		},

		-- Pistoler

		['WEAPON_PISTOL'] = {
			label = 'Pistol',
			weight = 1000,
			durability = 0,
			ammoname = 'ammo',
		},

		['WEAPON_COMBATPISTOL'] = {
			label = 'Tjenestepistol',
			weight = 785,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_PISTOL50'] = {
			label = 'Pistol .50',
			weight = 2000,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_PISTOL_MK2'] = {
			label = 'Pistol mk2',
			weight = 1000,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_CERAMICPISTOL'] = {
			label = 'Ceramic Pistol',
			weight = 800,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_PISTOLXM3'] = {
			label = 'WM 29 Pistol',
			weight = 969,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_SNSPISTOL'] = {
			label = 'SNS Pistol',
			weight = 465,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_STUNGUN'] = {
			label = 'Strømpistol',
			weight = 227,
			durability = 0,
		},

		['WEAPON_VINTAGEPISTOL'] = {
			label = 'Vintage Pistol',
			weight = 700,
			durability = 0,
			ammoname = 'ammo'
		},

		
		['WEAPON_REVOLVER'] = {
			label = 'Revolver',
			weight = 2000,
			durability = 0,
			ammoname = 'ammo'
		},

		-- SMG & Rifler

		['WEAPON_SMG'] = {
			label = 'Mp5',
			weight = 1700,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_TECPISTOL'] = {
			label = 'Tactical SMG',
			weight = 1000,
			durability = 0,
			ammoname = 'ammo-9',
		},

		['WEAPON_ASSAULTRIFLE'] = {
			label = 'Assault Rifle',
			weight = 2500,
			durability = 0,
			ammoname = 'ammo',
		},

		['WEAPON_CARBINERIFLE'] = {
			label = 'Gevær M/10',
			weight = 2500,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_COMBATPDW'] = {
			label = 'Combat PDW',
			weight = 2300,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_DBSHOTGUN'] = {
			label = 'DB Shotgun',
			weight = 3000,
			durability = 0,
			ammoname = 'ammo2'
		},
        
		['WEAPON_GUSENBERG'] = {
			label = 'Tommygun',
			weight = 3000,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_MICROSMG'] = {
			label = 'Micro SMG',
			weight = 3000,
			durability = 0,
			ammoname = 'ammo'
		},

		['WEAPON_PUMPSHOTGUN'] = {
			label = 'Pump Shotgun',
			weight = 2000,
			durability = 0,
			ammoname = 'ammo2'
		},

		-- Hunting
		['WEAPON_SNIPERRIFLE'] = {
			label = 'Jagtgevær',
			weight = 5000,
			durability = 0,
			ammoname = 'ammo-jagt'
		},

		['WEAPON_ACIDPACKAGE'] = {
			label = 'Avis',
			weight = 2500,
			durability = 0.05,
			ammoname = 'ammo-acid'
		},
},

	Components = {
		['flashlight'] = {
			label = 'Våben Lygte',
			weight = 120,
			stack = true,
			type = 'flashlight',
			client = {
				component = {`COMPONENT_AT_PI_FLSH`,`COMPONENT_AT_AR_FLSH`, `COMPONENT_AT_PI_FLSH_02`},
				usetime = 2500
			}
		},

		['silencer'] = {
			label = 'Lyddæmper',
			weight = 300,
			stack = true,
			type = 'barrel',
			client = {
				component = {
					`COMPONENT_AT_PI_SUPP`, 
					`COMPONENT_AT_PI_SUPP_02`,
					`COMPONENT_AT_AR_SUPP`, 
					`COMPONENT_AT_AR_SUPP_02`, 
					`COMPONENT_AT_SR_SUPP`, 
					`COMPONENT_AT_SR_SUPP_03`,
					`COMPONENT_AT_SR_BARREL_01`,
					`COMPONENT_AT_MRFL_BARREL_02`,
					`COMPONENT_AT_MG_BARREL_02`,
					`COMPONENT_AT_SC_BARREL_02`, 
					`COMPONENT_AT_CR_BARREL_02`, 
					`COMPONENT_AT_BP_BARREL_02`,
					`COMPONENT_AT_PI_COMP_02`, 
					`COMPONENT_AT_PI_COMP_03`, 
					`COMPONENT_AT_PI_COMP`,
					`COMPONENT_AT_MUZZLE_01`,
					`COMPONENT_AT_MUZZLE_02`,
					`COMPONENT_AT_MUZZLE_03`,
					`COMPONENT_AT_MUZZLE_04`,
					`COMPONENT_AT_MUZZLE_05`,
					`COMPONENT_AT_MUZZLE_06`,
					`COMPONENT_AT_MUZZLE_07`,
					`COMPONENT_AT_MUZZLE_08`,
					`COMPONENT_AT_MUZZLE_09`,
				},
				usetime = 2500
			}
		},

		['grip'] = {
			label = 'Greb',
			type = 'grip',
			weight = 280,
			client = {
				component = {
					`COMPONENT_AT_AR_AFGRIP`,
					`COMPONENT_AT_AR_AFGRIP_02`
				},
				usetime = 2500
			}
		},

		['clip'] = {
			label = 'Udvidet magasin',
			type = 'magazine',
			weight = 250,
			stack = true,
			client = {
				component = {
					`COMPONENT_PISTOL_CLIP_02`, 
					`COMPONENT_APPISTOL_CLIP_02`, 
					`COMPONENT_PISTOL_MK2_CLIP_02`, 
					`COMPONENT_SNSPISTOL_MK2_CLIP_02`, 
					`COMPONENT_COMBATPISTOL_CLIP_02`, 
					`COMPONENT_PISTOL50_CLIP_02`, 
					`COMPONENT_HEAVYPISTOL_CLIP_02`, 
					`COMPONENT_SNSPISTOL_CLIP_02`, 
					`COMPONENT_VINTAGEPISTOL_CLIP_02`,
					`COMPONENT_SMG_CLIP_02`, 
					`COMPONENT_SMG_MK2_CLIP_02`, 
					`COMPONENT_ASSAULTSMG_CLIP_02`, 
					`COMPONENT_MICROSMG_CLIP_02`, 
					`COMPONENT_MINISMG_CLIP_02`, 
					`COMPONENT_COMBATPDW_CLIP_02`, 
					`COMPONENT_MACHINEPISTOL_CLIP_02`,
					`COMPONENT_HEAVYSHOTGUN_CLIP_02`, 
					`COMPONENT_ASSAULTSHOTGUN_CLIP_02`,
					`COMPONENT_ASSAULTRIFLE_CLIP_02`, 
					`COMPONENT_CARBINERIFLE_CLIP_02`,
					`COMPONENT_MILITARYRIFLE_CLIP_02`, 
					`COMPONENT_ADVANCEDRIFLE_CLIP_02`,
					`COMPONENT_SPECIALCARBINE_CLIP_02`, 
					`COMPONENT_BULLPUPRIFLE_CLIP_02`, 
					`COMPONENT_COMPACTRIFLE_CLIP_02`, 
					`COMPONENT_ASSAULTRIFLE_MK2_CLIP_02`, 
					`COMPONENT_CARBINERIFLE_MK2_CLIP_02`,
					`COMPONENT_SPECIALCARBINE_MK2_CLIP_02`, 
					`COMPONENT_BULLPUPRIFLE_MK2_CLIP_02`,
					`COMPONENT_MG_CLIP_02`, 
					`COMPONENT_COMBATMG_CLIP_02`, 
					`COMPONENT_GUSENBERG_CLIP_02`, 
					`COMPONENT_COMBATMG_MK2_CLIP_02`,
					`COMPONENT_MARKSMANRIFLE_CLIP_02`, 
					`COMPONENT_HEAVYSNIPER_MK2_CLIP_02`, 
					`COMPONENT_MARKSMANRIFLE_MK2_CLIP_02`,

				},
				usetime = 2500
			}
		},

		['scope'] = {
			label = 'Sigte',
			type = 'sight',
			weight = 280,
			stack = true,
			client = {
				component = {
					`COMPONENT_AT_SIGHTS`, 
					`COMPONENT_AT_SCOPE_MACRO`, 
					`COMPONENT_AT_SCOPE_MACRO_02`, 
					`COMPONENT_AT_SCOPE_MACRO_02_MK2`, 
					`COMPONENT_AT_SCOPE_MACRO`, 
					`COMPONENT_AT_SCOPE_SMALL`, 
					`COMPONENT_AT_SCOPE_SMALL_02`, 
					`COMPONENT_AT_SCOPE_SMALL_MK2`, 
					`COMPONENT_AT_SCOPE_MACRO_MK2`,
					`COMPONENT_AT_SCOPE_MEDIUM`, 
					`COMPONENT_AT_SCOPE_MEDIUM_MK2`, 
					`COMPONENT_AT_PI_RAIL_02`, 
					`COMPONENT_AT_PI_RAIL`,
					`COMPONENT_AT_SCOPE_MAX`,
					`COMPONENT_AT_SCOPE_LARGE_MK2`,
					`COMPONENT_AT_SCOPE_NV`,
					`COMPONENT_AT_SCOPE_THERMAL`,
				},
				usetime = 2500
			}
		},
	},

	Ammo = {
       	['ammo'] = {
			label = 'Ammunition',
			weight = 10,
		},

		['ammo2'] = {
			label = 'Shotgun Slugs',
			weight = 10,
		},
        
        ['ammo-taser'] = {
			label = 'Taser Cartridges',
			weight = 10,
		},

		['ammo-jagt'] = {
			label = 'Jagtammunition',
			weight = 10,
		},
	}
}
