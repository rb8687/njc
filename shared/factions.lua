-- =============================================================================
-- NPC Criminal Factions — Shared faction & drug definitions
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Drug catalogue
-- Each entry defines the drug name, the unit used for display, the maximum
-- wholesale quantity that a cartel/mafia supplier can carry, and a base price
-- per unit (server can override this).
-- ---------------------------------------------------------------------------
Config = Config or {}

Config.Drugs = {
    cocaine = {
        label       = 'Cocaine',
        unit        = 'kg',
        maxSupply   = 500,   -- kilograms per supplier per spawn cycle
        pricePerUnit = 18000, -- $ per kg (wholesale)
    },
    heroin = {
        label       = 'Heroin',
        unit        = 'kg',
        maxSupply   = 500,   -- kilograms per supplier per spawn cycle
        pricePerUnit = 22000,
    },
    meth = {
        label       = 'Methamphetamine',
        unit        = 'g',
        -- 500 grams as specified in the requirements
        maxSupply   = 500,
        pricePerUnit = 80,
    },
    lean = {
        label       = 'Lean (Cough Syrup)',
        unit        = 'g',
        -- 500 grams as specified in the requirements
        maxSupply   = 500,
        pricePerUnit = 15,
    },
}

-- ---------------------------------------------------------------------------
-- Faction definitions
--   type:      'cartel' | 'mafia' | 'gang' | 'mcgang'
--   canSupply: whether this faction acts as a wholesale drug supplier
--   drugs:     list of drug keys this faction carries (only relevant when
--              canSupply == true)
--   spawnLocations: one or more world-space coords used by the client to
--                   place NPC groups and set map blips.
--   model:     ped model(s) used for members of this faction
--   blipSprite / blipColor: map-blip appearance
-- ---------------------------------------------------------------------------
Config.Factions = {
    -- ── Cartels ────────────────────────────────────────────────────────────
    {
        id          = 'cartel_norte',
        name        = 'Cartel del Norte',
        type        = 'cartel',
        canSupply   = true,
        drugs       = { 'cocaine', 'heroin', 'meth', 'lean' },
        blipSprite  = 84,
        blipColor   = 1,   -- red
        spawnLocations = {
            { x = -1095.47, y = -1593.53, z = 4.61, h = 180.0 },
        },
        models = { 'g_m_m_chicold_01', 'g_m_m_chicold_02' },
        memberCount = 6,
    },
    {
        id          = 'cartel_sur',
        name        = 'Cartel del Sur',
        type        = 'cartel',
        canSupply   = true,
        drugs       = { 'cocaine', 'heroin', 'lean' },
        blipSprite  = 84,
        blipColor   = 1,
        spawnLocations = {
            { x = 1386.17, y = -2283.69, z = 5.00, h = 270.0 },
        },
        models = { 'g_m_m_chicold_01', 'g_m_m_chicold_02' },
        memberCount = 6,
    },

    -- ── Mafias ─────────────────────────────────────────────────────────────
    {
        id          = 'mafia_east',
        name        = 'East Side Mafia',
        type        = 'mafia',
        canSupply   = true,
        drugs       = { 'cocaine', 'heroin' },
        blipSprite  = 84,
        blipColor   = 4,   -- blue
        spawnLocations = {
            { x = 1200.37, y = -1396.67, z = 35.22, h = 90.0 },
        },
        models = { 'g_m_m_armboss_01', 'g_m_m_armlieut_01' },
        memberCount = 5,
    },
    {
        id          = 'mafia_west',
        name        = 'Westside Outfit',
        type        = 'mafia',
        canSupply   = true,
        drugs       = { 'cocaine', 'meth' },
        blipSprite  = 84,
        blipColor   = 4,
        spawnLocations = {
            { x = -1473.12, y = -390.94, z = 40.16, h = 0.0 },
        },
        models = { 'g_m_m_armboss_01', 'g_m_m_armlieut_01' },
        memberCount = 5,
    },

    -- ── Street Gangs ───────────────────────────────────────────────────────
    {
        id          = 'gang_northside',
        name        = 'Northside Bloods',
        type        = 'gang',
        canSupply   = false,
        drugs       = {},
        blipSprite  = 84,
        blipColor   = 0,   -- white
        spawnLocations = {
            { x = 129.85, y = -1947.45, z = 20.77, h = 45.0 },
        },
        models = { 'g_m_y_lost_01', 'g_m_y_lost_02' },
        memberCount = 8,
    },
    {
        id          = 'gang_southside',
        name        = 'Southside Crips',
        type        = 'gang',
        canSupply   = false,
        drugs       = {},
        blipSprite  = 84,
        blipColor   = 0,
        spawnLocations = {
            { x = 312.99, y = -2086.28, z = 20.17, h = 225.0 },
        },
        models = { 'g_m_y_lost_01', 'g_m_y_lost_02' },
        memberCount = 8,
    },

    -- ── Motorcycle Gangs ───────────────────────────────────────────────────
    {
        id          = 'mcgang_iron',
        name        = 'Iron Riders MC',
        type        = 'mcgang',
        canSupply   = false,
        drugs       = {},
        blipSprite  = 478,  -- motorcycle blip
        blipColor   = 5,    -- yellow
        spawnLocations = {
            { x = -1200.34, y = -1574.75, z = 4.95, h = 90.0 },
        },
        models = { 'g_m_y_lost_01', 'g_m_y_lost_02', 'g_m_y_lost_03' },
        memberCount = 6,
    },
    {
        id          = 'mcgang_devils',
        name        = "Devil's Disciples MC",
        type        = 'mcgang',
        canSupply   = false,
        drugs       = {},
        blipSprite  = 478,
        blipColor   = 5,
        spawnLocations = {
            { x = 1893.22, y = 3743.68, z = 33.76, h = 180.0 },
        },
        models = { 'g_m_y_lost_01', 'g_m_y_lost_02', 'g_m_y_lost_03' },
        memberCount = 6,
    },
}

-- ---------------------------------------------------------------------------
-- Timing configuration
-- ---------------------------------------------------------------------------
Config.SpawnCycleMinutes  = 45   -- factions spawn/despawn every 45 minutes
Config.SpawnCycleTicks    = Config.SpawnCycleMinutes * 60 * 1000  -- ms

-- Maximum quantity a buyer can purchase per transaction
Config.MaxBuyPerTransaction = 50  -- kg or g depending on drug

-- Minimum cash a server-side player must carry to purchase
Config.MinCashRequired = 1000
