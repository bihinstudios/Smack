const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const windRe1 = /if player1\.currentAnim ~= oldAnimP1 and \(player1\.currentAnim == "slash" or player1\.currentAnim == "thrust" or player1\.currentAnim == "fireball"\) then\s+local y = Ground\.getGroundY\(player1X\) - 40\s+particles:spawnWindSlash\(player1X, y, player1\.facingRight and 1 or -1\)\s+end/;
const windRep1 = `if player1.currentAnim ~= oldAnimP1 then
            local y = Ground.getGroundY(player1X) - 40
            local dir = player1.facingRight and 1 or -1
            if player1.currentAnim == "slash" or player1.currentAnim == "thrust" or player1.currentAnim == "big_slash" or player1.currentAnim == "slash_combo" or player1.currentAnim == "leg_cut" then
                particles:spawnWindSlash(player1X, y, dir)
            elseif player1.currentAnim == "water_ball" then
                -- Could spawn a blue water ball particle
                particles:spawnWindSlash(player1X, y, dir) 
            elseif player1.currentAnim == "beam" or player1.currentAnim == "fireball" then
                -- Could spawn a large beam/fire particle
                particles:spawnWindSlash(player1X, y, dir)
            end
        end`;
data = data.replace(windRe1, windRep1);

const windRe2 = /if player2\.currentAnim ~= oldAnimP2 and \(player2\.currentAnim == "slash" or player2\.currentAnim == "thrust" or player2\.currentAnim == "fireball"\) then\s+local y = Ground\.getGroundY\(player2X\) - 40\s+particles:spawnWindSlash\(player2X, y, player2\.facingRight and 1 or -1\)\s+end/;
const windRep2 = `if player2.currentAnim ~= oldAnimP2 then
            local y = Ground.getGroundY(player2X) - 40
            local dir = player2.facingRight and 1 or -1
            if player2.currentAnim == "slash" or player2.currentAnim == "thrust" or player2.currentAnim == "big_slash" or player2.currentAnim == "slash_combo" or player2.currentAnim == "leg_cut" then
                particles:spawnWindSlash(player2X, y, dir)
            elseif player2.currentAnim == "water_ball" then
                particles:spawnWindSlash(player2X, y, dir) 
            elseif player2.currentAnim == "beam" or player2.currentAnim == "fireball" then
                particles:spawnWindSlash(player2X, y, dir)
            end
        end`;
data = data.replace(windRe2, windRep2);

fs.writeFileSync('main.lua', data);
