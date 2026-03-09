-- =============================================================================
-- spawnmanager | Client – Freeze player on connect, release on xprp:playerReady
-- =============================================================================

local spawned = false

AddEventHandler('playerSpawned', function()
    if spawned then return end
    -- Hide and freeze the local ped while the character selection UI is open
    DoScreenFadeOut(0)
    SetEntityVisible(PlayerPedId(), false, false)
    FreezeEntityPosition(PlayerPedId(), true)
end)

-- xprp-core fires this once the character has been fully loaded server-side
RegisterNetEvent('xprp:playerReady', function(playerData)
    if spawned then return end
    spawned = true

    local coords  = playerData.lastCoords or {
        x = 195.17, y = -933.77, z = 30.69, heading = 160.0
    }

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Citizen.Wait(100)
    end

    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.heading or 160.0)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    DoScreenFadeIn(500)
end)
