local Character = require("character")
local Ground    = require("ground")
local Particles = require("particles")
local AI        = require("ai")
local PF        = require("pixelfont")
local Intro     = require("intro")

local WS = require("websocket")
local wsClient
local onlineStatus = ""
local localPlayerNum = 1
local roomCodeInput = ""

-- !! Your Render.com server URL !!
local SERVER_HOST = "smack-fm1p.onrender.com"
local SERVER_PORT = 443

---------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------
local SCREEN_W     = 900
local SCREEN_H     = 600
local SCALE        = 4
local GROUND_Y     = 440
local CHAR_H       = 18 * SCALE
local GRAVITY      = 1000
local JUMP_IMPULSE = -400
local MOVE_SPEED   = 200
local STAGE_LEFT   = 10
local STAGE_RIGHT  = SCREEN_W - 80
local MAX_ROUNDS   = 3
local ROUND_WIN_NEED = 2

---------------------------------------------------------------
-- COLOUR PALETTE
---------------------------------------------------------------
local COL = {
    titleMain     = {0.80, 0.40, 1.00, 1},
    titleGlow     = {0.60, 0.20, 1.00, 0.35},
    subtitle      = {0.20, 0.85, 1.00, 1},
    menuNormal    = {0.50, 0.45, 0.60, 0.70},
    menuSelected  = {0.30, 1.00, 1.00, 1},
    cursor        = {1.00, 0.85, 0.20, 1},
    white         = {1, 1, 1, 1},
    dimText       = {0.55, 0.50, 0.70, 0.60},
    gold          = {1.00, 0.85, 0.20, 1},
    cyan          = {0.30, 1.00, 1.00, 1},
    magenta       = {0.90, 0.30, 1.00, 1},
    separator     = {0.40, 0.30, 0.55, 0.50},
    label         = {0.90, 0.85, 1.00, 1},
    hint          = {0.50, 0.40, 0.70, 0.50},
    roundText     = {0.70, 0.50, 1.00, 0.90},
    fight         = {1, 0.30, 0.30, 1},
    roundAnnounce = {1, 0.90, 0.20, 1},
    p1Win         = {0.80, 0.40, 1.00, 1},
    p2Win         = {0.20, 0.85, 1.00, 1},
    comingSoon    = {0.50, 0.45, 0.60, 0.60},
}

---------------------------------------------------------------
-- GAME STATE
---------------------------------------------------------------
-- States: intro, menu, options, credits, how_to_play,
--         round_intro, playing, paused, round_over, match_over
local gameState   = "intro"
local roundNumber = 1
local p1Wins      = 0
local p2Wins      = 0
local stateTimer  = 0
local matchWinner = 0
local cloudTimer  = 0
local selectedPlayerPalette = 1
local optionsNinjas = {}

---------------------------------------------------------------
-- MENU / PAUSE SELECTION
---------------------------------------------------------------
local menuItems    = {"1P VS AI", "2P LOCAL", "2P ONLINE", "OPTIONS", "CREDITS", "HOW TO PLAY", "QUIT"}
local gameMode     = "1p_ai"
local menuSelected = 1

local pauseItems    = {"CONTINUE", "RESTART", "MENU"}
local pauseSelected = 1

---------------------------------------------------------------
-- PLAYER STATE
---------------------------------------------------------------
local player1, player2
local p1X, p1Y, p1VelY, p1Grounded
local p2X, p2Y, p2VelY, p2Grounded

---------------------------------------------------------------
-- SYSTEMS
---------------------------------------------------------------
local particles
local aiController

---------------------------------------------------------------
-- HELPER: reset for a new round
---------------------------------------------------------------
local function resetRound()
    p1X, p1Y  = 180, GROUND_Y - CHAR_H
    p1VelY    = 0
    p1Grounded = true

    p2X, p2Y  = SCREEN_W - 250, GROUND_Y - CHAR_H
    p2VelY    = 0
    p2Grounded = true

    player1 = Character:new(1, true, selectedPlayerPalette)
    player2 = Character:new(2, false)

    particles    = Particles.new()
    aiController = AI.new()
end

---------------------------------------------------------------
-- LOVE CALLBACKS
---------------------------------------------------------------
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    resetRound()
    Intro.load()
    
    for i = 1, 5 do
        optionsNinjas[i] = Character:new(1, true, i)
        optionsNinjas[i]:setAnimation("stand")
    end
    
    gameState = "intro"
end

---------------------------------------------------------------
-- HIT DETECTION
---------------------------------------------------------------
local function checkHit(attacker, defender, atkX, defX, atkFacingRight)
    if attacker.hitRegistered then return false end
    if not attacker:isAttacking() then return false end
    if defender.isStunned or defender.isDizzy then return false end
    if defender.chakra <= 0 then return false end

    local atkData = Character.attackData[attacker.currentAnim]
    if not atkData then return false end

    local dist = math.abs(atkX - defX)
    if dist > atkData.range then return false end

    -- Must face the defender
    if atkFacingRight  and defX < atkX then return false end
    if not atkFacingRight and defX > atkX then return false end

    return true
end

local function processHit(attacker, defender, atkX, defX, atkFacingRight)
    local atkData = Character.attackData[attacker.currentAnim]
    attacker.hitRegistered = true

    local knockDir = atkFacingRight and 1 or -1
    
    local damage = atkData.damage
    if defender.isBlocking then
        damage = math.floor(damage * 0.2)
    end

    defender:takeHit(damage, knockDir, atkData.knockback)

    -- Particles at impact point
    local hitX = (atkX + defX) / 2
    local hitY = GROUND_Y - CHAR_H / 2 - 10

    if atkData.particle == "small" then
        particles:spawnSmallHit(hitX, hitY, knockDir)
    elseif atkData.particle == "medium" then
        particles:spawnMediumHit(hitX, hitY, knockDir)
    elseif atkData.particle == "big" then
        particles:spawnBigHit(hitX, hitY, knockDir)
    end

    if defender.isDizzy then
        particles:spawnDizzy(defX + 30, GROUND_Y - CHAR_H - 12)
    end
end

---------------------------------------------------------------
-- NETWORK MESSAGE HANDLER
---------------------------------------------------------------
local function handleServerMessage(msg)
    if msg == "WAITING" then
        onlineStatus = "WAITING FOR OPPONENT..."
    elseif string.sub(msg, 1, 12) == "ROOM_CREATED" then
        local code = string.sub(msg, 14)
        onlineStatus = "ROOM CODE: " .. code .. "\nSHARE THIS WITH YOUR FRIEND!"
    elseif msg == "ERROR|ROOM_FULL" then
        onlineStatus = "ROOM IS FULL!"
        if wsClient then wsClient:close(); wsClient = nil end
    elseif msg == "ERROR|ROOM_NOT_FOUND" then
        onlineStatus = "ROOM NOT FOUND!"
        if wsClient then wsClient:close(); wsClient = nil end
    elseif string.sub(msg, 1, 6) == "MATCH|" then
        local pNum = tonumber(string.sub(msg, 7))
        localPlayerNum = pNum
        onlineStatus = "MATCH FOUND! YOU ARE P" .. pNum
        resetRound(); roundNumber = 1; p1Wins = 0; p2Wins = 0
        gameState = "round_intro"; stateTimer = 2
    elseif string.sub(msg, 1, 5) == "SYNC|" and gameState == "playing" then
        local parts = {}
        for part in string.gmatch(msg, "[^|]+") do table.insert(parts, part) end
        local opX = tonumber(parts[2])
        local opY = tonumber(parts[3])
        local opVelY = tonumber(parts[4])
        local opGrounded = (parts[5] == "1")
        local opAnim = parts[6]
        local opChakra = tonumber(parts[7])
        local opBlocking = (parts[8] == "1")
        local opStunned = (parts[9] == "1")
        local opDizzy = (parts[10] == "1")
        local opFlash = tonumber(parts[11])
        local opFacing = (parts[12] == "1")
        
        local opponent = (localPlayerNum == 1) and player2 or player1
        if localPlayerNum == 1 then
            p2X, p2Y, p2VelY, p2Grounded = opX, opY, opVelY, opGrounded
        else
            p1X, p1Y, p1VelY, p1Grounded = opX, opY, opVelY, opGrounded
        end
        
        opponent.currentAnim = opAnim
        opponent.chakra = opChakra
        opponent.isBlocking = opBlocking
        opponent.isStunned = opStunned
        opponent.isDizzy = opDizzy
        opponent.flashTimer = opFlash
        opponent.facingRight = opFacing
    elseif msg == "DISCONNECT" then
        gameState = "online_lobby"
        onlineStatus = "OPPONENT DISCONNECTED."
    end
end

---------------------------------------------------------------
-- UPDATE
---------------------------------------------------------------
function love.update(dt)
    -- ==== NETWORK UPDATE ====
    if wsClient then
        wsClient:update()
        
        -- Send our state if playing
        if gameMode == "2p_online" and wsClient.connected and gameState == "playing" then
            local myP = (localPlayerNum == 1) and player1 or player2
            local myX = (localPlayerNum == 1) and p1X or p2X
            local myY = (localPlayerNum == 1) and p1Y or p2Y
            local myVelY = (localPlayerNum == 1) and p1VelY or p2VelY
            local myGrounded = (localPlayerNum == 1) and p1Grounded or p2Grounded
            local msg = string.format("SYNC|%.2f|%.2f|%.2f|%d|%s|%d|%d|%d|%d|%.2f|%d",
                myX, myY, myVelY, myGrounded and 1 or 0, myP.currentAnim, myP.chakra,
                myP.isBlocking and 1 or 0, myP.isStunned and 1 or 0,
                myP.isDizzy and 1 or 0, myP.flashTimer, myP.facingRight and 1 or 0)
            wsClient:send(msg)
        end
    end

    dt = math.min(dt, 1 / 30)
    cloudTimer = cloudTimer + dt * 15

    if gameState == "intro" then
        Intro.update(dt)
        if Intro.isFinished() then
            gameState = "menu"
        end
        return
    end

    -- Non-gameplay states: no update needed
    if gameState == "menu" or gameState == "credits"
       or gameState == "how_to_play" or gameState == "options"
       or gameState == "paused" then
        return
    end

    if gameState == "round_intro" then
        stateTimer = stateTimer - dt
        if stateTimer <= 0 then gameState = "playing" end
        return
    end

    if gameState == "round_over" then
        stateTimer = stateTimer - dt
        particles:update(dt)
        if stateTimer <= 0 then
            if p1Wins >= ROUND_WIN_NEED or p2Wins >= ROUND_WIN_NEED then
                gameState   = "match_over"
                matchWinner = p1Wins >= ROUND_WIN_NEED and 1 or 2
                stateTimer  = 4
            else
                roundNumber = roundNumber + 1
                resetRound()
                gameState  = "round_intro"
                stateTimer = 2
            end
        end
        return
    end

    if gameState == "match_over" then
        stateTimer = stateTimer - dt
        particles:update(dt)
        return
    end

    -- ============ PLAYING STATE ============

    -- Auto-face each other
    if p1X < p2X then
        player1.facingRight = true
        player2.facingRight = false
    else
        player1.facingRight = false
        player2.facingRight = true
    end

    -- ---- Player 1 movement (continuous) ----
    local isLocalP1 = (gameMode ~= "2p_online" or localPlayerNum == 1)
    local p1Moving = false
    if isLocalP1 and not player1.isStunned and not player1.isDizzy and player1.chakra > 0 then
        if love.keyboard.isDown("d") or (gameMode == "1p_ai" and love.keyboard.isDown("right")) then
            p1X = p1X + MOVE_SPEED * dt;  p1Moving = true
        end
        if love.keyboard.isDown("a") or (gameMode == "1p_ai" and love.keyboard.isDown("left")) then
            p1X = p1X - MOVE_SPEED * dt;  p1Moving = true
        end
        -- Block
        if love.keyboard.isDown("s") then
            player1.isBlocking = true
            if player1.currentAnim == "idle" or player1.currentAnim == "run" then
                player1:setAnimation("block_high")
            end
        elseif love.keyboard.isDown("c") then
            player1.isBlocking = true
            if player1.currentAnim == "idle" or player1.currentAnim == "run" then
                player1:setAnimation("block_low")
            end
        else
            player1.isBlocking = false
        end

        if p1Moving and p1Grounded and not player1:isAttacking() and not player1.isBlocking then
            player1:setAnimation("run")
        elseif not p1Moving and p1Grounded and player1.currentAnim == "run" then
            player1:setAnimation("idle")
        end
    end

    -- Knockback
    if math.abs(player1.knockbackVelX) > 1 then
        p1X = p1X + player1.knockbackVelX * dt
    end
    if math.abs(player2.knockbackVelX) > 1 then
        p2X = p2X + player2.knockbackVelX * dt
    end

    -- Clamp
    p1X = math.max(STAGE_LEFT, math.min(STAGE_RIGHT, p1X))
    p2X = math.max(STAGE_LEFT, math.min(STAGE_RIGHT, p2X))

    -- ---- P1 gravity ----
    if not p1Grounded then
        p1VelY = p1VelY + GRAVITY * dt
        p1Y    = p1Y + p1VelY * dt
        if p1Y >= GROUND_Y - CHAR_H then
            p1Y = GROUND_Y - CHAR_H;  p1VelY = 0;  p1Grounded = true
            if player1.currentAnim == "jump" or player1.currentAnim == "jump_punch" then
                player1:setAnimation("idle")
            end
        end
    end

    -- ---- P2 gravity ----
    if not p2Grounded then
        p2VelY = p2VelY + GRAVITY * dt
        p2Y    = p2Y + p2VelY * dt
        if p2Y >= GROUND_Y - CHAR_H then
            p2Y = GROUND_Y - CHAR_H;  p2VelY = 0;  p2Grounded = true
            if player2.currentAnim == "jump" or player2.currentAnim == "jump_punch" then
                player2:setAnimation("idle")
            end
        end
    end

    -- ---- AI or Player 2 (Local) ----
    if player2.chakra > 0 then
        if gameMode == "1p_ai" then
            local moveDir, jumpReq, attackName =
                aiController:update(dt, p2X, p2Y, p2Grounded, p1X, p1Y, player2)

            if moveDir ~= 0 and not player2:isAttacking() and not player2.isBlocking then
                p2X = p2X + moveDir * MOVE_SPEED * dt
                if p2Grounded and player2.currentAnim ~= "run" then
                    player2:setAnimation("run")
                end
            elseif moveDir == 0 and p2Grounded and player2.currentAnim == "run" then
                player2:setAnimation("idle")
            end

            if jumpReq and p2Grounded then
                player2:setAnimation("jump")
                p2VelY = JUMP_IMPULSE;  p2Grounded = false
            end

            if attackName then
                if attackName == "jump_punch" and not p2Grounded then
                    player2:setAnimation("jump_punch")
                elseif attackName ~= "jump_punch" then
                    player2:setAnimation(attackName)
                end
            end
        elseif (gameMode == "2p_local" or (gameMode == "2p_online" and localPlayerNum == 2)) and not player2.isStunned and not player2.isDizzy then
            local p2Moving = false
            if love.keyboard.isDown("right") or (gameMode == "2p_online" and love.keyboard.isDown("d")) then
                p2X = p2X + MOVE_SPEED * dt; p2Moving = true
            end
            if love.keyboard.isDown("left") or (gameMode == "2p_online" and love.keyboard.isDown("a")) then
                p2X = p2X - MOVE_SPEED * dt; p2Moving = true
            end
            if love.keyboard.isDown("down") or (gameMode == "2p_online" and love.keyboard.isDown("s")) then
                player2.isBlocking = true
                if player2.currentAnim == "idle" or player2.currentAnim == "run" then
                    player2:setAnimation("block_high")
                end
            else
                player2.isBlocking = false
            end
            
            if p2Moving and p2Grounded and not player2:isAttacking() and not player2.isBlocking then
                player2:setAnimation("run")
            elseif not p2Moving and p2Grounded and player2.currentAnim == "run" then
                player2:setAnimation("idle")
            end
        end
    end

    -- ---- Hit detection ----
    if checkHit(player1, player2, p1X, p2X, player1.facingRight) then
        processHit(player1, player2, p1X, p2X, player1.facingRight)
    end
    if checkHit(player2, player1, p2X, p1X, player2.facingRight) then
        processHit(player2, player1, p2X, p1X, player2.facingRight)
    end

    -- Dizzy particles (periodic)
    if player1.isDizzy and math.random() < 0.15 then
        particles:spawnDizzy(p1X + 30, p1Y - 12)
    end
    if player2.isDizzy and math.random() < 0.15 then
        particles:spawnDizzy(p2X + 30, p2Y - 12)
    end

    -- ---- Tick characters & particles ----
    player1:update(dt)
    player2:update(dt)
    particles:update(dt)

    -- ---- Round end ----
    if player1.chakra <= 0 then
        p2Wins = p2Wins + 1;  gameState = "round_over";  stateTimer = 2.5
    elseif player2.chakra <= 0 then
        p1Wins = p1Wins + 1;  gameState = "round_over";  stateTimer = 2.5
    end
end

---------------------------------------------------------------
-- KEY PRESSED
---------------------------------------------------------------
function love.mousepressed(x, y, button)
    if gameState == "options" and button == 1 then
        local startX = (SCREEN_W - (5 * 100)) / 2 + 50
        local yPos = 300
        for i = 1, 5 do
            local nx = startX + (i - 1) * 100
            if x >= nx - 32 and x <= nx + 32 and y >= yPos - 36 and y <= yPos + 36 then
                selectedPlayerPalette = i
                if player1 then
                    player1.palette = Character.palettes[selectedPlayerPalette]
                end
                Intro.setVictimPalette(selectedPlayerPalette)
            end
        end
    end
end

function love.keypressed(key)

    -- ==== INTRO ====
    if gameState == "intro" then
        if key == "escape" or key == "return" or key == "space" then
            gameState = "menu"
        end
        return
    end

    -- ==== MENU ====
    if gameState == "menu" then
        if key == "up" or key == "w" then
            menuSelected = menuSelected - 1
            if menuSelected < 1 then menuSelected = #menuItems end
        elseif key == "down" or key == "s" then
            menuSelected = menuSelected + 1
            if menuSelected > #menuItems then menuSelected = 1 end
        elseif key == "return" or key == "space" then
            local chosen = menuItems[menuSelected]
            if chosen == "1P VS AI" then
                gameMode = "1p_ai"
                resetRound(); roundNumber = 1; p1Wins = 0; p2Wins = 0
                gameState = "round_intro"; stateTimer = 2
            elseif chosen == "2P LOCAL" then
                gameMode = "2p_local"
                resetRound(); roundNumber = 1; p1Wins = 0; p2Wins = 0
                gameState = "round_intro"; stateTimer = 2
            elseif chosen == "2P ONLINE" then
                gameMode = "2p_online"
                gameState = "online_lobby"
                onlineStatus = "ENTER ROOM CODE TO JOIN\nOR PRESS SPACE TO CREATE ROOM"
                roomCodeInput = ""
                if wsClient then wsClient:close(); wsClient = nil end
            elseif chosen == "OPTIONS"     then gameState = "options"
            elseif chosen == "CREDITS"     then gameState = "credits"
            elseif chosen == "HOW TO PLAY" then gameState = "how_to_play"
            elseif chosen == "QUIT"        then love.event.quit()
            end
        end
        return
    end

    -- ==== SUB-SCREENS (back on ESC) ====
    if gameState == "credits" or gameState == "how_to_play" or gameState == "options" or gameState == "online_lobby" then
        if key == "escape" or (key == "backspace" and gameState ~= "online_lobby") then
            if gameState == "online_lobby" then
                if wsClient then wsClient:close(); wsClient = nil end
            end
            gameState = "menu"
            return
        end
        
        if gameState == "online_lobby" and onlineStatus == "ENTER ROOM CODE TO JOIN\nOR PRESS SPACE TO CREATE ROOM" then
            if key == "space" then
                onlineStatus = "CONNECTING..."
                wsClient = WS.new()
                wsClient.onMessage = handleServerMessage
                wsClient.onClose = function(reason)
                    gameState = "online_lobby"
                    onlineStatus = "DISCONNECTED: " .. (reason or "unknown")
                    wsClient = nil
                end
                local ok = wsClient:connect(SERVER_HOST, SERVER_PORT, "/")
                if ok then
                    wsClient:send("CREATE_ROOM")
                    onlineStatus = "CREATING ROOM..."
                else
                    onlineStatus = "FAILED TO CONNECT!"
                    wsClient = nil
                end
            elseif key == "backspace" then
                roomCodeInput = string.sub(roomCodeInput, 1, -2)
            elseif key == "return" and #roomCodeInput == 4 then
                onlineStatus = "CONNECTING..."
                wsClient = WS.new()
                wsClient.onMessage = handleServerMessage
                wsClient.onClose = function(reason)
                    gameState = "online_lobby"
                    onlineStatus = "DISCONNECTED: " .. (reason or "unknown")
                    wsClient = nil
                end
                local ok = wsClient:connect(SERVER_HOST, SERVER_PORT, "/")
                if ok then
                    wsClient:send("JOIN_ROOM|" .. roomCodeInput)
                    onlineStatus = "JOINING ROOM " .. roomCodeInput .. "..."
                else
                    onlineStatus = "FAILED TO CONNECT!"
                    wsClient = nil
                end
            end
        end
        return
    end

    -- ==== ROUND INTRO (ignore input) ====
    if gameState == "round_intro" then return end

    -- ==== PLAYING ====
    if gameState == "playing" then
        -- Pause
        if key == "escape" then
            gameState = "paused"; pauseSelected = 1; return
        end

        -- Block player actions while stunned / dizzy / KO
        local isLocalP1 = (gameMode ~= "2p_online" or localPlayerNum == 1)
        if isLocalP1 and not (player1.isStunned or player1.isDizzy or player1.chakra <= 0) then
            -- Jump
            if (key == "w" or (gameMode == "1p_ai" and key == "up")) and p1Grounded then
                player1:setAnimation("jump")
                p1VelY = JUMP_IMPULSE; p1Grounded = false
            end
            -- Attacks
            if     key == "f" then player1:setAnimation("punch")
            elseif key == "g" then player1:setAnimation("kick")
            elseif key == "r" then player1:setAnimation("uppercut")
            elseif key == "t" then player1:setAnimation("lowercut")
            elseif key == "v" then player1:setAnimation("low_kick")
            elseif key == "b" then player1:setAnimation("high_kick")
            elseif key == "z" then player1:setAnimation("punch_combo")
            elseif key == "x" then player1:setAnimation("kick_combo")
            elseif key == "h" and not p1Grounded then player1:setAnimation("jump_punch")
            end
        end

        -- Player 2 Controls (Local or Online as P2)
        local isLocalP2 = (gameMode == "2p_local" or (gameMode == "2p_online" and localPlayerNum == 2))
        if isLocalP2 and not (player2.isStunned or player2.isDizzy or player2.chakra <= 0) then
            if (key == "up" or (gameMode == "2p_online" and key == "w")) and p2Grounded then
                player2:setAnimation("jump")
                p2VelY = JUMP_IMPULSE; p2Grounded = false
            end
            
            -- If online P2, use P1 keys (WASD + FGRT), else use P2 keys (UIOJKL)
            if gameMode == "2p_online" then
                if     key == "f" then player2:setAnimation("punch")
                elseif key == "g" then player2:setAnimation("kick")
                elseif key == "r" then player2:setAnimation("uppercut")
                elseif key == "t" then player2:setAnimation("lowercut")
                elseif key == "v" then player2:setAnimation("low_kick")
                elseif key == "b" then player2:setAnimation("high_kick")
                elseif key == "z" then player2:setAnimation("punch_combo")
                elseif key == "x" then player2:setAnimation("kick_combo")
                elseif key == "h" and not p2Grounded then player2:setAnimation("jump_punch")
                end
            else
                if     key == "j" then player2:setAnimation("punch")
                elseif key == "k" then player2:setAnimation("kick")
                elseif key == "i" then player2:setAnimation("uppercut")
                elseif key == "o" then player2:setAnimation("lowercut")
                elseif key == "m" then player2:setAnimation("low_kick")
                elseif key == "," then player2:setAnimation("high_kick")
                elseif key == "n" then player2:setAnimation("punch_combo")
                elseif key == "." then player2:setAnimation("kick_combo")
                elseif key == "l" and not p2Grounded then player2:setAnimation("jump_punch")
                end
            end
        end

        return
    end

    -- ==== PAUSED ====
    if gameState == "paused" then
        if key == "escape" then gameState = "playing"; return end
        if key == "up" or key == "w" then
            pauseSelected = pauseSelected - 1
            if pauseSelected < 1 then pauseSelected = #pauseItems end
        elseif key == "down" or key == "s" then
            pauseSelected = pauseSelected + 1
            if pauseSelected > #pauseItems then pauseSelected = 1 end
        elseif key == "return" or key == "space" then
            local chosen = pauseItems[pauseSelected]
            if chosen == "CONTINUE" then
                gameState = "playing"
            elseif chosen == "RESTART" then
                resetRound(); roundNumber = 1; p1Wins = 0; p2Wins = 0
                gameState = "round_intro"; stateTimer = 2
            elseif chosen == "MENU" then
                gameState = "menu"; menuSelected = 1
            end
        end
        return
    end

    -- ==== MATCH OVER ====
    if gameState == "match_over" then
        if key == "return" or key == "space" then
            gameState = "menu"; menuSelected = 1
        end
        return
    end
end

function love.textinput(t)
    if gameState == "online_lobby" and onlineStatus == "ENTER ROOM CODE TO JOIN\nOR PRESS SPACE TO CREATE ROOM" then
        if #roomCodeInput < 4 and t:match("%w") then
            roomCodeInput = roomCodeInput .. string.upper(t)
        end
    end
end

---------------------------------------------------------------
-- DRAW HELPERS
---------------------------------------------------------------
local function drawPagodaSilhouette(centerX, bottomY)
    love.graphics.setColor(0.05, 0.04, 0.10, 1)
    
    -- Multi-tiered Roof Structure
    local tiers = {
        {w = 110, h = 12, yOff = 0},
        {w = 85,  h = 10, yOff = 22},
        {w = 65,  h = 10, yOff = 42},
        {w = 48,  h = 8,  yOff = 60},
        {w = 32,  h = 8,  yOff = 76}
    }

    for _, t in ipairs(tiers) do
        local y = bottomY - t.yOff - t.h
        -- Roof eaves
        love.graphics.polygon("fill", 
            centerX - (t.w / 2) - 8, y + t.h, 
            centerX - (t.w / 2), y, 
            centerX + (t.w / 2), y, 
            centerX + (t.w / 2) + 8, y + t.h
        )
        -- Walls
        love.graphics.rectangle("fill", centerX - (t.w / 3), y - 10, (t.w / 1.5), 10)
        
        -- Glowing Windows
        love.graphics.setColor(0.95, 0.65, 0.25, 0.85)
        love.graphics.rectangle("fill", centerX - 6, y - 7, 4, 5)
        love.graphics.rectangle("fill", centerX + 2, y - 7, 4, 5)
        love.graphics.setColor(0.05, 0.04, 0.10, 1)
    end
    
    -- Spire (Sorin)
    love.graphics.rectangle("fill", centerX - 2, bottomY - 110, 4, 25)
end

local function drawPineTree(x, y, flip)
    local dir = flip and -1 or 1
    love.graphics.setColor(0.04, 0.03, 0.08, 1)

    -- Gnarled Trunk
    love.graphics.polygon("fill", 
        x, y, 
        x + (20 * dir), y - 70, 
        x + (10 * dir), y - 120, 
        x + (30 * dir), y - 170, 
        x + (15 * dir), y - 170, 
        x - 10, y
    )

    -- Horizontal Needle Clusters
    local clusters = {
        {cx = x + (10 * dir), cy = y - 80, rx = 35, ry = 12},
        {cx = x + (35 * dir), cy = y - 120, rx = 40, ry = 14},
        {cx = x + (20 * dir), cy = y - 165, rx = 45, ry = 16},
        {cx = x + (30 * dir), cy = y - 200, rx = 30, ry = 12}
    }

    for _, c in ipairs(clusters) do
        love.graphics.ellipse("fill", c.cx, c.cy, c.rx, c.ry)
    end
end

local function drawBackgroundEnvironment()
    local screenW = SCREEN_W
    local screenH = SCREEN_H
    local centerX = screenW / 2

    -- Night Sky Gradient (Deep Navy to Violet)
    local skyTop = {0.05, 0.03, 0.12}
    local skyMid = {0.12, 0.06, 0.20}
    local skyBot = {0.22, 0.10, 0.28}
    
    for y = 0, screenH do
        local r, g, b
        if y < 220 then
            local t = y / 220
            r = skyTop[1] + (skyMid[1] - skyTop[1]) * t
            g = skyTop[2] + (skyMid[2] - skyTop[2]) * t
            b = skyTop[3] + (skyMid[3] - skyTop[3]) * t
        else
            local t = (y - 220) / (screenH - 220)
            r = skyMid[1] + (skyBot[1] - skyMid[1]) * t
            g = skyMid[2] + (skyBot[2] - skyMid[2]) * t
            b = skyMid[3] + (skyBot[3] - skyMid[3]) * t
        end
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", 0, y, screenW, 1)
    end

    -- Background Stars
    love.graphics.setColor(0.9, 0.85, 1.0, 0.8)
    local starPositions = {{80, 40}, {200, 70}, {350, 30}, {600, 50}, {720, 80}, {140, 110}, {650, 120}}
    for _, s in ipairs(starPositions) do
        love.graphics.rectangle("fill", s[1], s[2], 2, 2)
    end

    -- Giant Moon (Backlit)
    love.graphics.setColor(0.85, 0.92, 1.0, 0.95)
    love.graphics.circle("fill", centerX, 210, 110)
    
    -- Moon Craters / Texture
    love.graphics.setColor(0.75, 0.82, 0.92, 0.4)
    love.graphics.circle("fill", centerX - 40, 180, 22)
    love.graphics.circle("fill", centerX + 30, 240, 18)
    love.graphics.circle("fill", centerX + 10, 160, 14)

    -- Central Backlit Pagoda
    drawPagodaSilhouette(centerX, 330)

    -- Drifting Japanese Pink/Violet Clouds (Opaque to prevent overlap artifacts)
    local function drawCloudBand(y, offsetX, color, h)
        love.graphics.setColor(color[1], color[2], color[3], 1)
        for i = -1, 2 do
            local x = ((cloudTimer + offsetX + (i * 400)) % (screenW + 400)) - 200
            love.graphics.ellipse("fill", x, y, 140, h)
            love.graphics.ellipse("fill", x + 60, y - 6, 90, h - 4)
            love.graphics.ellipse("fill", x - 50, y + 4, 80, h - 2)
        end
    end

    drawCloudBand(150, 0, {0.25, 0.14, 0.35}, 20)
    drawCloudBand(220, 180, {0.32, 0.18, 0.40}, 26)
    drawCloudBand(280, 90, {0.40, 0.25, 0.45}, 32)
    drawCloudBand(340, 250, {0.20, 0.12, 0.28}, 40)

    -- Oriental Pine Trees Framing Left & Right Sides
    drawPineTree(40, GROUND_Y, false)
    drawPineTree(screenW - 40, GROUND_Y, true)
end

local function drawDarkOverlay(alpha)
    love.graphics.setColor(0, 0, 0, alpha or 0.5)
    love.graphics.rectangle("fill", 0, 0, SCREEN_W, SCREEN_H)
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawBlinkHint(text, y, speed)
    local blink = 0.4 + 0.6 * math.abs(math.sin(love.timer.getTime() * (speed or 2)))
    PF.drawTextCentered(text, y, SCREEN_W, 2, {0.6, 0.5, 0.8, blink})
end

---------------------------------------------------------------
-- VERTICAL MENU BLOCK (reusable for main menu & pause)
---------------------------------------------------------------
local function drawMenuBlock(items, selected, startY, itemSpacing)
    itemSpacing = itemSpacing or 38

    -- Find widest item for alignment
    local maxW = 0
    for _, item in ipairs(items) do
        local w = PF.getTextWidth(item, 3)
        if w > maxW then maxW = w end
    end
    local cursorW = PF.getTextWidth("> ", 3)
    local blockX  = math.floor((SCREEN_W - cursorW - maxW) / 2)

    for i, item in ipairs(items) do
        local iy = startY + (i - 1) * itemSpacing
        if i == selected then
            local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 5)
            PF.drawText(">", blockX, iy, 3, {1, 0.85, 0.2, pulse})
            PF.drawText(item, blockX + cursorW, iy, 3, COL.menuSelected)
        else
            PF.drawText(item, blockX + cursorW, iy, 3, COL.menuNormal)
        end
    end
end

---------------------------------------------------------------
-- CHAKRA BAR
---------------------------------------------------------------
local function drawChakraBar(x, y, w, h, chakra, palette, label, winsCount, isFlipped)
    -- Background
    love.graphics.setColor(0.05, 0.03, 0.12, 0.9)
    love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4, 4, 4)

    -- Border glow
    love.graphics.setColor(palette[5][1], palette[5][2], palette[5][3], 0.6)
    love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4, 4, 4)

    -- Fill
    local ratio = chakra / 100
    local fillW = w * ratio
    local r, g, b = 1 - ratio, ratio, 0.3

    if isFlipped then
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.rectangle("fill", x + w - fillW, y, fillW, h, 3, 3)
        love.graphics.setColor(r + 0.2, g + 0.2, b + 0.3, 0.7)
        love.graphics.rectangle("fill", x + w - fillW, y, 3, h)
    else
        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.rectangle("fill", x, y, fillW, h, 3, 3)
        love.graphics.setColor(r + 0.2, g + 0.2, b + 0.3, 0.7)
        love.graphics.rectangle("fill", x + fillW - 3, y, 3, h)
    end

    -- Label (pixel font)
    if isFlipped then
        PF.drawTextRight(label, x + w, y - 18, 2, COL.label)
    else
        PF.drawText(label, x, y - 18, 2, COL.label)
    end

    -- Percentage centred inside bar
    local pctText = math.floor(chakra) .. "%"
    local pctW = PF.getTextWidth(pctText, 2)
    local pctH = PF.getTextHeight(2)
    PF.drawText(pctText,
        x + math.floor((w - pctW) / 2),
        y + math.floor((h - pctH) / 2) + 1,
        2, {1, 1, 1, 0.85})

    -- Round-win dots
    local dotY = y + h + 6
    for i = 1, ROUND_WIN_NEED do
        local dotX = isFlipped
            and (x + w - (i - 1) * 18 - 10)
            or  (x + (i - 1) * 18 + 4)
        if i <= winsCount then
            love.graphics.setColor(1, 0.85, 0.2, 1)
        else
            love.graphics.setColor(0.3, 0.25, 0.4, 0.6)
        end
        love.graphics.circle("fill", dotX, dotY, 5)
        love.graphics.setColor(0.6, 0.5, 0.8, 0.5)
        love.graphics.circle("line", dotX, dotY, 5)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

---------------------------------------------------------------
-- SCREEN: MAIN MENU
---------------------------------------------------------------
local function drawMenuScreen()
    drawBackgroundEnvironment()
    Ground:draw(SCREEN_W, GROUND_Y, SCALE)

    -- Characters posing
    player1:draw(SCREEN_W / 2 - 140, GROUND_Y - CHAR_H, SCALE)
    player2:draw(SCREEN_W / 2 + 60,  GROUND_Y - CHAR_H, SCALE)

    drawDarkOverlay(0.55)

    -- Title glow + main
    local pulse = 0.7 + 0.3 * math.sin(love.timer.getTime() * 3)
    PF.drawTextCentered("SMACK", 80, SCREEN_W, 6,
        {0.6, 0.2, 1.0, 0.3 * pulse})
    PF.drawTextCentered("SMACK", 78, SCREEN_W, 6,
        {0.8, 0.4, 1.0, pulse})

    -- Subtitle
    PF.drawTextCentered("CHAKRA CLASH", 130, SCREEN_W, 3, COL.subtitle)

    -- Menu items
    drawMenuBlock(menuItems, menuSelected, 210, 36)

    -- Footer hint
    PF.drawTextCentered("BEST OF 3 ROUNDS  -  1V1 VS AI",
        SCREEN_H - 30, SCREEN_W, 2, COL.hint)
end

---------------------------------------------------------------
-- SCREEN: CREDITS
---------------------------------------------------------------
local function drawCreditsScreen()
    love.graphics.clear(0.04, 0.03, 0.12)

    PF.drawTextCentered("CREDITS", 45, SCREEN_W, 4, COL.white)

    PF.drawTextCentered("--- CREATED BY ---", 115, SCREEN_W, 2, COL.separator)
    PF.drawTextCentered("BIHIN STUDIOS", 155, SCREEN_W, 5, COL.magenta)
    PF.drawTextCentered("EST. 2025", 200, SCREEN_W, 2, COL.dimText)

    PF.drawTextCentered("--- POWERED BY ---", 270, SCREEN_W, 2, COL.separator)
    PF.drawTextCentered("LOVE2D FRAMEWORK", 310, SCREEN_W, 3, COL.cyan)
    PF.drawTextCentered("LUA RUNTIME", 350, SCREEN_W, 2, COL.dimText)

    drawBlinkHint("ESC - BACK", SCREEN_H - 40)
end

---------------------------------------------------------------
-- SCREEN: OPTIONS (placeholder)
---------------------------------------------------------------
local function drawOptionsScreen()
    drawBackgroundEnvironment()
    drawDarkOverlay(0.8)

    PF.drawTextCentered("OPTIONS", 60, SCREEN_W, 6, COL.white)
    PF.drawTextCentered("CHOOSE YOUR NINJA", 130, SCREEN_W, 3, COL.gold)

    local mouseX, mouseY = love.mouse.getPosition()
    local startX = (SCREEN_W - (5 * 100)) / 2 + 50
    local yPos = 300

    for i = 1, 5 do
        local x = startX + (i - 1) * 100
        local isHovered = (mouseX >= x - 32 and mouseX <= x + 32 and mouseY >= yPos - 36 and mouseY <= yPos + 36)
        local drawScale = 4
        
        if isHovered then drawScale = 4.5 end
        
        if selectedPlayerPalette == i then
            love.graphics.setColor(1, 0.8, 0, 0.3)
            love.graphics.rectangle("fill", x - 40, yPos - 45, 80, 90)
            love.graphics.setColor(1, 0.8, 0, 1)
            love.graphics.rectangle("line", x - 40, yPos - 45, 80, 90)
        elseif isHovered then
            love.graphics.setColor(1, 1, 1, 0.1)
            love.graphics.rectangle("fill", x - 40, yPos - 45, 80, 90)
        end
        
        love.graphics.setColor(1, 1, 1, 1)
        optionsNinjas[i]:draw(x - (16 * drawScale)/2, yPos - (18 * drawScale)/2, drawScale)
        
        if selectedPlayerPalette == i then
            local titles = {"ORIGINAL", "PURPLE", "WHITE", "SHINOBI", "ORANGE"}
            local titleWidth = PF.getTextWidth(titles[i], 2)
            PF.drawText(titles[i], x - math.floor(titleWidth/2), yPos + 60, 2, COL.cyan)
        end
    end

    drawBlinkHint("ESC - BACK TO MENU", SCREEN_H - 40)
end

---------------------------------------------------------------
-- SCREEN: HOW TO PLAY
---------------------------------------------------------------
local function drawHowToPlayScreen()
    love.graphics.clear(0.04, 0.03, 0.12)

    PF.drawTextCentered("HOW TO PLAY", 25, SCREEN_W, 4, COL.gold)

    local leftX  = 80
    local rightX = 480
    local lineH  = 20

    -- ---- LEFT COLUMN: Movement ----
    local y = 85
    PF.drawText("MOVEMENT", leftX, y, 3, COL.cyan)
    y = y + 30

    local movement = {
        {"W", "JUMP"},
        {"A", "MOVE LEFT"},
        {"D", "MOVE RIGHT"},
        {"B", "HIGH BLOCK"},
        {"N", "LOW BLOCK"},
    }
    for _, ctrl in ipairs(movement) do
        PF.drawText(ctrl[1], leftX + 10, y, 2, COL.gold)
        PF.drawText(ctrl[2], leftX + 48, y, 2, COL.white)
        y = y + lineH
    end

    y = y + 14
    PF.drawText("SPECIAL", leftX, y, 3, COL.cyan)
    y = y + 30
    PF.drawText("ESC", leftX + 10, y, 2, COL.gold)
    PF.drawText("PAUSE GAME", leftX + 62, y, 2, COL.white)

    -- ---- RIGHT COLUMN: Attacks ----
    y = 85
    PF.drawText("ATTACKS", rightX, y, 3, COL.magenta)
    y = y + 30

    local attacks = {
        {"F", "PUNCH"},
        {"G", "KICK"},
        {"R", "UPPERCUT"},
        {"T", "LOWERCUT"},
        {"V", "LOW KICK"},
        {"B", "HIGH KICK"},
        {"C", "PUNCH COMBO"},
        {"X", "KICK COMBO"},
        {"H", "JUMP PUNCH"},
    }
    for _, ctrl in ipairs(attacks) do
        PF.drawText(ctrl[1], rightX + 10, y, 2, COL.gold)
        PF.drawText(ctrl[2], rightX + 48, y, 2, COL.white)
        y = y + lineH
    end

    -- ---- Bottom: Objective ----
    PF.drawTextCentered("--- OBJECTIVE ---", 380, SCREEN_W, 2, COL.separator)
    PF.drawTextCentered("DEPLETE YOUR OPPONENT'S CHAKRA", 410, SCREEN_W, 2, COL.white)
    PF.drawTextCentered("TO WIN THE ROUND", 432, SCREEN_W, 2, COL.white)
    PF.drawTextCentered("WIN 2 ROUNDS TO WIN THE MATCH", 464, SCREEN_W, 2, COL.white)

    drawBlinkHint("ESC - BACK", SCREEN_H - 40)
end

---------------------------------------------------------------
-- GAME SCENE (shared by playing / paused / round_over / match_over)
---------------------------------------------------------------
local function drawGameScene()
    drawBackgroundEnvironment()
    Ground:draw(SCREEN_W, GROUND_Y, SCALE)
    player1:draw(p1X, p1Y, SCALE)
    player2:draw(p2X, p2Y, SCALE)
    particles:draw()
end

local function drawHUD()
    local barW, barH, barY = 280, 18, 50
    drawChakraBar(20, barY, barW, barH,
        player1.chakra, Character.paletteP1, "P1 - CHAKRA", p1Wins, false)
    drawChakraBar(SCREEN_W - barW - 20, barY, barW, barH,
        player2.chakra, Character.paletteP2, "AI - CHAKRA", p2Wins, true)

    -- Round indicator
    PF.drawTextCentered("ROUND " .. roundNumber, 14, SCREEN_W, 2, COL.roundText)
end

local function drawControlsHint()
    PF.drawTextCentered("WASD MOVE  B/N BLOCK  F PUNCH  G KICK  ESC PAUSE",
        SCREEN_H - 22, SCREEN_W, 2, COL.hint)
end

---------------------------------------------------------------
-- OVERLAYS
---------------------------------------------------------------
local function drawPauseOverlay()
    drawDarkOverlay(0.6)
    PF.drawTextCentered("PAUSED", 155, SCREEN_W, 5, COL.white)
    drawMenuBlock(pauseItems, pauseSelected, 260, 38)
end

local function drawRoundIntroOverlay()
    drawDarkOverlay(0.4)
    PF.drawTextCentered("ROUND " .. roundNumber, 185, SCREEN_W, 6, COL.roundAnnounce)
    if stateTimer < 1 then
        PF.drawTextCentered("FIGHT!", 258, SCREEN_W, 4, COL.fight)
    end
end

local function drawRoundOverOverlay()
    drawDarkOverlay(0.35)
    if player1.chakra <= 0 then
        PF.drawTextCentered("AI WINS ROUND " .. roundNumber .. "!",
            230, SCREEN_W, 3, COL.p2Win)
    else
        PF.drawTextCentered("PLAYER 1 WINS ROUND " .. roundNumber .. "!",
            230, SCREEN_W, 3, COL.p1Win)
    end
end

local function drawMatchOverOverlay()
    drawDarkOverlay(0.55)
    if matchWinner == 1 then
        PF.drawTextCentered("YOU WIN!", 170, SCREEN_W, 6, COL.p1Win)
    else
        PF.drawTextCentered("AI WINS!", 170, SCREEN_W, 6, COL.p2Win)
    end
    PF.drawTextCentered("SCORE: " .. p1Wins .. " - " .. p2Wins,
        245, SCREEN_W, 3, COL.white)
    drawBlinkHint("PRESS ENTER FOR MENU", 310, 2.5)
end

---------------------------------------------------------------
-- SCREEN: ONLINE LOBBY
---------------------------------------------------------------
local function drawOnlineLobby()
    drawBackgroundEnvironment()
    drawDarkOverlay(0.8)
    PF.drawTextCentered("ONLINE LOBBY", 60, SCREEN_W, 6, COL.cyan)
    PF.drawTextCentered(onlineStatus, 200, SCREEN_W, 3, COL.white)
    
    if onlineStatus == "ENTER ROOM CODE TO JOIN\nOR PRESS SPACE TO CREATE ROOM" then
        PF.drawTextCentered("CODE: " .. roomCodeInput .. (love.timer.getTime() % 1 < 0.5 and "_" or ""), 280, SCREEN_W, 4, COL.gold)
    end
    
    if onlineStatus == "CONNECTING..." or string.match(onlineStatus, "WAITING") then
        drawBlinkHint("ESC - CANCEL", SCREEN_H - 40)
    else
        drawBlinkHint("ESC - MENU", SCREEN_H - 40)
    end
end

---------------------------------------------------------------
-- MAIN DRAW
---------------------------------------------------------------
function love.draw()
    -- Full-screen states
    if gameState == "intro"       then Intro.draw();           return end
    if gameState == "menu"        then drawMenuScreen();       return end
    if gameState == "credits"     then drawCreditsScreen();    return end
    if gameState == "options"     then drawOptionsScreen();    return end
    if gameState == "how_to_play" then drawHowToPlayScreen();  return end
    if gameState == "online_lobby" then drawOnlineLobby();     return end

    -- All remaining states draw the game scene
    drawGameScene()

    if gameState == "round_intro" then
        drawRoundIntroOverlay(); return
    end

    -- HUD is visible for playing / paused / round_over / match_over
    drawHUD()

    if gameState == "playing"    then drawControlsHint() end
    if gameState == "paused"     then drawPauseOverlay() end
    if gameState == "round_over" then drawRoundOverOverlay() end
    if gameState == "match_over" then drawMatchOverOverlay() end
end
