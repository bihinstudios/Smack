const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const resetRoundRe = /player1 = Character:new\(1, true, selectedPlayerPalette\)\s+player2 = Character:new\(2, false\)/;
const resetRoundRep = `player1 = Character:new(selectedPlayerPalette or 1, true)
    player2 = Character:new(selectedP2Palette or 2, false)`;
data = data.replace(resetRoundRe, resetRoundRep);

const optionsEnterRe = /if gameState == "options" and key == "return" then[\s\S]*?return\s+end/m;
const optionsEnterRep = `if gameState == "options" and key == "return" then
        player1 = Character:new(selectedPlayerPalette or 1, true)
        player2 = Character:new(selectedP2Palette or 2, false)
        p1Wins = 0
        p2Wins = 0
        roundNumber = 1
        resetRound()
        gameState = "round_intro"
        stateTimer = 2.0
        return
    end`;
data = data.replace(optionsEnterRe, optionsEnterRep);

fs.writeFileSync('main.lua', data);
