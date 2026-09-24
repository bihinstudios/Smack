const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const processHitRe = /local function processHit\(attacker, defender, atkX, defX, atkFacingRight\)[\s\S]*?local damage = atkData\.damage/;
const processHitRep = `local function processHit(attacker, defender, atkX, defX, atkFacingRight)
    local atkData = Character.attackData[attacker.playerType][attacker.currentAnim]
    attacker.hitRegistered = true

    local knockDir = atkFacingRight and 1 or -1
    
    -- Magic Stone dodge logic
    if attacker.currentAnim == "magic_stone" then
        local defGrounded = (defender == player1 and p1Grounded) or (defender == player2 and p2Grounded)
        if not defGrounded then
            return -- Dodged by jumping!
        end
        -- Apply petrification
        defender.isPetrified = true
        defender.petrifyTimer = 2.0
    end

    local damage = atkData.damage`;
data = data.replace(processHitRe, processHitRep);

// Also need to fix the attackData indexing in the update loop!
const atkData1Re = /local p1AttackData = Character\.attackData\[player1\.currentAnim\]/g;
const atkData1Rep = `local p1AttackData = Character.attackData[player1.playerType][player1.currentAnim]`;
data = data.replace(atkData1Re, atkData1Rep);

const atkData2Re = /local p2AttackData = Character\.attackData\[player2\.currentAnim\]/g;
const atkData2Rep = `local p2AttackData = Character.attackData[player2.playerType][player2.currentAnim]`;
data = data.replace(atkData2Re, atkData2Rep);

fs.writeFileSync('main.lua', data);
