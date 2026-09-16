local AI = {}
AI.__index = AI

function AI.new()
    local self = setmetatable({}, AI)
    self.thinkTimer = 0         -- time until next decision
    self.thinkInterval = 0.3    -- seconds between decisions
    self.aggression = 0.65      -- probability of attacking when in range
    self.currentAction = "idle" -- idle | approach | attack | retreat
    self.attackCooldown = 0     -- prevent spam
    self.retreatTimer = 0
    return self
end

-- Available attacks with weights (higher = more likely to pick)
local attacks = {
    { name = "punch",       weight = 5,  range = 90 },
    { name = "kick",        weight = 4,  range = 95 },
    { name = "uppercut",    weight = 3,  range = 85 },
    { name = "lowercut",    weight = 3,  range = 85 },
    { name = "low_kick",    weight = 3,  range = 95 },
    { name = "high_kick",   weight = 2,  range = 90 },
    { name = "punch_combo", weight = 1,  range = 80 },
    { name = "kick_combo",  weight = 1,  range = 85 },
}

local function weightedRandom(list)
    local totalWeight = 0
    for _, entry in ipairs(list) do
        totalWeight = totalWeight + entry.weight
    end
    local roll = math.random() * totalWeight
    local running = 0
    for _, entry in ipairs(list) do
        running = running + entry.weight
        if roll <= running then
            return entry
        end
    end
    return list[1]
end

--- Main update: returns moveDir (-1, 0, 1), jumpRequest (bool), attackName (string or nil)
function AI:update(dt, aiX, aiY, aiGrounded, playerX, playerY, aiChar)
    local moveDir = 0
    local jumpRequest = false
    local attackName = nil

    -- Cooldowns
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end
    if self.retreatTimer > 0 then
        self.retreatTimer = self.retreatTimer - dt
    end

    -- Don't act while stunned or mid-attack
    if aiChar.isStunned or aiChar.isDizzy then
        return 0, false, nil
    end
    -- If currently attacking, don't override
    local curAnim = aiChar.currentAnim
    if curAnim ~= "idle" and curAnim ~= "run" and curAnim ~= "jump" and curAnim ~= "stand" then
        return 0, false, nil
    end

    self.thinkTimer = self.thinkTimer - dt
    if self.thinkTimer > 0 then
        -- Continue last decision
        if self.currentAction == "approach" then
            if playerX > aiX then moveDir = 1
            elseif playerX < aiX then moveDir = -1
            end
        elseif self.currentAction == "retreat" then
            if playerX > aiX then moveDir = -1
            else moveDir = 1 end
        end
        return moveDir, false, nil
    end

    -- Time to think
    self.thinkTimer = self.thinkInterval + math.random() * 0.15

    local dist = math.abs(playerX - aiX)
    local attackRange = 100

    if self.retreatTimer > 0 then
        self.currentAction = "retreat"
        if playerX > aiX then moveDir = -1 else moveDir = 1 end
        return moveDir, false, nil
    end

    if dist > attackRange then
        -- Approach the player
        self.currentAction = "approach"
        if playerX > aiX then moveDir = 1
        elseif playerX < aiX then moveDir = -1
        end

        -- Occasionally jump while approaching
        if aiGrounded and math.random() < 0.08 then
            jumpRequest = true
        end
    else
        -- In attack range
        if self.attackCooldown <= 0 and math.random() < self.aggression then
            -- Pick an attack
            local chosen = weightedRandom(attacks)
            attackName = chosen.name
            self.attackCooldown = 0.4 + math.random() * 0.3
            self.currentAction = "attack"

            -- Sometimes jump punch
            if not aiGrounded and math.random() < 0.3 then
                attackName = "jump_punch"
            end
            if aiGrounded and math.random() < 0.12 then
                jumpRequest = true
                attackName = "jump_punch"
            end
        else
            -- Idle or slight retreat
            if math.random() < 0.3 then
                self.currentAction = "retreat"
                self.retreatTimer = 0.2 + math.random() * 0.3
                if playerX > aiX then moveDir = -1 else moveDir = 1 end
            else
                self.currentAction = "idle"
                moveDir = 0
            end
        end
    end

    return moveDir, jumpRequest, attackName
end

return AI
