-- =============================================================================
-- xprp-core | Server – Character Management
-- =============================================================================

-- ── Fetch Characters ──────────────────────────────────────────────────────────

RegisterNetEvent('xprp:requestCharacters', function()
    local src     = source
    local license = GetPlayerIdentifierByType(src, 'license')

    local accountId = MySQL.scalar.await(
        'SELECT id FROM xprp_accounts WHERE license = ?',
        { license }
    )

    if not accountId then
        TriggerClientEvent('xprp:notify', src, 'Account not found.', 'error')
        return
    end

    local chars = MySQL.query.await(
        'SELECT id, firstname, lastname, dob, gender FROM xprp_characters WHERE account_id = ?',
        { accountId }
    )

    TriggerClientEvent('xprp:receiveCharacters', src, chars or {})
end)

-- ── Create Character ─────────────────────────────────────────────────────────

RegisterNetEvent('xprp:createCharacter', function(data)
    local src     = source
    local license = GetPlayerIdentifierByType(src, 'license')

    -- Basic server-side validation
    if type(data.firstname) ~= 'string' or #data.firstname < 2
    or type(data.lastname)  ~= 'string' or #data.lastname  < 2 then
        TriggerClientEvent('xprp:notify', src, 'Invalid character name.', 'error')
        return
    end

    local accountId = MySQL.scalar.await(
        'SELECT id FROM xprp_accounts WHERE license = ?',
        { license }
    )

    local count = MySQL.scalar.await(
        'SELECT COUNT(*) FROM xprp_characters WHERE account_id = ?',
        { accountId }
    )

    if count >= Config.MaxCharacters then
        TriggerClientEvent('xprp:notify', src, 'Maximum characters reached.', 'error')
        return
    end

    MySQL.insert.await(
        [[INSERT INTO xprp_characters
          (account_id, firstname, lastname, dob, gender, cash, bank, job, job_grade, faction, faction_grade, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, 'unemployed', 0, 'none', 0, NOW())]],
        {
            accountId,
            data.firstname,
            data.lastname,
            data.dob    or '2000-01-01',
            data.gender or 'male',
            Config.StartingMoney.cash,
            Config.StartingMoney.bank,
        }
    )

    TriggerClientEvent('xprp:notify', src, 'Character created!', 'success')

    -- Refresh the character list on the client
    local updatedChars = MySQL.query.await(
        'SELECT id, firstname, lastname, dob, gender FROM xprp_characters WHERE account_id = ?',
        { accountId }
    )
    TriggerClientEvent('xprp:receiveCharacters', src, updatedChars or {})
end)

-- ── Delete Character ─────────────────────────────────────────────────────────

RegisterNetEvent('xprp:deleteCharacter', function(charId)
    local src     = source
    local license = GetPlayerIdentifierByType(src, 'license')

    local accountId = MySQL.scalar.await(
        'SELECT id FROM xprp_accounts WHERE license = ?',
        { license }
    )

    MySQL.query.await(
        'DELETE FROM xprp_characters WHERE id = ? AND account_id = ?',
        { charId, accountId }
    )

    TriggerClientEvent('xprp:notify', src, 'Character deleted.', 'info')
end)
