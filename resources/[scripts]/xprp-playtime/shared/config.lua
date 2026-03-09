-- =============================================================================
-- xprp-playtime | Shared Configuration
-- =============================================================================

PlaytimeConfig = {}

-- ── Interval ──────────────────────────────────────────────────────────────────
-- How often (in minutes) XP and cash are awarded for being online.
PlaytimeConfig.IntervalMinutes = 5

-- ── Base rewards (every interval) ────────────────────────────────────────────
PlaytimeConfig.BaseXp   = 50   -- XP per interval
PlaytimeConfig.BaseCash = 250  -- Cash per interval

-- ── Clean gameplay bonus ──────────────────────────────────────────────────────
-- Awarded on top of the base when no infractions are recorded this session.
PlaytimeConfig.CleanBonusXp   = 25   -- extra XP per interval for clean play
PlaytimeConfig.CleanBonusCash = 125  -- extra cash per interval for clean play

-- Minimum minutes a player must have been online before the clean bonus applies.
PlaytimeConfig.CleanMinimumMinutes = 10

-- Delay (ms) between the two reward notification lines shown on the client.
PlaytimeConfig.NotificationDelayMs = 500
