local Character = {}

-- Player 1 Palette (Classic Dark Slate / Navy Ninja - Exact Match)
Character.paletteP1 = {
    [1] = {0.05, 0.07, 0.11}, -- Darkest Outline / Shadows
    [2] = {0.10, 0.16, 0.22}, -- Suit Base (Dark Navy)
    [3] = {0.20, 0.32, 0.40}, -- Suit Highlight (Slate Blue)
    [4] = {0.96, 0.70, 0.50}, -- Skin Base (Peach)
    [5] = {0.82, 0.54, 0.36}, -- Skin Shadow
    [6] = {0.02, 0.02, 0.04}  -- Eye Pixels
}

Character.palettes = {
    -- 1: Original (Navy)
    Character.paletteP1,
    -- 2: Purple / Dark Skin
    {
        [1] = {0.12, 0.05, 0.15},
        [2] = {0.35, 0.15, 0.45},
        [3] = {0.55, 0.25, 0.65},
        [4] = {0.45, 0.30, 0.20},
        [5] = {0.30, 0.18, 0.12},
        [6] = {0.90, 0.90, 0.90}
    },
    -- 3: White Ninja / Black Belt
    {
        [1] = {0.10, 0.10, 0.12},
        [2] = {0.80, 0.80, 0.85},
        [3] = {1.00, 1.00, 1.00},
        [4] = {0.96, 0.70, 0.50},
        [5] = {0.82, 0.54, 0.36},
        [6] = {0.00, 0.00, 0.00}
    },
    -- 4: Shinobi Black / White Eyes
    {
        [1] = {0.00, 0.00, 0.00},
        [2] = {0.15, 0.15, 0.15},
        [3] = {0.30, 0.30, 0.30},
        [4] = {0.96, 0.70, 0.50},
        [5] = {0.82, 0.54, 0.36},
        [6] = {1.00, 1.00, 1.00}
    },
    -- 5: Orange Ninja / Brown Skin
    {
        [1] = {0.15, 0.05, 0.05},
        [2] = {0.85, 0.45, 0.10},
        [3] = {1.00, 0.60, 0.20},
        [4] = {0.55, 0.35, 0.25},
        [5] = {0.35, 0.20, 0.15},
        [6] = {0.00, 0.00, 0.00}
    }
}

-- Player 2 Palette (Crimson Red Ninja)
Character.paletteP2 = {
    [1] = {0.12, 0.03, 0.05}, -- Darkest Outline
    [2] = {0.35, 0.08, 0.12}, -- Suit Base (Dark Crimson)
    [3] = {0.60, 0.18, 0.22}, -- Suit Highlight (Scarlet)
    [4] = {0.96, 0.70, 0.50}, -- Skin Base
    [5] = {0.82, 0.54, 0.36}, -- Skin Shadow
    [6] = {0.02, 0.02, 0.04}  -- Eye Pixels
}

Character.palettes = {
    Character.paletteP1,
    { -- 2: Purple / Dark Skin
        [1] = {0.12, 0.05, 0.15}, [2] = {0.35, 0.15, 0.45}, [3] = {0.55, 0.25, 0.65},
        [4] = {0.45, 0.30, 0.20}, [5] = {0.30, 0.18, 0.12}, [6] = {0.90, 0.90, 0.90}
    },
    { -- 3: White Ninja / Black Belt
        [1] = {0.10, 0.10, 0.12}, [2] = {0.80, 0.80, 0.85}, [3] = {1.00, 1.00, 1.00},
        [4] = {0.96, 0.70, 0.50}, [5] = {0.82, 0.54, 0.36}, [6] = {0.00, 0.00, 0.00}
    },
    { -- 4: Shinobi Black / White Eyes
        [1] = {0.00, 0.00, 0.00}, [2] = {0.15, 0.15, 0.15}, [3] = {0.30, 0.30, 0.30},
        [4] = {0.96, 0.70, 0.50}, [5] = {0.82, 0.54, 0.36}, [6] = {1.00, 1.00, 1.00}
    },
    { -- 5: Orange Ninja / Brown Skin
        [1] = {0.15, 0.05, 0.05}, [2] = {0.85, 0.45, 0.10}, [3] = {1.00, 0.60, 0.20},
        [4] = {0.55, 0.35, 0.25}, [5] = {0.35, 0.20, 0.15}, [6] = {0.00, 0.00, 0.00}
    }
}

Character.frames = {}

-- Idle Fighting Stance - Frame 1: Neutral Planted Combat Guard (18x20)
Character.frames["stand"] = {
    {0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,2,3,3,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,3,3,2,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,6,4,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0,0},
    {0,0,0,1,1,1,0,1,2,2,2,1,0,1,1,1,0,0},
    {0,0,1,4,4,4,1,1,2,2,2,1,1,4,4,5,1,0},
    {0,0,1,5,4,1,2,2,3,3,2,2,1,5,4,1,0,0},
    {0,0,0,1,1,2,3,3,2,2,3,3,2,1,1,0,0,0},
    {0,0,0,0,1,2,2,3,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,0,1,1,2,2,1,1,2,2,1,1,0,0,0,0},
    {0,0,0,0,1,2,2,2,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,2,1,0,0,1,2,2,2,1,0,0,0},
    {0,0,1,2,2,2,1,0,0,0,0,1,2,2,2,1,0,0},
    {0,0,1,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,2,1,0,0,0,0,0,1,2,2,2,1,0,0},
    {1,2,2,2,2,1,0,0,0,0,0,1,2,2,2,2,1,0},
    {1,2,2,2,2,2,1,0,0,0,1,2,2,2,2,2,1,0},
    {1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0}
}

-- Idle Frame 2: Inhale / Torso & Shoulder Elevation
Character.frames["idle_2"] = {
    {0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,2,3,3,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,3,3,2,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,6,4,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0,0},
    {0,0,0,1,1,1,0,1,2,2,2,1,0,1,1,1,0,0},
    {0,0,1,4,4,4,1,1,3,3,3,1,1,4,4,5,1,0},
    {0,0,1,5,4,1,2,3,3,3,3,2,1,5,4,1,0,0},
    {0,0,0,1,1,2,3,3,3,3,3,3,2,1,1,0,0,0},
    {0,0,0,0,1,2,2,3,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,0,1,1,2,2,1,1,2,2,1,1,0,0,0,0},
    {0,0,0,0,1,2,2,2,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,2,1,0,0,1,2,2,2,1,0,0,0},
    {0,0,1,2,2,2,1,0,0,0,0,1,2,2,2,1,0,0},
    {0,0,1,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,2,1,0,0,0,0,0,1,2,2,2,1,0,0},
    {1,2,2,2,2,1,0,0,0,0,0,1,2,2,2,2,1,0},
    {1,2,2,2,2,2,1,0,0,0,1,2,2,2,2,2,1,0},
    {1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0}
}

-- Idle Frame 3: Peak Breath / Rear Weight Shift
Character.frames["idle_3"] = {
    {0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,2,2,3,3,2,1,0,0,0,0},
    {0,0,0,0,0,0,0,1,2,3,3,2,2,1,0,0,0,0},
    {0,0,0,0,0,0,0,1,2,4,6,4,2,1,0,0,0,0},
    {0,0,0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0},
    {0,0,0,0,1,1,1,0,1,2,2,2,1,0,1,1,1,0},
    {0,0,0,1,4,4,4,1,1,3,3,3,1,1,4,4,5,1},
    {0,0,0,1,5,4,1,2,3,3,3,3,2,1,5,4,1,0},
    {0,0,0,0,1,1,2,3,3,3,3,3,2,1,1,0,0,0},
    {0,0,0,0,0,1,2,2,3,2,2,2,2,1,0,0,0,0},
    {0,0,0,0,0,1,1,2,2,1,1,2,2,1,1,0,0,0},
    {0,0,0,0,0,1,2,2,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,0,1,2,2,2,1,0,0,1,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,1,0,0,0,1,2,2,2,1,0,0},
    {0,0,0,1,2,2,1,0,0,0,0,0,1,2,2,1,0,0},
    {0,0,1,2,2,2,1,0,0,0,0,0,1,2,2,1,0,0},
    {0,0,1,2,2,2,1,0,0,0,0,1,2,2,2,1,0,0},
    {0,1,2,2,2,2,1,0,0,0,0,1,2,2,2,2,1,0},
    {0,1,2,2,2,2,1,0,0,0,1,2,2,2,2,2,1,0},
    {0,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0}
}

-- Idle Frame 4: Exhale / Settle Into Spring Coil
Character.frames["idle_4"] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,2,3,3,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,3,3,2,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,6,4,2,1,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,4,4,4,2,1,0,0,0,0,0},
    {0,0,0,1,1,1,0,1,2,2,2,1,0,1,1,1,0,0},
    {0,0,1,4,4,4,1,1,2,2,2,1,1,4,4,5,1,0},
    {0,0,1,5,4,1,2,2,3,3,2,2,1,5,4,1,0,0},
    {0,0,0,1,1,2,3,3,2,2,3,3,2,1,1,0,0,0},
    {0,0,0,0,1,2,2,3,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,0,1,1,2,2,1,1,2,2,1,1,0,0,0,0},
    {0,0,0,0,1,2,2,2,2,2,2,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,2,1,0,0,1,2,2,2,1,0,0,0},
    {0,0,1,2,2,2,2,1,0,0,1,2,2,2,2,1,0,0},
    {0,1,2,2,2,2,1,0,0,0,0,1,2,2,2,2,1,0},
    {0,1,2,2,2,1,0,0,0,0,0,0,1,2,2,2,1,0},
    {1,2,2,2,2,1,0,0,0,0,0,0,1,2,2,2,2,1},
    {1,2,2,2,2,2,1,0,0,0,1,2,2,2,2,2,1,0},
    {1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,0}
}

-- Ninja Dash / Running Frames (4-frame cycle)
Character.frames["run_1"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,0,0,1,1,0,1,2,2,2,2,2,2,1,0,0},
    {0,1,2,2,1,2,3,3,2,2,2,2,2,1,0,0},
    {1,2,2,1,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,1,1,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,4,4},
    {0,0,1,4,4,2,2,2,1,1,2,2,2,1,4,5},
    {0,1,4,4,1,2,2,2,1,1,2,2,2,1,0,0},
    {0,0,1,1,1,2,2,2,2,2,2,1,1,0,0,0},
    {0,0,0,1,2,2,1,1,1,2,2,1,0,0,0,0},
    {0,0,1,2,2,1,0,0,1,2,2,1,0,0,0,0},
    {0,1,2,2,1,0,0,0,0,1,2,2,1,0,0,0},
    {0,1,2,1,0,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,1,1,0,0,0,0,0,0,1,1,1,1,0,0}
}

Character.frames["run_2"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,2,1,2,2,2,2,1,0,0},
    {0,0,0,1,4,4,2,2,1,2,2,4,4,1,0,0},
    {0,0,0,1,4,5,2,2,2,2,2,4,5,1,0,0},
    {0,0,0,0,1,1,2,2,2,1,1,1,1,0,0,0},
    {0,0,0,0,0,1,2,2,2,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,2,2,1,0,0,0,0,0,0},
    {0,0,0,0,1,2,2,1,2,2,1,0,0,0,0,0},
    {0,0,0,0,1,1,1,0,1,1,1,0,0,0,0,0}
}

Character.frames["run_3"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,0,0,1,1,0,1,2,2,2,2,2,2,1,0,0},
    {0,1,2,2,1,2,3,3,2,2,2,2,2,1,0,0},
    {1,2,2,1,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,1,1,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,4,4,2,2,2,1,1,2,2,2,2,1,0},
    {0,1,4,4,1,2,2,2,1,2,2,2,4,4,1,0},
    {0,0,1,1,1,2,2,2,2,2,2,4,4,5,1,0},
    {0,0,0,1,2,2,1,1,1,2,2,1,1,1,0,0},
    {0,0,0,1,2,2,1,0,1,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,0,1,2,2,1,0,0,0,1,2,2,1,0,0},
    {0,0,0,1,1,1,1,0,0,0,0,1,1,1,0,0}
}

Character.frames["run_4"] = Character.frames["run_2"]

-- Dynamic Jump with Knee Tucked
Character.frames["jump"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,0,0,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {0,1,1,0,1,2,3,3,2,2,2,2,2,1,0,0},
    {1,2,2,1,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,1,1,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,4,4,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,4,5,1,2,2,2,2,2,1,4,4,1,0},
    {0,0,0,1,1,1,2,2,2,2,1,0,4,5,1,0},
    {0,0,0,0,1,2,2,1,2,2,2,1,1,1,0,0},
    {0,0,0,1,2,2,1,0,1,2,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,1,2,2,1,0,0,0},
    {0,1,2,2,1,0,0,0,0,0,1,2,2,1,0,0},
    {0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}

-- Straight Punch Jab
Character.frames["punch"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,1,1,1},
    {0,1,2,2,2,2,2,2,1,2,2,2,2,4,4,4},
    {1,2,2,1,2,2,2,1,1,1,2,2,2,5,5,5},
    {1,2,1,0,1,4,4,2,1,2,2,2,2,1,1,1},
    {0,1,0,0,1,4,5,1,2,2,2,1,1,0,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,1,0,0,0,0,0,0,1,2,2,1,0},
    {0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0}
}

-- Uppercut (Rising Fist Strike)
Character.frames["uppercut"] = {
    {0,0,0,0,0,0,0,0,0,0,1,1,1,4,4,4},
    {0,0,0,0,0,0,1,1,1,1,2,2,2,5,5,5},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,1,1,1},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,1,2,2,2,2,2,2,1,2,2,2,2,2,1,0},
    {1,2,2,1,2,2,2,1,1,1,2,2,2,2,1,0},
    {1,2,1,0,1,4,4,2,1,2,2,2,2,1,0,0},
    {0,1,0,0,1,4,5,1,2,2,2,1,1,0,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,1,2,2,1,0,0},
    {0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0}
}

-- Lowercut (Crouched Uppercut)
Character.frames["lowercut"] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,1,1},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,4,4,4},
    {0,1,2,2,2,2,2,2,1,2,2,2,2,5,5,5},
    {1,2,2,1,2,2,2,1,1,1,2,2,2,1,1,1},
    {1,2,1,0,1,4,4,2,1,2,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,1,2,2,1,0,0},
    {0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0}
}

-- Low Kick (Leg Sweep)
Character.frames["low_kick"] = {
    {0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0},
    {0,0,0,1,1,0,0,1,2,2,2,2,2,2,1,0},
    {0,0,1,2,2,1,1,2,3,3,2,2,2,2,2,1},
    {0,0,0,1,1,2,1,2,2,2,2,2,2,2,2,1},
    {0,0,0,0,1,1,1,2,4,4,4,4,4,4,2,1},
    {0,0,0,0,0,0,1,2,4,6,4,4,6,4,2,1},
    {0,0,0,0,0,0,1,2,4,4,4,4,4,4,2,1},
    {0,0,0,0,0,0,1,1,2,2,2,2,2,2,1,1},
    {0,0,0,0,1,1,2,2,2,2,2,2,2,2,2,1},
    {0,0,0,1,2,2,2,2,2,2,1,2,2,2,2,2},
    {0,0,1,2,2,1,2,2,2,1,1,1,2,2,2,2},
    {0,0,1,2,1,0,1,4,4,2,1,2,2,2,2,1},
    {0,0,0,1,0,0,1,4,5,1,2,2,2,1,1,0},
    {0,0,0,0,0,1,2,2,2,1,2,2,2,1,0,0},
    {0,0,0,0,1,2,2,2,1,0,0,0,0,0,0,0},
    {0,0,0,0,1,2,2,1,0,0,0,0,0,0,0,0},
    {0,0,0,1,2,2,1,1,1,1,1,1,1,1,1,1},
    {0,0,0,1,1,1,1,2,2,2,2,2,2,2,2,1}
}

-- High Kick (Snap Kick)
Character.frames["high_kick"] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,1,1,1,1,1,1,0,0,0,1,1,1},
    {1,1,0,0,1,2,2,2,2,2,2,0,1,2,2,1},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,2,2,1},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,1,0},
    {0,1,1,1,2,4,4,4,4,4,4,0,2,1,0,0},
    {0,0,1,2,4,6,4,4,6,4,2,0,2,1,0,0},
    {0,0,1,2,4,4,4,4,4,4,2,0,2,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,1,0,1,1,0,0},
    {0,1,1,2,2,2,2,2,2,2,2,2,2,1,0,0},
    {1,2,2,2,2,2,2,1,2,2,2,2,2,1,4},
    {2,2,1,2,2,2,1,1,1,2,2,2,2,1,4},
    {2,1,0,1,4,4,2,1,2,2,2,2,1,0,0},
    {1,0,0,1,4,5,1,2,2,2,1,1,0,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0},
    {0,1,2,2,1,0,0,0,0,0,0,0,0,0,0,0},
    {0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0}
}

-- Jump Punch
Character.frames["jump_punch"] = {
    {0,1,1,0,0,1,1,1,1,1,1,0,0,0,0,0},
    {1,2,2,1,1,2,2,2,2,2,2,1,0,0,0,0},
    {0,1,1,2,1,2,3,3,2,2,2,2,1,0,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,0,1,2,2,2,2,2,2,2,2,2,1,1,1},
    {0,0,1,2,2,2,2,2,2,2,2,2,2,4,4,4},
    {0,1,2,2,1,2,2,2,2,2,2,1,2,5,5,5},
    {0,1,4,1,0,1,2,2,2,2,1,0,1,1,1,1},
    {0,0,1,0,0,0,1,1,1,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,2,2,2,1,0,0,0,0,0},
    {0,0,0,0,1,2,2,1,1,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,0,1,1,1,0,0,0,0,1,1,1,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
}

-- 1. High Block (Protecting Head and Upper Chest)
Character.frames["block_high"] = {
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,0,0,1,1,2,3,3,3,3,2,1,1,0,0},
    {0,0,1,1,2,2,3,4,5,4,3,2,2,1,0,0},
    {0,1,2,2,2,2,1,4,5,4,1,2,2,2,1,0},
    {1,2,2,1,2,2,2,1,1,1,2,2,2,2,1,0},
    {1,2,1,0,1,2,2,2,1,2,2,2,2,1,0,0},
    {0,1,0,0,1,2,2,1,2,2,2,1,1,0,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,1,2,2,1,0,0},
    {0,1,2,2,1,0,0,0,0,0,0,1,2,2,1,0},
    {0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0}
}

-- 2. Low Block (Crouched Guard Covering Legs and Midsection)
Character.frames["block_low"] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0},
    {0,1,1,0,0,1,2,2,2,2,2,2,1,0,0,0},
    {1,2,2,1,1,2,3,3,2,2,2,2,2,1,0,0},
    {0,1,1,2,1,2,2,2,2,2,2,2,2,1,0,0},
    {0,0,1,1,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,2,4,6,4,4,6,4,2,1,0,0},
    {0,0,0,0,1,2,4,4,4,4,4,4,2,1,0,0},
    {0,0,0,0,1,1,2,2,2,2,2,2,1,1,0,0},
    {0,0,1,1,2,2,2,2,2,2,2,2,2,1,0,0},
    {0,1,2,2,2,2,1,3,3,3,1,2,2,2,1,0},
    {1,2,2,1,2,2,2,4,5,4,2,2,2,2,1,0},
    {1,2,1,0,1,2,2,1,1,1,2,2,2,1,0,0},
    {0,0,0,1,2,2,2,1,2,2,2,1,0,0,0,0},
    {0,0,1,2,2,2,1,0,0,1,2,2,1,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,1,2,2,1,0,0},
    {0,1,1,1,1,0,0,0,0,0,0,1,1,1,1,0}
}

-- Fallback for states requiring legacy support (hit_stun, dizzy, ko)
Character.frames["hit_stun"] = Character.frames["stand"]
Character.frames["dizzy"]    = Character.frames["stand"]
Character.frames["block"]    = Character.frames["block_high"]
Character.frames["ko"]       = Character.frames["stand"]
Character.frames["kick"]     = Character.frames["high_kick"]
Character.frames["dive"]     = Character.frames["jump_punch"]

-- ANIMATION DICTIONARY
Character.animations = {
    idle         = { frames = {"stand", "idle_2", "idle_3", "idle_4"}, speed = 0.16, loop = true },
    run          = { frames = {"run_1", "run_2", "run_3", "run_4"}, speed = 0.08, loop = true },
    jump         = { frames = {"jump"}, speed = 1, loop = false },
    kick         = { frames = {"high_kick"}, speed = 0.2, loop = false },
    dive         = { frames = {"jump_punch"}, speed = 1, loop = false },
    flip         = { frames = {"jump"}, speed = 0.08, loop = true, autoRotate = 360 },
    backflip     = { frames = {"jump"}, speed = 0.08, loop = true, autoRotate = -360 },
    
    punch        = { frames = {"punch"}, speed = 0.15, loop = false },
    uppercut     = { frames = {"uppercut"}, speed = 0.2, loop = false },
    lowercut     = { frames = {"lowercut"}, speed = 0.2, loop = false },
    low_kick     = { frames = {"low_kick"}, speed = 0.18, loop = false },
    high_kick    = { frames = {"high_kick"}, speed = 0.2, loop = false },
    jump_punch   = { frames = {"jump_punch"}, speed = 0.2, loop = false },

    -- Multi-Frame Action Combos
    punch_combo  = { frames = {"punch", "uppercut", "punch", "lowercut", "punch", "uppercut", "punch"}, speed = 0.04, loop = false },
    kick_combo   = { frames = {"low_kick", "high_kick", "low_kick", "high_kick", "low_kick", "high_kick"}, speed = 0.04, loop = false },

    -- Combat state animations (Using fallbacks)
    hit_stun     = { frames = {"hit_stun"}, speed = 0.3, loop = false },
    dizzy        = { frames = {"dizzy"}, speed = 1, loop = true },
    block        = { frames = {"block"}, speed = 0.3, loop = false },
    block_high   = { frames = {"block_high"}, speed = 0.3, loop = false },
    block_low    = { frames = {"block_low"}, speed = 0.3, loop = false },
    ko           = { frames = {"ko"}, speed = 1, loop = true },
}

-- Attack data: damage, particle type, range, active frames, knockback
Character.attackData = {
    punch       = { damage = 6,  particle = "small",  range = 75,  knockback = 60 },
    kick        = { damage = 7,  particle = "small",  range = 85,  knockback = 70 },
    uppercut    = { damage = 10, particle = "medium", range = 70,  knockback = 100 },
    lowercut    = { damage = 8,  particle = "small",  range = 70,  knockback = 80 },
    low_kick    = { damage = 6,  particle = "small",  range = 90,  knockback = 50 },
    high_kick   = { damage = 9,  particle = "medium", range = 85,  knockback = 90 },
    jump_punch  = { damage = 12, particle = "medium", range = 80,  knockback = 120 },
    punch_combo = { damage = 20, particle = "big",    range = 75,  knockback = 150 },
    kick_combo  = { damage = 18, particle = "big",    range = 85,  knockback = 140 },
    dive        = { damage = 8,  particle = "small",  range = 80,  knockback = 60 },
}

function Character:new(playerType, facingRight, customPaletteIdx)
    local chosenPalette
    if playerType == 1 then
        chosenPalette = Character.palettes[customPaletteIdx or 1] or Character.paletteP1
    else
        chosenPalette = Character.paletteP2
    end
    
    local obj = {
        palette = chosenPalette,
        playerType = playerType,
        currentAnim = "idle",
        frameIdx = 1,
        timer = 0,
        angle = 0,
        facingRight = (facingRight == nil) and true or facingRight,

        -- Combat state
        chakra = 100,           -- Health (0-100)
        isStunned = false,      -- hit stun
        stunTimer = 0,
        isDizzy = false,        -- dizzy from combo
        dizzyTimer = 0,
        isBlocking = false,
        hitRegistered = false,  -- prevent multi-hit per attack
        comboHits = 0,          -- track consecutive hits for dizzy
        comboResetTimer = 0,    -- reset combo counter after delay
        knockbackVelX = 0,      -- horizontal knockback velocity

        -- Flash effect on hit
        flashTimer = 0,
    }
    setmetatable(obj, { __index = Character })
    return obj
end

function Character:setAnimation(animName)
    if self.animations[animName] and self.currentAnim ~= animName then
        self.currentAnim = animName
        self.frameIdx = 1
        self.timer = 0
        self.angle = 0
        self.hitRegistered = false
    end
end

function Character:isAttacking()
    local anim = self.currentAnim
    return self.attackData[anim] ~= nil
end

function Character:update(dt)
    -- Update flash
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end

    -- Update stun
    if self.isStunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer <= 0 then
            self.isStunned = false
            self:setAnimation("idle")
        end
        return -- don't update animation while stunned
    end

    -- Update dizzy
    if self.isDizzy then
        self.dizzyTimer = self.dizzyTimer - dt
        if self.dizzyTimer <= 0 then
            self.isDizzy = false
            self.comboHits = 0
            self:setAnimation("idle")
        end
        return
    end

    -- Combo reset timer
    if self.comboResetTimer > 0 then
        self.comboResetTimer = self.comboResetTimer - dt
        if self.comboResetTimer <= 0 then
            self.comboHits = 0
        end
    end

    -- Knockback decay
    if math.abs(self.knockbackVelX) > 0 then
        self.knockbackVelX = self.knockbackVelX * (1 - 8 * dt)
        if math.abs(self.knockbackVelX) < 5 then
            self.knockbackVelX = 0
        end
    end

    local anim = self.animations[self.currentAnim]
    if not anim then return end

    if anim.autoRotate then
        self.angle = self.angle + (anim.autoRotate * (self.facingRight and 1 or -1) * dt * 2)
    else
        self.angle = 0
    end
    
    -- Special case for KO animation
    if self.currentAnim == "ko" then
        self.angle = -90
    end

    if #anim.frames > 1 then
        self.timer = self.timer + dt
        if self.timer >= anim.speed then
            self.timer = self.timer - anim.speed
            self.frameIdx = self.frameIdx + 1
            if self.frameIdx > #anim.frames then
                if anim.loop then
                    self.frameIdx = 1
                else
                    self.frameIdx = #anim.frames
                    self:setAnimation("idle")
                end
            end
        end
    elseif not anim.loop then
        -- Single-frame non-looping anim: auto-return to idle after speed duration
        self.timer = self.timer + dt
        if self.timer >= anim.speed then
            self:setAnimation("idle")
        end
    end
end

function Character:takeHit(damage, knockbackDir, knockbackForce)
    self.chakra = math.max(0, self.chakra - damage)
    self.isStunned = true
    self.stunTimer = 0.25
    self.knockbackVelX = knockbackDir * knockbackForce
    self.flashTimer = 0.15

    -- Track combo hits
    self.comboHits = self.comboHits + 1
    self.comboResetTimer = 1.5

    self:setAnimation("hit_stun")

    -- Trigger dizzy if too many hits in succession
    if self.comboHits >= 4 then
        self.isDizzy = true
        self.dizzyTimer = 1.8
        self.isStunned = false
        self:setAnimation("dizzy")
    end

    -- KO check
    if self.chakra <= 0 then
        self.isStunned = false
        self.isDizzy = false
        self:setAnimation("ko")
    end
end

function Character:draw(posX, posY, scale, isShadow)
    scale = scale or 4
    local anim = self.animations[self.currentAnim]
    if not anim then return end
    local frameKey = anim.frames[self.frameIdx]
    if not frameKey then return end
    local pixels = self.frames[frameKey]
    if not pixels then return end

    local width = #pixels[1] * scale
    local height = #pixels * scale

    love.graphics.push()
    love.graphics.translate(posX + width / 2, posY + height / 2)

    -- Horizontal flip scaling depending on character direction
    local dirScaleX = self.facingRight and 1 or -1
    love.graphics.scale(dirScaleX, 1)
    love.graphics.rotate(math.rad(self.angle))
    love.graphics.translate(-width / 2, -height / 2)

    for r, row in ipairs(pixels) do
        for c, colorIdx in ipairs(row) do
            if colorIdx > 0 then
                local color = self.palette[colorIdx]
                if color then
                    if isShadow then
                        love.graphics.setColor(0.05, 0.1, 0.15, 0.7)
                    else
                        -- Flash white on hit
                        if self.flashTimer > 0 then
                            local flash = self.flashTimer / 0.15
                            love.graphics.setColor(
                                color[1] + (1 - color[1]) * flash,
                                color[2] + (1 - color[2]) * flash,
                                color[3] + (1 - color[3]) * flash,
                                1
                            )
                        else
                            love.graphics.setColor(color[1], color[2], color[3], 1)
                        end
                    end
                    love.graphics.rectangle("fill", (c - 1) * scale, (r - 1) * scale, scale, scale)
                end
            end
        end
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return Character
