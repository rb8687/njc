-- =============================================================================
-- NPC Criminal Factions — Server-side logic
-- Handles:
--   • Broadcasting spawn/despawn events to all clients on the 45-min cycle
--   • Drug supply inventory per faction per cycle
--   • Player purchase requests (validation, deduction, inventory grant)
--   • Criminal faction purchase requests (same pipeline, faction flag)
-- =============================================================================

local cycleActive  = false   -- true while factions are in the world
local cycleSupply  = {}      -- [factionId][drugKey] = remaining kg/g this cycle

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

--- Reset supply inventories for all supplier factions at the start of a cycle.
local function resetSupply()
    cycleSupply = {}
    for _, faction in ipairs(Config.Factions) do
        if faction.canSupply then
            cycleSupply[faction.id] = {}
            for _, drugKey in ipairs(faction.drugs) do
                local drug = Config.Drugs[drugKey]
                if drug then
                    cycleSupply[faction.id][drugKey] = drug.maxSupply
                end
            end
        end
    end
end

--- Find a faction definition by id.
local function getFaction(factionId)
    for _, f in ipairs(Config.Factions) do
        if f.id == factionId then
            return f
        end
    end
    return nil
end

-- ---------------------------------------------------------------------------
-- Spawn cycle — runs every 45 minutes
-- ---------------------------------------------------------------------------

local function runCycle()
    while true do
        -- ── Spawn phase ────────────────────────────────────────────────────
        cycleActive = true
        resetSupply()
        TriggerClientEvent('njc:factionsSpawn', -1, Config.Factions)
        print(('[NPC Factions] Cycle started — %d factions active'):format(#Config.Factions))

        -- Wait for the full cycle duration
        Wait(Config.SpawnCycleTicks)

        -- ── Despawn phase ──────────────────────────────────────────────────
        cycleActive = false
        cycleSupply = {}
        TriggerClientEvent('njc:factionsDespawn', -1)
        print('[NPC Factions] Cycle ended — factions despawned')

        -- Brief pause between cycles (30 seconds) before the next spawn
        Wait(30000)
    end
end

-- Start the cycle loop when the resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Citizen.CreateThread(runCycle)
end)

-- ---------------------------------------------------------------------------
-- Drug purchase — player buys from a supplier NPC
--
-- Event: njc:buyDrug
-- Params:
--   factionId  (string)  — which supplier faction
--   drugKey    (string)  — which drug
--   quantity   (number)  — amount requested (kg or g)
--   isFaction  (boolean) — true when the buyer is a criminal faction rather
--                          than an individual player
-- ---------------------------------------------------------------------------

RegisterNetEvent('njc:buyDrug', function(factionId, drugKey, quantity, isFaction)
    local src = source

    -- ── Validate cycle is active ───────────────────────────────────────────
    if not cycleActive then
        TriggerClientEvent('njc:buyResult', src, false, 'Suppliers are not available right now.')
        return
    end

    -- ── Validate faction exists and can supply ─────────────────────────────
    local faction = getFaction(factionId)
    if not faction or not faction.canSupply then
        TriggerClientEvent('njc:buyResult', src, false, 'Invalid supplier.')
        return
    end

    -- ── Validate drug is offered by this faction ───────────────────────────
    local drug = Config.Drugs[drugKey]
    if not drug then
        TriggerClientEvent('njc:buyResult', src, false, 'Unknown drug.')
        return
    end

    local offered = false
    for _, dk in ipairs(faction.drugs) do
        if dk == drugKey then offered = true; break end
    end
    if not offered then
        TriggerClientEvent('njc:buyResult', src, false,
            faction.name .. ' does not carry ' .. drug.label .. '.')
        return
    end

    -- ── Validate quantity ──────────────────────────────────────────────────
    quantity = math.floor(tonumber(quantity) or 0)
    if quantity <= 0 then
        TriggerClientEvent('njc:buyResult', src, false, 'Invalid quantity.')
        return
    end
    if quantity > Config.MaxBuyPerTransaction then
        TriggerClientEvent('njc:buyResult', src, false,
            ('Maximum per transaction is %d %s.'):format(Config.MaxBuyPerTransaction, drug.unit))
        return
    end

    -- ── Check faction supply inventory ────────────────────────────────────
    local remaining = (cycleSupply[factionId] or {})[drugKey] or 0
    if quantity > remaining then
        TriggerClientEvent('njc:buyResult', src, false,
            ('Only %d %s of %s remaining this cycle.'):format(remaining, drug.unit, drug.label))
        return
    end

    -- ── Calculate total cost ──────────────────────────────────────────────
    local totalCost = quantity * drug.pricePerUnit

    -- ── Deduct money from player (framework-agnostic stub) ────────────────
    -- Replace the block below with your server framework's money functions
    -- (e.g. ESX, QBCore, vRP, etc.).  The stub below uses a simple export
    -- convention: exports['your_framework']:RemoveMoney(src, totalCost)
    -- and exports['your_framework']:AddItem(src, drugKey, quantity)
    -- For now we emit a server-event that other scripts can hook into.

    -- Emit pre-purchase hook so the owning framework can validate/deduct cash.
    -- IMPORTANT: In production you MUST integrate your server framework here.
    -- Uncomment and adapt the lines below for ESX / QBCore / vRP etc.:
    --
    --   if not exports['framework']:CanAfford(src, totalCost) then
    --       TriggerClientEvent('njc:buyResult', src, false,
    --           ('You need $%s.'):format(formatMoney(totalCost)))
    --       return
    --   end
    --   exports['framework']:RemoveMoney(src, totalCost)
    --
    -- Until a framework is wired in, purchases are allowed without cash checks.
    local allowed = true

    if not allowed then
        TriggerClientEvent('njc:buyResult', src, false,
            ('You need $%s to buy %d %s of %s.'):format(
                formatMoney(totalCost), quantity, drug.unit, drug.label))
        return
    end

    -- ── Deduct from cycle supply ──────────────────────────────────────────
    cycleSupply[factionId][drugKey] = remaining - quantity

    -- ── Grant item to buyer ───────────────────────────────────────────────
    -- Framework hook — replace with your inventory system
    -- exports['framework']:AddItem(src, drugKey, quantity)

    -- Notify the buying client
    TriggerClientEvent('njc:buyResult', src, true,
        ('You purchased %d %s of %s from %s for $%s.'):format(
            quantity, drug.unit, drug.label, faction.name, formatMoney(totalCost)))

    -- Broadcast an anonymised supply-update so other buyers see fresh stock
    TriggerClientEvent('njc:supplyUpdate', -1, factionId, drugKey,
        cycleSupply[factionId][drugKey])

    print(('[NPC Factions] src=%d bought %d%s %s from %s (isFaction=%s)'):format(
        src, quantity, drug.unit, drugKey, factionId, tostring(isFaction)))
end)

-- ---------------------------------------------------------------------------
-- Supply query — client asks for current stock of a supplier faction
-- ---------------------------------------------------------------------------

RegisterNetEvent('njc:querySupply', function(factionId)
    local src = source
    if not cycleActive then
        TriggerClientEvent('njc:supplyInfo', src, nil)
        return
    end
    TriggerClientEvent('njc:supplyInfo', src, cycleSupply[factionId])
end)

-- ---------------------------------------------------------------------------
-- Utility
-- ---------------------------------------------------------------------------

function formatMoney(n)
    local s = tostring(math.floor(n))
    local result = ''
    local len = #s
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then
            result = result .. ','
        end
        result = result .. s:sub(i, i)
    end
    return result
end
