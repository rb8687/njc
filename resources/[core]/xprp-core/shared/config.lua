-- =============================================================================
-- xprp-core | Shared Configuration
-- =============================================================================

Config = {}

-- Server locale (used by client UI)
Config.Locale = GetConvar('locale', 'en')

-- Debug logging (set 'xprp_debug' true in server.cfg to enable)
Config.Debug = GetConvar('xprp_debug', 'false') == 'true'

-- Starting money granted to brand-new characters
Config.StartingMoney = {
    cash   = 500,
    bank   = 2500,
}

-- Spawn position for new characters (Legion Square, Los Santos)
Config.DefaultSpawn = {
    x     = 195.17,
    y     = -933.77,
    z     = 30.69,
    heading = 160.0,
}

-- Maximum number of characters per player account
Config.MaxCharacters = 3

-- Jobs available on the server (populated further in xprp-jobs)
Config.Jobs = {
    { name = 'unemployed', label = 'Unemployed', defaultGrade = 0 },
    { name = 'police',     label = 'Police',     defaultGrade = 0 },
    { name = 'mechanic',   label = 'Mechanic',   defaultGrade = 0 },
}
