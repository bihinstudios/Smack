const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const aiAtkRe = /if attackName then[\s\S]*?end\n\s+end/m;
const aiAtkRep = `if attackName then
                triggerAttack(player2, attackName)
            end`;
data = data.replace(aiAtkRe, aiAtkRep);

fs.writeFileSync('main.lua', data);
