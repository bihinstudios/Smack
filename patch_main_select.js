const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const drawOptionsRe = /local function drawOptionsScreen\(\)[\s\S]*?end\n\n---------------------------------------------------------------/m;
const drawOptionsRep = `local function drawOptionsScreen()
    drawBackgroundEnvironment()
    drawDarkOverlay(0.8)

    PF.drawTextCentered("CHARACTER SELECT", 30, SCREEN_W, 5, COL.gold)

    -- Top half: 3 playable characters
    local names = {"SHINSUKE", "DAISUKE", "ITSUKI"}
    local startX = (SCREEN_W - (3 * 150)) / 2 + 75
    local yPos = 200

    for i = 1, 3 do
        local x = startX + (i - 1) * 150
        
        if selectedPlayerPalette == i then
            love.graphics.setColor(1, 0.8, 0, 0.4)
            love.graphics.rectangle("fill", x - 60, yPos - 60, 120, 150)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle("line", x - 60, yPos - 60, 120, 150)
        else
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", x - 60, yPos - 60, 120, 150)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
        if Character.images[i] and Character.images[i]["a"] then
            -- Draw a sample frame (e.g., jump or idle)
            local img = Character.images[i]["b"] or Character.images[i]["a"]
            if img then
                love.graphics.draw(img, x, yPos, 0, 4, 4, img:getWidth()/2, img:getHeight()/2)
            end
        end
        
        PF.drawTextCentered(names[i], yPos + 100, x * 2, 2, selectedPlayerPalette == i and COL.cyan or COL.white)
    end
    
    PF.drawTextCentered("P1 SELECTS: " .. names[selectedPlayerPalette], 330, SCREEN_W, 2, COL.white)

    -- Bottom half: Upcoming Characters (8 items)
    PF.drawTextCentered("UPCOMING CHARACTERS", 380, SCREEN_W, 3, COL.red)
    
    local ucStartX = (SCREEN_W - (4 * 100)) / 2 + 50
    local ucY1 = 450
    local ucY2 = 550
    
    love.graphics.setColor(1, 1, 1, 0.4) -- Fade them out a bit
    for i = 1, 8 do
        local row = (i <= 4) and 1 or 2
        local col = (i <= 4) and i or (i - 4)
        local bx = ucStartX + (col - 1) * 100
        local by = (row == 1) and ucY1 or ucY2
        
        if Character.upcomingImages and Character.upcomingImages[i] then
            local img = Character.upcomingImages[i]
            love.graphics.draw(img, bx, by, 0, 2.5, 2.5, img:getWidth()/2, img:getHeight()/2)
        end
        
        PF.drawTextCentered("COMING SOON", by + 40, bx * 2, 1, COL.white)
    end
    love.graphics.setColor(1, 1, 1, 1)

    drawBlinkHint("ENTER - FIGHT    ESC - BACK", SCREEN_H - 40)
end

---------------------------------------------------------------`;
data = data.replace(drawOptionsRe, drawOptionsRep);

fs.writeFileSync('main.lua', data);
