-- =============================================================================
-- xprp-playtime | Client – Reward Notifications
-- =============================================================================

-- Displayed when the server grants the playtime milestone reward.
RegisterNetEvent('xprp:playtime:reward', function(data)
    -- Line 1: reward amounts
    local line1 = ('~g~Play-time reward: ~w~+%d XP   +$%d'):format(
        data.xp,
        data.cash
    )

    -- Line 2: context (faction or regular threshold reached)
    local line2
    if data.isFaction then
        line2 = ('~b~Faction member reward – %d min threshold reached!'):format(data.threshold)
    else
        line2 = ('~y~%d min play-time threshold reached!'):format(data.threshold)
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(line1)
    EndTextCommandThefeedPostTicker(false, true)

    Citizen.Wait(PlaytimeConfig.NotificationDelayMs)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(line2)
    EndTextCommandThefeedPostTicker(false, true)
end)
