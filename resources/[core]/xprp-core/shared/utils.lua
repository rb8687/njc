-- =============================================================================
-- xprp-core | Shared Utilities
-- =============================================================================

--- Simple debug-aware logging helper.
--- @param msg string
--- @param level? string  'info' | 'warn' | 'error'
function xprp_log(msg, level)
    if not Config.Debug and (level == nil or level == 'info') then return end
    local prefix = ('[xprp][%s] '):format(level or 'info')
    print(prefix .. tostring(msg))
end

--- Deep-copy a table.
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
