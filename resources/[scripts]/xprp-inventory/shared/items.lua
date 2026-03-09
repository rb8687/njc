-- =============================================================================
-- xprp-inventory | Shared – Item Definitions
-- =============================================================================

Items = {
    bread = {
        label    = 'Bread',
        weight   = 0.5,
        usable   = true,
        stackable = true,
    },
    water = {
        label    = 'Water Bottle',
        weight   = 0.3,
        usable   = true,
        stackable = true,
    },
    bandage = {
        label    = 'Bandage',
        weight   = 0.2,
        usable   = true,
        stackable = true,
    },
    phone = {
        label    = 'Phone',
        weight   = 0.1,
        usable   = true,
        stackable = false,
    },
    id_card = {
        label    = 'ID Card',
        weight   = 0.05,
        usable   = false,
        stackable = false,
    },
}

-- Maximum inventory weight (kg)
MaxWeight = 30.0
