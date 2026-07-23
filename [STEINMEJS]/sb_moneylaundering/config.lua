Config = {}

Config.Debug = false

Config.FeePercent = 25

Config.MinimumAmount = 500
Config.MaximumAmount = 250000

Config.TransactionCooldownSeconds = 3
Config.SessionDurationSeconds = 60
Config.SessionMaxMoveDistance = 5.0 -- Hvor langt spilleren må gå under handlen

Config.TargetDistance = 2.0

-- Alle almindelige NPC'er, der går rundt på mappet, kan bruges.
-- Sæt onlyWalkingPeds til true, hvis NPC'en skal være til fods og ikke sidde i et køretøj.
Config.AmbientNPCs = {
    onlyWalkingPeds = true,
    requireHuman = true,
    requireAlive = true,

    -- Job-/service-NPC'er som ikke skal kunne bruges.
    blockedModels = {
        `s_m_y_cop_01`,
        `s_f_y_cop_01`,
        `s_m_y_sheriff_01`,
        `s_f_y_sheriff_01`,
        `s_m_y_hwaycop_01`,
        `s_m_m_paramedic_01`,
        `s_m_m_doctor_01`,
        `s_m_y_fireman_01`
    }
}


Config.TradeAnimation = {
    dict = 'mp_common',
    clip = 'givetake1_a',
    turnDuration = 700,
    duration = 1450,
    pauseBetween = 180,
    cashProp = `prop_anim_cash_pile_01`,
    progressLabel = 'Gennemfører handel...',

    -- NPC'en bliver frigivet og går videre normalt efter handlen.
    pedResume = {
        delay = 650,
        wanderSpeed = 10.0,
        pauseChance = 10
    }
}
