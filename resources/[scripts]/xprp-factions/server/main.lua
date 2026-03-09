-- =============================================================================
-- xprp-factions | Server – Faction Membership & Salary
-- =============================================================================

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function setPlayerFaction(src, factionName, grade)
    local player = exports['xprp-core']:getPlayer(src)
    if not player then return end

    player.faction = { name = factionName, grade = grade }

    MySQL.query.await(
        'UPDATE xprp_characters SET faction = ?, faction_grade = ? WHERE id = ?',
        { factionName, grade, player.charId }
    )

    TriggerClientEvent('xprp:factionUpdated', src, player.faction)
end

-- ── Admin Command: /setfaction <targetId> <factionName> [grade] ──────────────
-- Allows admins (command ACE) to assign any faction at any grade.

RegisterCommand('setfaction', function(src, args)
    if not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('xprp:notify', src, 'No permission.', 'error')
        return
    end

    local targetSrc  = tonumber(args[1])
    local factionName = args[2]
    local grade       = tonumber(args[3]) or 0

    if not targetSrc then
        TriggerClientEvent('xprp:notify', src, 'Usage: /setfaction <playerId> <faction> [grade]', 'error')
        return
    end

    if factionName == 'none' then
        setPlayerFaction(targetSrc, 'none', 0)
        TriggerClientEvent('xprp:notify', src, ('Removed faction for player %d.'):format(targetSrc), 'success')
        TriggerClientEvent('xprp:notify', targetSrc, 'You have been removed from your faction.', 'info')
        return
    end

    if not Factions[factionName] then
        TriggerClientEvent('xprp:notify', src, 'Unknown faction: ' .. tostring(factionName), 'error')
        return
    end

    if not Factions[factionName].grades[grade] then
        TriggerClientEvent('xprp:notify', src, 'Unknown grade for faction.', 'error')
        return
    end

    setPlayerFaction(targetSrc, factionName, grade)

    TriggerClientEvent('xprp:notify', src,
        ('Set %s to %s (grade %d).'):format(GetPlayerName(targetSrc), Factions[factionName].label, grade),
        'success')
    TriggerClientEvent('xprp:notify', targetSrc,
        ('You have been assigned to %s as %s.'):format(
            Factions[factionName].label,
            Factions[factionName].grades[grade].label),
        'success')
end, false)

-- ── Player Command: /joinfaction <factionName> ────────────────────────────────
-- State factions require the ACE permission 'xprp.faction.state'.
-- Gang factions are open to any player.

RegisterCommand('joinfaction', function(src, args)
    local factionName = args[1]

    if not factionName then
        TriggerClientEvent('xprp:notify', src, 'Usage: /joinfaction <faction>', 'error')
        return
    end

    if not Factions[factionName] then
        TriggerClientEvent('xprp:notify', src, 'Unknown faction: ' .. tostring(factionName), 'error')
        return
    end

    -- State factions require special permission
    if isStateFaction(factionName) and not IsPlayerAceAllowed(src, 'xprp.faction.state') then
        TriggerClientEvent('xprp:notify', src,
            'You are not authorised to join a state faction.', 'error')
        return
    end

    local player = exports['xprp-core']:getPlayer(src)
    if not player then
        TriggerClientEvent('xprp:notify', src, 'No active character.', 'error')
        return
    end

    if player.faction and player.faction.name ~= 'none' then
        TriggerClientEvent('xprp:notify', src,
            ('You are already in a faction (%s). Use /leavefaction first.'):format(player.faction.name),
            'error')
        return
    end

    setPlayerFaction(src, factionName, 0)

    TriggerClientEvent('xprp:notify', src,
        ('You have joined %s as %s.'):format(
            Factions[factionName].label,
            Factions[factionName].grades[0].label),
        'success')
end, false)

-- ── Player Command: /leavefaction ────────────────────────────────────────────

RegisterCommand('leavefaction', function(src)
    local player = exports['xprp-core']:getPlayer(src)
    if not player then
        TriggerClientEvent('xprp:notify', src, 'No active character.', 'error')
        return
    end

    if not player.faction or player.faction.name == 'none' then
        TriggerClientEvent('xprp:notify', src, 'You are not in any faction.', 'error')
        return
    end

    local oldLabel = Factions[player.faction.name] and Factions[player.faction.name].label
                     or player.faction.name

    setPlayerFaction(src, 'none', 0)

    TriggerClientEvent('xprp:notify', src,
        ('You have left %s.'):format(oldLabel), 'info')
end, false)

-- ── Player Command: /listfactions [state|gang] ───────────────────────────────

RegisterCommand('listfactions', function(src, args)
    local filter = args[1]  -- optional: 'state' or 'gang'
    local lines  = {}

    for name, data in pairs(Factions) do
        if not filter or data.type == filter then
            lines[#lines + 1] = ('[%s] %s – %s'):format(
                data.type:upper(), data.label, name)
        end
    end

    table.sort(lines)

    if #lines == 0 then
        TriggerClientEvent('xprp:notify', src, 'No factions found.', 'info')
        return
    end

    for _, line in ipairs(lines) do
        TriggerClientEvent('xprp:notify', src, line, 'info')
    end
end, false)

-- ── Net Event: xprp:setFaction (server-to-server or admin trigger) ────────────

RegisterNetEvent('xprp:setFaction', function(targetSrc, factionName, grade)
    local src = source
    if not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('xprp:notify', src, 'No permission.', 'error')
        return
    end

    if factionName ~= 'none' then
        if not Factions[factionName] then
            TriggerClientEvent('xprp:notify', src, 'Unknown faction.', 'error')
            return
        end
        grade = tonumber(grade) or 0
        if not Factions[factionName].grades[grade] then
            TriggerClientEvent('xprp:notify', src, 'Unknown grade.', 'error')
            return
        end
    else
        grade = 0
    end

    setPlayerFaction(targetSrc, factionName, grade)
end)

-- ── Faction Salary Payout ─────────────────────────────────────────────────────

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(FactionSalaryIntervalMinutes * 60 * 1000)
        local players = exports['xprp-core']:getPlayers()
        for src, player in pairs(players) do
            if player.faction and player.faction.name ~= 'none' then
                local gradeData = getFactionGrade(player.faction.name, player.faction.grade)
                if gradeData and gradeData.salary > 0 then
                    MySQL.query.await(
                        'UPDATE xprp_characters SET bank = bank + ? WHERE id = ?',
                        { gradeData.salary, player.charId }
                    )
                    player.bank = (player.bank or 0) + gradeData.salary
                    TriggerClientEvent('xprp:notify', src,
                        ('Faction salary paid: $%d'):format(gradeData.salary), 'success')
                end
            end
        end
    end
end)
