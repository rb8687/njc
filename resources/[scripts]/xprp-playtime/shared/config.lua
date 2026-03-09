-- =============================================================================
-- xprp-playtime | Shared Configuration
-- =============================================================================

PlaytimeConfig = {}

-- ── Milestone thresholds ───────────────────────────────────────────────────────
-- Minutes of continuous play required to earn the one-time session reward.
PlaytimeConfig.RewardMinutes        = 60   -- regular players
PlaytimeConfig.FactionRewardMinutes = 45   -- faction members (shorter threshold)

-- ── Reward values (awarded once per session on reaching the threshold) ─────────
PlaytimeConfig.RewardCash = 10000
PlaytimeConfig.RewardXp   = 25

-- ── Faction jobs ───────────────────────────────────────────────────────────────
-- Players whose character job matches one of these names are treated as faction
-- members and benefit from the shorter FactionRewardMinutes threshold.
PlaytimeConfig.FactionJobs = {
    'police',
    'mechanic',
}

-- Delay (ms) between the two reward notification lines shown on the client.
PlaytimeConfig.NotificationDelayMs = 500
