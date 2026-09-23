const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const updateRe = /player1:update\(scaledDt\)/;
const updateRep = `local oldAnimP1 = player1.currentAnim
        player1:update(scaledDt)
        if player1.currentAnim ~= oldAnimP1 and (player1.currentAnim == "slash" or player1.currentAnim == "thrust" or player1.currentAnim == "fireball") then
            local y = Ground.getGroundY(player1X) - 40
            particles:spawnWindSlash(player1X, y, player1.facingRight and 1 or -1)
        end`;
data = data.replace(updateRe, updateRep);

const update2Re = /player2:update\(scaledDt\)/;
const update2Rep = `local oldAnimP2 = player2.currentAnim
        player2:update(scaledDt)
        if player2.currentAnim ~= oldAnimP2 and (player2.currentAnim == "slash" or player2.currentAnim == "thrust" or player2.currentAnim == "fireball") then
            local y = Ground.getGroundY(player2X) - 40
            particles:spawnWindSlash(player2X, y, player2.facingRight and 1 or -1)
        end`;
data = data.replace(update2Re, update2Rep);

fs.writeFileSync('main.lua', data);
