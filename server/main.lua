local enet = require("enet")
local host

local waitingPeer = nil
local rooms = {} -- Maps peer to their opponent peer

function love.load()
    print("====================================")
    print(" SMACK MATCHMAKING SERVER STARTED   ")
    print(" Listening on port: 54321           ")
    print("====================================")
    
    host = enet.host_create("localhost:54321")
    if not host then
        print("ERROR: Failed to start server on port 54321.")
        love.event.quit()
    end
end

function love.update(dt)
    if not host then return end
    
    local event = host:service(1) -- 1ms timeout
    while event do
        if event.type == "connect" then
            print("Client Connected: " .. tostring(event.peer))
            
            if waitingPeer then
                -- Match found!
                rooms[event.peer] = waitingPeer
                rooms[waitingPeer] = event.peer
                
                print("Match Started! " .. tostring(waitingPeer) .. " VS " .. tostring(event.peer))
                
                -- Send assignments (P1 vs P2)
                waitingPeer:send("MATCH|1")
                event.peer:send("MATCH|2")
                
                waitingPeer = nil
            else
                -- Wait for opponent
                waitingPeer = event.peer
                waitingPeer:send("WAITING")
                print("Client waiting in lobby...")
            end
            
        elseif event.type == "receive" then
            local opponent = rooms[event.peer]
            if opponent then
                -- Relay the message directly to the opponent
                -- using the "unsequenced" flag for minimum latency
                opponent:send(event.data, 0, "unsequenced")
            end
            
        elseif event.type == "disconnect" then
            print("Client Disconnected: " .. tostring(event.peer))
            local opponent = rooms[event.peer]
            
            if opponent then
                -- Inform opponent and close the room
                print("Closing room...")
                opponent:send("DISCONNECT")
                rooms[opponent] = nil
            end
            rooms[event.peer] = nil
            
            if waitingPeer == event.peer then
                waitingPeer = nil
            end
        end
        
        event = host:service()
    end
end
