const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const triggerFunc = `
local function triggerAttack(player, moveType)
    if player.isStunned or player.isPetrified or player.isDizzy then return end

    local pType = player.playerType
    local isAir = not (player == player1 and p1Grounded or player == player2 and p2Grounded)
    
    if pType == 1 then
        if moveType == "light" then player:setAnimation("thrust")
        elseif moveType == "heavy" then player:setAnimation("slash")
        elseif moveType == "sp1" then
            if player.damageDealt >= 60 then player:setAnimation("fireball") end
        elseif moveType == "sp2" then
            if isAir then player:setAnimation("slash") end
        end
        
    elseif pType == 2 then
        if moveType == "light" then player:setAnimation("punch")
        elseif moveType == "heavy" then player:setAnimation("slash")
        elseif moveType == "sp1" then player:setAnimation("water_ball")
        elseif moveType == "sp2" then player:setAnimation("big_slash")
        end
        
    elseif pType == 3 then
        if moveType == "light" then player:setAnimation("stab")
        elseif moveType == "heavy" then player:setAnimation("slash_combo")
        elseif moveType == "sp1" then player:setAnimation("beam")
        elseif moveType == "sp2" then player:setAnimation("magic_stone")
        end
    end
end
`;

const insertPtRe = /function love\.keypressed\(key\)/;
data = data.replace(insertPtRe, triggerFunc + '\nfunction love.keypressed(key)');

// Replace P1 inputs
const p1KeysRe = /if\s+key == "f" then player1:setAnimation\("thrust"\)[\s\S]*?elseif key == "h" and not p1Grounded then player1:setAnimation\("slash"\)\s+end/;
const p1KeysRep = `if key == "f" then triggerAttack(player1, "light")
            elseif key == "g" then triggerAttack(player1, "heavy")
            elseif key == "z" then triggerAttack(player1, "sp1")
            elseif key == "h" then triggerAttack(player1, "sp2")
            end`;
data = data.replace(p1KeysRe, p1KeysRep);

// Replace P2 inputs
const p2KeysRe = /if\s+key == "f" then player2:setAnimation\("thrust"\)[\s\S]*?elseif key == "h" and not p2Grounded then player2:setAnimation\("slash"\)\s+end/;
const p2KeysRep = `if key == "f" then triggerAttack(player2, "light")
                elseif key == "g" then triggerAttack(player2, "heavy")
                elseif key == "z" then triggerAttack(player2, "sp1")
                elseif key == "h" then triggerAttack(player2, "sp2")
                end`;
data = data.replace(p2KeysRe, p2KeysRep);

const p2Keys2Re = /if\s+key == "j" then player2:setAnimation\("thrust"\)[\s\S]*?elseif key == "l" and not p2Grounded then player2:setAnimation\("slash"\)\s+end/;
const p2Keys2Rep = `if key == "j" then triggerAttack(player2, "light")
                elseif key == "k" then triggerAttack(player2, "heavy")
                elseif key == "n" then triggerAttack(player2, "sp1")
                elseif key == "l" then triggerAttack(player2, "sp2")
                end`;
data = data.replace(p2Keys2Re, p2Keys2Rep);

// Also update UI text
const uiRe = /\{"F", "THRUST"\},[\s\S]*?\{"H", "AERIAL SLASH"\}/;
const uiRep = `{"F", "LIGHT ATK"},
        {"G", "HEAVY ATK"},
        {"Z", "SPECIAL 1"},
        {"H", "SPECIAL 2"}`;
data = data.replace(uiRe, uiRep);

const uiTextRe = /PF\.drawTextCentered\("WASD MOVE.*?FIREBALL"/;
const uiTextRep = `PF.drawTextCentered("WASD MOVE  F LIGHT  G HEAVY  Z SP1  H SP2"`;
data = data.replace(uiTextRe, uiTextRep);


fs.writeFileSync('main.lua', data);
