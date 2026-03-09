-- =============================================================================
-- xprp-playtime | Client – Reward Notifications
-- =============================================================================

-- Displayed when the server grants a periodic playtime reward.
RegisterNetEvent('xprp:playtime:reward', function(data)
    local line1, line2

    if data.isClean then
        line1 = ('~g~Play-time reward: ~w~+%d XP   +$%d'):format(data.xp, data.cash)
        line2 = '~b~Clean gameplay bonus included!'
    else
        line1 = ('~y~Play-time reward: ~w~+%d XP   +$%d'):format(data.xp, data.cash)
        line2 = nil
    end

    -- Show a big-message feed notification
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(line1)
    EndTextCommandThefeedPostTicker(false, true)

    if line2 then
        Citizen.Wait(PlaytimeConfig.NotificationDelayMs)
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(line2)
        EndTextCommandThefeedPostTicker(false, true)
    end
end)
