-- =============================================================================
-- xprp-core | Client – Bootstrap
-- =============================================================================

local playerData = nil

-- ── Framework Ready ───────────────────────────────────────────────────────────

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    -- Request character list once core has loaded
    TriggerServerEvent('xprp:requestCharacters')
end)

-- ── Receive character list ────────────────────────────────────────────────────

RegisterNetEvent('xprp:receiveCharacters', function(chars)
    -- Show a simple character selection NUI or fall back to the first character.
    if #chars == 0 then
        xprp_log('No characters found – opening creation menu.')
        -- In a full implementation, open a character-creation NUI here.
        -- For now we notify the player.
        TriggerEvent('xprp:openCharacterCreation')
    else
        -- Auto-select the first character for the demo; replace with NUI selector.
        TriggerServerEvent('xprp:playerLoaded', chars[1].id)
    end
end)

-- ── Player Ready ──────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:playerReady', function(data)
    playerData = data
    xprp_log(('Local player ready as "%s"'):format(data.name))

    -- Spawn at default position
    local spawn = Config.DefaultSpawn
    RequestModel('a_m_y_business_01')
    while not HasModelLoaded('a_m_y_business_01') do
        Citizen.Wait(100)
    end

    local ped = PlayerPedId()
    SetEntityCoords(ped, spawn.x, spawn.y, spawn.z, false, false, false, true)
    SetEntityHeading(ped, spawn.heading)
    FreezeEntityPosition(ped, false)

    TriggerEvent('xprp:hudUpdate', playerData)
end)

-- ── Exports ──────────────────────────────────────────────────────────────────

exports('getPlayerData', function()
    return playerData
end)
