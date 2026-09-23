-- intro.lua (Smack - Ninja Intro)
local intro = {}

local VW, VH = 320, 240
local canvas
local markCanvas
local t = 0
local shake = 0
local Character = require("character")
local fallAnim = require("fall_animation")
local introNinja
local victimNinja

-- Track previous Y to calculate velocity
local ninjaYLast = 240 - 36
local ninjaVy = 0

-- Visual FX & Particles
local sparks = {}
local smokePuffs = {}
local slashLines = {}
local slashTriggered = false

-- Title & Transition State
local titleScale = 0
local titleAngle = -0.05
local isIntroDone = false

-- Timeline Markers
local tEntranceStart = 1.2
local tArriveCenter  = 3.2                  -- Drops in from top
local tDialogue1     = tArriveCenter + 1.8  -- "I LURK IN SHADOWS..."
local tDialogue2     = tDialogue1 + 2.0     -- "AND I CAME TO..."
local tDashLeft      = tDialogue2 + 1.5     -- Wall Strike Left
local tStickLeft     = tDashLeft + 0.35
local tDashRight     = tStickLeft + 0.15    -- Wall Strike Right
local tStickRight    = tDashRight + 0.35
local tAnticUp       = tStickRight + 0.20   -- Leap to sky
local tSlashDown     = tAnticUp + 0.40      -- Smash down impact
local tSplatImpact   = tSlashDown + 0.30    -- Logo reveal
local tIntroEnd      = tSplatImpact + 2.50

---------------------------------------------------------
-- CHUNKY RETRO BITMAP FONT ENGINE (3x5 Grid)
---------------------------------------------------------
local GLYPHS = {
    ["A"] = {0x7, 0x5, 0x7, 0x5, 0x5}, ["B"] = {0x6, 0x5, 0x6, 0x5, 0x6},
    ["C"] = {0x7, 0x4, 0x4, 0x4, 0x7}, ["D"] = {0x6, 0x5, 0x5, 0x5, 0x6},
    ["E"] = {0x7, 0x4, 0x6, 0x4, 0x7}, ["F"] = {0x7, 0x4, 0x6, 0x4, 0x4},
    ["G"] = {0x7, 0x4, 0x5, 0x5, 0x7}, ["H"] = {0x5, 0x5, 0x7, 0x5, 0x5},
    ["I"] = {0x7, 0x2, 0x2, 0x2, 0x7}, ["J"] = {0x1, 0x1, 0x1, 0x5, 0x2},
    ["K"] = {0x5, 0x5, 0x6, 0x5, 0x5}, ["L"] = {0x4, 0x4, 0x4, 0x4, 0x7},
    ["M"] = {0x5, 0x7, 0x5, 0x5, 0x5}, ["N"] = {0x6, 0x5, 0x5, 0x5, 0x5},
    ["O"] = {0x7, 0x5, 0x5, 0x5, 0x7}, ["P"] = {0x7, 0x5, 0x7, 0x4, 0x4},
    ["Q"] = {0x7, 0x5, 0x5, 0x6, 0x3}, ["R"] = {0x6, 0x5, 0x6, 0x5, 0x5},
    ["S"] = {0x7, 0x4, 0x7, 0x1, 0x7}, ["T"] = {0x7, 0x2, 0x2, 0x2, 0x2},
    ["U"] = {0x5, 0x5, 0x5, 0x5, 0x7}, ["V"] = {0x5, 0x5, 0x5, 0x5, 0x2},
    ["W"] = {0x5, 0x5, 0x5, 0x7, 0x5}, ["X"] = {0x5, 0x5, 0x2, 0x5, 0x5},
    ["Y"] = {0x5, 0x5, 0x7, 0x2, 0x2}, ["Z"] = {0x7, 0x1, 0x2, 0x4, 0x7},
    ["!"] = {0x2, 0x2, 0x2, 0x0, 0x2}, ["?"] = {0x7, 0x1, 0x3, 0x0, 0x2},
    [","] = {0x0, 0x0, 0x0, 0x2, 0x4}, ["."] = {0x0, 0x0, 0x0, 0x0, 0x2},
    [" "] = {0x0, 0x0, 0x0, 0x0, 0x0}
}

local function measureRetroText(str, scale)
    scale = scale or 1
    return #str * (4 * scale) - scale, 5 * scale
end

local function drawRetroText(str, px, py, scale)
    scale = scale or 1
    local cx = px
    for i = 1, #str do
        local ch = string.sub(str, i, i):upper()
        local rows = GLYPHS[ch] or GLYPHS[" "]
        for rowIdx = 1, 5 do
            local byte = rows[rowIdx]
            for colIdx = 1, 3 do
                local bit = math.floor(byte / (2 ^ (3 - colIdx))) % 2
                if bit == 1 then
                    love.graphics.rectangle("fill", cx + (colIdx - 1) * scale, py + (rowIdx - 1) * scale, scale, scale)
                end
            end
        end
        cx = cx + 4 * scale
    end
end

local function getVisibleText(fullText, elapsed, charsPerSec)
    local count = math.floor(elapsed * (charsPerSec or 18))
    return string.sub(fullText, 1, math.min(#fullText, count))
end

local function stampSlashMark(side, hitY)
    love.graphics.setCanvas(markCanvas)
    love.graphics.setColor(0.85, 0.15, 0.18) -- Crimson Ninja Mark

    local originX = (side == "left") and 0 or VW
    local dir = (side == "left") and 1 or -1

    love.graphics.polygon("fill", originX, hitY - 15, originX + dir * 18, hitY, originX, hitY + 15)

    for _ = 1, 10 do
        table.insert(sparks, {
            x = originX + dir * 4, y = hitY,
            vx = dir * math.random(80, 200), vy = math.random(-100, 100),
            life = 0.4
        })
    end
    love.graphics.setCanvas(canvas)
end

local function drawSpeechBubble(fullText, elapsedText, targetX, targetY, scale)
    if scale <= 0.05 then return end
    local fontScale = 2
    local textW, textH = measureRetroText(fullText, fontScale)
    local padX, padY = 6, 5
    local bw, bh = textW + padX * 2, textH + padY * 2
    local bx, by = math.max(6, math.min(VW - bw - 6, targetX - bw / 2)), targetY - bh - 12

    love.graphics.push()
    love.graphics.translate(targetX, targetY)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-targetX, -targetY)

    -- Crimson & Slate Ninja Styling
    love.graphics.setColor(0.85, 0.15, 0.18)
    love.graphics.rectangle("fill", bx - 2, by - 2, bw + 4, bh + 4, 2, 2)
    love.graphics.polygon("fill", bx + bw/2 - 4, by + bh, bx + bw/2 + 4, by + bh, targetX, targetY)

    love.graphics.setColor(0.12, 0.12, 0.16)
    love.graphics.rectangle("fill", bx, by, bw, bh, 1, 1)

    love.graphics.setColor(0.95, 0.95, 0.95)
    drawRetroText(getVisibleText(fullText, elapsedText, 18), math.floor(bx + padX), math.floor(by + padY), fontScale)
    love.graphics.pop()
end


local function drawNinjaSprite(x, y, scaleX, scaleY, pose)
    love.graphics.push()
    love.graphics.translate(math.floor(x), math.floor(y))
    love.graphics.scale(scaleX, scaleY)

    if introNinja then
        if pose == "slash" then
            introNinja:setAnimation("slash")
        else
            introNinja:setAnimation("idle")
        end
        love.graphics.setColor(1, 1, 1, 1)
        -- PNG uses 1.2 scale naturally, adjust Y anchor. The old pixel art drew at -8, -9.
        -- For PNG, origin is bottom-center, so Y should be slightly lower (e.g. 0).
        introNinja:draw(-8, 10, 1.2)
    end

    

    love.graphics.pop()
end

function intro.load()
    canvas = love.graphics.newCanvas(VW, VH)
    canvas:setFilter("nearest", "nearest")

    markCanvas = love.graphics.newCanvas(VW, VH)
    markCanvas:setFilter("nearest", "nearest")
    love.graphics.setCanvas(markCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setCanvas()

    t, shake = 0, 0
    sparks, smokePuffs, slashLines = {}, {}, {}
    slashTriggered = false
    titleScale = 0
    isIntroDone = false
    ninjaYLast = VH - 36
    ninjaVy = 0
    
    fallAnim.load()
    
    introNinja = Character:new(2, false)
    victimNinja = Character:new(1, false)
end

function intro.setVictimPalette(idx)
    if victimNinja then victimNinja.playerType = idx end
end

function intro.update(dt)
    t = t + dt
    shake = math.max(0, shake - dt * 25)

    -- Impact / Shake triggers
    if t >= tStickLeft and t < tStickLeft + 0.08 then
        shake = 14
        stampSlashMark("left", VH - 100)
    elseif t >= tStickRight and t < tStickRight + 0.08 then
        shake = 14
        stampSlashMark("right", VH - 80)
    elseif t >= tSplatImpact and titleScale == 0 then
        shake = 28
    end

    if t >= tSplatImpact then
        titleScale = math.min(1.0, titleScale + dt * 5.0)
    end

    if t >= tIntroEnd then
        isIntroDone = true
    end

    -- Update Sparks & Smoke
    for i = #sparks, 1, -1 do
        local p = sparks[i]
        p.x, p.y = p.x + p.vx * dt, p.y + p.vy * dt
        p.life = p.life - dt
        if p.life <= 0 then table.remove(sparks, i) end
    end
    
    if introNinja then
        introNinja:update(dt)
        victimNinja:update(dt)
    end

    -- Calculate ninja position & velocity for fallAnim
    local groundY = VH - 36
    local centerX = VW / 2
    local currentNinjaY = groundY
    local currentNinjaX = centerX
    local isGrounded = true

    if t < tEntranceStart then
        currentNinjaY = -50
        isGrounded = false
    elseif t < tArriveCenter then
        local p = (t - tEntranceStart) / (tArriveCenter - tEntranceStart)
        currentNinjaY = -20 + p * (groundY + 20)
        isGrounded = false
    end

    if dt > 0 then
        ninjaVy = (currentNinjaY - ninjaYLast) / dt
    else
        ninjaVy = 0
    end
    ninjaYLast = currentNinjaY

    fallAnim.update(dt, ninjaVy, isGrounded, currentNinjaX, currentNinjaY)
end

function intro.isFinished()
    return isIntroDone
end

function intro.draw()
    love.graphics.setCanvas(canvas)
    love.graphics.clear(0.08, 0.08, 0.10) -- Midnight Ninja Background

    local groundY = VH - 36
    local centerX, centerY = VW / 2, VH / 2
    local ninjaX, ninjaY = centerX, groundY
    local sx, sy = 1.0, 1.0
    local pose = "idle"

    local activeDialogue, dialogueElapsed = nil, 0
    local bubbleScale = 0

    ---------------------------------------------------------
    -- 1. STUDIO PRESENTATION
    ---------------------------------------------------------
    if t < tEntranceStart then
        local line1 = "BIHIN STUDIOS PRESENTS"
        local w1, _ = measureRetroText(line1, 1)
        love.graphics.setColor(0.85, 0.15, 0.18)
        drawRetroText(line1, math.floor(centerX - w1 / 2), math.floor(centerY - 10), 1)

    ---------------------------------------------------------
    -- 2. NINJA DROPS IN & DIALOGUE
    ---------------------------------------------------------
    elseif t < tArriveCenter then
        local p = (t - tEntranceStart) / (tArriveCenter - tEntranceStart)
        ninjaX = centerX
        ninjaY = -20 + p * (groundY + 20)
        sx, sy = 0.8, 1.4

        -- Use fall animation instead of default sprite logic
        pose = "falling"

    elseif t < tDialogue1 then
        ninjaX, ninjaY = centerX, groundY
        activeDialogue, dialogueElapsed = "I LURK IN THE SHADOWS...", t - tArriveCenter
        bubbleScale = math.min(1, dialogueElapsed / 0.25)

    elseif t < tDialogue2 then
        ninjaX, ninjaY = centerX, groundY
        activeDialogue, dialogueElapsed = "AND I CAME TO...", t - tDialogue1
        bubbleScale = math.min(1, dialogueElapsed / 0.25)

    ---------------------------------------------------------
    -- 3. HIGH-SPEED WALL SLASHES
    ---------------------------------------------------------
    elseif t < tStickLeft then
        local p = (t - tDialogue2) / (tStickLeft - tDialogue2)
        ninjaX = centerX + (12 - centerX) * p
        ninjaY = groundY - p * 60
        pose = "slash"

    elseif t < tStickRight then
        local p = (t - tStickLeft) / (tStickRight - tStickLeft)
        ninjaX = 12 + (VW - 24) * p
        ninjaY = (groundY - 60) + p * 20
        pose = "slash"

    elseif t < tAnticUp then
        ninjaX, ninjaY = VW - 12, groundY - 40
        sx, sy = 1.3, 0.7

    elseif t < tSlashDown then
        local p = (t - tAnticUp) / (tSlashDown - tAnticUp)
        ninjaX = centerX
        ninjaY = (groundY - 40) - math.sin(p * math.pi) * 80
        pose = "slash"

    else
        ninjaX, ninjaY = centerX, groundY
        sx, sy = 1.5, 0.5
    end

    -- Camera Shake
    local ox = math.floor((math.random() - 0.5) * shake)
    local oy = math.floor((math.random() - 0.5) * shake)
    love.graphics.push()
    love.graphics.translate(ox, oy)

    -- Persistent Wall Marks & Sparks
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(markCanvas, 0, 0)

    -- Draw Victim Ninja
    if t > tDialogue2 and t < tSplatImpact then
        love.graphics.push()
        local vx, vy, poseV
        if t < tStickLeft then
            vx, vy = 16, VH - 100
            poseV = "idle"
            love.graphics.translate(vx, vy)
            love.graphics.scale(-1, 1)
        elseif t < tStickRight - 0.2 then
            vx, vy = 16, VH - 100
            poseV = "jump"
            love.graphics.translate(vx, vy)
            love.graphics.scale(-1, 1)
        elseif t < tStickRight then
            vx, vy = VW - 16, VH - 80
            poseV = "idle"
            love.graphics.translate(vx, vy)
        else
            vx, vy = VW - 16, VH - 80
            poseV = "jump"
            love.graphics.translate(vx, vy)
        end
        
        victimNinja:setAnimation(poseV)
        love.graphics.setColor(1, 1, 1, 1)
        victimNinja:draw(-8, -9, 1.5)
        love.graphics.pop()
    end

    love.graphics.setColor(1.0, 0.8, 0.2)
    for _, p in ipairs(sparks) do
        love.graphics.rectangle("fill", math.floor(p.x), math.floor(p.y), 2, 2)
    end

    -- Draw Ninja Character
    if t >= tEntranceStart and t < tSplatImpact + 0.1 then
        if pose == "falling" or (t >= tArriveCenter and t < tArriveCenter + 0.5) then
            -- Let fallAnim draw during the fall and shortly after for landing squash and dust
            local isGrounded = (t >= tArriveCenter)
            fallAnim.draw(ninjaX, ninjaY, ninjaVy, isGrounded, true, t, introNinja)
        else
            drawNinjaSprite(ninjaX, ninjaY, sx, sy, pose)
        end
    end

    -- Speech Bubbles
    if activeDialogue then
        drawSpeechBubble(activeDialogue, dialogueElapsed, ninjaX, ninjaY - 10, bubbleScale)
    end

    ---------------------------------------------------------
    -- 4. TITLE CARD REVEAL (SMACK)
    ---------------------------------------------------------
    if titleScale > 0.01 then
        love.graphics.setColor(0.85, 0.15, 0.18)
        love.graphics.circle("fill", centerX, centerY, 85 * titleScale)

        love.graphics.push()
        love.graphics.translate(centerX, centerY)
        love.graphics.rotate(titleAngle)
        love.graphics.scale(titleScale, titleScale)

        local titleText = "SMACK"
        local titleW, titleH = measureRetroText(titleText, 7)
        love.graphics.setColor(0.95, 0.95, 0.95)
        drawRetroText(titleText, -math.floor(titleW / 2), -math.floor(titleH / 2) - 6, 7)

        local demoText = "DEMO"
        local demoW, demoH = measureRetroText(demoText, 2)
        love.graphics.setColor(0.12, 0.12, 0.16)
        love.graphics.rectangle("fill", -math.floor(demoW / 2) - 4, math.floor(titleH / 2) + 2, demoW + 8, demoH + 4)
        love.graphics.setColor(0.95, 0.95, 0.95)
        drawRetroText(demoText, -math.floor(demoW / 2), math.floor(titleH / 2) + 4, 2)

        love.graphics.pop()
    end

    love.graphics.pop()
    love.graphics.setCanvas()

    -- Render Scaled Canvas
    local sw, sh = love.graphics.getDimensions()
    local scale = math.min(sw / VW, sh / VH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(canvas, (sw - VW * scale) / 2, (sh - VH * scale) / 2, 0, scale, scale)
end

return intro
