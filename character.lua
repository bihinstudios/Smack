local Character = {}

-------------------------------------------------------------------------------
-- ASSET LOADING (Called once from main.lua love.load)
-------------------------------------------------------------------------------
Character.images = {}

function Character.loadAssets()
    local types = {1, 2, 3}
    local frames = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"}
    
    for _, t in ipairs(types) do
        Character.images[t] = {}
        for _, f in ipairs(frames) do
            local path = "Asset/Ninja-" .. t .. "-" .. f .. ".png"
            local success, img = pcall(love.graphics.newImage, path)
            if success then
                img:setFilter("linear", "linear")
                Character.images[t][f] = img
            end
        end
    end
    
    Character.upcomingImages = {}
    for i = 1, 8 do
        local path = "Asset/Upcoming_Characters-" .. i .. ".png"
        local success, img = pcall(love.graphics.newImage, path)
        if success then
            img:setFilter("linear", "linear")
            Character.upcomingImages[i] = img
        end
    end
    end
end

-------------------------------------------------------------------------------
-- ANIMATION SEQUENCES DICTIONARY
-------------------------------------------------------------------------------
-- Mapping based on user input:
-- a: jump
-- b: offensive idle
-- c: block (defence from kick or slashes)
-- d: thrust (hunt in the chest)
-- e: pre-thrust
-- f: fireball (start)
-- g: pre-slash
-- h: defensive idle
-- i: slash 1
-- j: slash 2
-- k: move
-- l: fireball (end) / hit reaction

Character.animations = {
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
}

-------------------------------------------------------------------------------
-- ATTACK DATA CONFIGURATION
-------------------------------------------------------------------------------
Character.attackData = {
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
}

-------------------------------------------------------------------------------
-- CLASS CONSTRUCTOR & METHODS
-------------------------------------------------------------------------------
function Character:new(playerType, facingRight)
    local obj = {
        playerType = playerType,
        currentAnim = "idle",
        frameIdx = 1,
        timer = 0,
        angle = 0,
        facingRight = (facingRight == nil) and true or facingRight,

        -- Combat parameters
        chakra = 100,
        damageDealt = 0,
        isStunned = false,
        isPetrified = false,
        petrifyTimer = 0,
        stunTimer = 0,
        isDizzy = false,
        dizzyTimer = 0,
        hitRegistered = false,
        comboHits = 0,
        comboResetTimer = 0,
        knockbackVelX = 0,
        flashTimer = 0,
        deathTimer = 0
    }
    setmetatable(obj, { __index = Character })
    return obj
end

function Character:setAnimation(animName)
    if self.animations[animName] and self.currentAnim ~= animName then
        self.currentAnim = animName
        self.frameIdx = 1
        self.timer = 0
        self.angle = 0
        self.hitRegistered = false
    end
end

function Character:isAttacking()
    return self.attackData[self.currentAnim] ~= nil
end

function Character:update(dt)
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
    end

    if self.isStunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer <= 0 then
            self.isStunned = false
            self:setAnimation("idle")
        end
        return
    end

    if self.isDizzy then
        self.dizzyTimer = self.dizzyTimer - dt
        if self.dizzyTimer <= 0 then
            self.isDizzy = false
            self.comboHits = 0
            self:setAnimation("idle")
        end
        return
    end

    if self.currentAnim == "slow_death" then
        self.deathTimer = self.deathTimer + dt
        local targetAngle = self.facingRight and -90 or 90
        self.angle = (self.deathTimer / 0.5) * targetAngle
        if math.abs(self.angle) > 90 then
            self.angle = targetAngle
        end
        return
    end

    if self.comboResetTimer > 0 then
        self.comboResetTimer = self.comboResetTimer - dt
        if self.comboResetTimer <= 0 then
            self.comboHits = 0
        end
    end

    if math.abs(self.knockbackVelX) > 0 then
        self.knockbackVelX = self.knockbackVelX * (1 - 8 * dt)
        if math.abs(self.knockbackVelX) < 5 then
            self.knockbackVelX = 0
        end
    end

    local anim = self.animations[self.playerType][self.currentAnim]
    if not anim then return end

    if not self.isPetrified then
            self.timer = self.timer + dt
        end
        if self.timer >= anim.speed then
        self.timer = self.timer - anim.speed
        self.frameIdx = self.frameIdx + 1
        if self.frameIdx > #anim.frames then
            if anim.loop then
                self.frameIdx = 1
            else
                self.frameIdx = #anim.frames
                self:setAnimation("idle")
            end
        end
    end
end

function Character:takeHit(damage, knockbackDir, knockbackForce)
    self.chakra = math.max(0, self.chakra - damage)
    self.isStunned = true
    self.stunTimer = 0.25
    self.knockbackVelX = knockbackDir * knockbackForce
    self.flashTimer = 0.15

    self.comboHits = self.comboHits + 1
    self.comboResetTimer = 1.5

    self:setAnimation("hit_stun")

    if self.comboHits >= 4 then
        self.isDizzy = true
        self.dizzyTimer = 1.8
        self.isStunned = false
        self:setAnimation("dizzy")
    end

    if self.chakra <= 0 then
        self.isStunned = false
        self.isDizzy = false
        self:setAnimation("ko")
    end
end

function Character:draw(posX, posY, scale, isShadow)
    local anim = self.animations[self.playerType][self.currentAnim]
    if not anim then return end
    
    local frameKey = anim.frames[self.frameIdx]
    
    local imgTable = self.images[self.playerType] or self.images[1]
    local img = imgTable and imgTable[frameKey]
    if not img then return end

    local w = img:getWidth()
    local h = img:getHeight()

    love.graphics.push()
    
    love.graphics.translate(posX, posY)
    love.graphics.rotate(math.rad(self.angle))

    local drawScale = 1.2
    love.graphics.scale(self.facingRight and drawScale or -drawScale, drawScale)
    
    if isShadow then
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.shear(-0.5, 0)
        love.graphics.draw(img, -w/2, -h)
    else
        if self.flashTimer > 0 then
            local flash = self.flashTimer / 0.15
            love.graphics.setColor(1, 1 - flash, 1 - flash, 1)
        else
            -- Color tint based on player type if needed, but black silhouette is default
            if self.playerType == 2 then
                -- Add a slight dark red tint for P2 so they are distinguishable?
                -- Since image is black, tinting doesn't do much unless it has white pixels.
                if self.isPetrified then
            love.graphics.setColor(0.4, 0.4, 0.4, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
            else
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
        love.graphics.draw(img, -w/2, -h)
    end

    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

return Character
