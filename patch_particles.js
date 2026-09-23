const fs = require('fs');
let data = fs.readFileSync('particles.lua', 'utf8');

const windSlash = `
--- Dynamic wind slash for fast weapon attacks (thrust/slash)
function Particles:spawnWindSlash(x, y, direction)
    local dir = direction or 1
    
    table.insert(self.particles, {
        x = x,
        y = y,
        vx = 400 * dir,
        vy = -50 + math.random() * 100,
        life = 0.2,
        maxLife = 0.2,
        size = 8,
        color = {0.8, 0.9, 1, 0.9},
        shape = "wind", -- Custom shape
        gravity = 0,
        scaleX = 1.0
    })
    
    -- A few trailing wind streaks
    for i = 1, 3 do
        table.insert(self.particles, {
            x = x - (20 * dir),
            y = y + math.random(-20, 20),
            vx = 250 * dir,
            vy = 0,
            life = 0.15 + math.random() * 0.1,
            maxLife = 0.2,
            size = 2 + math.random() * 2,
            color = {0.6, 0.8, 1, 0.6},
            shape = "rect",
            gravity = 0
        })
    end
end
`;

data = data.replace('function Particles:spawnBigHit(x, y, direction)', windSlash + '\nfunction Particles:spawnBigHit(x, y, direction)');

const drawRe = /if p\.shape == "rect" then[\s\S]*?end/;
const drawRep = `if p.shape == "rect" then
                love.graphics.rectangle("fill", p.x - p.size/2, p.y - p.size/2, p.size, p.size)
            elseif p.shape == "circle" then
                love.graphics.circle("fill", p.x, p.y, p.size)
            elseif p.shape == "wind" then
                -- Draw a stretched slash crescent
                love.graphics.push()
                love.graphics.translate(p.x, p.y)
                local stretch = p.scaleX or 1
                love.graphics.scale(stretch * (p.vx > 0 and 1 or -1), 1 - (1 - p.life/p.maxLife))
                -- Quick polygon for a sharp crescent
                love.graphics.polygon("fill", -15, -4, 25, 0, -15, 4, -5, 0)
                love.graphics.pop()
            end`;
data = data.replace(drawRe, drawRep);

// Update logic to stretch wind
const updateRe = /p\.y = p\.y \+ p\.vy \* scaledDt/;
const updateRep = `p.y = p.y + p.vy * scaledDt
        if p.shape == "wind" then
            p.scaleX = (p.scaleX or 1) + 8 * scaledDt
        end`;
data = data.replace(updateRe, updateRep);

fs.writeFileSync('particles.lua', data);
