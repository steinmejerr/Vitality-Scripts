Config = {}

Config.AdminGroups = {
    'admin',
    'superadmin'
}

-- Alle jobcenter-jobs gemmes i databasen og administreres med /jobcenteradmin.
-- Config.Jobs bruges kun én gang til automatisk import af eksisterende jobs,
-- hvis databasetabellen er tom.


-- Kortkalibrering til html/gta_map.png.
-- Jobmarkører beregnes automatisk fra job.location, så du ikke længere skal gætte map.x/map.y.
-- Procenterne beskriver, hvor selve GTA-verdenen ligger på billedet.
Config.MapCalibration = {
    world = {
        minX = -4000.0,
        maxX = 4500.0,
        minY = -4000.0,
        maxY = 8000.0
    },
    image = {
        left = 17.85,
        right = 82.15,
        top = 5.75,
        bottom = 94.25
    }
}

Config.MapCommands = {
    coordinates = 'jobmapcoords', -- Stå på lokationen og brug /jobmapcoords
    preview = 'jobmappreview',    -- /jobmappreview [job-id]
    calibrate = 'jobmapcalibrate' -- /jobmapcalibrate [job-id]
}

Config.JobCenter = {
    ped = {
        model = `a_f_y_business_02`,
        coords = vector4(-265.12, -963.62, 31.22, 205.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    targetDistance = 2.0,
    blip = {
        enabled = true,
        sprite = 407,
        colour = 2,
        scale = 0.8,
        label = 'Jobcenter'
    }
}

Config.DefaultJob = {
    name = 'unemployed',
    grade = 0
}

Config.Jobs = {
    {
        id = 'taxi',
        job = 'taxi',
        grade = 0,
        label = 'Taxachauffør',
        category = 'Transport',
        description = 'Kør borgere sikkert rundt i byen og tjen penge på ture.',
        icon = 'fa-solid fa-taxi',
        color = '#f4c542',
        salary = 'Varierer efter ture',
        location = vector3(-322.23, -1546.10, 31.02),
        requirements = {
            'Gyldigt kørekort',
            'God kundeservice'
        }
    },
    {
        id = 'trucker',
        job = 'trucker',
        grade = 0,
        label = 'Lastbilchauffør',
        category = 'Transport',
        description = 'Lever varer mellem virksomheder og lagre i hele staten.',
        icon = 'fa-solid fa-truck',
        color = '#f29f4b',
        salary = 'Betaling pr. levering',
        location = vector3(1208.14, -3115.30, 5.54),
        requirements = {
            'Stabil kørsel',
            'Kan arbejde selvstændigt'
        }
    },
    {
        id = 'garbage',
        job = 'garbage',
        grade = 0,
        label = 'Skraldemand',
        category = 'Service',
        description = 'Hold byen ren ved at samle affald på faste ruter.',
        icon = 'fa-solid fa-trash-can',
        color = '#59d67c',
        salary = 'Fast betaling pr. rute',
        location = vector3(-321.72, -1545.78, 31.02),
        requirements = {
            'Ingen erfaring nødvendig',
            'Kan arbejde i hold'
        }
    },
    {
        id = 'bus',
        job = 'bus',
        grade = 0,
        label = 'Buschauffør',
        category = 'Transport',
        description = 'Kør faste ruter og sørg for offentlig transport i byen.',
        icon = 'fa-solid fa-bus',
        color = '#55a8ff',
        salary = 'Betaling pr. gennemført rute',
        location = vector3(454.63, -600.70, 28.58),
        requirements = {
            'Gyldigt kørekort',
            'Ansvarlig kørsel'
        }
    },
    {
        id = 'miner',
        job = 'miner',
        grade = 0,
        label = 'Minearbejder',
        category = 'Industri',
        description = 'Udvind råmaterialer og lever dem til videre forarbejdning.',
        icon = 'fa-solid fa-helmet-safety',
        color = '#caa777',
        salary = 'Betaling efter udvinding',
        location = vector3(2954.38, 2787.97, 41.49),
        requirements = {
            'Fysisk arbejde',
            'Sikkerhedsbevidst'
        }
    },
    {
        id = 'fisherman',
        job = 'fisherman',
        grade = 0,
        label = 'Fisker',
        category = 'Natur',
        description = 'Fang fisk langs kysten og sælg din fangst.',
        icon = 'fa-solid fa-fish',
        color = '#4ecde6',
        salary = 'Afhænger af fangsten',
        location = vector3(-1598.77, 5197.82, 4.38),
        requirements = {
            'Ingen erfaring nødvendig',
            'Tålmodighed'
        }
    }
}
