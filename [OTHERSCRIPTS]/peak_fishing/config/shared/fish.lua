return {
    rarity = {
        baseChances = {
            common = 0.40,
            uncommon = 0.30,
            rare = 0.15,
            epic = 0.10,
            legendary = 0.05,
            treasure = 0.05
        },
        
        noBait = {
            catchRate = 0.4,

            rarityModifier = {
                common = 1.0,
                uncommon = 0.5,
                rare = 0.25,
                epic = 0.1,
                legendary = 0.05,
                treasure = 0.25
            }
        },
        
        noTackle = {
            minigameModifiers = {
                rodSpeed = 1.0,

                fishSpeed = 1.0,
                dashSpeed = 1.0,
                dashFrequency = 1.0,
                
                catchZone = 1.0,
                catchTime = 1.0,
                progressDecay = 1.0,
                totalTime = 1.0,
            }
        }
    },

    list = {
        common = {
            bitterling = {
                label = 'Bitterling',
                description = 'A small freshwater fish common in calm waters.',
                weight = { min = 0.1, max = 0.3 },
                price = { min = 100, max = 200 },
                habitat = 'freshwater'
            },

            pale_chub = {
                label = 'Pale Chub',
                description = 'A modest-sized fish found in streams and rivers.',
                weight = { min = 0.2, max = 0.5 },
                price = { min = 150, max = 250 },
                habitat = 'freshwater'
            },

            dace = {
                label = 'Dace',
                description = 'A river fish most active during evening and early morning.',
                weight = { min = 0.2, max = 0.5 },
                price = { min = 100, max = 150 },
                habitat = 'river'
            },
            
            carp = {
                label = 'Carp',
                description = 'A large pond-dwelling fish found year-round.',
                weight = { min = 1.0, max = 2.0 },
                price = { min = 120, max = 180 },
                habitat = 'pond'
            },

            goldfish = {
                label = 'Goldfish',
                description = 'A classic small pond fish.',
                weight = { min = 0.1, max = 0.3 },
                price = { min = 400, max = 500 },
                habitat = 'pond'
            },

            killifish = {
                label = 'Killifish',
                description = 'A small pond fish found during spring and summer.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 180, max = 220 },
                habitat = 'pond'
            },

            crawfish = {
                label = 'Crawfish',
                description = 'A crustacean found in ponds during spring and summer.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 300, max = 400 },
                habitat = 'pond'
            },

            tadpole = {
                label = 'Tadpole',
                description = 'A young amphibian found in ponds during spring.',
                weight = { min = 0.05, max = 0.1 },
                price = { min = 250, max = 350 },
                habitat = 'pond'
            },
            
            frog = {
                label = 'Frog',
                description = 'An amphibian found in ponds during late spring and summer.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 1300, max = 1500 },
                habitat = 'pond'
            },

            freshwater_goby = {
                label = 'Freshwater Goby',
                description = 'A small river fish most active during evening hours.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 1000, max = 1200 },
                habitat = 'river'
            },

            loach = {
                label = 'Loach',
                description = 'A river fish found during spring.',
                weight = { min = 0.3, max = 0.5 },
                price = { min = 500, max = 600 },
                habitat = 'river'
            },

            bluegill = {
                label = 'Bluegill',
                description = 'A small river fish active during daytime.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 600, max = 800 },
                habitat = 'river'
            },

            yellow_perch = {
                label = 'Yellow Perch',
                description = 'A river fish found during winter and early spring.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'river'
            },

            black_bass = {
                label = 'Black Bass',
                description = 'A large and common river fish found year-round.',
                weight = { min = 1.0, max = 2.0 },
                price = { min = 4000, max = 4500 },
                habitat = 'river'
            },

            tilapia = {
                label = 'Tilapia',
                description = 'A river fish found during summer months.',
                weight = { min = 0.5, max = 1.5 },
                price = { min = 900, max = 1000 },
                habitat = 'river'
            },

            pond_smelt = {
                label = 'Pond Smelt',
                description = 'A small river fish found in winter months.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 400, max = 500 },
                habitat = 'river'
            },

            sweetfish = {
                label = 'Sweetfish',
                description = 'A river fish found during summer months.',
                weight = { min = 0.3, max = 0.6 },
                price = { min = 250, max = 350 },
                habitat = 'river'
            },

            anchovy = {
                label = 'Anchovy',
                description = 'A small, silvery marine fish often found in schools.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 200, max = 250 },
                habitat = 'sea'
            },
            
            horse_mackerel = {
                label = 'Horse Mackerel',
                description = 'A common marine fish found in large schools.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 150, max = 200 },
                habitat = 'sea'
            },

            sea_bass = {
                label = 'Sea Bass',
                description = 'A common large marine fish found year-round.',
                weight = { min = 2.0, max = 4.0 },
                price = { min = 400, max = 500 },
                habitat = 'sea'
            },

            dab = {
                label = 'Dab',
                description = 'A flatfish found in marine environments.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 300, max = 400 },
                habitat = 'sea'
            },

            olive_flounder = {
                label = 'Olive Flounder',
                description = 'A large flatfish found in marine environments.',
                weight = { min = 1.0, max = 3.0 },
                price = { min = 800, max = 900 },
                habitat = 'sea'
            },

            squid = {
                label = 'Squid',
                description = 'A marine cephalopod with a distinctive elongated body.',
                weight = { min = 0.3, max = 0.6 },
                price = { min = 500, max = 600 },
                habitat = 'sea'
            }
        },

        uncommon = {
            koi = {
                label = 'Koi',
                description = 'A colorful and sought-after ornamental carp.',
                weight = { min = 2.0, max = 5.0 },
                price = { min = 500, max = 1000 },
                habitat = 'freshwater'
            },

            pop_eyed_goldfish = {
                label = 'Pop-eyed Goldfish',
                description = 'A unique goldfish variant with prominent eyes.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 800, max = 900 },
                habitat = 'pond'
            },

            ranchu_goldfish = {
                label = 'Ranchu Goldfish',
                description = 'A round-bodied goldfish breed.',
                weight = { min = 0.3, max = 0.5 },
                price = { min = 5500, max = 6000 },
                habitat = 'pond'
            },

            angelfish = {
                label = 'Angelfish',
                description = 'A tropical river fish with distinctive shape.',
                weight = { min = 0.3, max = 0.6 },
                price = { min = 3000, max = 3500 },
                habitat = 'river'
            },

            betta = {
                label = 'Betta',
                description = 'A colorful river fish known for its vibrant fins.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 2500, max = 3000 },
                habitat = 'river'
            },

            neon_tetra = {
                label = 'Neon Tetra',
                description = 'A small, brightly colored river fish.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 500, max = 600 },
                habitat = 'river'
            },

            rainbowfish = {
                label = 'Rainbowfish',
                description = 'A colorful river fish active during late spring and summer.',
                weight = { min = 0.2, max = 0.3 },
                price = { min = 800, max = 900 },
                habitat = 'river'
            },
            
            sea_butterfly = {
                label = 'Sea Butterfly',
                description = 'A delicate marine creature found in winter seas.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 1000, max = 1200 },
                habitat = 'sea'
            },

            seahorse = {
                label = 'Seahorse',
                description = 'A unique marine fish with a distinctive shape.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 1100, max = 1300 },
                habitat = 'sea'
            },

            clownfish = {
                label = 'Clownfish',
                description = 'A small, brightly colored tropical marine fish.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 650, max = 800 },
                habitat = 'sea'
            },

            surgeonfish = {
                label = 'Surgeonfish',
                description = 'A colorful marine fish with distinctive markings.',
                weight = { min = 0.3, max = 0.5 },
                price = { min = 1000, max = 1200 },
                habitat = 'sea'
            },

            butterfly_fish = {
                label = 'Butterfly Fish',
                description = 'A vibrant tropical marine fish with unique patterns.',
                weight = { min = 0.2, max = 0.4 },
                price = { min = 1000, max = 1200 },
                habitat = 'sea'
            },

            zebra_turkeyfish = {
                label = 'Zebra Turkeyfish',
                description = 'A unique marine fish with striking striped patterns.',
                weight = { min = 0.3, max = 0.5 },
                price = { min = 500, max = 600 },
                habitat = 'sea'
            },

            barred_knifejaw = {
                label = 'Barred Knifejaw',
                description = 'A distinctive marine fish with unique markings.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 5000, max = 5500 },
                habitat = 'sea'
            },

            red_snapper = {
                label = 'Red Snapper',
                description = 'A prized marine fish with distinctive red coloration.',
                weight = { min = 1.0, max = 3.0 },
                price = { min = 3000, max = 3500 },
                habitat = 'sea'
            },
            
            moray_eel = {
                label = 'Moray Eel',
                description = 'A serpentine marine creature found in rocky areas.',
                weight = { min = 1.0, max = 3.0 },
                price = { min = 2000, max = 2300 },
                habitat = 'sea'
            },

            ribbon_eel = {
                label = 'Ribbon Eel',
                description = 'A colorful and unique marine eel species.',
                weight = { min = 0.5, max = 1.5 },
                price = { min = 600, max = 800 },
                habitat = 'sea'
            }
        },

        rare = {
            sturgeon = {
                label = 'Sturgeon',
                description = 'An ancient species known for its size and caviar.',
                weight = { min = 10.0, max = 30.0 },
                price = { min = 2000, max = 4000 },
                habitat = 'freshwater'
            },
            
            giant_snakehead = {
                label = 'Giant Snakehead',
                description = 'A large and distinctive pond fish.',
                weight = { min = 3.0, max = 5.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'pond'
            },

            golden_trout = {
                label = 'Golden Trout',
                description = 'A rare and beautiful trout with golden coloring.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 15000, max = 16000 },
                habitat = 'river'
            },

            stringfish = {
                label = 'Stringfish',
                description = 'A large clifftop river fish found in winter.',
                weight = { min = 3.0, max = 5.0 },
                price = { min = 15000, max = 16000 },
                habitat = 'river'
            },

            king_salmon = {
                label = 'King Salmon',
                description = 'The largest and most prestigious salmon species.',
                weight = { min = 4.0, max = 6.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'river'
            },

            napoleonfish = {
                label = 'Napoleonfish',
                description = 'A large, distinctive marine fish found during summer.',
                weight = { min = 4.0, max = 6.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'sea'
            },

            dorado = {
                label = 'Dorado',
                description = 'A powerful predatory river fish from South America.',
                weight = { min = 3.0, max = 5.0 },
                price = { min = 15000, max = 16000 },
                habitat = 'river'
            },

            gar = {
                label = 'Gar',
                description = 'A prehistoric-looking fish found in ponds during summer.',
                weight = { min = 3.0, max = 5.0 },
                price = { min = 6000, max = 7000 },
                habitat = 'pond'
            },

            arapaima = {
                label = 'Arapaima',
                description = 'A massive river fish from the Amazon basin.',
                weight = { min = 4.0, max = 6.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'river'
            },
            
            tuna = {
                label = 'Tuna',
                description = 'A large, powerful marine fish prized by anglers.',
                weight = { min = 20.0, max = 50.0 },
                price = { min = 7000, max = 7500 },
                habitat = 'sea'
            },

            blue_marlin = {
                label = 'Blue Marlin',
                description = 'A massive and powerful oceanic predator.',
                weight = { min = 50.0, max = 80.0 },
                price = { min = 10000, max = 11000 },
                habitat = 'sea'
            },

            giant_trevally = {
                label = 'Giant Trevally',
                description = 'A large and aggressive marine game fish.',
                weight = { min = 10.0, max = 30.0 },
                price = { min = 4500, max = 5000 },
                habitat = 'sea'
            },

            mahi_mahi = {
                label = 'Mahi-Mahi',
                description = 'A colorful and fast-swimming tropical marine fish.',
                weight = { min = 5.0, max = 15.0 },
                price = { min = 6000, max = 6500 },
                habitat = 'sea'
            },

            ray = {
                label = 'Ray',
                description = 'A flat marine creature gliding through the waters.',
                weight = { min = 50.0, max = 80.0 },
                price = { min = 3000, max = 3500 },
                habitat = 'sea'
            }
        },

        epic = {
            saw_shark = {
                label = 'Saw Shark',
                description = 'A unique shark species with a distinctive saw-like snout.',
                weight = { min = 60.0, max = 80.0 },
                price = { min = 12000, max = 13000 },
                habitat = 'sea'
            },

            hammerhead_shark = {
                label = 'Hammerhead Shark',
                description = 'A shark with a uniquely shaped head resembling a hammer.',
                weight = { min = 60.0, max = 80.0 },
                price = { min = 8000, max = 8500 },
                habitat = 'sea'
            },

            whale_shark = {
                label = 'Whale Shark',
                description = 'The largest fish species in the world, despite being a gentle giant.',
                weight = { min = 70.0, max = 85.0 },
                price = { min = 13000, max = 14000 },
                habitat = 'sea'
            },

            ocean_sunfish = {
                label = 'Ocean Sunfish',
                description = 'A massive and unique marine creature with a distinctive fin.',
                weight = { min = 70.0, max = 85.0 },
                price = { min = 4000, max = 4500 },
                habitat = 'sea'
            },

            oarfish = {
                label = 'Oarfish',
                description = 'A long, mysterious deep-sea creature rarely seen.',
                weight = { min = 50.0, max = 80.0 },
                price = { min = 9000, max = 9500 },
                habitat = 'sea'
            }
        },

        legendary = {
            great_white_shark = {
                label = 'Great White Shark',
                description = 'The ocean\'s apex predator. A legendary catch.',
                weight = { min = 70.0, max = 85.0 },
                price = { min = 8000, max = 12000 },
                habitat = 'deep_sea'
            },

            coelacanth = {
                label = 'Coelacanth',
                description = 'A prehistoric fish thought to be extinct, only catchable during rain.',
                weight = { min = 50.0, max = 80.0 },
                price = { min = 15000, max = 16000 },
                habitat = 'sea'
            },

            barreleye = {
                label = 'Barreleye',
                description = 'A unique deep-sea fish with a transparent head.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 15000, max = 16000 },
                habitat = 'sea'
            }
        },
        
        treasure = {
            old_boot = {
                label = 'Old Boot',
                description = 'A worn-out leather boot. Not valuable, but a fishing classic.',
                weight = { min = 0.5, max = 1.0 },
                price = { min = 10, max = 30 },
                habitat = 'all'
            },
            
            rusty_anchor = {
                label = 'Rusty Anchor',
                description = 'A small, corroded ship anchor. Might be of interest to collectors.',
                weight = { min = 5.0, max = 10.0 },
                price = { min = 300, max = 600 },
                habitat = 'sea'
            },
            
            broken_bottle = {
                label = 'Antique Bottle',
                description = 'An old glass bottle with faded markings. Could be centuries old.',
                weight = { min = 0.3, max = 0.6 },
                price = { min = 150, max = 450 },
                habitat = 'all'
            },
            
            gold_coin = {
                label = 'Gold Doubloon',
                description = 'A well-preserved gold coin from a bygone era. Quite valuable!',
                weight = { min = 0.01, max = 0.03 },
                price = { min = 2000, max = 5000 },
                habitat = 'deep_sea'
            },
            
            silver_necklace = {
                label = 'Silver Necklace',
                description = 'A tarnished silver necklace with an intricate pendant.',
                weight = { min = 0.05, max = 0.1 },
                price = { min = 800, max = 1500 },
                habitat = 'river'
            },
            
            treasure_chest = {
                label = 'Small Treasure Chest',
                description = 'A miniature wooden chest containing a few valuables. What a find!',
                weight = { min = 2.0, max = 4.0 },
                price = { min = 3000, max = 8000 },
                habitat = 'deep_sea'
            },
            
            ancient_statue = {
                label = 'Ancient Statue',
                description = 'A small stone figurine of unknown origin. Archaeologists might be interested.',
                weight = { min = 0.5, max = 1.5 },
                price = { min = 1200, max = 2400 },
                habitat = 'pond'
            },
            
            pearl = {
                label = 'Giant Pearl',
                description = 'An unusually large and lustrous pearl. Extremely rare.',
                weight = { min = 0.02, max = 0.08 },
                price = { min = 5000, max = 10000 },
                habitat = 'sea'
            },
            
            diving_watch = {
                label = 'Vintage Diving Watch',
                description = 'A high-quality waterproof watch, somehow still in working condition.',
                weight = { min = 0.1, max = 0.2 },
                price = { min = 1000, max = 2500 },
                habitat = 'sea'
            },
            
            shipwreck_plank = {
                label = 'Shipwreck Fragment',
                description = 'A piece of wood with ornate carvings, likely from an old shipwreck.',
                weight = { min = 1.0, max = 3.0 },
                price = { min = 400, max = 800 },
                habitat = 'deep_sea'
            }
        }
    }
}