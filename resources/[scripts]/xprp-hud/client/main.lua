-- =============================================================================
-- xprp-hud | Client – HUD Controller
-- =============================================================================

local hudVisible = false

-- Show HUD when player is ready
AddEventHandler('xprp:hudUpdate', function(data)
    if not hudVisible then
        SendNUIMessage({ action = 'show' })
        hudVisible = true
    end
    SendNUIMessage({
        action = 'update',
        health = math.max(0, GetEntityHealth(PlayerPedId()) - 100),
        armour = GetPedArmour(PlayerPedId()),
        cash   = data.cash or 0,
        bank   = data.bank or 0,
        job    = data.job  and data.job.name or 'unemployed',
    })
end)

-- Poll health / armour every second
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if hudVisible then
            local coreData = exports['xprp-core']:getPlayerData()
            if coreData then
                SendNUIMessage({
                    action = 'update',
                    health = math.max(0, GetEntityHealth(PlayerPedId()) - 100),
                    armour = GetPedArmour(PlayerPedId()),
                    cash   = coreData.cash or 0,
                    bank   = coreData.bank or 0,
                    job    = coreData.job  and coreData.job.name or 'unemployed',
                })
            end
        end
    end
end)
