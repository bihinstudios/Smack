const fs = require('fs');
let data = fs.readFileSync('ai.lua', 'utf8');

const baseAttacksRe = /local baseAttacks = \{[\s\S]*?\n\}/;
const baseAttacksRep = `-- Attacks are generated dynamically based on playerType inside update`;
data = data.replace(baseAttacksRe, baseAttacksRep);

const availAttacksRe = /local availableAttacks = \{ baseAttacks\[1\], baseAttacks\[2\] \}\s+if aiChar\.damageDealt >= 60 then\s+table\.insert\(availableAttacks, \{ name = "fireball", weight = 6, range = 180 \}\)\s+end/;
const availAttacksRep = `local availableAttacks = {}
            if aiChar.playerType == 1 then
                availableAttacks = {
                    { name = "light", weight = 5 },
                    { name = "heavy", weight = 4 }
                }
                if aiChar.damageDealt >= 60 then
                    table.insert(availableAttacks, { name = "sp1", weight = 6 })
                end
            elseif aiChar.playerType == 2 then
                availableAttacks = {
                    { name = "light", weight = 5 },
                    { name = "heavy", weight = 4 },
                    { name = "sp1", weight = 3 },
                    { name = "sp2", weight = 4 }
                }
            elseif aiChar.playerType == 3 then
                availableAttacks = {
                    { name = "light", weight = 5 },
                    { name = "heavy", weight = 4 },
                    { name = "sp1", weight = 3 },
                    { name = "sp2", weight = 4 }
                }
            end`;
data = data.replace(availAttacksRe, availAttacksRep);

const jumpSlashRe = /attackName = "slash"/g;
const jumpSlashRep = `attackName = "sp2"`;
data = data.replace(jumpSlashRe, jumpSlashRep);

const fireballRe = /attackName ~= "fireball"/g;
const fireballRep = `attackName ~= "sp1"`;
data = data.replace(fireballRe, fireballRep);

fs.writeFileSync('ai.lua', data);
