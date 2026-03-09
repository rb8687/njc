-- =============================================================================
-- xprp-core | Client – Bootstrap
-- =============================================================================

-- Listen for the server confirming our character is ready
RegisterNetEvent('xprp:playerReady', function(playerData)
    LocalPlayer.state:set('xprp_ready', true, true)
    TriggerEvent('xprp:ready', playerData)
end)

-- Generic notification display (other resources can call xprp:notify)
RegisterNetEvent('xprp:notify', function(message, notifyType)
    -- notifyType: 'success' | 'error' | 'info'
    notifyType = notifyType or 'info'
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end)
