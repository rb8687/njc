-- =============================================================================
-- NPC Criminal Factions — Client-side UI helpers
-- Provides in-game text-based buy menu (no HTML/NUI file required).
-- If you wish to replace this with a full NUI panel just remove this file and
-- implement the HTML/CSS/JS in an `html/` directory.
-- =============================================================================

local menuOpen = false

-- ---------------------------------------------------------------------------
-- HUD hint — small on-screen text shown when near a supplier
-- ---------------------------------------------------------------------------
local hudVisible    = false
local hudFactionName = ''

function DisplayNpcFactionHud(show, factionName)
    hudVisible     = show
    hudFactionName = factionName or ''
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if hudVisible and not menuOpen then
            DrawText2D(0.5, 0.9,
                '~INPUT_PICKUP~ Buy drugs from ~y~' .. hudFactionName)
        end
    end
end)

-- ---------------------------------------------------------------------------
-- Simple text-based buy menu
-- Shows a list of available drugs with remaining stock and allows the player
-- to purchase by cycling with arrow keys and pressing Enter/E.
-- ---------------------------------------------------------------------------

local menuFaction = nil
local menuSupply  = {}
local menuItems   = {}
local menuSelected = 1

--- Build an ordered list of purchasable items from the faction + supply data.
local function buildMenuItems(faction, supply)
    local items = {}
    for _, drugKey in ipairs(faction.drugs) do
        local drug = Config.Drugs[drugKey]
        if drug then
            local stock = supply[drugKey] or 0
            table.insert(items, {
                drugKey  = drugKey,
                label    = drug.label,
                unit     = drug.unit,
                stock    = stock,
                price    = drug.pricePerUnit,
            })
        end
    end
    return items
end

--- Open the in-game supply menu for the given faction and supply table.
function OpenSupplyMenu(faction, supply)
    if not faction or not supply then return end

    menuFaction  = faction
    menuSupply   = supply
    menuItems    = buildMenuItems(faction, supply)
    menuSelected = 1
    menuOpen     = true

    -- Run the interactive menu loop
    Citizen.CreateThread(function()
        local quantity = 1

        while menuOpen do
            Wait(0)

            -- Draw the menu background overlay
            DrawRect(0.5, 0.5, 0.45, 0.6, 0, 0, 0, 180)

            -- Title
            DrawText2D(0.5, 0.22, ('~y~%s ~w~— Drug Wholesale'):format(faction.name))
            DrawText2D(0.5, 0.26,
                ('Qty: ~b~%d~w~  (←/→ adjust, ↑/↓ item, ~INPUT_PICKUP~ buy, ~INPUT_FRONTEND_CANCEL~ close)'):format(quantity))

            -- Items list
            for i, item in ipairs(menuItems) do
                local yPos    = 0.32 + (i - 1) * 0.05
                local color   = (i == menuSelected) and '~g~' or '~w~'
                local prefix  = (i == menuSelected) and '► ' or '  '
                local stockTxt = (item.stock <= 0) and '~r~OUT OF STOCK' or
                    ('Stock: ~b~%d %s'):format(item.stock, item.unit)
                DrawText2D(0.5, yPos,
                    ('%s%s%s  $%s/%s  |  %s'):format(
                        prefix, color, item.label,
                        FormatMoney(item.price), item.unit,
                        stockTxt))
            end

            -- ── Controls ──────────────────────────────────────────────────

            -- Navigate up/down
            if IsControlJustReleased(0, 172) then  -- UP arrow
                menuSelected = math.max(1, menuSelected - 1)
                Wait(150)
            elseif IsControlJustReleased(0, 173) then  -- DOWN arrow
                menuSelected = math.min(#menuItems, menuSelected + 1)
                Wait(150)
            end

            -- Adjust quantity left/right
            if IsControlJustReleased(0, 174) then  -- LEFT arrow
                quantity = math.max(1, quantity - 1)
                Wait(100)
            elseif IsControlJustReleased(0, 175) then  -- RIGHT arrow
                quantity = math.min(Config.MaxBuyPerTransaction, quantity + 1)
                Wait(100)
            end

            -- Buy (E key / INPUT_PICKUP = 38)
            if IsControlJustReleased(0, 38) then
                local item = menuItems[menuSelected]
                if item and item.stock > 0 then
                    local finalQty = math.min(quantity, item.stock)
                    TriggerServerEvent('njc:buyDrug',
                        faction.id, item.drugKey, finalQty, false)
                    menuOpen = false
                else
                    ShowNotification('~r~This item is out of stock.')
                end
                Wait(200)
            end

            -- Close (Escape / FRONTEND_CANCEL = 200)
            if IsControlJustReleased(0, 200) then
                menuOpen = false
                Wait(200)
            end
        end
    end)
end

-- Called by supplyUpdate event to refresh stock figures while menu is open
function RefreshMenuStock(drugKey, remaining)
    if not menuOpen then return end
    menuSupply[drugKey] = remaining
    for _, item in ipairs(menuItems) do
        if item.drugKey == drugKey then
            item.stock = remaining
            break
        end
    end
end

-- ---------------------------------------------------------------------------
-- Drawing helpers (GTA5 native wrappers)
-- ---------------------------------------------------------------------------

function DrawText2D(x, y, text)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 220)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentSubstringPlayerName(text)
    DrawText(x, y)
end

function FormatMoney(n)
    local s = tostring(math.floor(n))
    local result = ''
    local len = #s
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then
            result = result .. ','
        end
        result = result .. s:sub(i, i)
    end
    return result
end
