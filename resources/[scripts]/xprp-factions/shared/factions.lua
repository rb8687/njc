-- =============================================================================
-- xprp-factions | Shared – Faction Definitions
-- =============================================================================

-- Faction type constants
FactionType = {
    STATE = 'state',
    GANG  = 'gang',
}

-- Salary payout interval in minutes (shared with xprp-jobs interval)
FactionSalaryIntervalMinutes = 30

-- State factions require the 'xprp.faction.state' ACE permission to join.
-- Gang factions are open and any player may join or leave freely.
Factions = {

    -- ── State Factions ────────────────────────────────────────────────────────

    sheriff = {
        label  = 'Sheriff',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Deputy',             salary = 300 },
            [1] = { label = 'Senior Deputy',       salary = 400 },
            [2] = { label = 'Sergeant',            salary = 500 },
            [3] = { label = 'Lieutenant',          salary = 650 },
            [4] = { label = 'Sheriff',             salary = 900 },
        },
    },

    dfa = {
        label  = 'DFA (Federal Police)',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Agent Trainee',       salary = 400 },
            [1] = { label = 'Special Agent',       salary = 550 },
            [2] = { label = 'Senior Agent',        salary = 700 },
            [3] = { label = 'Supervisory Agent',   salary = 900 },
            [4] = { label = 'Director',            salary = 1200 },
        },
    },

    state_police = {
        label  = 'State Police',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Trooper Trainee',     salary = 300 },
            [1] = { label = 'Trooper',             salary = 400 },
            [2] = { label = 'Corporal',            salary = 500 },
            [3] = { label = 'Sergeant',            salary = 650 },
            [4] = { label = 'Captain',             salary = 850 },
        },
    },

    medical = {
        label  = 'Medical Services',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Paramedic',           salary = 300 },
            [1] = { label = 'EMT',                 salary = 400 },
            [2] = { label = 'Nurse',               salary = 500 },
            [3] = { label = 'Doctor',              salary = 700 },
            [4] = { label = 'Chief of Medicine',   salary = 950 },
        },
    },

    military_army = {
        label  = 'Army',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Private',             salary = 350 },
            [1] = { label = 'Corporal',            salary = 450 },
            [2] = { label = 'Sergeant',            salary = 600 },
            [3] = { label = 'Lieutenant',          salary = 800 },
            [4] = { label = 'General',             salary = 1100 },
        },
    },

    military_navy = {
        label  = 'Navy',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Seaman',              salary = 350 },
            [1] = { label = 'Petty Officer',       salary = 450 },
            [2] = { label = 'Chief Petty Officer', salary = 600 },
            [3] = { label = 'Commander',           salary = 800 },
            [4] = { label = 'Admiral',             salary = 1100 },
        },
    },

    military_airforce = {
        label  = 'Air Force',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Airman',              salary = 350 },
            [1] = { label = 'Senior Airman',       salary = 450 },
            [2] = { label = 'Staff Sergeant',      salary = 600 },
            [3] = { label = 'Captain',             salary = 800 },
            [4] = { label = 'General',             salary = 1100 },
        },
    },

    judge = {
        label  = 'Judiciary',
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Clerk',               salary = 300 },
            [1] = { label = 'Magistrate',          salary = 600 },
            [2] = { label = 'Associate Judge',     salary = 900 },
            [3] = { label = 'Senior Judge',        salary = 1100 },
            [4] = { label = 'Chief Justice',       salary = 1500 },
        },
    },

    da = {
        label  = "District Attorney's Office",
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Legal Intern',        salary = 250 },
            [1] = { label = 'ADA',                 salary = 500 },
            [2] = { label = 'Senior ADA',          salary = 700 },
            [3] = { label = 'Deputy DA',           salary = 900 },
            [4] = { label = 'District Attorney',   salary = 1200 },
        },
    },

    governor = {
        label  = "Governor's Office",
        type   = FactionType.STATE,
        grades = {
            [0] = { label = 'Aide',                salary = 400 },
            [1] = { label = 'Senior Aide',         salary = 600 },
            [2] = { label = 'Chief of Staff',      salary = 900 },
            [3] = { label = 'Lt. Governor',        salary = 1200 },
            [4] = { label = 'Governor',            salary = 2000 },
        },
    },

    -- ── Gang Factions ─────────────────────────────────────────────────────────
    -- Add gang entries here following the same pattern.
    -- Example (uncomment and customise as needed):
    --
    -- lost_mc = {
    --     label  = 'The Lost MC',
    --     type   = FactionType.GANG,
    --     grades = {
    --         [0] = { label = 'Prospect',  salary = 0 },
    --         [1] = { label = 'Hangaround', salary = 0 },
    --         [2] = { label = 'Member',    salary = 0 },
    --         [3] = { label = 'Sergeant',  salary = 0 },
    --         [4] = { label = 'President', salary = 0 },
    --     },
    -- },
}

--- Return grade data for a given faction and grade number, or nil.
--- @param factionName  string
--- @param grade        number
--- @return table|nil
function getFactionGrade(factionName, grade)
    local faction = Factions[factionName]
    if not faction then return nil end
    return faction.grades[grade]
end

--- Return true if the faction is a state faction.
--- @param factionName string
--- @return boolean
function isStateFaction(factionName)
    local faction = Factions[factionName]
    return faction ~= nil and faction.type == FactionType.STATE
end

-- =============================================================================
-- Criminal Factions – player-created (gang, cartel, mafia, motorcycle_club)
-- =============================================================================

-- Grade labels per criminal faction type (index 4 is always the Leader/founder).
CriminalFactionTypes = {
    gang = {
        label  = 'Gang',
        grades = {
            [0] = 'Recruit',
            [1] = 'Gangster',
            [2] = 'Shotcaller',
            [3] = 'OG',
            [4] = 'Boss',
        },
    },
    cartel = {
        label  = 'Cartel',
        grades = {
            [0] = 'Runner',
            [1] = 'Soldier',
            [2] = 'Enforcer',
            [3] = 'Underboss',
            [4] = 'Boss',
        },
    },
    mafia = {
        label  = 'Mafia',
        grades = {
            [0] = 'Associate',
            [1] = 'Soldier',
            [2] = 'Capo',
            [3] = 'Underboss',
            [4] = 'Don',
        },
    },
    motorcycle_club = {
        label  = 'Motorcycle Club',
        grades = {
            [0] = 'Hang-Around',
            [1] = 'Prospect',
            [2] = 'Member',
            [3] = 'Sergeant-at-Arms',
            [4] = 'President',
        },
    },
}

-- Configuration for player-created criminal factions.
CriminalFactionConfig = {
    creationCost = 1000000,  -- amount deducted from the founding player's bank balance
    maxMembers   = 45,       -- hard cap on total members per faction
    leaderGrade  = 4,        -- grade index assigned to the founding player
}

--- Return the grade label string for a criminal faction type and grade.
--- @param factionType string  (gang | cartel | mafia | motorcycle_club)
--- @param grade       number
--- @return string|nil
function getCriminalFactionGradeLabel(factionType, grade)
    local t = CriminalFactionTypes[factionType]
    if not t then return nil end
    return t.grades[grade]
end
