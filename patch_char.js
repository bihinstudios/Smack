const fs = require('fs');
let data = fs.readFileSync('character.lua', 'utf8');

const animRe = /Character\.animations = \{[\s\S]*?slow_death\s+=\s+\{ frames = \{"l"\}, speed = 1\.0, loop = false \}\n\}/;
const animRep = `Character.animations = {
    [1] = {
        idle           = { frames = {"b"}, speed = 1.0, loop = true },
        defensive_idle = { frames = {"h"}, speed = 1.0, loop = true },
        run            = { frames = {"k"}, speed = 1.0, loop = true },
        jump           = { frames = {"a"}, speed = 1.0, loop = true },
        block          = { frames = {"c"}, speed = 1.0, loop = true },
        thrust         = { frames = {"e", "d", "d"}, speed = 0.08, loop = false },
        slash          = { frames = {"g", "i", "j", "j"}, speed = 0.06, loop = false },
        fireball       = { frames = {"f", "l", "l"}, speed = 0.12, loop = false },
        hit_stun       = { frames = {"l"}, speed = 0.25, loop = false },
        dizzy          = { frames = {"l"}, speed = 0.2, loop = true },
        ko             = { frames = {"l"}, speed = 1.0, loop = true },
        slow_death     = { frames = {"l"}, speed = 1.0, loop = false }
    },
    [2] = {
        idle           = { frames = {"c"}, speed = 1.0, loop = true },
        run            = { frames = {"a"}, speed = 1.0, loop = true },
        jump           = { frames = {"d"}, speed = 1.0, loop = true },
        defensive_jump = { frames = {"g"}, speed = 1.0, loop = true },
        slash          = { frames = {"d", "b", "b"}, speed = 0.06, loop = false },
        big_slash      = { frames = {"k", "l", "l"}, speed = 0.08, loop = false },
        punch          = { frames = {"j", "i", "i"}, speed = 0.06, loop = false },
        low_kick       = { frames = {"f"}, speed = 0.1, loop = false },
        leg_cut        = { frames = {"h"}, speed = 0.1, loop = false },
        water_ball     = { frames = {"e", "e", "e"}, speed = 0.15, loop = false },
        hit_stun       = { frames = {"c"}, speed = 0.25, loop = false },
        dizzy          = { frames = {"c"}, speed = 0.2, loop = true },
        ko             = { frames = {"c"}, speed = 1.0, loop = true },
        slow_death     = { frames = {"c"}, speed = 1.0, loop = false }
    },
    [3] = {
        idle           = { frames = {"a"}, speed = 1.0, loop = true },
        offensive_idle = { frames = {"b"}, speed = 1.0, loop = true },
        jump           = { frames = {"j"}, speed = 1.0, loop = true },
        slash_combo    = { frames = {"e", "f", "h"}, speed = 0.08, loop = false },
        beam           = { frames = {"i", "k", "k"}, speed = 0.1, loop = false },
        stab           = { frames = {"l", "g", "g"}, speed = 0.08, loop = false },
        magic_stone    = { frames = {"d", "c", "c"}, speed = 0.15, loop = false },
        hit_stun       = { frames = {"a"}, speed = 0.25, loop = false },
        dizzy          = { frames = {"a"}, speed = 0.2, loop = true },
        ko             = { frames = {"a"}, speed = 1.0, loop = true },
        slow_death     = { frames = {"a"}, speed = 1.0, loop = false }
    }
}`;
data = data.replace(animRe, animRep);

const attackRe = /Character\.attackData = \{[\s\S]*?knockback = 200 \}\n\}/;
const attackRep = `Character.attackData = {
    [1] = {
        thrust   = { damage = 10, particle = "small",  range = 80,  knockback = 70 },
        slash    = { damage = 15, particle = "medium", range = 95,  knockback = 100 },
        fireball = { damage = 25, particle = "big",    range = 150, knockback = 200 }
    },
    [2] = {
        slash      = { damage = 12, particle = "medium", range = 90,  knockback = 80 },
        big_slash  = { damage = 20, particle = "big",    range = 120, knockback = 150 },
        punch      = { damage = 8,  particle = "small",  range = 70,  knockback = 50 },
        low_kick   = { damage = 10, particle = "small",  range = 80,  knockback = 60 },
        leg_cut    = { damage = 15, particle = "medium", range = 90,  knockback = 100 },
        water_ball = { damage = 18, particle = "big",    range = 150, knockback = 120 }
    },
    [3] = {
        slash_combo = { damage = 18, particle = "medium", range = 100, knockback = 120 },
        beam        = { damage = 22, particle = "big",    range = 180, knockback = 180 },
        stab        = { damage = 14, particle = "medium", range = 95,  knockback = 90 },
        magic_stone = { damage = 0,  particle = "none",   range = 250, knockback = 0 }
    }
}`;
data = data.replace(attackRe, attackRep);

// Update setAnimation and update to use [self.playerType]
const setAnimRe = /if self\.animations\[animName\] and self\.currentAnim ~= animName then\s+self\.currentAnim = animName\s+self\.frameIdx = 1\s+self\.timer = 0\s+end/;
const setAnimRep = `if self.animations[self.playerType][animName] and self.currentAnim ~= animName then
        self.currentAnim = animName
        self.frameIdx = 1
        self.timer = 0
    end`;
data = data.replace(setAnimRe, setAnimRep);

const getAnimRe = /local anim = self\.animations\[self\.currentAnim\]/g;
const getAnimRep = `local anim = self.animations[self.playerType][self.currentAnim]`;
data = data.replace(getAnimRe, getAnimRep);

// Also we need to add petrified state to character
const classRe = /isStunned = false,/;
const classRep = `isStunned = false,
        isPetrified = false,
        petrifyTimer = 0,`;
data = data.replace(classRe, classRep);

// Update logic for petrify
const updateRe = /if self\.stunTimer > 0 then\s+self\.stunTimer = self\.stunTimer - dt\s+if self\.stunTimer <= 0 then\s+self\.isStunned = false\s+self:setAnimation\("idle"\)\s+end\s+end/;
const updateRep = `if self.stunTimer > 0 then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer <= 0 then
            self.isStunned = false
            self:setAnimation("idle")
        end
    end
    
    if self.petrifyTimer > 0 then
        self.petrifyTimer = self.petrifyTimer - dt
        self.chakra = math.max(0, self.chakra - 3 * dt) -- drain health/energy
        if self.petrifyTimer <= 0 then
            self.isPetrified = false
            self:setAnimation("idle")
        end
    end`;
data = data.replace(updateRe, updateRep);

// Freeze animation if petrified
const frameRe = /self\.timer = self\.timer \+ dt\s+if self\.timer >= anim\.speed then/;
const frameRep = `if not self.isPetrified then
            self.timer = self.timer + dt
        end
        if self.timer >= anim.speed then`;
data = data.replace(frameRe, frameRep);

// Tint gray if petrified
const drawRe = /love\.graphics\.setColor\(1, 1, 1, 1\)/;
const drawRep = `if self.isPetrified then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end`;
data = data.replace(drawRe, drawRep);

fs.writeFileSync('character.lua', data);
