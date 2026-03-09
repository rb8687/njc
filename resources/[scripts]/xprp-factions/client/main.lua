-- =============================================================================
-- xprp-factions | Client – Faction UI Feedback
-- =============================================================================

RegisterNetEvent('xprp:factionUpdated', function(factionData)
    -- Refresh the HUD whenever the player's faction changes
    TriggerEvent('xprp:hudUpdate', exports['xprp-core']:getPlayerData())
end)
