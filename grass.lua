-- grass.lua (Organic Tapered Blade Engine)
local grass = {}

local blades = {}
local windTime = 0
local windStrength = 0
local globalGust = 0

local GRASS_COUNT = 260
local BASE_Y = 440       -- matches riverY - 20 in ground.lua
local SLOPE_TILT = 0     -- straight ground

function grass.load(count, baseY, slope)
    blades = {}
    count = count or GRASS_COUNT
    baseY = baseY or BASE_Y
    slope = slope or SLOPE_TILT

    for i = 1, count do
        local x = math.random(-10, 910)
        local slopeOffset = (x / 900) * slope
        local bladeY = baseY + slopeOffset

        local layer = math.random(1, 3) -- 1: Background, 2: Mid, 3: Foreground
        local baseWidth = math.random(3, 5)

        table.insert(blades, {
            x = x,
            baseY = bladeY,
            height = math.random(12, 22) + (layer * 2),
            baseWidth = baseWidth,
            midWidth = math.max(1, math.floor(baseWidth * 0.55)),
            stiffness = math.random(70, 110) / 100,
            phaseOffset = math.random() * math.pi * 2,
            layer = layer,
            -- Night palette: darker, cooler tones
            rootColor = (layer == 1 and {0.04, 0.12, 0.08}) or
                        (layer == 2 and {0.07, 0.22, 0.10}) or
                        {0.10, 0.30, 0.14},
            tipColor  = (layer == 1 and {0.08, 0.24, 0.12}) or
                        (layer == 2 and {0.14, 0.40, 0.18}) or
                        {0.22, 0.58, 0.25}
        })
    end

    table.sort(blades, function(a, b) return a.layer < b.layer end)
end

function grass.update(dt)
    windTime = windTime + dt

    -- Dynamic multi-frequency wind wave
    local baseWind = math.sin(windTime * 1.4) * 0.5 + math.sin(windTime * 0.6) * 0.5
    if math.random() < 0.012 then
        globalGust = math.random(18, 32) / 10
    end
    globalGust = math.max(0, globalGust - dt * 1.8)

    windStrength = baseWind + globalGust
end

function grass.draw()
    for _, b in ipairs(blades) do
        -- Spatial wave math (wind travels across the X axis)
        local wave = math.sin(windTime * 3.8 - b.x * 0.03 + b.phaseOffset) * 0.4
        local totalBend = (windStrength + wave) * (2.2 / b.stiffness)

        -- 1. Calculate Multi-Segment Keypoints
        local h = b.height
        local bendAmount = totalBend * (h / 14)

        -- Root Base Coordinates
        local xBaseL = b.x - b.baseWidth / 2
        local xBaseR = b.x + b.baseWidth / 2
        local yBase  = b.baseY

        -- Middle Curve Segment (45% up the height)
        local midY = b.baseY - h * 0.45
        local midOffset = bendAmount * 0.45
        local xMidL = (b.x + midOffset) - b.midWidth / 2
        local xMidR = (b.x + midOffset) + b.midWidth / 2

        -- Blade Tip (100% up height with arch compression)
        local tipOffset = bendAmount * 1.1
        local xTip = b.x + tipOffset
        local yTip = b.baseY - h + math.abs(bendAmount) * 0.22

        ---------------------------------------------------------
        -- 2. DRAW SHADED TAPERED POLYGON (5-Point Blade Mesh)
        ---------------------------------------------------------
        -- Lower Darker Root Segment
        love.graphics.setColor(b.rootColor[1], b.rootColor[2], b.rootColor[3])
        love.graphics.polygon("fill",
            xBaseL, yBase,
            xBaseR, yBase,
            xMidR,  midY,
            xMidL,  midY
        )

        -- Upper Vibrant Tip Segment (Forms pointed tip)
        love.graphics.setColor(b.tipColor[1], b.tipColor[2], b.tipColor[3])
        love.graphics.polygon("fill",
            xMidL, midY,
            xMidR, midY,
            xTip,  yTip
        )

        -- Tip Highlight Pixel on foreground blades
        if b.layer == 3 then
            love.graphics.setColor(0.30, 0.70, 0.30, 0.8)
            love.graphics.rectangle("fill", math.floor(xTip), math.floor(yTip), 1, 1)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return grass
