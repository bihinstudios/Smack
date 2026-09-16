local Ground = {}

function Ground:draw(screenWidth, groundY, scale)
    scale = scale or 4
    local groundHeight = love.graphics.getHeight() - groundY

    -- Main Deck Base (Dark Indigo Stone / Timber)
    love.graphics.setColor(0.06, 0.05, 0.12, 1)
    love.graphics.rectangle("fill", 0, groundY, screenWidth, groundHeight)

    -- Wooden Deck Planking Lines
    love.graphics.setColor(0.12, 0.10, 0.22, 1)
    for x = 0, screenWidth, 24 * (scale / 2) do
        love.graphics.rectangle("fill", x, groundY, 2, groundHeight)
    end

    -- Japanese Red Lacquer Edge Trim
    love.graphics.setColor(0.58, 0.12, 0.22, 1)
    love.graphics.rectangle("fill", 0, groundY, screenWidth, 8)

    -- Gold Deck Fastener Accents
    love.graphics.setColor(0.88, 0.70, 0.25, 1)
    for x = 20, screenWidth, 80 do
        love.graphics.rectangle("fill", x, groundY + 2, 10, 4)
    end

    -- Stone Lanterns (Tōrō) Framing the Arena
    self:drawLantern(70, groundY - 48)
    self:drawLantern(screenWidth - 94, groundY - 48)
end

function Ground:drawLantern(x, y)
    -- Stone Pedestal
    love.graphics.setColor(0.12, 0.12, 0.20, 1)
    love.graphics.rectangle("fill", x + 6, y + 36, 12, 12)
    love.graphics.rectangle("fill", x + 9, y + 20, 6, 16)
    
    -- Glowing Fire Core
    love.graphics.setColor(0.98, 0.65, 0.20, 0.95)
    love.graphics.rectangle("fill", x + 6, y + 10, 12, 10)
    
    -- Wooden Frame & Curved Roof
    love.graphics.setColor(0.08, 0.06, 0.14, 1)
    love.graphics.rectangle("fill", x + 4, y + 10, 2, 10)
    love.graphics.rectangle("fill", x + 18, y + 10, 2, 10)
    love.graphics.rectangle("fill", x + 2, y + 6, 20, 4)
    love.graphics.rectangle("fill", x + 6, y + 2, 12, 4)
end

return Ground
