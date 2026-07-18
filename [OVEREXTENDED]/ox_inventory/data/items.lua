return {
	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['black_money'] = {
		label = 'Sorte penge',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'Du spiste en lækker burger!'
		},
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
		}
	},

	['parachute'] = {
		label = 'Faldskærm',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},
	['garbage'] = {
		label = 'Skrald',
	},

	['paperbag'] = {
		label = 'Papirspose',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['panties'] = {
		label = 'Trusser',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Dirkesæt',
		weight = 160,
	},

	['phone'] = {
		label = 'Telefon',
		weight = 190,
		stack = false,
		consume = 0,
	},

	['money'] = {
		label = 'Kontanter',
	},

	['water'] = {
		label = 'Vandflaske',
		weight = 500,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	["bread"] = {
		label = "Brød",
		weight = 1,
		stack = true,
		close = true,
	},
    
	["medikit"] = {
		label = "Medikit",
		weight = 2,
		stack = true,
		close = true,
	},
    
    ['fakeplate'] = {
	label = "Falsk nummerplade",
	weight = 1500,
	client = {
		event = "op-garages:useFakePlate",
	}
},
    
-- garagesystem
['fakeplate_remover'] = {
	label = "Original nummerplade",
	weight = 1500,
	client = {
		event = "op-garages:removeFakePlate",
	}
},

['car_contract'] = {
	label = "Bilkontrakt",
	weight = 1500,
	client = {
		event = "op-garages:carContractUse",
	}
},
    
    -- banking
    ['debitcard_personal'] = {
    label = 'Betalingskort',
    stack = false,
    weight = 10,
    consume = 0,
    client = {
        export = "tgg-banking.UseCardOnAtm"
    }
},
['debitcard_shared'] = {
    label = 'Dele betalingskort',
    stack = false,
    weight = 10,
    consume = 0,
    client = {
        export = "tgg-banking.UseCardOnAtm"
    }
},
['debitcard_business'] = {
    label = 'Firma betalingskort',
    stack = false,
    weight = 10,
    consume = 0,
    client = {
        export = "tgg-banking.UseCardOnAtm"
    }
},

-- P Ambulance
	['crutch'] = {
		label = 'Krykke',
		weight = 100,
		stack = false,
		close = true,
	},

	['wheelchair'] = {
		label = 'Kørestol',
		weight = 100,
		stack = false,
		close = true,
	},

	['stretcher'] = {
		label = 'Båre',
		weight = 100,
		stack = false,
		close = true,
	},

	['medical_kit'] = {
		label = 'Medicinsæt',
		weight = 200,
		stack = false,
		close = false,
		description = 'Et basalt medicinsæt, der indeholder vigtige forsyninger til behandling af mindre skader og sygdomme.',
	},

	['advanced_medical_kit'] = {
		label = 'Avanceret Medicinsæt',
		weight = 200,
		stack = false,
		close = false,
		description = 'Et mere avanceret medicinsæt, der indeholder yderligere forsyninger og udstyr til behandling af skader og sygdomme.',
	},

	['blood_bag_250'] = {
		label = 'Blodpose 250ml',
		weight = 250,
		stack = true,
		close = false,
		description = 'En 250ml blodpose, der bruges til blodtransfusioner.',
	},

	['blood_bag_500'] = {
		label = 'Blodpose 500ml',
		weight = 500,
		stack = true,
		close = false,
		description = 'En 500ml blodpose, der bruges til blodtransfusioner.',
	},

	['painkillers'] = {
		label = 'Smertestillende',
		weight = 50,
		stack = true,
		close = false,
		description = 'Medicin, der bruges til at lindre smerter og nedsætte feber.',
	},

	['adrenaline'] = {
		label = 'Adrenalin',
		weight = 50,
		stack = true,
		close = false,
	},

	['morphine'] = {
		label = 'Morfin',
		weight = 50,
		stack = true,
		close = false,
		description = 'Medicin, der bruges til at lindre smerter og nedsætte feber.',
	},

	['suture_kit'] = {
		label = 'Sutursæt',
		weight = 100,
		stack = true,
		close = false,
		description = 'Et medicinsk redskab, der bruges til at lukke sår eller kirurgiske snit.',
	},

	['icepack'] = {
		label = 'Ispose',
		weight = 100,
		stack = true,
		close = false,
		description = 'En ispose, der bruges til at reducere hævelse og bedøve smerter.',
	},

	['splint'] = {
		label = 'Skinne',
		weight = 100,
		stack = true,
		close = false,
		description = 'En anordning, der bruges til at lægge pres på et lem.',
	},

	['defibrilator'] = {
		label = 'Hjertestarter',
		weight = 500,
		stack = false,
		close = true,
	},

	['bodybag'] = {
		label = 'Ligpose',
		weight = 500,
		stack = true,
		close = false,
	},

	['gauze'] = {
		label = 'Gaze',
		weight = 20,
		stack = true,
		close = true,
		description = 'Et tyndt, gennemsigtigt stof med en løs åben vævning, der bruges til forbindinger, bandager og kirurgiske svampe.',
	},

	['bandage'] = {
		label = 'Bandage',
		description = 'Meget god til at stoppe blødninger og mindre skader',
		weight = 115,
		stack = true,
		close = true
	},

	['ointment'] = {
		label = 'Salve',
		weight = 50,
		stack = true,
		close = true,
		description = 'En medicinsk creme, der bruges til at fremme heling og forhindre infektion i mindre snitsår, skrammer og forbrændinger.',
	},

	['disinfectant'] = {
		label = 'Desinfektionsmiddel',
		weight = 50,
		stack = true,
		close = true,
		description = 'En væske, der dræber bakterier og andre mikroorganismer på overflader.',
	},

	['cyclonamine'] = {
		label = 'Cyklonamin',
		weight = 50,
		stack = true,
		close = true,
	},

	['tourniquet'] = {
		label = 'Årepresse',
		weight = 100,
		stack = true,
		close = true,
		description = 'En anordning, der bruges til at lægge pres på et lem.',
	},

	['medicbag'] = {
		label = 'Medicintaske',
		weight = 500,
		stack = false,
		close = true,
		description = 'En taske, der indeholder medicinske forsyninger og udstyr.',
	},

	['antipyretics'] = {
		label = 'Febernedsættende',
		weight = 50,
		stack = true,
		close = true,
		description = 'Medicin, der nedsætter feber.',
	},

	['ambulance_gps'] = {
		label = 'Ambulance GPS',
		weight = 100,
		stack = false,
		close = true,
	},

	-- VEX PANT
	['pant_bottle'] = {
		label = 'Pant Bottle',
		weight = 300,
	},

	['pant_can'] = {
		label = 'Pant Can',
		weight = 200,
	},

	['pant_large_bottle'] = {
		label = 'Large Pant Bottle',
		weight = 500,
	},

	['pant_bon'] = {
		label = 'Pantbon',
		weight = 1,
		stack = false,
		close = true,
		consume = 0,
		server = {
			export = 'vex_pant.readReceipt'
		}
	},

	-- VEX TOBACCO
	-- SNUS  
  ['welo_racism'] = {
        label = 'Welo Max Taste Of Racism',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },

    ['welo_capitalism'] = {
        label = 'Welo Max Taste Of Capitalism',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },

    ['welo_dragonpee'] = {
        label = 'Welo Max Taste Of Dragonpee',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },

    ['welo_mysoul'] = {
        label = 'Welo Max Taste Of "My Soul"',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },

    ['welo_air'] = {
        label = 'Welo Max Taste Of Air',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },

    ['welo_max'] = {
        label = 'Welo Taste of Max Vax',
        weight = 50,
        stack = false,
        close = true,
        description = 'En dåse Welo snus.'
    },
    
-- Snus Poser
    ['pouch_racism'] = { 
        label = 'Welo Racism Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

    ['pouch_capitalism'] = { 
        label = 'Welo Capitalism Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

    ['pouch_dragonpee'] = { 
        label = 'Welo Dragonpee Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

    ['pouch_mysoul'] = { 
        label = 'Welo My Soul Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

    ['pouch_air'] = { 
        label = 'Welo Air Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

    ['pouch_max'] = { 
        label = 'Welo Max Vax Pose', 
        weight = 1, 
        close = true, 
        description = 'En lille nikotinpose.' 
    },

-- CigarettePacks
    ['debonaire_orginal'] = {
        label = 'Debonaire Original',
        weight = 100,
        stack = false,
        close = true,
        description = 'En pakke cigaretter.'
    },
	['debonaire_light'] = {
        label = 'Debonaire Light',
        weight = 100,
        stack = false,
        close = true,
        description = 'En pakke cigaretter.'
    },

    ['redwood_original'] = {
        label = 'Redwood Original',
        weight = 100,
        stack = false,
        close = true,
        description = 'En pakke cigaretter.'
    },

    ['redwood_golds'] = {
        label = 'Redwood Golds',
        weight = 100,
        stack = false,
        close = true,
        description = 'En pakke cigaretter.'
    },

    ['redwood_export'] = {
        label = 'Redwood Export',
        weight = 100,
        stack = false,
        close = true,
        description = 'En pakke cigaretter.'
    },
	
-- Cigarettes
    ['cigarette'] = {
        label = 'Cigaret',
        weight = 10,
        stack = false,
        close = true,
        description = 'En enkelt cigaret.'
    },
-- Pipe
    ['bzzz_prop_smoking_pipe_a'] = {
        label = 'Pipe',
        weight = 10,
        stack = false,
        close = true,
    },

-- Spray Paint
['spraycloth'] = {
    label = 'Spray Cloth',
    weight = 200,
    stack = true,
    close = true,
    description = 'A cloth used to wipe or clean spray paint.'
},

['spraypaint'] = {
    label = 'Spray Paint',
    weight = 500,
    stack = true,
    close = true,
    description = 'A spray paint can used to paint surfaces.'
},

    -- Mani houserobbery
    	['necklace'] = {
		label = 'Halskæde',
		weight = 5,
	},

	['diamond_necklace'] = {
		label = 'Diamant-halskæde',
		weight = 10,
	},

	['ring'] = {
		label = 'Ring',
		weight = 2,
	},

	['diamond_ring'] = {
		label = 'Diamantring',
		weight = 5,
	},

	['watch'] = {
		label = 'Ur',
		weight = 10,
	},

	['luxurious_watch'] = {
		label = 'Luksusur',
		weight = 20,
	},

	['gold_bar'] = {
		label = 'Guldbarre',
		weight = 35,
	},

	['diamantboks'] = {
		label = 'Stor diamant',
		weight = 40,
	},

	['skull_art'] = {
		label = 'Kranium-kunst',
		weight = 25,
	},

	['painting1'] = {
		label = 'Maleri 1',
		weight = 85,
		client = {
			image = 'painting1.png',
		},
	},

	['painting2'] = {
		label = 'Maleri 2',
		weight = 85,
		client = {
			image = 'painting2.png',
		},
	},

	['painting3'] = {
		label = 'Maleri 3',
		weight = 85,
		client = {
			image = 'painting3.png',
		},
	},

	['painting4'] = {
		label = 'Maleri 4',
		weight = 85,
		client = {
			image = 'painting4.png',
		},
	},
    
-- =========================================================================
-- vex_kamera Items
-- =========================================================================

	['camera'] = {
		label = 'Kamera',
		weight = 1200,
		stack = false,
		close = true,
		client = {
			event = 'vex_camera:client:useCameraItem'
		},
		description = 'Et professionelt DSLR-kamera til skarpe billeder.'
	},

	['polaroid'] = {
		label = 'Polaroid Kamera',
		weight = 800,
		stack = false,
		close = true,
		client = {
			event = 'vex_camera:client:usePolaroidItem'
		},
		description = 'Et klassisk polaroidkamera, der printer billedet med det samme.'
	},

	['videocamera'] = {
		label = 'Videokamera',
		weight = 2500,
		stack = false,
		close = true,
		client = {
			event = 'vex_camera:client:useVideoItem'
		},
		description = 'Et retro camcorder videokamera.'
	},

	['camera_photo'] = {
		label = 'Billede',
		weight = 10,
		stack = true,
		close = true,
		consume = 0,
		client = {
			event = 'vex_camera:client:usePhotoItem'
		},
		description = 'Et fremkaldt kamera-billede.'
	},

	['polaroid_photo'] = {
		label = 'Polaroid Billede',
		weight = 10,
		stack = true,
		close = true,
		consume = 0,
		client = {
			event = 'vex_camera:client:usePolaroidPhotoItem'
		},
		description = 'Et unikt polaroidbillede med hilsen.'
	},

-- BZZZ FOOD
	['barfs'] = {
		label = 'Popsicle Barfs',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_barfs_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},
	['chilldo'] = {
		label = 'Popsicle Childo',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_chilldo_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},
	['chufty'] = {
		label = 'Chocolate Chufty',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_chufty_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['chufty2'] = {
		label = 'Creamy Chufty',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_chufty2_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['freeze'] = {
		label = 'Freeze sucka',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_freeze_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['milken'] = {
		label = 'Üder milken',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_milken_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['orang'] = {
		label = 'Orang-O-Tang',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_orang_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['starfish'] = {
		label = 'Chocolate starfish',
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_popsicle_starfish_b`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			notification = 'Bon appétit'
		}
	},	
	['bzzz_croissant'] = {
			label = 'Croissant',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_new_snacks_croissant_a`, pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, -50.0, 80.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
	},	
	['bzzz_donut_a'] = {
			label = 'Pink donut',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_new_snacks_donut_a`, pos = vec3(0.0, 0.0, -0.02), rot = vec3(0.0, -20.0, 80.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
	},		
	['bzzz_donut_b'] = {
			label = 'Chocolate donut',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_new_snacks_donut_b`, pos = vec3(0.0, 0.0, -0.02), rot = vec3(0.0, -20.0, 80.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},
	['bzzz_peanuts'] = {
			label = 'Peanuts',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_new_snacks_peanuts_a`, pos = vec3(0.0, -0.02, -0.01), rot = vec3(0.0, -20.0, 80.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},
	['bzzz_pretzels'] = {
			label = 'Pretzels',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_new_snacks_pretzels_a`, pos = vec3(0.03, -0.04, -0.01), rot = vec3(-80.0, 0.0, 70.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},
	['bzzz_pepsiloca_a'] = {
			label = 'Pepsiloca',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bzzz_new_snacks_pepsiloca_a`, pos = vec3(0.01 ,0.00, 0.07), rot = vec3(0.0, 0.0, 0.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},
	['bzzz_pepsiloca_b'] = {
			label = 'Pepsiloca light',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bzzz_new_snacks_pepsiloca_b`, pos = vec3(0.01 ,0.00, 0.07), rot = vec3(0.0, 0.0, 0.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},
	['bzzz_energy'] = {
			label = 'Energy drink',
			weight = 500,
			client = {
				status = { thirst = 200000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bzzz_new_snacks_energy_a`, pos = vec3(0.01 ,0.00, 0.05), rot = vec3(0.0, 0.0, 0.0) },
				usetime = 2500,
				cancel = true,
				notification = 'Bon appétit'
			}
		},	
	['bzzz_mushroomsfood_omelette_a'] = {
        label = 'Mushroom omelette',
        degrade = 2880,-- 48 hours
        weight = 200,
        stack = false,
        close = true,
        description = "Mushroom omelette",
        client = {
            status = { hunger = 200000 },
            anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

            prop = { model = 'bzzz_mushroomsfood_omelette_a',
			bone = 60309,
            pos = vec3(0.08, 0.01, 0.05),
            rot = vec3(-30.0, 0.0, 0.0) },

            propTwo = { model = 'bzzz_mushroomsfood_omelette_b',
			bone = 28422,
            pos = vec3(0.09, 0.04, -0.05),
            rot = vec3(-90.0, 0.0, -30.0) },

            usetime = 17500,
			notification = 'You have satisfied your hunger'
        },
    },
	['bzzz_mushroomsfood_rolls_a'] = {
			label = 'Mushroom Beef Rolls',
			degrade = 2880,-- 48 hours
			weight = 200,
			stack = false,
			close = true,
			description = "Mushroom Beef Rolls",
			client = {
				status = { hunger = 200000 },
				anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

				prop = { model = 'bzzz_mushroomsfood_rolls_a',
				bone = 60309,
				pos = vec3(0.08, 0.01, 0.05),
				rot = vec3(-30.0, 0.0, 0.0) },

				propTwo = { model = 'bzzz_mushroomsfood_rolls_b',
				bone = 28422,
				pos = vec3(0.09, 0.04, -0.05),
				rot = vec3(-90.0, 0.0, -30.0) },

				usetime = 10500,
				notification = 'You have satisfied your hunger'
			},
		},	
	['bzzz_mushroomsfood_pho_a'] = {
			label = 'Mushroom Pho',
			degrade = 2880,-- 48 hours
			weight = 200,
			stack = false,
			close = true,
			description = "Mushroom Pho",
			client = {
				status = { hunger = 200000 },
				anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

				prop = { model = 'bzzz_mushroomsfood_pho_a',
				bone = 60309,
				pos = vec3(0.07, 0.03, 0.07),
				rot = vec3(-30.0, 0.0, 0.0) },
				
				propTwo = { model = 'bzzz_mushroomsfood_pho_b',
				bone = 28422,
				pos = vec3(0.08, 0.04, -0.05),
				rot = vec3(-90.0, -20.0, -10.0) },

				usetime = 10500,
				notification = 'You have satisfied your hunger'
			},
		},	
	['bzzz_mushroomsfood_risotto_a'] = {
			label = 'Porcini Mushroom Risotto',
			degrade = 2880,-- 48 hours
			weight = 200,
			stack = false,
			close = true,
			description = "Porcini Mushroom Risotto",
			client = {
				status = { hunger = 200000 },
				anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

				prop = { model = 'bzzz_mushroomsfood_risotto_a',
				bone = 60309,
				pos = vec3(0.07, 0.03, 0.07),
				rot = vec3(-30.0, 0.0, 0.0) },
				
				propTwo = { model = 'bzzz_mushroomsfood_risotto_b',
				bone = 28422,
				pos = vec3(0.09, 0.03, -0.06),
				rot = vec3(-110.0, 150.0, -30.0) },

				usetime = 10500,
				notification = 'You have satisfied your hunger'
			},
		},	
	['bzzz_mushroomsfood_soup_a'] = {
			label = 'Mushroom Soup',
			degrade = 2880,-- 48 hours
			weight = 200,
			stack = false,
			close = true,
			description = "Mushroom Soup",
			client = {
				status = { hunger = 200000 },
				anim = { dict = 'bzzz_mushrooms_food', clip = 'bzzz_mushrooms_food' },

				prop = { model = 'bzzz_mushroomsfood_soup_a',
				bone = 60309,
				pos = vec3(0.07, 0.03, 0.07),
				rot = vec3(-30.0, 0.0, 0.0) },
				
				propTwo = { model = 'bzzz_mushroomsfood_soup_b',
				bone = 28422,
				pos = vec3(0.09, 0.03, -0.06),
				rot = vec3(-110.0, 150.0, -30.0) },

				usetime = 10500,
				notification = 'You have satisfied your hunger'
			},
		},	
	['bzzz_mushroomsfood_skewer_a'] = {
		label = 'Grilled Mushroom Skewer',
		degrade = 2880,-- 48 hours
		stack = false,
		close = true,
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_mushroomsfood_skewer_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.0), rot = vec3(-90.0, -90.0, 0.0) },
			usetime = 5500,
			notification = 'Bon appétit'
		}
	},	
	['bzzz_mushroomsfood_taco_a'] = {
		label = 'Mushroom Taco',
		degrade = 2880,-- 48 hours
		stack = false,
		close = true,
		weight = 350,
		client = {
			status = { hunger = 200000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_mushroomsfood_taco_a`, bone = 60309, pos = vec3(0.0, 0.0, 0.01), rot = vec3(0.0, 5.0, 5.0) },
			usetime = 5500,
			notification = 'Bon appétit'
		}
	},
	['bzzz_prop_pickle_a2'] = {
		label = 'Classic Dill Pickle',
		weight = 200,
		client = {
			status = { hunger = 30000 },
			anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
			prop = { model = `bzzz_prop_pickle_a2`, bone = 60309, pos = vec3(0.02, 0.01, -0.03), rot = vec3(10.0, 0.0, 90.0) },
			usetime = 5000, 
			notification = 'Bon appétit!'
		}
	},
	['bzzz_prop_pickle_b2'] = {
			label = 'Garlic Crunch',
			weight = 200,
			client = {
				status = { hunger = 30000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_prop_pickle_b2`, bone = 60309, pos = vec3(0.02, 0.01, -0.03), rot = vec3(10.0, 0.0, 90.0) },
				usetime = 5000, 
				notification = 'Bon appétit!'
			}
		},
	['bzzz_prop_pickle_c2'] = {
			label = 'Hot Fire Pickle',
			weight = 200,
			client = {
				status = { hunger = 30000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_prop_pickle_c2`, bone = 60309, pos = vec3(0.02, 0.01, -0.03), rot = vec3(10.0, 0.0, 90.0) },
				usetime = 5000, 
				notification = 'Bon appétit!'
			}
		},
	['bzzz_prop_pickle_d2'] = {
			label = 'Smoky BBQ Pickle',
			weight = 200,
			client = {
				status = { hunger = 30000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_prop_pickle_d2`, bone = 60309, pos = vec3(0.02, 0.01, -0.03), rot = vec3(10.0, 0.0, 90.0) },
				usetime = 5000, 
				notification = 'Bon appétit!'
			}
		},
	['bzzz_prop_pickle_e2'] = {
			label = 'Sweet Honey Pickle',
			weight = 200,
			client = {
				status = { hunger = 30000 },
				anim = { dict = 'mp_player_inteat@burger', clip = 'mp_player_int_eat_burger' },
				prop = { model = `bzzz_prop_pickle_e2`, bone = 60309, pos = vec3(0.02, 0.01, -0.03), rot = vec3(10.0, 0.0, 90.0) },
				usetime = 5000, 
				notification = 'Bon appétit!'
			}
		},

	-- ID
	["id_card"] = {
		label = "ID Kort", 
		weight = 1,
		stack = true,
		close = true,
	},

	["driver_license"] = {
		label = "Kørekort",
		weight = 1,
		stack = true,
		close = true,
	},
    
    -- Policejob
       ['cone'] = {
		label = 'Kegle',
		weight = 100,
		stack = true,
		close = true,
	},

	['barrier'] = {
		label = 'Blokade',
		weight = 100,
		stack = true,
		close = true,
	},

	['worklight'] = {
		label = 'Arbejdslys',
		weight = 100,
		stack = true,
		close = true,
	},

	['spike_strips'] = {
		label = 'Sømmåtte',
		weight = 100,
		stack = true,
		close = true,
	},

	['speed_camera'] = {
		label = 'Fartkamera',
		weight = 1000,
		stack = true,
		close = true,
	},

	['breathalyzer'] = {
		label = 'Alkometer',
		weight = 100,
		stack = true,
		close = true,
	},

	['fingerprint_scanner'] = {
		label = 'Fingeraftryk scanner',
		weight = 100,
		stack = true,
		close = true,
	},

	['handcuffs'] = {
		label = 'Håndjern',
		weight = 100,
		stack = true,
		close = true,
	},

-- Bite Sandwiches
	['bitecookies'] = {---Spawn name 
		label = 'Bite Cookies Box', ---Inventory Lable
		weight = 350, ----Weight
		client = {
			status = { thirst = 20000 }, --Status change amount
			anim = { dict = 'anim@scripted@island@special_peds@pavel@hs4_pavel_ig5_caviar_p1', clip = 'base_idle' },----Animation
			prop = { model = `bv_bite_cookiepack`, pos = vec3(0.06, 0.01, 0.0), rot = vec3(0.0, 45.0, 90.0) }, ---Prop position
			usetime = 9500, --- How long the player will drink
			notification = 'You quenched your thirst with 7UP' -- In game message when drinking
		}
	},
	['bitesalad'] = {
			label = 'Bite Salad',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'anim@scripted@island@special_peds@pavel@hs4_pavel_ig5_caviar_p1', clip = 'base_idle' },----Animation
				prop = { model = `bv_bite_salad`, pos = vec3(0.0, 0.0, -0.05), rot = vec3(0.0, 0.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Bite Mixed Salad Bowl'
			}
	},
	['bitecupecola'] = {
			label = 'Bite Ecola Cup',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bv_bite_cup`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a cold Bite Ecola Cup'
			}
	},
	['bitecupecolalight'] = {
			label = 'Bite Ecola Light Cup',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bv_bite_cup`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a cold Bite Ecola Light Cup'
			}
	},
	['bitecupsprunklight'] = {
			label = 'Bite Sprunk Light Cup',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bv_bite_cup`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a cold Bite Sprunk Light Cup'
			}	
	},
	['bitecupsprunklime'] = {
			label = 'Bite Sprunk Lime Cup',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bv_bite_cup`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a cold Bite Sprunk Lime Flavoured Cup'
			}		
	},
	['bitecupsprunk'] = {
			label = 'Bite Sprunk Cup',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
				prop = { model = `bv_bite_cup`, pos = vec3(0.025, 0.010, -0.01), rot = vec3(5.0, 5.0, -180.5) }, 
				usetime = 9500,
				notification = 'You enjoyed a cold Bite Sprunk Cup'
			}	
	},
	['biteclub'] = {
			label = 'Bite Club Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_biteclub`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a BIte Club Sandwich'
			}
	},
	['blackforestham'] = {
			label = 'Black Forest Ham Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_blackforestham`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Black Forest Ham Sandwich'
			}
	},

	['chickenbaconranch'] = {
			label = 'Chicken Bacon Ranch Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_chickenbaconranch`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Chicken Bacon Ranch Sandwich'
			}
	},

	['classictuna'] = {
			label = 'Classic Tuna Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_classictuna`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Classic Tuna Sandwich'
			}
	},

	['coldcutcombo'] = {
			label = 'Cold Cut Combo Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_coldcutcombo`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Cold Cut Combo Sandwich'
			}
	},

	['italian_bmt'] = {
			label = 'Italian B.M.T. Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_italian_bmt`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed an Italian B.M.T. Sandwich'
			}
	},

	['meatballmarinara'] = {
			label = 'Meatball Marinara Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_meatballmarinara`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Meatball Marinara Sandwich'
			}
	},

	['ovenroastedchicken'] = {
			label = 'Oven Roasted Chicken Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_ovenroastedchicken`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed an Oven Roasted Chicken Sandwich'
			}
	},

	['roastbeef'] = {
			label = 'Roast Beef Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_roastbeef`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Roast Beef Sandwich'
			}
	},

	['rotisseriechicken'] = {
			label = 'Rotisserie Chicken Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_rotisseriechicken`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Rotisserie Chicken Sandwich'
			}
	},

	['spicyitalian'] = {
			label = 'Spicy Italian Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_spicyitalian`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Spicy Italian Sandwich'
			}
	},

	['steakcheese'] = {
			label = 'Steak & Cheese Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_steakcheese`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Steak & Cheese Sandwich'
			}
	},

	['sweetonionteriyaki'] = {
			label = 'Sweet Onion Teriyaki Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_sweetonionteriyaki`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Sweet Onion Teriyaki Sandwich'
			}
	},

	['turkeybreast'] = {
			label = 'Turkey Breast Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_sweetonionteriyaki`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Turkey Breast Sandwich'
			}
	},

	['veggiedelite'] = {
			label = 'Veggie Delite Sandwich',
			weight = 350,
			client = {
				status = { hunger = 20000 },
				anim = 'eating',
				prop = { model = `bv_sw_veggiedelite`, pos = vec3(0.0, 0.01, 0.0), rot = vec3(0.0, -90.0, 0.0) },
				usetime = 9500,
				notification = 'You enjoyed a Veggie Sandwich'
			}
	},

	["alive_chicken"] = {
		label = "Living chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["blowpipe"] = {
		label = "Blowtorch",
		weight = 2,
		stack = true,
		close = true,
	},

	["cannabis"] = {
		label = "Cannabis",
		weight = 3,
		stack = true,
		close = true,
	},

	["carokit"] = {
		label = "Body Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["carotool"] = {
		label = "Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["clothe"] = {
		label = "Cloth",
		weight = 1,
		stack = true,
		close = true,
	},

	["copper"] = {
		label = "Copper",
		weight = 1,
		stack = true,
		close = true,
	},

	["cutted_wood"] = {
		label = "Cut wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["diamond"] = {
		label = "Diamond",
		weight = 1,
		stack = true,
		close = true,
	},

	["essence"] = {
		label = "Gas",
		weight = 1,
		stack = true,
		close = true,
	},

	["fabric"] = {
		label = "Fabric",
		weight = 1,
		stack = true,
		close = true,
	},

	["fish"] = {
		label = "Fish",
		weight = 1,
		stack = true,
		close = true,
	},

	["fixkit"] = {
		label = "Repair Kit",
		weight = 3,
		stack = true,
		close = true,
	},

	["fixtool"] = {
		label = "Repair Tools",
		weight = 2,
		stack = true,
		close = true,
	},

	["gazbottle"] = {
		label = "Gas Bottle",
		weight = 2,
		stack = true,
		close = true,
	},

	["gold"] = {
		label = "Gold",
		weight = 1,
		stack = true,
		close = true,
	},

	["iron"] = {
		label = "Iron",
		weight = 1,
		stack = true,
		close = true,
	},

	["marijuana"] = {
		label = "Marijuana",
		weight = 2,
		stack = true,
		close = true,
	},

	["packaged_chicken"] = {
		label = "Chicken fillet",
		weight = 1,
		stack = true,
		close = true,
	},

	["packaged_plank"] = {
		label = "Packaged wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol"] = {
		label = "Oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["petrol_raffin"] = {
		label = "Processed oil",
		weight = 1,
		stack = true,
		close = true,
	},

	["pl_drill"] = {
		label = "Drill",
		weight = 1,
		stack = true,
		close = true,
	},

	["pl_hackingdevice"] = {
		label = "Hacking Device",
		weight = 1,
		stack = true,
		close = true,
	},

	["pl_rope"] = {
		label = "Rope",
		weight = 1,
		stack = true,
		close = true,
	},

	["slaughtered_chicken"] = {
		label = "Slaughtered chicken",
		weight = 1,
		stack = true,
		close = true,
	},

	["stone"] = {
		label = "Stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["washed_stone"] = {
		label = "Washed stone",
		weight = 1,
		stack = true,
		close = true,
	},

	["wood"] = {
		label = "Wood",
		weight = 1,
		stack = true,
		close = true,
	},

	["wool"] = {
		label = "Wool",
		weight = 1,
		stack = true,
		close = true,
	},
    
    -- tk_evidence
    
["gsr_cloth"] = {
    label = "GSR-klud",
    weight = 100,
    stack = true,
    close = true,
},

["gsr_test_kit"] = {
    label = "GSR-testkit",
    weight = 100,
    stack = true,
    close = true,
},

["uv_light"] = {
    label = "UV-lommelygte",
    weight = 250,
    stack = true,
    close = true,
},

["evidence_camera"] = {
    label = "Beviskamera",
    weight = 500,
    stack = true,
    close = true,
},

["bullet_casing"] = {
    label = "Hylster",
    weight = 1,
    stack = false,
},

["bullet_fragment"] = {
    label = "Kuglefragment",
    weight = 1,
    stack = false,
},

["blood_sample"] = {
    label = "Blodprøve",
    weight = 1,
    stack = false,
},

["fingerprint"] = {
    label = "Fingeraftryk",
    weight = 1,
    stack = false,
},

["evidence"] = {
    label = "Bevis",
    weight = 1,
    stack = false,
},

["bullet_hole"] = {
    label = "Påvirkningsprøve",
    weight = 1,
    stack = false,
},

-- JG Mechanic
  ["engine_oil"] = {
    label = "Engine Oil",
    weight = 1000,
  },
  ["tyre_replacement"] = {
    label = "Tyre Replacement",
    weight = 1000,
  },
  ["clutch_replacement"] = {
    label = "Clutch Replacement",
    weight = 1000,
  },
  ["air_filter"] = {
    label = "Air Filter",
    weight = 100,
  },
  ["spark_plug"] = {
    label = "Spark Plug",
    weight = 1000,
  },
  ["brakepad_replacement"] = {
    label = "Brakepad Replacement",
    weight = 1000,
  },
  ["suspension_parts"] = {
    label = "Suspension Parts",
    weight = 1000,
  },
  -- Engine Items
  ["i4_engine"] = {
    label = "I4 Engine",
    weight = 1000,
  },
  ["v6_engine"] = {
    label = "V6 Engine",
    weight = 1000,
  },
  ["v8_engine"] = {
    label = "V8 Engine",
    weight = 1000,
  },
  ["v12_engine"] = {
    label = "V12 Engine",
    weight = 1000,
  },
  ["turbocharger"] = {
    label = "Turbocharger",
    weight = 1000,
  },
  -- Electric Engines
  ["ev_motor"] = {
    label = "EV Motor",
    weight = 1000,
  },
  ["ev_battery"] = {
    label = "EV Battery",
    weight = 1000,
  },
  ["ev_coolant"] = {
    label = "EV Coolant",
    weight = 1000,
  },
  -- Drivetrain Items
  ["awd_drivetrain"] = {
    label = "AWD Drivetrain",
    weight = 1000,
  },
  ["rwd_drivetrain"] = {
    label = "RWD Drivetrain",
    weight = 1000,
  },
  ["fwd_drivetrain"] = {
    label = "FWD Drivetrain",
    weight = 1000,
  },
  -- Tuning Items
  ["slick_tyres"] = {
    label = "Slick Tyres",
    weight = 1000,
  },
  ["semi_slick_tyres"] = {
    label = "Semi Slick Tyres",
    weight = 1000,
  },
  ["offroad_tyres"] = {
    label = "Offroad Tyres",
    weight = 1000,
  },
  ["drift_tuning_kit"] = {
    label = "Drift Tuning Kit",
    weight = 1000,
  },
  ["ceramic_brakes"] = {
    label = "Ceramic Brakes",
    weight = 1000,
  },
  -- Cosmetic Items
  ["lighting_controller"] = {
    label = "Lighting Controller",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-lighting-controller",
    }
  },
  ["stancing_kit"] = {
    label = "Stancer Kit",
    weight = 100,
    client = {
      event = "jg-mechanic:client:show-stancer-kit",
    }
  },
  ["cosmetic_part"] = {
    label = "Cosmetic Parts",
    weight = 100,
  },
  ["respray_kit"] = {
    label = "Respray Kit",
    weight = 1000,
  },
  ["vehicle_wheels"] = {
    label = "Vehicle Wheels Set",
    weight = 1000,
  },
  ["tyre_smoke_kit"] = {
    label = "Tyre Smoke Kit",
    weight = 1000,
  },
  ["bulletproof_tyres"] = {
    label = "Bulletproof Tyres",
    weight = 1000,
  },
  ["extras_kit"] = {
    label = "Extras Kit",
    weight = 1000,
  },
  -- Nitrous & Cleaning Items
  ["nitrous_bottle"] = {
    label = "Nitrous Bottle",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-nitrous-bottle",
    }
  },
  ["empty_nitrous_bottle"] = {
    label = "Empty Nitrous Bottle",
    weight = 1000,
  },
  ["nitrous_install_kit"] = {
    label = "Nitrous Install Kit",
    weight = 1000,
  },
  ["cleaning_kit"] = {
    label = "Cleaning Kit",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:clean-vehicle",
    }
  },
  ["repair_kit"] = {
    label = "Repair Kit",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:repair-vehicle",
    }
  },
  ["duct_tape"] = {
    label = "Duct Tape",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-duct-tape",
    }
  },
  -- Performance Item
  ["performance_part"] = {
    label = "Performance Parts",
    weight = 1000,
  },
  -- Mechanic Tablet Item
  ["mechanic_tablet"] = {
    label = "Mechanic Tablet",
    weight = 1000,
    client = {
      event = "jg-mechanic:client:use-tablet",
    }
  },
  -- Gearbox
  ["manual_gearbox"] = {
    label = "Manual Gearbox",
    weight = 1000,
  },
    
    -- Petty crimes
    ['bletter'] = {
    label = 'Brev',
    weight = 200,
    stack = false,
},
['bpackage'] = {
    label = 'Pakke',
    weight = 500,
    stack = false,
},
['batm_hacker'] = {
    label = 'ATM Hacker',
    weight = 1000,
    stack = false,
},
['bbag'] = {
    label = 'Sportstaske',
    weight = 1000,
    stack = false,
},
['bbrick'] = {
    label = 'Mursten',
    weight = 2500,
    stack = false,
},
    
    -- Fishing
        -- Fish Items

bitterling = {
    label = 'Bitterling',
    description = 'En lille ferskvandsfisk, som er almindelig i rolige vande.',
    stack = true,
},

pale_chub = {
    label = 'Bækørred (Pale Chub)',
    description = 'En mindre fisk, som findes i bække og floder.',
    stack = true,
},

dace = {
    label = 'Skalle',
    description = 'En flodfisk, som er mest aktiv om aftenen og tidlig morgen.',
    stack = true,
},

carp = {
    label = 'Karpe',
    description = 'En stor damfisk, som findes året rundt.',
    stack = true,
},

goldfish = {
    label = 'Guldfisk',
    description = 'En klassisk lille damfisk.',
    stack = true,
},

killifish = {
    label = 'Killifisk',
    description = 'En lille damfisk, som findes i forår og sommer.',
    stack = true,
},

crawfish = {
    label = 'Krebs',
    description = 'Et krebsdyr, som findes i damme om forår og sommer.',
    stack = true,
},

tadpole = {
    label = 'Haletudse',
    description = 'En ung padde, som findes i damme om foråret.',
    stack = true,
},

frog = {
    label = 'Frø',
    description = 'En padde, som findes i damme i sen forår og sommer.',
    stack = true,
},

freshwater_goby = {
    label = 'Ferskvandskutling',
    description = 'En lille flodfisk, mest aktiv om aftenen.',
    stack = true,
},

loach = {
    label = 'Smerling',
    description = 'En flodfisk, som findes om foråret.',
    stack = true,
},

bluegill = {
    label = 'Blågællet Solaborre',
    description = 'En lille flodfisk aktiv om dagen.',
    stack = true,
},

yellow_perch = {
    label = 'Gul Aborre',
    description = 'En flodfisk, som findes om vinteren og tidligt forår.',
    stack = true,
},

black_bass = {
    label = 'Sort Aborre',
    description = 'En stor og almindelig flodfisk, som findes året rundt.',
    stack = true,
},

tilapia = {
    label = 'Tilapia',
    description = 'En flodfisk, som findes i sommermånederne.',
    stack = true,
},

pond_smelt = {
    label = 'Smelt',
    description = 'En lille flodfisk, som findes om vinteren.',
    stack = true,
},

sweetfish = {
    label = 'Ayu',
    description = 'En flodfisk, som findes om sommeren.',
    stack = true,
},

anchovy = {
    label = 'Ansjos',
    description = 'En lille sølvfarvet havfisk, som ofte findes i stimer.',
    stack = true,
},

horse_mackerel = {
    label = 'Hestemakrel',
    description = 'En almindelig havfisk, som findes i store stimer.',
    stack = true,
},

sea_bass = {
    label = 'Havaborre',
    description = 'En almindelig stor havfisk, som findes året rundt.',
    stack = true,
},

dab = {
    label = 'Skrubbe',
    description = 'En fladfisk, som lever i havmiljøer.',
    stack = true,
},

olive_flounder = {
    label = 'Pighvar',
    description = 'En stor fladfisk, som lever i havmiljøer.',
    stack = true,
},

squid = {
    label = 'Blæksprutte',
    description = 'Et havdyr med en langstrakt krop.',
    stack = true,
},

koi = {
    label = 'Koi-karpe',
    description = 'En farverig og eftertragtet prydkarpe.',
    stack = true,
},

pop_eyed_goldfish = {
    label = 'Udbulende Guldfisk',
    description = 'En unik guldfisk med fremtrædende øjne.',
    stack = true,
},

ranchu_goldfish = {
    label = 'Ranchu Guldfisk',
    description = 'En rund guldfisk-variant uden rygfinne.',
    stack = true,
},

angelfish = {
    label = 'Skalar',
    description = 'En tropisk flodfisk med en karakteristisk form.',
    stack = true,
},

betta = {
    label = 'Betta',
    description = 'En farverig flodfisk kendt for sine livlige finner.',
    stack = true,
},

neon_tetra = {
    label = 'Neon Tetra',
    description = 'En lille, stærkt farvet flodfisk.',
    stack = true,
},

rainbowfish = {
    label = 'Regnbuefisk',
    description = 'En farverig flodfisk aktiv i sen forår og sommer.',
    stack = true,
},

sea_butterfly = {
    label = 'Søsommerfugl',
    description = 'Et delikat havdyr, som findes i vinterhavene.',
    stack = true,
},

seahorse = {
    label = 'Søhest',
    description = 'En unik havfisk med en karakteristisk form.',
    stack = true,
},

clownfish = {
    label = 'Klumpfisk',
    description = 'En lille, farverig tropisk havfisk.',
    stack = true,
},

surgeonfish = {
    label = 'Kirurgfisk',
    description = 'En farverig havfisk med karakteristiske markeringer.',
    stack = true,
},

butterfly_fish = {
    label = 'Sommerfuglefisk',
    description = 'En livlig tropisk havfisk med unikke mønstre.',
    stack = true,
},

zebra_turkeyfish = {
    label = 'Zebratyrkefisk',
    description = 'En unik havfisk med markante stribede mønstre.',
    stack = true,
},

barred_knifejaw = {
    label = 'Stribet knivkæbe',
    description = 'En karakteristisk havfisk med særlige markeringer.',
    stack = true,
},

red_snapper = {
    label = 'Rød Snapper',
    description = 'En værdsat havfisk med karakteristisk rød farve.',
    stack = true,
},

moray_eel = {
    label = 'Muræne',
    description = 'Et slangelignende havdyr, som lever i klippeområder.',
    stack = true,
},

ribbon_eel = {
    label = 'Båndmuræne',
    description = 'En farverig og unik muræne-art.',
    stack = true,
},

sturgeon = {
    label = 'Stør',
    description = 'En gammel fiskeart kendt for sin størrelse og kaviar.',
    stack = true,
},

giant_snakehead = {
    label = 'Kæmpe Slangehoved',
    description = 'En stor og karakteristisk søfisk.',
    stack = true,
},

golden_trout = {
    label = 'Guldørred',
    description = 'En sjælden og smuk ørred med gylden farve.',
    stack = true,
},

stringfish = {
    label = 'Snorfisk',
    description = 'En stor klippeflodsfisk, som findes om vinteren.',
    stack = true,
},

king_salmon = {
    label = 'Konge Laks',
    description = 'Den største og mest prestigefyldte lakseart.',
    stack = true,
},

napoleonfish = {
    label = 'Napoleonfisk',
    description = 'En stor, karakteristisk havfisk, som findes om sommeren.',
    stack = true,
},

dorado = {
    label = 'Dorado',
    description = 'En kraftfuld rovfisk fra floder i Sydamerika.',
    stack = true,
},

gar = {
    label = 'Gar',
    description = 'En forhistorisk udseende fisk, som findes i damme om sommeren.',
    stack = true,
},

arapaima = {
    label = 'Arapaima',
    description = 'En enorm flodfisk fra Amazonas-bassinet.',
    stack = true,
},

tuna = {
    label = 'Tun',
    description = 'En stor og stærk havfisk, som er værdsat af lystfiskere.',
    stack = true,
},

blue_marlin = {
    label = 'Blå Marlin',
    description = 'En enorm og kraftfuld oceanisk rovfisk.',
    stack = true,
},

giant_trevally = {
    label = 'Kæmpe Trevally',
    description = 'En stor og aggressiv sportsfisk fra havet.',
    stack = true,
},

mahi_mahi = {
    label = 'Mahi-Mahi',
    description = 'En farverig og hurtig tropisk havfisk.',
    stack = true,
},

ray = {
    label = 'Rokke',
    description = 'Et fladt havdyr, der glider gennem vandet.',
    stack = true,
},

saw_shark = {
    label = 'Savhaj',
    description = 'En unik hajart med en sav-lignende snude.',
    stack = true,
},

hammerhead_shark = {
    label = 'Hammerhaj',
    description = 'En haj med et hoved formet som en hammer.',
    stack = true,
},

whale_shark = {
    label = 'Hvalhaj',
    description = 'Verdens største fiskeart, men en fredelig kæmpe.',
    stack = true,
},

ocean_sunfish = {
    label = 'Klumpfisk',
    description = 'Et enormt og unikt havdyr med en karakteristisk finne.',
    stack = true,
},

oarfish = {
    label = 'Ålefisk',
    description = 'Et langt og mystisk dybhavsdyr, som sjældent ses.',
    stack = true,
},

great_white_shark = {
    label = 'Stor Hvid Haj',
    description = 'Havets top-rovdyr. En legendarisk fangst.',
    stack = true,
},

coelacanth = {
    label = 'Kvælerfisk (Coelacanth)',
    description = 'En forhistorisk fisk, som man troede var uddød, kan kun fanges i regnvejr.',
    stack = true,
},

barreleye = {
    label = 'Tøndehoved-fisk',
    description = 'En unik dybhavsfisk med et gennemsigtigt hoved.',
    stack = true,
},

-- Fiskegrej

fishing_rod = {
    label = 'Fiskestang',
    weight = 1000,
    stack = false,
    description = 'Et redskab til at fange fisk.',
    server = {
        export = 'peak_fishing.useFishingRod',
    },
    buttons = {
        {
            label = 'Åbn agn-opbevaring',
            action = function(slot)
                TriggerServerEvent('peak_fishing:server:openBaitStorage', slot)
            end
        },
        {
            label = 'Åbn tackel-opbevaring',
            action = function(slot)
                TriggerServerEvent('peak_fishing:server:openTackleStorage', slot)
            end
        },
    },
},

fishing_net = {
    label = 'Fiskernet',
    weight = 2000,
    description = 'Et solidt fiskernet, der bruges til at fange flere fisk ad gangen. Ideel til dybt vand eller store fangster.',
    stack = false,
    server = {
        export = 'peak_fishing.useFishingNet',
    }
},

-- Tackel-items

bobber = {
    label = 'Standard Flåd',
    weight = 50,
    description = 'Forbedrer bid-detektion og stabiliserer fiskelinen.',
    stack = true,
},

spinner = {
    label = 'Spinner Blink',
    weight = 75,
    description = 'Tiltrækker rovfisk med sine blinkende bevægelser.',
    stack = true,
},

sinker_set = {
    label = 'Professionelt Loddesæt',
    weight = 120,
    description = 'Højkvalitetslodder til præcis dybdekontrol og bedre stabilitet i strøm.',
    stack = true,
},

premium_tackle = {
    label = 'Premium Tackel Kit',
    weight = 200,
    description = 'Højkvalitets line og kroge for bedre kontrol og mindre risiko for at miste fisk.',
    stack = true,
},

-- Bait items

earthworm = {
    label = 'Regnorm',
    weight = 10,
    stack = true,
    description = 'En klassisk naturlig agn, perfekt til begyndere.',
},

bread = {
    label = 'Brødklump',
    weight = 10,
    stack = true,
    description = 'Enkel, men effektiv agn til fiskeri ved overfladen.',
},

corn = {
    label = 'Sødkorn',
    weight = 10,
    stack = true,
    description = 'Populær agn til ferskvandsfiskeri.',
},

maggots = {
    label = 'Maddiker',
    weight = 10,
    stack = true,
    description = 'Små, men meget effektive naturlige agn.',
},

minnow = {
    label = 'Levende Skalle',
    weight = 30,
    stack = true,
    description = 'Frisk levende agn, meget attraktiv for rovfisk.',
},

nightcrawler = {
    label = 'Natorm',
    weight = 20,
    stack = true,
    description = 'Store orme, fremragende til natfiskeri.',
},

bloodworm = {
    label = 'Blodorm',
    weight = 15,
    stack = true,
    description = 'Premium havagn, meget effektiv i saltvand.',
},

magnet = {
    label = 'Fiskemagnet',
    weight = 200,
    stack = true,
    description = 'En specialiseret magnet til skattejagt. Fanger næppe fisk, men er god til at finde metalfund.',
},

-- Treasure Items

old_boot = {
    label = 'Gammel Støvle',
    weight = 500,
    description = 'En slidt læderstøvle. Ikke værdifuld, men en klassiker indenfor fiskeri.',
    stack = true,
},

rusty_anchor = {
    label = 'Rustent Anker',
    weight = 5000,
    description = 'Et lille, rustent skibsanker. Kunne være interessant for samlere.',
    stack = true,
},

broken_bottle = {
    label = 'Antik Flaske',
    weight = 300,
    description = 'En gammel glasflaske med falmede mærker. Den kan være flere hundrede år gammel.',
    stack = true,
},

gold_coin = {
    label = 'Guld Dublon',
    weight = 20,
    description = 'En velbevaret guldmønt fra en svunden tid. Ret værdifuld!',
    stack = true,
},

silver_necklace = {
    label = 'Sølv Halskæde',
    weight = 50,
    description = 'En anløben sølvhalskæde med et detaljeret vedhæng.',
    stack = true,
},

treasure_chest = {
    label = 'Lille Skattekiste',
    weight = 2000,
    description = 'En lille trækiste med nogle værdigenstande. Sikke et fund!',
    stack = true,
},

ancient_statue = {
    label = 'Oldgammel Statue',
    weight = 1000,
    description = 'En lille stenfigur af ukendt oprindelse. Arkæologer kunne være interesserede.',
    stack = true,
},

pearl = {
    label = 'Kæmpe Perle',
    weight = 50,
    description = 'En usædvanligt stor og skinnende perle. Ekstremt sjælden.',
    stack = true,
},

diving_watch = {
    label = 'Vintage Dykkerur',
    weight = 150,
    description = 'Et vandtæt kvalitetsur, som på mystisk vis stadig virker.',
    stack = true,
},

shipwreck_plank = {
    label = 'Skibsvrags Fragment',
    weight = 2000,
    description = 'Et stykke træ med flotte udskæringer, sandsynligvis fra et gammelt skibsvrag.',
    stack = true,
},

	["kq_airdrop_flare"] = {
		label = "Airdrop flare",
		weight = 2,
		stack = true,
		close = true,
	},

-- Hunting
   ['hunting_scanner'] = {
        label = 'Dyre-Scanner',
        weight = 250,
        stack = false,
        close = false,
        description = 'Scanner dyreliv inden for 300m',
    },

    ['hunting_logbook'] = {
        label = 'Jæger-Logbog',
        weight = 100,
        stack = false,
        close = false,
        description = 'Din personlige jagtnotesbog med statistik og hold-funktion',
    },

    ['hunting_bait'] = {
        label = 'Lokkemad',
        weight = 350,
        stack = true,
        close = true,
        description = 'Placér på jorden for at tiltrække dyr (virker bedst med duftfjerner)',
    },

    ['hunting_spray'] = {
        label = 'Duft-Fjerner',
        weight = 180,
        stack = true,
        close = true,
        description = 'Maskerer din duft i 10 minutter — dyr opdager dig sværere',
    },

	['hunting_knife'] = {
        label = 'Jagtkniv',
        weight = 200,
        stack = false,
        close = false,
        description = 'En skarp jagtkniv, der bruges til at slagte og flå byttedyr',
    },

    ['deer_meat'] = {
        label = 'Hjortekød',
        weight = 500,
        stack = true,
        close = true,
        description = 'Frisk hjortekød — sælg til slagteren',
    },

    ['deer_hide'] = {
        label = 'Hjorteskind',
        weight = 800,
        stack = true,
        close = true,
        description = 'Et frisk hjorteskind',
    },

    ['deer_antlers'] = {
        label = 'Gevir',
        weight = 650,
        stack = true,
        close = false,
        description = 'Et imponerende gevir fra en stolt hjort',
    },

    ['boar_meat'] = {
        label = 'Vildsvinekød',
        weight = 500,
        stack = true,
        close = true,
        description = 'Frisk vildsvinekød',
    },

    ['boar_hide'] = {
        label = 'Vildsvineskind',
        weight = 750,
        stack = true,
        close = true,
        description = 'Et groft vildsvineskind',
    },
    
    -- NN_SPYSYSTEM
    
    ['nanospytablet'] = {
    label = 'NSK Tablet',
    weight = 3,
    stack = false,
    close = true,
    description = 'Advanced surveillance tablet for monitoring spy devices'
},

['nanospymic'] = {
    label = 'NSK Mini-mikrofon',
    weight = 1,
    stack = true,
    close = true,
    description = 'Hidden surveillance microphone for audio monitoring'
},

['nanospycam'] = {
    label = 'NSK Microkamera',
    weight = 1,
    stack = true,
    close = true,
    description = 'Hidden spy camera for visual surveillance'
},

['nanospygps'] = {
    label = 'NSK Køretøj GPS',
    weight = 1,
    stack = true,
    close = true,
    description = 'GPS tracking device for vehicle surveillance'
},

['digiscanner'] = {
    label = 'Digiscanner',
    weight = 1,
    stack = true,
    close = true,
    description = 'Professional device scanner that can detect nearby spy devices through electromagnetic signatures'
},

-- Force Kikkert
	['binoculars'] = {
		label = 'Kikkert', 
		weight = 1,
		stack = true,
		close = true,
	},

	['binoculars_modes'] = {
		label = 'Advanceret Kikkert',
		weight = 1,
		stack = true,
		close = true,
	},

-- WAIS Jobpack
	["gold_tooth"] = {
		label = "Guldtand",
		weight = 1,
		stack = true,
		close = false,
	},
	["dirty_photo"] = {
		label = "Beskidt Foto",
		weight = 1,
		stack = true,
		close = false,
	},
	["chain"] = {
		label = "Kæde",
		weight = 1,
		stack = true,
		close = false,
	},
	["medal"] = {
		label = "Medalje",
		weight = 1,
		stack = true,
		close = false,
	},
	["rusted_tin"] = {
		label = "Rustent Bliktin",
		weight = 1,
		stack = true,
		close = false,
	},
	["nail"] = {
		label = "Søm",
		weight = 1,
		stack = true,
		close = false,
	},
	["ring"] = {
		label = "Ring",
		weight = 1,
		stack = true,
		close = false,
	},
	["vehicle_tyre"] = {
		label = "Køretøjsdæk",
		weight = 1,
		stack = true,
		close = false,
	},
	["vehicle_door"] = {
		label = "Bildør",
		weight = 1,
		stack = true,
		close = false,
	},

	-- SB DIVING
	['diving_gear'] = {
		label = 'Dykkerudstyr',
		weight = 5000,
		stack = false,
		close = true,
		consume = 0,
		description = 'Komplet scuba-udstyr med iltflaske, maske og våddragt.',
		client = {
			export = 'sb_diving.useDivingGear'
		}
	},

	['diving_chest_common'] = {
		label = 'Slidt dykkerkiste',
		weight = 2500,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'sb_diving.useDivingChest'
		}
	},

	['diving_chest_uncommon'] = {
		label = 'Forseglet dykkerkiste',
		weight = 3000,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'sb_diving.useDivingChest'
		}
	},

	['diving_chest_rare'] = {
		label = 'Sjælden dykkerkiste',
		weight = 3500,
		stack = false,
		close = true,
		consume = 0,
		client = {
			export = 'sb_diving.useDivingChest'
		}
	},

	['old_coin'] = { label = 'Gammel mønt', weight = 50, stack = true, close = false },
	['coral_fragment'] = { label = 'Koralfund', weight = 150, stack = true, close = false },
	['antique_watch'] = { label = 'Antikt ur', weight = 120, stack = true, close = false },
	['pearl'] = { label = 'Perle', weight = 25, stack = true, close = false },
	['sealed_case'] = { label = 'Forseglet værdikasse', weight = 750, stack = true, close = false },

	-- SB METAL DETECTING
	['metal_detector'] = {
		label = 'Metaldetektor',
		weight = 3500,
		stack = false,
		close = true,
		description = 'Bruges til at finde nedgravede genstande i markerede søgeområder.',
		client = {
			export = 'sb_metaldetecting.useMetalDetector'
		}
	},

	['md_scrap_metal'] = {
		label = 'Metalskrot',
		weight = 250,
		stack = true,
		close = false
	},

	['md_old_coin'] = {
		label = 'Gammel mønt',
		weight = 50,
		stack = true,
		close = false
	},

	['md_silver_ring'] = {
		label = 'Sølvring',
		weight = 40,
		stack = true,
		close = false
	},

	['md_gold_chain'] = {
		label = 'Guldkæde',
		weight = 80,
		stack = true,
		close = false
	},

	['md_antique_watch'] = {
		label = 'Antikt ur',
		weight = 120,
		stack = true,
		close = false
	},

	['md_treasure_token'] = {
		label = 'Sjælden medaljon',
		weight = 75,
		stack = true,
		close = false
	},

	-- SB MINING
	['mining_pickaxe_basic'] = {
		label = 'Slidt hakke',
		weight = 1800,
		stack = false,
		close = true,
		client = {
			export = 'sb_mining.usePickaxe'
		}
	},

	['mining_pickaxe_iron'] = {
		label = 'Jernhakke',
		weight = 2100,
		stack = false,
		close = true,
		client = {
			export = 'sb_mining.usePickaxe'
		}
	},

	['mining_pickaxe_steel'] = {
		label = 'Stålhakke',
		weight = 2400,
		stack = false,
		close = true,
		client = {
			export = 'sb_mining.usePickaxe'
		}
	},

	['mining_pickaxe_industrial'] = {
		label = 'Industriforstærket hakke',
		weight = 2900,
		stack = false,
		close = true,
		client = {
			export = 'sb_mining.usePickaxe'
		}
	},
	['mining_coal'] = {
		label = 'Kul',
		weight = 250,
		stack = true,
		close = false
	},
	['mining_iron'] = {
		label = 'Jernmalm',
		weight = 300,
		stack = true,
		close = false
	},
	['mining_gold'] = {
		label = 'Guldmalm',
		weight = 300,
		stack = true,
		close = false
	},
	['mining_silver'] = {
		label = 'Sølvmalm',
		weight = 300,
		stack = true,
		close = false
	},
	['mining_diamond'] = {
		label = 'Rå diamant',
		weight = 150,
		stack = true,
		close = false
	},
	['mining_sapphire'] = {
		label = 'Safir',
		weight = 150,
		stack = true,
		close = false
	},
	['mining_ruby'] = {
		label = 'Rubin',
		weight = 150,
		stack = true,
		close = false
	},
	['mining_emerald'] = {
		label = 'Smaragd',
		weight = 150,
		stack = true,
		close = false
	},
}