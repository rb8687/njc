# NJC xprp – FiveM Roleplay Server

A **FiveM xprp** (experience roleplay) server framework built in Lua.  
It provides player accounts, multi-character selection, a job system, an item inventory, a screen HUD, and a clean spawn manager — all ready to run on your own FiveM server instance.

---

## Features

| Feature | Resource |
|---|---|
| Player accounts & multi-character selection | `xprp-core` |
| Job system with salary payouts | `xprp-jobs` |
| Item inventory (add / remove / use) | `xprp-inventory` |
| In-game HUD (health, armour, cash, job) | `xprp-hud` |
| Spawn management | `spawnmanager` |

---

## Prerequisites

| Requirement | Notes |
|---|---|
| [FiveM Server](https://docs.fivem.net/docs/server-manual/setting-up-a-server/) | txAdmin or bare artifact |
| [MySQL 8.x](https://dev.mysql.com/downloads/) | or MariaDB 10.6+ |
| [oxmysql](https://github.com/overextended/oxmysql/releases) | async MySQL driver for FiveM |
| A [FiveM license key](https://keymaster.fivem.net/) | free for non-profit servers |

---

## Quick Start

### 1. Clone / copy this repository

```
git clone https://github.com/rb8687/njc.git
```

Place the contents in your FiveM server's root directory (alongside the `citizen/` folder).

### 2. Import the database schema

```sql
mysql -u root -p < sql/schema.sql
```

### 3. Install oxmysql

Download `oxmysql.zip` from the [releases page](https://github.com/overextended/oxmysql/releases), extract it to:

```
resources/[core]/oxmysql/
```

### 4. Configure `server.cfg`

Open `server.cfg` and update the following placeholders:

```cfg
sv_licenseKey "your_fivem_license_key"
set mysql_connection_string "mysql://root:yourpassword@localhost/njc_xprp?waitForConnections=true"
add_principal identifier.steam:YOUR_STEAM_HEX group.admin
```

> **Tip:** Find your Steam hex at https://steamid.io/ (use the "Steam64" value, convert to hex).

### 5. Start the server

```bash
./FXServer +exec server.cfg
```

---

## Resource Overview

```
resources/
├── [core]/
│   └── xprp-core/          # Accounts, characters, player data
├── [essentials]/
│   └── spawnmanager/       # Freeze/unfreeze on first connect
└── [scripts]/
    ├── xprp-hud/           # On-screen HUD (NUI)
    ├── xprp-inventory/     # Item storage and usage
    └── xprp-jobs/          # Job definitions and salary timer
```

---

## Adding Custom Items

Edit `resources/[scripts]/xprp-inventory/shared/items.lua`:

```lua
Items.pizza = {
    label     = 'Pizza Slice',
    weight    = 0.4,
    usable    = true,
    stackable = true,
}
```

Then handle the use event client-side in `xprp-inventory/client/main.lua`:

```lua
RegisterNetEvent('xprp:itemUsed', function(item)
    if item == 'pizza' then
        -- restore health, play animation, etc.
    end
end)
```

---

## Adding Custom Jobs

Edit `resources/[scripts]/xprp-jobs/shared/jobs.lua` and add a new entry to the `Jobs` table:

```lua
Jobs.taxi = {
    label  = 'Taxi Driver',
    grades = {
        [0] = { label = 'Driver',    salary = 150 },
        [1] = { label = 'Dispatcher', salary = 220 },
    },
}
```

You can also adjust the salary payout interval (default 30 minutes):

```lua
SalaryIntervalMinutes = 15  -- pay out every 15 minutes
```

---

## License

MIT – see [LICENSE](LICENSE) for details.
