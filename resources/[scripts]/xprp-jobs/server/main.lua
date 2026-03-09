-- =============================================================================
-- xprp-jobs | Server – Job Assignment & Salary
-- =============================================================================

-- ── Set Job ───────────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:setJob', function(targetSrc, jobName, grade)
    local src = source
    -- Only allow admins or on-duty police supervisors (extend as needed)
    if not IsPlayerAceAllowed(src, 'command') then
        TriggerClientEvent('xprp:notify', src, 'No permission.', 'error')
        return
    end

    if not Jobs[jobName] then
        TriggerClientEvent('xprp:notify', src, 'Unknown job.', 'error')
        return
    end

    grade = tonumber(grade) or 0
    if not Jobs[jobName].grades[grade] then
        TriggerClientEvent('xprp:notify', src, 'Unknown grade.', 'error')
        return
    end

    MySQL.query.await(
        'UPDATE xprp_characters SET job = ?, job_grade = ? WHERE id = (SELECT charId FROM xprp_session WHERE src = ?)',
        { jobName, grade, targetSrc }
    )

    local player = exports['xprp-core']:getPlayer(targetSrc)
    if player then
        player.job = { name = jobName, grade = grade }
        TriggerClientEvent('xprp:jobUpdated', targetSrc, player.job)
        TriggerClientEvent('xprp:notify', targetSrc,
            ('Your job is now: %s (%s)'):format(Jobs[jobName].label, Jobs[jobName].grades[grade].label),
            'success')
    end
end)

-- ── Salary Payout (configurable interval) ────────────────────────────────────

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(SalaryIntervalMinutes * 60 * 1000)
        local players = exports['xprp-core']:getPlayers()
        for src, player in pairs(players) do
            local gradeData = getJobGrade(player.job.name, player.job.grade)
            if gradeData and gradeData.salary > 0 then
                player.bank = (player.bank or 0) + gradeData.salary
                MySQL.query.await(
                    'UPDATE xprp_characters SET bank = ? WHERE id = ?',
                    { player.bank, player.charId }
                )
                TriggerClientEvent('xprp:notify', src,
                    ('Salary paid: $%d'):format(gradeData.salary), 'success')
            end
        end
    end
end)
