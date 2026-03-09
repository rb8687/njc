-- =============================================================================
-- xprp-jobs | Shared – Job Definitions
-- =============================================================================

-- Salary payout interval in minutes (configurable per server)
SalaryIntervalMinutes = 30

Jobs = {
    unemployed = {
        label  = 'Unemployed',
        grades = {
            [0] = { label = 'Freelancer', salary = 0 },
        },
    },
    police = {
        label  = 'Police Department',
        grades = {
            [0] = { label = 'Cadet',        salary = 250 },
            [1] = { label = 'Officer',       salary = 350 },
            [2] = { label = 'Sergeant',      salary = 450 },
            [3] = { label = 'Lieutenant',    salary = 600 },
            [4] = { label = 'Chief',         salary = 800 },
        },
    },
    mechanic = {
        label  = 'Mechanic',
        grades = {
            [0] = { label = 'Apprentice',   salary = 200 },
            [1] = { label = 'Technician',   salary = 300 },
            [2] = { label = 'Specialist',   salary = 400 },
            [3] = { label = 'Supervisor',   salary = 500 },
        },
    },
}

--- Return grade data for a given job and grade number, or nil.
--- @param jobName  string
--- @param grade    number
--- @return table|nil
function getJobGrade(jobName, grade)
    local job = Jobs[jobName]
    if not job then return nil end
    return job.grades[grade]
end
