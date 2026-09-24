const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

// Replace mousepressed for options
const mouseRe = /if gameState == "options" and button == 1 then[\s\S]*?end\n    end/;
const mouseRep = `if gameState == "options" and button == 1 then
        local startX = (SCREEN_W - (3 * 150)) / 2 + 75
        local yPos = 200
        for i = 1, 3 do
            local nx = startX + (i - 1) * 150
            if x >= nx - 60 and x <= nx + 60 and y >= yPos - 60 and y <= yPos + 90 then
                if button == 1 then
                    -- Left click sets P1
                    selectedPlayerPalette = i
                end
            end
        end
    end`;
data = data.replace(mouseRe, mouseRep);

// We need a right click to set P2, or just we can let them use numbers? 
// The user said "and there you can choose enemy character as well". 
// Let's add a variable for p2 selection.
const varRe = /local selectedPlayerPalette = 1/;
const varRep = `local selectedPlayerPalette = 1\nlocal selectedP2Palette = 2`;
data = data.replace(varRe, varRep);

// Update drawOptionsScreen to show P2 selection
const drawOptionsRe = /PF\.drawTextCentered\("P1 SELECTS: " \.\. names\[selectedPlayerPalette\], 330, SCREEN_W, 2, COL\.white\)/;
const drawOptionsRep = `PF.drawTextCentered("P1: " .. names[selectedPlayerPalette], 330, SCREEN_W/2, 2, COL.cyan)
    PF.drawTextCentered("P2: " .. names[selectedP2Palette], 330, SCREEN_W * 1.5, 2, COL.red)`;
data = data.replace(drawOptionsRe, drawOptionsRep);

const p2DrawRe = /if selectedPlayerPalette == i then\s+love\.graphics\.setColor\(1, 0\.8, 0, 0\.4\)[\s\S]*?love\.graphics\.rectangle\("fill", x - 60, yPos - 60, 120, 150\)\s+end/;
const p2DrawRep = `if selectedPlayerPalette == i then
            love.graphics.setColor(0, 1, 1, 0.4)
            love.graphics.rectangle("fill", x - 60, yPos - 60, 60, 150)
            love.graphics.setColor(0, 1, 1, 1)
            love.graphics.rectangle("line", x - 60, yPos - 60, 60, 150)
        end
        if selectedP2Palette == i then
            love.graphics.setColor(1, 0, 0, 0.4)
            love.graphics.rectangle("fill", x, yPos - 60, 60, 150)
            love.graphics.setColor(1, 0, 0, 1)
            love.graphics.rectangle("line", x, yPos - 60, 60, 150)
        end
        if selectedPlayerPalette ~= i and selectedP2Palette ~= i then
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", x - 60, yPos - 60, 120, 150)
        end`;
data = data.replace(p2DrawRe, p2DrawRep);

const p2MouseRe = /if button == 1 then\s+-- Left click sets P1\s+selectedPlayerPalette = i\s+end/;
const p2MouseRep = `if button == 1 then
                    selectedPlayerPalette = i
                elseif button == 2 then
                    selectedP2Palette = i
                end`;
data = data.replace(p2MouseRe, p2MouseRep);

// The original mousepressed check only looks for button == 1.
const mouseDefRe = /if gameState == "options" and button == 1 then/;
const mouseDefRep = `if gameState == "options" then`;
data = data.replace(mouseDefRe, mouseDefRep);

// Make sure options screen tells them how to select P2
const hintRe = /drawBlinkHint\("ENTER - FIGHT    ESC - BACK", SCREEN_H - 40\)/;
const hintRep = `drawBlinkHint("LCLICK - P1 | RCLICK - P2 | ENTER - FIGHT | ESC - BACK", SCREEN_H - 40)`;
data = data.replace(hintRe, hintRep);

// Enter key starts game from options
const optionsKeyRe = /if gameState == "credits" or gameState == "how_to_play" or gameState == "options" or gameState == "online_lobby" then\s+if key == "escape" or \(key == "backspace" and gameState ~= "online_lobby"\) then/;
const optionsKeyRep = `if gameState == "options" and key == "return" then
        player1 = Character:new(selectedPlayerPalette, true)
        player2 = Character:new(selectedP2Palette, false)
        if gameMode == "pve" then ai = AI.new() else ai = nil end
        resetMatch()
        return
    end

    if gameState == "credits" or gameState == "how_to_play" or gameState == "options" or gameState == "online_lobby" then
        if key == "escape" or (key == "backspace" and gameState ~= "online_lobby") then`;
data = data.replace(optionsKeyRe, optionsKeyRep);

// Update initPlayers to respect selections
const initPRe = /function initPlayers\(\)\s+player1 = Character:new\(1, true\)\s+player2 = Character:new\(1, false\)/;
const initPRep = `function initPlayers()
    player1 = Character:new(selectedPlayerPalette or 1, true)
    player2 = Character:new(selectedP2Palette or 2, false)`;
data = data.replace(initPRe, initPRep);

fs.writeFileSync('main.lua', data);
