-- =============================================================================
-- NPC Criminal Factions — Client-side main
-- Handles:
--   • Receiving spawn/despawn events from the server
--   • Spawning NPC ped groups at faction locations
--   • Creating/removing map blips
--   • Proximity detection so the buy UI only appears when near a supplier NPC
-- =============================================================================

local spawnedPeds   = {}   -- [netId or handle] = true
local activeBlips   = {}   -- [factionId] = blipHandle
local activeFactions = {}  -- current list of faction tables (set on spawn event)
local nearbySupplier = nil -- faction table of the supplier the player is near

local INTERACTION_DISTANCE = 3.0  -- metres — how close before interaction prompt

-- ---------------------------------------------------------------------------
-- Utility: load and request a ped model
-- ---------------------------------------------------------------------------
local function requestModel(modelHash)
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 100 do
        Wait(100)
        timeout = timeout + 1
    end
    return HasModelLoaded(modelHash)
end

-- ---------------------------------------------------------------------------
-- Spawn a single NPC at the given coords
-- ---------------------------------------------------------------------------
local function spawnNpc(modelName, coords, heading)
    local hash = GetHashKey(modelName)
    if not requestModel(hash) then
        print(('[NPC Factions] WARNING: model %s failed to load'):format(modelName))
        return nil
    end

    -- PED_TYPE_CIVMALE = 4 (civilian male, used for all faction NPCs)
    local ped = CreatePed(4, hash, coords.x, coords.y, coords.z - 1.0, heading,
                          false, true)

    if not DoesEntityExist(ped) then
        SetModelAsNoLongerNeeded(hash)
        return nil
    end

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    TaskWanderStandard(ped, 10.0, 10)
    SetModelAsNoLongerNeeded(hash)

    return ped
end

-- ---------------------------------------------------------------------------
-- Spawn all NPCs for a faction
-- ---------------------------------------------------------------------------
local function spawnFaction(faction)
    if not faction.spawnLocations or #faction.spawnLocations == 0 then return end

    local memberModels = faction.models or { 'a_m_m_bevhills_01' }
    local spawned = {}

    for _, loc in ipairs(faction.spawnLocations) do
        local coords = vector3(loc.x, loc.y, loc.z)
        for i = 1, faction.memberCount do
            -- Spread members slightly around the spawn point
            local offsetX = math.random(-5, 5)
            local offsetY = math.random(-5, 5)
            local spawnCoords = vector3(coords.x + offsetX,
                                        coords.y + offsetY,
                                        coords.z)
            local model = memberModels[((i - 1) % #memberModels) + 1]
            local ped = spawnNpc(model, spawnCoords, loc.h or 0.0)
            if ped then
                table.insert(spawned, ped)
            end
        end

        -- Map blip
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, faction.blipSprite or 84)
        SetBlipColour(blip, faction.blipColor or 0)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(faction.name)
        EndTextCommandSetBlipName(blip)
        activeBlips[faction.id] = blip
    end

    spawnedPeds[faction.id] = spawned
end

-- ---------------------------------------------------------------------------
-- Despawn all active NPCs and remove blips
-- ---------------------------------------------------------------------------
local function despawnAll()
    for factionId, peds in pairs(spawnedPeds) do
        for _, ped in ipairs(peds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
    spawnedPeds = {}

    for factionId, blip in pairs(activeBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    activeBlips = {}

    activeFactions  = {}
    nearbySupplier  = nil
    DisplayNpcFactionHud(false)
end

-- ---------------------------------------------------------------------------
-- Network events from the server
-- ---------------------------------------------------------------------------

RegisterNetEvent('njc:factionsSpawn', function(factions)
    -- Despawn any lingering peds before re-spawning
    despawnAll()
    activeFactions = factions
    for _, faction in ipairs(factions) do
        Citizen.CreateThread(function()
            spawnFaction(faction)
        end)
    end
    ShowNotification('~g~NPC criminal factions have arrived in the city.')
end)

RegisterNetEvent('njc:factionsDespawn', function()
    despawnAll()
    ShowNotification('~r~NPC criminal factions have left the city.')
end)

-- Supply update broadcast — refresh UI if player is currently browsing
RegisterNetEvent('njc:supplyUpdate', function(factionId, drugKey, remaining)
    if nearbySupplier and nearbySupplier.id == factionId then
        -- Refresh the in-game text menu stock counts
        RefreshMenuStock(drugKey, remaining)
    end
end)

-- Result of a purchase attempt
RegisterNetEvent('njc:buyResult', function(success, message)
    if success then
        ShowNotification('~g~' .. message)
    else
        ShowNotification('~r~' .. message)
    end
    -- Re-enable NUI cursor after transaction
    SetNuiFocus(false, false)
end)

-- Supply query response
RegisterNetEvent('njc:supplyInfo', function(supply)
    if not supply then
        ShowNotification('~r~This supplier has no stock right now.')
        return
    end
    OpenSupplyMenu(nearbySupplier, supply)
end)

-- ---------------------------------------------------------------------------
-- Proximity loop — detects when the player is close to a supplier NPC/location
-- ---------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local sleep = 1000

        if #activeFactions > 0 then
            sleep = 500
            local playerPos = GetEntityCoords(PlayerPedId())

            local closestFaction = nil
            local closestDist    = INTERACTION_DISTANCE + 1.0

            for _, faction in ipairs(activeFactions) do
                if faction.canSupply and faction.spawnLocations then
                    for _, loc in ipairs(faction.spawnLocations) do
                        local dist = #(playerPos - vector3(loc.x, loc.y, loc.z))
                        if dist < closestDist then
                            closestDist    = dist
                            closestFaction = faction
                        end
                    end
                end
            end

            if closestFaction then
                nearbySupplier = closestFaction
                DisplayNpcFactionHud(true, closestFaction.name)
                sleep = 0
            else
                if nearbySupplier then
                    nearbySupplier = nil
                    DisplayNpcFactionHud(false)
                end
            end
        end

        Wait(sleep)
    end
end)

-- ---------------------------------------------------------------------------
-- Input handler — [E] to open buy menu when near a supplier
-- ---------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if nearbySupplier and IsControlJustReleased(0, 38) then  -- E key
            TriggerServerEvent('njc:querySupply', nearbySupplier.id)
        end
    end
end)

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

function ShowNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end
