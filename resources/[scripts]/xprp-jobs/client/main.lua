-- =============================================================================
-- xprp-jobs | Client – Job UI Feedback
-- =============================================================================

RegisterNetEvent('xprp:jobUpdated', function(jobData)
    local job       = Jobs[jobData.name]
    local gradeData = job and job.grades[jobData.grade]
    if job and gradeData then
        TriggerEvent('xprp:hudUpdate', exports['xprp-core']:getPlayerData())
    end
end)
