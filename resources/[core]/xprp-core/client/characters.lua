-- =============================================================================
-- xprp-core | Client – Character Selection / Creation UI
-- =============================================================================

-- ── Open Character Creation ───────────────────────────────────────────────────

AddEventHandler('xprp:openCharacterCreation', function()
    -- In production this would open a NUI overlay; here we auto-create a demo char.
    local data = {
        firstname = 'John',
        lastname  = 'Doe',
        dob       = '1990-06-15',
        gender    = 'male',
    }
    TriggerServerEvent('xprp:createCharacter', data)
end)

-- ── Notify ────────────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:notify', function(message, notifType)
    notifType = notifType or 'info'
    local colors = { info = '~b~', success = '~g~', warn = '~y~', error = '~r~' }
    local color  = colors[notifType] or '~w~'
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(color .. message)
    EndTextCommandThefeedPostTicker(false, true)
end)
