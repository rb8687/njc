-- =============================================================================
-- xprp-core | Server – Player Management
-- =============================================================================

xprp.Players = {}

-- ── Helpers ──────────────────────────────────────────────────────────────────

local function getOrCreateAccount(license)
    local result = MySQL.scalar.await(
        'SELECT id FROM xprp_accounts WHERE license = ?',
        { license }
    )
    if result then return result end

    return MySQL.insert.await(
        'INSERT INTO xprp_accounts (license, created_at) VALUES (?, NOW())',
        { license }
    )
end

-- ── Player Connect ────────────────────────────────────────────────────────────

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local src     = source
    local license = GetPlayerIdentifierByType(src, 'license')

    if not license then
        setKickReason('Could not retrieve your Rockstar license. Please reconnect.')
        CancelEvent()
        return
    end

    deferrals.defer()
    deferrals.update('Authenticating – please wait…')

    local accountId = getOrCreateAccount(license)
    xprp_log(('Player %s (src %d) account id: %d'):format(name, src, accountId))

    deferrals.done()
end)

-- ── Player Dropped ────────────────────────────────────────────────────────────

AddEventHandler('playerDropped', function(reason)
    local src = source
    if xprp.Players[src] then
        xprp_log(('Player src %d dropped: %s'):format(src, reason))
        TriggerEvent('xprp:playerDropped', src, xprp.Players[src])
        xprp.Players[src] = nil
    end
end)

-- ── Network Events ────────────────────────────────────────────────────────────

RegisterNetEvent('xprp:playerLoaded', function(charId)
    local src       = source
    local license   = GetPlayerIdentifierByType(src, 'license')
    local accountId = MySQL.scalar.await(
        'SELECT id FROM xprp_accounts WHERE license = ?',
        { license }
    )

    local char = MySQL.single.await(
        'SELECT * FROM xprp_characters WHERE id = ? AND account_id = ?',
        { charId, accountId }
    )

    if not char then
        TriggerClientEvent('xprp:notify', src, 'Character not found.', 'error')
        return
    end

    xprp.Players[src] = {
        source       = src,
        license      = license,
        accountId    = accountId,
        charId       = char.id,
        name         = char.firstname .. ' ' .. char.lastname,
        cash         = char.cash          or Config.StartingMoney.cash,
        bank         = char.bank          or Config.StartingMoney.bank,
        xp           = char.xp            or 0,
        playtimeSecs = char.playtime_secs or 0,
    }

    TriggerClientEvent('xprp:playerReady', src, xprp.Players[src])
    TriggerEvent('xprp:playerLoaded', src, xprp.Players[src])
    xprp_log(('Character "%s" loaded for src %d'):format(xprp.Players[src].name, src))
end)
