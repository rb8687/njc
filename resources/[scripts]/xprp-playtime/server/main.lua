-- =============================================================================
-- xprp-playtime | Server – XP & Cash Rewards
--
-- Awards players XP and cash at regular intervals for:
--   • Being connected and having a character loaded  (base reward)
--   • Clean gameplay – no infractions recorded this session (bonus reward)
-- =============================================================================

-- Session table: keyed by player server ID.
-- Each entry tracks when the player loaded their character and whether
-- any infraction has been flagged against them this session.
local Sessions = {}

-- ── Session lifecycle ─────────────────────────────────────────────────────────

-- Called by xprp-core when a character is fully loaded server-side.
AddEventHandler('xprp:playerLoaded', function(src, player)
    Sessions[src] = {
        loadTime = os.time(),  -- wall-clock seconds when session started
        charId   = player.charId,
        clean    = true,       -- innocent until an infraction is recorded
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

-- ── Infraction recording ──────────────────────────────────────────────────────

--- Record an infraction against a player, removing their clean-play bonus.
--- Any server-side admin or resource may call this via TriggerEvent.
--- @param targetSrc  number  server ID of the offending player
--- @param reason     string  human-readable reason (logged only)
AddEventHandler('xprp:playtime:recordInfraction', function(targetSrc, reason)
    local session = Sessions[targetSrc]
    if session and session.clean then
        session.clean = false
        xprp_log(('Infraction recorded for src %d: %s'):format(targetSrc, tostring(reason)))
        TriggerClientEvent('xprp:notify', targetSrc,
            'An infraction has been recorded against you. Clean-play bonus removed for this session.',
            'error')
    end
end)

--- Net-event wrapper so admins can flag a player from the client side.
RegisterNetEvent('xprp:playtime:adminInfraction', function(targetSrc, reason)
    local src = source
    if not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('xprp:notify', src, 'No permission.', 'error')
        return
    end
    TriggerEvent('xprp:playtime:recordInfraction', targetSrc, reason or 'admin flag')
end)

-- ── Periodic reward loop ──────────────────────────────────────────────────────

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(PlaytimeConfig.IntervalMinutes * 60 * 1000)

        for src, session in pairs(Sessions) do
            local player = exports['xprp-core']:getPlayer(src)
            if not player then
                -- Player must have disconnected without the drop event firing; clean up.
                Sessions[src] = nil
            else
                local elapsedMinutes = (os.time() - session.loadTime) / 60

                -- Calculate rewards
                local xpGain   = PlaytimeConfig.BaseXp
                local cashGain = PlaytimeConfig.BaseCash
                local gotClean = false

                if session.clean and elapsedMinutes >= PlaytimeConfig.CleanMinimumMinutes then
                    xpGain   = xpGain   + PlaytimeConfig.CleanBonusXp
                    cashGain = cashGain + PlaytimeConfig.CleanBonusCash
                    gotClean = true
                end

                -- Persist to DB; roll back in-memory changes if this fails.
                local ok, err = pcall(function()
                    MySQL.query.await(
                        'UPDATE xprp_characters SET xp = xp + ?, cash = cash + ? WHERE id = ?',
                        { xpGain, cashGain, player.charId }
                    )
                end)

                if not ok then
                    xprp_log(('DB update failed for src %d: %s'):format(src, tostring(err)), 'error')
                else
                    -- Update in-memory player table so other resources see current values
                    player.xp   = (player.xp   or 0) + xpGain
                    player.cash = (player.cash or 0) + cashGain

                    -- Tell the client so it can display a notification
                    TriggerClientEvent('xprp:playtime:reward', src, {
                        xp        = xpGain,
                        cash      = cashGain,
                        isClean   = gotClean,
                        totalXp   = player.xp,
                        totalCash = player.cash,
                    })

                    xprp_log(('Reward for src %d: +%d XP, +$%d cash (clean=%s)'):format(
                        src, xpGain, cashGain, tostring(gotClean)))
                end
            end
        end
    end
end)
