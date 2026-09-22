local fallAnim = {}

-- Visual Settings
local maxFallSpeed = 500   -- Speed at which maximum stretch occurs
local windParticles = {}
local dustParticles = {}

-- State Variables
local landingSquashTimer = 0
local landingSquashDuration = 0.15
local wasFallingLastFrame = false

function fallAnim.load()
    windParticles = {}
    dustParticles = {}
    landingSquashTimer = 0
    wasFallingLastFrame = false
end

function fallAnim.update(dt, vy, isGrounded, x, y)
    -- 1. Handle Landing Impact Detection
    if isGrounded then
        if wasFallingLastFrame and vy > 100 then
            -- Trigger Impact Squash & Dust Cloud
            landingSquashTimer = landingSquashDuration
            fallAnim.spawnDust(x, y, vy)
        end
        wasFallingLastFrame = false
    else
        if vy > 50 then
            wasFallingLastFrame = true
        end
    end

    -- Update Landing Timer
    if landingSquashTimer > 0 then
        landingSquashTimer = landingSquashTimer - dt
    end

    -- 2. Spawn Wind Lines during high-speed fall
    if not isGrounded and vy > 150 then
        if math.random() < 0.6 then
            table.insert(windParticles, {
                x = x + math.random(-16, 16),
                y = y + math.random(-10, 20),
                length = math.random(10, 25),
                speed = vy * 1.2 + math.random(50, 150),
                alpha = math.random(0.4, 0.8)
            })
        end
    end

    -- Update Wind Particles (Moving upward relative to falling ninja)
    for i = #windParticles, 1, -1 do
        local p = windParticles[i]
        p.y = p.y - p.speed * dt
        p.alpha = p.alpha - dt * 2
        if p.alpha <= 0 then
            table.remove(windParticles, i)
        end
    end

    -- Update Dust Particles on Impact
    for i = #dustParticles, 1, -1 do
        local p = dustParticles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.size = math.max(0, p.size - dt * 12)
        p.life = p.life - dt
        if p.life <= 0 or p.size <= 0 then
            table.remove(dustParticles, i)
        end
    end
end

function fallAnim.spawnDust(x, y, vy)
    local particleCount = math.min(16, math.floor(vy / 35))
    for _ = 1, particleCount do
        local dir = (math.random() < 0.5) and -1 or 1
        table.insert(dustParticles, {
            x = x,
            y = y,
            vx = dir * math.random(40, 140),
            vy = math.random(-20, -5),
            size = math.random(3, 6),
            life = math.random(0.2, 0.4)
        })
    end
end

function fallAnim.draw(x, y, vy, isGrounded, facingRight, t, character)
    t = t or love.timer.getTime()
    local dir = facingRight and 1 or -1

    ---------------------------------------------------------
    -- 1. CALCULATE SQUASH & STRETCH
    ---------------------------------------------------------
    local sx, sy = 1.0, 1.0

    if not isGrounded and vy > 0 then
        -- Vertical stretch proportional to downward velocity
        local fallRatio = math.min(1.0, vy / maxFallSpeed)
        sy = 1.0 + fallRatio * 0.45            -- Stretches up to 1.45x
        sx = 1.0 / math.sqrt(sy)               -- Preserves body volume
    elseif landingSquashTimer > 0 then
        -- Heavy landing impact squash
        local p = landingSquashTimer / landingSquashDuration
        sx = 1.0 + math.sin(p * math.pi) * 0.5 -- Flattens horizontally
        sy = 1.0 / sx                          -- Compresses vertically
    end

    ---------------------------------------------------------
    -- 2. DRAW WIND LINES & PARTICLES
    ---------------------------------------------------------
    love.graphics.setColor(0.9, 0.9, 1.0, 0.7)
    for _, p in ipairs(windParticles) do
        love.graphics.setLineWidth(1)
        love.graphics.line(p.x, p.y, p.x, p.y - p.length)
    end

    -- Draw Dust Cloud
    love.graphics.setColor(0.7, 0.7, 0.75, 0.8)
    for _, p in ipairs(dustParticles) do
        love.graphics.rectangle("fill", math.floor(p.x), math.floor(p.y), p.size, p.size)
    end

    ---------------------------------------------------------
    -- 3. DRAW NINJA FALLING SPRITE
    ---------------------------------------------------------
    love.graphics.push()
    love.graphics.translate(math.floor(x), math.floor(y))
    love.graphics.scale(sx * dir, sy)

    if character then
        if not isGrounded and vy > 100 then
            character:setAnimation("jump")
        else
            character:setAnimation("idle")
        end
        love.graphics.setColor(1, 1, 1, 1)
        character:draw(-8, -9, 1)
    else
        -- Fallback to drawing a simple dark suit block if no character is passed
        love.graphics.setColor(0.10, 0.10, 0.14)
        love.graphics.rectangle("fill", -7, -14, 14, 20)
        love.graphics.setColor(0.85, 0.15, 0.18)
        love.graphics.rectangle("fill", -7, -12, 14, 4)
        love.graphics.setColor(0.95, 0.95, 0.95)
        love.graphics.rectangle("fill", 1, -10, 3, 2)
        love.graphics.rectangle("fill", 5, -10, 3, 2)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

return fallAnim
