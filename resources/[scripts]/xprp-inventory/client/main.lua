-- =============================================================================
-- xprp-inventory | Client – Item Usage Effects
-- =============================================================================

RegisterNetEvent('xprp:itemUsed', function(item)
    if item == 'bandage' then
        local ped = PlayerPedId()
        local hp  = GetEntityHealth(ped)
        SetEntityHealth(ped, math.min(hp + 20, 200))
        TriggerEvent('xprp:notify', 'You used a bandage.', 'info')
    elseif item == 'bread' or item == 'water' then
        TriggerEvent('xprp:notify', ('You consumed a %s.'):format(item), 'info')
    end
end)

-- Open inventory with I key (using RegisterKeyMapping for performance)
RegisterKeyMapping('xprp_inventory', 'Open Inventory', 'keyboard', 'i')
RegisterCommand('xprp_inventory', function()
    TriggerServerEvent('xprp:getInventory')
end, false)

RegisterNetEvent('xprp:receiveInventory', function(inventory)
    -- In production, render a NUI inventory grid here.
    -- For now, print items to the notification feed.
    if #inventory == 0 then
        TriggerEvent('xprp:notify', 'Your inventory is empty.', 'info')
        return
    end
    local lines = {}
    for _, row in ipairs(inventory) do
        local def = Items[row.item]
        lines[#lines + 1] = ('%s x%d'):format(def and def.label or row.item, row.amount)
    end
    TriggerEvent('xprp:notify', table.concat(lines, ', '), 'info')
end)
