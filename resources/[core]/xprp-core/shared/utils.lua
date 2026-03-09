-- =============================================================================
-- xprp-core | Shared – Utilities
-- =============================================================================

--- Log helper respects Config.Debug flag.
--- @param msg    string
--- @param level  string  'info' | 'warn' | 'error'
function xprp_log(msg, level)
    level = level or 'info'
    if level == 'info' and not Config.Debug then return end
    local prefix = ('[xprp][%s] '):format(level:upper())
    print(prefix .. tostring(msg))
end

--- Deep-copy a table.
--- Note: tables that reference themselves (cycles) will cause a stack overflow.
--- Only use this on plain data tables that are guaranteed to be acyclic.
--- @param orig table
--- @return table
function xprp_deepcopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[xprp_deepcopy(k)] = xprp_deepcopy(v)
        end
        setmetatable(copy, xprp_deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
