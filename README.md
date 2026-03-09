# NJC xprp – FiveM Roleplay Server

A **FiveM xprp** (experience roleplay) server where players earn **XP and cash** for
play time on the server.

---

## Features

| Feature | Resource |
|---|---|
| Player accounts & character loading | `xprp-core` |
| One-time XP + cash reward for reaching playtime threshold | `xprp-playtime` |
| Faction-member shorter threshold (45 min vs 60 min) | `xprp-playtime` |
| Freeze/unfreeze player on connect | `spawnmanager` |

---

## XP & Cash Reward System (`xprp-playtime`)

Players receive a **one-time reward per session** once they have been connected
and have a character loaded for their required threshold.

### Thresholds and reward

| Player type | Required playtime | Reward |
|---|---|---|
| Regular player | **60 minutes** | **+25 XP**, **+$10,000 cash** |
| Faction member | **45 minutes** | **+25 XP**, **+$10,000 cash** |

The reward is paid out exactly once per login session.  
If a player disconnects before reaching the threshold, the clock resets on
their next session.

### Faction membership

A player is treated as a faction member when their active character's job
matches one of the jobs listed in `PlaytimeConfig.FactionJobs`.  
Default faction jobs: `police`, `mechanic`.  
Add any job name to the list to give it the shorter threshold.

### Tuning rewards

Edit `resources/[scripts]/xprp-playtime/shared/config.lua`:

```lua
PlaytimeConfig.RewardMinutes        = 60      -- threshold for regular players (minutes)
PlaytimeConfig.FactionRewardMinutes = 45      -- threshold for faction members (minutes)
PlaytimeConfig.RewardCash           = 10000   -- cash reward
PlaytimeConfig.RewardXp             = 25      -- XP reward
PlaytimeConfig.FactionJobs          = { 'police', 'mechanic' }
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
