-- ground.lua
local ground = {}

local VW, VH = 900, 600
local riverY = 460       -- Base height of the riverbank (ground starts at riverY - 20 = 440)
local slopeTilt = 0      -- Straight ground (Left to Right)

local dirtPebbles = {}
local grassTufts = {}

function ground.load()
    dirtPebbles = {}
    grassTufts = {}

    -- 1. Seed organic pebbles and specks throughout the soil layer
    for _ = 1, 45 do
        table.insert(dirtPebbles, {
            x = math.random(0, VW),
            y = math.random(140, VH),
            size = math.random(1, 3),
            shade = math.random() * 0.12
        })
    end

    -- 2. Seed grass blades along the sloped top edge
    for x = 0, VW, 5 do
        local slopeY = (riverY - 20) + (x / VW) * slopeTilt
        table.insert(grassTufts, {
            x = x,
            y = slopeY,
            height = math.random(4, 8)
        })
    end
end

-- Helper: Returns the dynamic ground Y height for any given X coordinate
function ground.getGroundY(x)
    local normX = math.max(0, math.min(VW, x))
    return (riverY - 20) + (normX / VW) * slopeTilt
end

-- Helper: Returns the river level Y
function ground.getRiverY()
    return riverY + 16
end

-- Render Soil, Grass, and River Surface
function ground.draw(t)
    t = t or love.timer.getTime()

    ---------------------------------------------------------
    -- 1. SOIL & DIRT LAYER (Sloped)
    ---------------------------------------------------------
    -- Rich Topsoil
    love.graphics.setColor(0.24, 0.15, 0.10)
    love.graphics.polygon("fill",
        0, riverY - 20,
        VW, riverY - 20 + slopeTilt,
        VW, VH,
        0, VH
    )

    -- Deep Underground Dirt Layer
    love.graphics.setColor(0.16, 0.10, 0.06)
    love.graphics.polygon("fill",
        0, riverY + 12,
        VW, riverY + 12 + slopeTilt,
        VW, VH,
        0, VH
    )

    -- Pebbles / Roots
    for _, p in ipairs(dirtPebbles) do
        local bankY = ground.getGroundY(p.x)
        if p.y > bankY + 4 then
            love.graphics.setColor(0.32 + p.shade, 0.20 + p.shade, 0.12 + p.shade)
            love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
        end
    end

    ---------------------------------------------------------
    -- 2. GRASS EDGE (Sloped & Animated Sway)
    ---------------------------------------------------------
    -- Dark Base Rim
    love.graphics.setColor(0.05, 0.15, 0.10)
    for _, g in ipairs(grassTufts) do
        love.graphics.rectangle("fill", g.x - 1, g.y - g.height, 3, g.height + 4)
    end

    -- Vibrant Top Grass Tufts (Night color)
    love.graphics.setColor(0.10, 0.30, 0.20)
    for _, g in ipairs(grassTufts) do
        local sway = math.sin(t * 3.5 + g.x * 0.1) * 1.5
        love.graphics.polygon("fill",
            g.x - 2, g.y + 1,
            g.x + 2, g.y + 1,
            g.x + sway, g.y - g.height
        )
    end

    ---------------------------------------------------------
    -- 3. FLOWING RIVER
    ---------------------------------------------------------
    local waterStartY = riverY + 16
    local waterPoly = {
        0, waterStartY,
        VW, waterStartY + slopeTilt,
        VW, VH,
        0, VH
    }

    -- Deep Dark Water Base
    love.graphics.setColor(0.06, 0.18, 0.30, 0.5)
    love.graphics.polygon("fill", waterPoly)

    -- Flowing Specular Waves (Wavy Lines)
    for yOffset = 0, VH - waterStartY, 10 do
        local lineY = waterStartY + yOffset
        local waveSpeed = (15 - yOffset * 0.2) * 5
        local waveShift = (t * waveSpeed) % 90

        love.graphics.setColor(0.35, 0.70, 0.90, 0.28 - (yOffset / (VH - waterStartY)) * 0.20)
        love.graphics.setLineWidth(1.5)

        for x = -60 + waveShift, VW + 60, 90 do
            local points = {}
            for px = 0, 40, 5 do
                local currentX = x + px
                local currentY = lineY + math.sin(t * 2 + currentX * 0.05) * 2.5
                if currentY >= waterStartY then
                    table.insert(points, currentX)
                    table.insert(points, currentY)
                end
            end
            if #points >= 4 then
                love.graphics.line(points)
            end
        end
    end

    -- Shore Water Foam Trim (Wavy)
    love.graphics.setColor(0.75, 0.90, 0.98, 0.45)
    for x = 0, VW, 3 do
        local foamY = waterStartY + math.sin(t * 3 + x * 0.1) * 2
        love.graphics.rectangle("fill", x, foamY, 2, 1)
    end
end

---------------------------------------------------------
-- 4. VAGUE WATER REFLECTION RENDERER
---------------------------------------------------------
-- Draws a wavy, semi-transparent flipped reflection in the river
function ground.drawReflection(drawSpriteFunc, charX, charY, facingRight, t)
    t = t or love.timer.getTime()
    local waterStartY = riverY + 16 + (charX / VW) * slopeTilt

    -- Only reflect if near the shoreline
    if charY < waterStartY + 50 then
        love.graphics.push()

        local reflectBaseY = waterStartY + (waterStartY - charY) * 0.55
        local dir = facingRight and 1 or -1
        local slices = 10
        local sliceH = 2

        -- Render distorted horizontal slices
        for i = 0, slices - 1 do
            local wobble = math.sin(t * 8 + i * 0.7) * 2.2
            love.graphics.push()
            love.graphics.translate(charX + wobble, reflectBaseY + (i * sliceH))
            love.graphics.scale(dir, -0.45) -- Flipped vertically and squashed

            -- Vague Dark-Blue Reflection Tint
            love.graphics.setColor(0.12, 0.35, 0.55, 0.25 - (i * 0.02))

            -- Render object sprite slice
            drawSpriteFunc(0, 0)

            love.graphics.pop()
        end

        love.graphics.pop()
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return ground
