-- =============================================================================
-- xprp-playtime | Server – XP & Cash Rewards
--
-- Awards players a one-time session reward when they reach their playtime
-- threshold:
--   • Regular players  – 60 minutes
--   • Faction members  – 45 minutes
-- Reward: $10,000 cash + 25 XP (configurable in shared/config.lua)
-- =============================================================================

-- Session table: keyed by player server ID.
-- Each entry tracks when the player loaded their character and whether the
-- session reward has already been paid out.
local Sessions = {}

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- Build a fast lookup set from the FactionJobs list.
local factionJobSet = {}
for _, jobName in ipairs(PlaytimeConfig.FactionJobs) do
    factionJobSet[jobName] = true
end

--- Return the required playtime threshold (minutes) for this player.
--- @param player table  in-memory player object from xprp-core
--- @return number
local function getThreshold(player)
    if factionJobSet[player.job] then
        return PlaytimeConfig.FactionRewardMinutes
    end
    return PlaytimeConfig.RewardMinutes
end

-- ── Session lifecycle ─────────────────────────────────────────────────────────

-- Called by xprp-core when a character is fully loaded server-side.
AddEventHandler('xprp:playerLoaded', function(src, player)
    Sessions[src] = {
        loadTime = os.time(),  -- wall-clock seconds when session started
        charId   = player.charId,
        rewarded = false,      -- true once the milestone reward has been paid
    }
    xprp_log(('Playtime session started for src %d (char %d)'):format(src, player.charId))
end)

-- Clean up when the player leaves.
AddEventHandler('xprp:playerDropped', function(src, player)
    local session = Sessions[src]
    if not session then return end

    -- Persist accumulated playtime so the character record stays accurate.
    local elapsed = os.time() - session.loadTime
    MySQL.query.await(
        'UPDATE xprp_characters SET playtime_secs = playtime_secs + ? WHERE id = ?',
        { elapsed, session.charId }
    )
    Sessions[src] = nil
    xprp_log(('Playtime session ended for src %d (+%ds)'):format(src, elapsed))
end)

-- ── Milestone reward loop ─────────────────────────────────────────────────────

-- Poll every 60 seconds to keep CPU usage minimal.
local POLL_INTERVAL_MS = 60 * 1000

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(POLL_INTERVAL_MS)

        for src, session in pairs(Sessions) do
            -- Skip players who already received their reward this session.
            if not session.rewarded then
                local player = exports['xprp-core']:getPlayer(src)
                if not player then
                    -- Player disconnected without the drop event firing; clean up.
                    Sessions[src] = nil
                else
                    local elapsedMinutes = (os.time() - session.loadTime) / 60
                    local threshold      = getThreshold(player)

                    if elapsedMinutes >= threshold then
                        -- Mark as rewarded immediately to prevent double-payout.
                        session.rewarded = true

                        local xpGain   = PlaytimeConfig.RewardXp
                        local cashGain = PlaytimeConfig.RewardCash

                        -- Persist to DB; revert in-memory state on failure.
                        local ok, err = pcall(function()
                            MySQL.query.await(
                                'UPDATE xprp_characters SET xp = xp + ?, cash = cash + ? WHERE id = ?',
                                { xpGain, cashGain, player.charId }
                            )
                        end)

                        if not ok then
                            session.rewarded = false  -- allow retry next poll
                            xprp_log(('DB update failed for src %d: %s'):format(src, tostring(err)), 'error')
                        else
                            -- Update in-memory player table.
                            player.xp   = (player.xp   or 0) + xpGain
                            player.cash = (player.cash or 0) + cashGain

                            local isFaction = factionJobSet[player.job] == true
                            TriggerClientEvent('xprp:playtime:reward', src, {
                                xp         = xpGain,
                                cash       = cashGain,
                                isFaction  = isFaction,
                                threshold  = threshold,
                                totalXp    = player.xp,
                                totalCash  = player.cash,
                            })

                            xprp_log(('Milestone reward for src %d: +%d XP, +$%d cash (faction=%s, threshold=%dmin)'):format(
                                src, xpGain, cashGain, tostring(isFaction), threshold))
                        end
                    end
                end
            end
        end
    end
end)
