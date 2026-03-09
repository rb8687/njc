-- =============================================================================
-- xprp-core | Server – Bootstrap
-- =============================================================================

-- Expose framework table globally so other resources can use exports
xprp = {}

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    xprp_log('xprp-core started', 'info')
end)

-- ── Exports ──────────────────────────────────────────────────────────────────

--- Get the full player table by server ID, or nil if not loaded.
--- @param src number
--- @return table|nil
exports('getPlayer', function(src)
    return xprp.Players[src]
end)

--- Get all currently connected xprp players.
--- @return table
exports('getPlayers', function()
    return xprp.Players
end)
