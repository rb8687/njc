-- =============================================================================
-- spawnmanager | Client – Initial Spawn
-- =============================================================================

-- Disable the default FiveM spawn and hand control to xprp-core
AddEventHandler('playerSpawned', function()
    -- FiveM's built-in playerSpawned fires after the player model loads.
    -- We block the default spawn point; xprp-core handles the actual position.
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
end)

-- Ensure the player is invisible and frozen until xprp-core moves them.
AddEventHandler('onClientResourceStart', function(name)
    if name ~= GetCurrentResourceName() then return end
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, false)

    -- Wait for xprp-core to signal the player is ready
    AddEventHandler('xprp:playerReady', function()
        local ped2 = PlayerPedId()
        FreezeEntityPosition(ped2, false)
        SetEntityVisible(ped2, true, false)
    end)
end)
