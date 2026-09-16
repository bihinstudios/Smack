local Particles = {}
Particles.__index = Particles

-- A single particle
-- { x, y, vx, vy, life, maxLife, size, color, shape }

function Particles.new()
    local self = setmetatable({}, Particles)
    self.particles = {}
    return self
end

---------------------------------------------------------------
-- SPAWN HELPERS
---------------------------------------------------------------

--- Small sparks for normal hits (punch, kick)
function Particles:spawnSmallHit(x, y, direction)
    local dir = direction or 1
    for i = 1, 8 do
        local angle = math.random() * math.pi - math.pi / 2  -- spread in front
        local speed = 80 + math.random() * 160
        table.insert(self.particles, {
            x = x + math.random(-4, 4),
            y = y + math.random(-4, 4),
            vx = math.cos(angle) * speed * dir,
            vy = math.sin(angle) * speed - 40,
            life = 0.18 + math.random() * 0.15,
            maxLife = 0.18 + math.random() * 0.15,
            size = 2 + math.random() * 2,
            color = self:_randomSmallColor(),
            shape = "rect",
            gravity = 200
        })
    end
end

--- Medium clash burst for jump_punch / uppercut
function Particles:spawnMediumHit(x, y, direction)
    local dir = direction or 1
    -- central flash
    table.insert(self.particles, {
        x = x, y = y,
        vx = 0, vy = 0,
        life = 0.12, maxLife = 0.12,
        size = 18,
        color = {1, 1, 1, 1},
        shape = "circle",
        gravity = 0
    })
    -- ring of sparks
    for i = 1, 18 do
        local angle = (i / 18) * math.pi * 2
        local speed = 120 + math.random() * 200
        table.insert(self.particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed * (0.6 + 0.8 * dir),
            vy = math.sin(angle) * speed - 30,
            life = 0.25 + math.random() * 0.2,
            maxLife = 0.25 + math.random() * 0.2,
            size = 2.5 + math.random() * 3,
            color = self:_randomMediumColor(),
            shape = "rect",
            gravity = 140
        })
    end
end

--- Big clash burst for combos
function Particles:spawnBigHit(x, y, direction)
    local dir = direction or 1
    -- huge white flash
    table.insert(self.particles, {
        x = x, y = y,
        vx = 0, vy = 0,
        life = 0.18, maxLife = 0.18,
        size = 30,
        color = {1, 1, 1, 1},
        shape = "circle",
        gravity = 0
    })
    -- secondary colored flash
    table.insert(self.particles, {
        x = x, y = y,
        vx = 0, vy = 0,
        life = 0.22, maxLife = 0.22,
        size = 22,
        color = {0.9, 0.3, 1, 0.8},
        shape = "circle",
        gravity = 0
    })
    -- explosive ring
    for i = 1, 30 do
        local angle = (i / 30) * math.pi * 2
        local speed = 160 + math.random() * 280
        table.insert(self.particles, {
            x = x + math.random(-3, 3),
            y = y + math.random(-3, 3),
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed - 50,
            life = 0.3 + math.random() * 0.3,
            maxLife = 0.3 + math.random() * 0.3,
            size = 3 + math.random() * 4,
            color = self:_randomBigColor(),
            shape = "rect",
            gravity = 100
        })
    end
end

--- Dizzy stars above a character's head
function Particles:spawnDizzy(x, y)
    for i = 1, 5 do
        local angle = (i / 5) * math.pi * 2
        table.insert(self.particles, {
            x = x + math.cos(angle) * 16,
            y = y - 10 + math.sin(angle) * 6,
            vx = math.cos(angle) * 30,
            vy = math.sin(angle) * 20 - 15,
            life = 0.4 + math.random() * 0.25,
            maxLife = 0.4 + math.random() * 0.25,
            size = 3 + math.random() * 2,
            color = self:_randomDizzyColor(),
            shape = "star",
            gravity = -20  -- float up slightly
        })
    end
end

---------------------------------------------------------------
-- UPDATE / DRAW
---------------------------------------------------------------

function Particles:update(dt)
    local i = 1
    while i <= #self.particles do
        local p = self.particles[i]
        p.life = p.life - dt
        if p.life <= 0 then
            table.remove(self.particles, i)
        else
            p.vy = p.vy + (p.gravity or 0) * dt
            p.x = p.x + p.vx * dt
            p.y = p.y + p.vy * dt
            -- shrink toward end of life
            p.size = p.size * (0.96 + 0.04 * (p.life / p.maxLife))
            i = i + 1
        end
    end
end

function Particles:draw()
    for _, p in ipairs(self.particles) do
        local alpha = math.min(1, (p.life / p.maxLife) * 2)
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha * (p.color[4] or 1))

        if p.shape == "circle" then
            love.graphics.circle("fill", p.x, p.y, p.size)
        elseif p.shape == "star" then
            -- draw a simple 4-point star using two overlapping rects
            local s = p.size
            love.graphics.rectangle("fill", p.x - s, p.y - s * 0.3, s * 2, s * 0.6)
            love.graphics.rectangle("fill", p.x - s * 0.3, p.y - s, s * 0.6, s * 2)
        else
            love.graphics.rectangle("fill", p.x - p.size / 2, p.y - p.size / 2, p.size, p.size)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

---------------------------------------------------------------
-- COLOR PALETTES
---------------------------------------------------------------

function Particles:_randomSmallColor()
    local colors = {
        {1.0, 0.85, 0.3, 1},   -- gold spark
        {1.0, 0.6, 0.15, 1},   -- orange spark
        {1.0, 1.0, 0.8, 1},    -- white-yellow
    }
    return colors[math.random(#colors)]
end

function Particles:_randomMediumColor()
    local colors = {
        {0.4, 0.8, 1.0, 1},    -- cyan
        {0.7, 0.5, 1.0, 1},    -- lavender
        {1.0, 1.0, 1.0, 1},    -- white
        {0.2, 0.9, 0.9, 1},    -- teal
        {0.9, 0.3, 1.0, 1},    -- magenta
    }
    return colors[math.random(#colors)]
end

function Particles:_randomBigColor()
    local colors = {
        {1.0, 0.2, 0.5, 1},    -- hot pink
        {0.9, 0.1, 1.0, 1},    -- neon magenta
        {0.5, 0.2, 1.0, 1},    -- electric purple
        {1.0, 1.0, 1.0, 1},    -- white
        {1.0, 0.7, 0.2, 1},    -- gold
        {0.2, 0.8, 1.0, 1},    -- cyan
    }
    return colors[math.random(#colors)]
end

function Particles:_randomDizzyColor()
    local colors = {
        {1.0, 1.0, 0.3, 1},    -- yellow star
        {0.3, 1.0, 1.0, 1},    -- cyan star
        {1.0, 0.5, 1.0, 1},    -- pink star
        {1.0, 1.0, 1.0, 1},    -- white star
    }
    return colors[math.random(#colors)]
end

return Particles
