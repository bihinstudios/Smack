const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

data = data.replace('love.graphics.setDefaultFilter("nearest", "nearest")', 'Character.loadAssets()\n    love.graphics.setDefaultFilter("nearest", "nearest")');

const p1re = /key == "f" then player1:setAnimation\("punch"\)[\s\S]*?elseif key == "h" and not p1Grounded then player1:setAnimation\("jump_punch"\)[\s\S]*?end/;
data = data.replace(p1re, `key == "f" then player1:setAnimation("thrust")
            elseif key == "g" then player1:setAnimation("slash")
            elseif key == "z" then
                if player1.damageDealt >= 60 then player1:setAnimation("fireball") end
            elseif key == "h" and not p1Grounded then player1:setAnimation("slash")
            end`);

const p2re1 = /key == "f" then player2:setAnimation\("punch"\)[\s\S]*?elseif key == "h" and not p2Grounded then player2:setAnimation\("jump_punch"\)[\s\S]*?end/;
data = data.replace(p2re1, `key == "f" then player2:setAnimation("thrust")
                elseif key == "g" then player2:setAnimation("slash")
                elseif key == "z" then
                    if player2.damageDealt >= 60 then player2:setAnimation("fireball") end
                elseif key == "h" and not p2Grounded then player2:setAnimation("slash")
                end`);

const p2re2 = /key == "j" then player2:setAnimation\("punch"\)[\s\S]*?elseif key == "l" and not p2Grounded then player2:setAnimation\("jump_punch"\)[\s\S]*?end/;
data = data.replace(p2re2, `key == "j" then player2:setAnimation("thrust")
                elseif key == "k" then player2:setAnimation("slash")
                elseif key == "n" then
                    if player2.damageDealt >= 60 then player2:setAnimation("fireball") end
                elseif key == "l" and not p2Grounded then player2:setAnimation("slash")
                end`);

const ui1re = /\{"W,A,S,D", "MOVE \/ JUMP"\}[\s\S]*?\{"ESC", "PAUSE"\}/;
data = data.replace(ui1re, `{"W,A,S,D", "MOVE / JUMP"},
        {"F", "THRUST"},
        {"G", "SLASH"},
        {"Z", "FIREBALL (IF 60 DMG DEALT)"},
        {"C, V", "BLOCK HIGH/LOW"},
        {"H", "AERIAL SLASH"},
        {"ESC", "PAUSE"}`);

const ui2re = /PF\.drawTextCentered\("WASD MOVE.*?ESC PAUSE"/;
data = data.replace(ui2re, `PF.drawTextCentered("WASD MOVE  B/N BLOCK  F THRUST  G SLASH  Z FIREBALL"`);

const phRe = /local damage = atkData\.damage\s+if defender\.isBlocking then\s+damage = math\.floor\(damage \* 0\.2\)\s+end\s+defender:takeHit\(damage, knockDir, atkData\.knockback\)/;
data = data.replace(phRe, `local damage = atkData.damage
    if defender.isBlocking then
        damage = math.floor(damage * 0.2)
    end

    defender:takeHit(damage, knockDir, atkData.knockback)
    attacker.damageDealt = attacker.damageDealt + damage`);

const zoomRe = /local isCombo = \(attacker\.currentAnim == "punch_combo" or attacker\.currentAnim == "kick_combo"\)/;
data = data.replace(zoomRe, `local isCombo = (attacker.currentAnim == "slash" or attacker.currentAnim == "fireball")`);

fs.writeFileSync('main.lua', data);
