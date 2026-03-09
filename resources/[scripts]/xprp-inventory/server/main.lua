-- =============================================================================
-- xprp-inventory | Server – Inventory Operations
-- =============================================================================

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function getCharId(src)
    local player = exports['xprp-core']:getPlayer(src)
    return player and player.charId
end

local function fetchInventory(charId)
    return MySQL.query.await(
        'SELECT item, amount FROM xprp_inventory WHERE char_id = ?',
        { charId }
    ) or {}
end

local function totalWeight(inventory)
    local w = 0
    for _, row in ipairs(inventory) do
        local def = Items[row.item]
        if def then w = w + def.weight * row.amount end
    end
    return w
end

-- ── Get Inventory ─────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:getInventory', function()
    local src    = source
    local charId = getCharId(src)
    if not charId then return end

    TriggerClientEvent('xprp:receiveInventory', src, fetchInventory(charId))
end)

-- ── Add Item ──────────────────────────────────────────────────────────────────

--- @param src     number  server source
--- @param item    string  item name
--- @param amount  number
--- @return boolean  success
local function addItem(src, item, amount)
    local charId = getCharId(src)
    if not charId then return false end
    if not Items[item] then return false end

    local inv = fetchInventory(charId)
    if totalWeight(inv) + Items[item].weight * amount > MaxWeight then
        TriggerClientEvent('xprp:notify', src, 'Inventory too heavy.', 'warn')
        return false
    end

    MySQL.query.await([[
        INSERT INTO xprp_inventory (char_id, item, amount)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE amount = amount + VALUES(amount)
    ]], { charId, item, amount })

    TriggerClientEvent('xprp:notify', src,
        ('Received %dx %s'):format(amount, Items[item].label), 'info')
    return true
end

exports('addItem', addItem)

-- ── Remove Item ───────────────────────────────────────────────────────────────

--- @param src     number
--- @param item    string
--- @param amount  number
--- @return boolean  success
local function removeItem(src, item, amount)
    local charId = getCharId(src)
    if not charId then return false end

    local current = MySQL.scalar.await(
        'SELECT amount FROM xprp_inventory WHERE char_id = ? AND item = ?',
        { charId, item }
    ) or 0

    if current < amount then
        TriggerClientEvent('xprp:notify', src, 'Not enough items.', 'error')
        return false
    end

    if current == amount then
        MySQL.query.await(
            'DELETE FROM xprp_inventory WHERE char_id = ? AND item = ?',
            { charId, item }
        )
    else
        MySQL.query.await(
            'UPDATE xprp_inventory SET amount = amount - ? WHERE char_id = ? AND item = ?',
            { amount, charId, item }
        )
    end

    return true
end

exports('removeItem', removeItem)

-- ── Use Item ──────────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:useItem', function(item)
    local src = source
    if not Items[item] or not Items[item].usable then return end
    if removeItem(src, item, 1) then
        TriggerClientEvent('xprp:itemUsed', src, item)
    end
end)
