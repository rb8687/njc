# NJC xprp – FiveM Roleplay Server

A **FiveM xprp** (experience roleplay) server where players earn **XP and cash** for
play time and clean gameplay.

---

## Features

| Feature | Resource |
|---|---|
| Player accounts & character loading | `xprp-core` |
| XP + cash rewards for play time | `xprp-playtime` |
| Clean-gameplay bonus (infraction-free session) | `xprp-playtime` |
| Freeze/unfreeze player on connect | `spawnmanager` |

---

## XP & Cash Reward System (`xprp-playtime`)

Players accumulate XP and cash while they are connected and have a character loaded.

### How it works

| Trigger | Reward |
|---|---|
| Every **5 minutes** of playtime | **+50 XP**, **+$250 cash** |
| Clean session (≥10 min, no infractions) | Additional **+25 XP**, **+$125 cash** per interval |

All values are configurable in  
`resources/[scripts]/xprp-playtime/shared/config.lua`.

### Clean gameplay

A session is considered *clean* until an admin (or another resource) fires the
`xprp:playtime:recordInfraction` server event:

```lua
-- From any server-side script
TriggerEvent('xprp:playtime:recordInfraction', targetSrc, 'rule violation')
```

Admins can also flag a player from the client with the ACE-protected net-event:

```lua
-- From a client-side admin script
TriggerServerEvent('xprp:playtime:adminInfraction', targetSrc, 'reason')
```

---

## Setup

### Prerequisites

* [FiveM server artifact](https://runtime.fivem.net/artifacts/fivem/)
* MySQL 5.7+ or MariaDB 10.3+
* [oxmysql](https://github.com/overextended/oxmysql) resource

### Steps

1. Import `sql/schema.sql` into your database.
2. Copy all `resources/` folders to your FiveM server's `resources/` directory.
3. Edit `server.cfg`:
   - Set `sv_licenseKey` (from [keymaster.fivem.net](https://keymaster.fivem.net/))
   - Set `mysql_connection_string` with your DB credentials
4. Start the server.

### Tuning rewards

Edit `resources/[scripts]/xprp-playtime/shared/config.lua`:

```lua
PlaytimeConfig.IntervalMinutes    = 5    -- how often rewards are paid out
PlaytimeConfig.BaseXp             = 50   -- XP per interval
PlaytimeConfig.BaseCash           = 250  -- cash per interval
PlaytimeConfig.CleanBonusXp       = 25   -- bonus XP for clean gameplay
PlaytimeConfig.CleanBonusCash     = 125  -- bonus cash for clean gameplay
PlaytimeConfig.CleanMinimumMinutes = 10  -- min session minutes before bonus kicks in
```
