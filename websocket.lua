-- websocket.lua
-- Minimal WebSocket client for LÖVE2D using luasocket + luasec
-- Implements RFC 6455 (WebSocket Protocol)

local socket = require("socket")
local mime   = require("mime")  -- for base64

-- Try to load luasec for TLS support
local ssl
pcall(function() ssl = require("ssl") end)

local WS = {}
WS.__index = WS

--- Create a new WebSocket client (not yet connected).
function WS.new()
    local self = setmetatable({}, WS)
    self.tcp = nil
    self.connected = false
    self.buffer = ""
    self.onMessage = nil
    self.onClose   = nil
    self.onError   = nil
    return self
end

--- Generate a random 16-byte key, base64 encoded.
local function generateKey()
    local bytes = {}
    for i = 1, 16 do
        bytes[i] = string.char(math.random(0, 255))
    end
    return mime.b64(table.concat(bytes))
end

--- Connect to a WebSocket server.
-- @param host  string  e.g. "my-server.onrender.com"
-- @param port  number  e.g. 443 or 80
-- @param path  string  e.g. "/"
function WS:connect(host, port, path)
    path = path or "/"
    self.tcp = socket.tcp()
    self.tcp:settimeout(5)

    local ok, err = self.tcp:connect(host, port)
    if not ok then
        if self.onError then self.onError("connect failed: " .. tostring(err)) end
        return false
    end

    -- Wrap with TLS if connecting on port 443
    if port == 443 then
        if not ssl then
            if self.onError then self.onError("TLS required but luasec not available") end
            return false
        end
        local params = {
            mode = "client",
            protocol = "any",
            verify = "none",
            options = "all",
        }
        local wrapped, err2 = ssl.wrap(self.tcp, params)
        if not wrapped then
            if self.onError then self.onError("TLS wrap failed: " .. tostring(err2)) end
            return false
        end
        wrapped:settimeout(5)
        local sOk, sErr = wrapped:dohandshake()
        if not sOk then
            if self.onError then self.onError("TLS handshake failed: " .. tostring(sErr)) end
            return false
        end
        self.tcp = wrapped
    end

    -- Send the WebSocket upgrade request
    local key = generateKey()
    local request = table.concat({
        "GET " .. path .. " HTTP/1.1",
        "Host: " .. host,
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Key: " .. key,
        "Sec-WebSocket-Version: 13",
        "", ""
    }, "\r\n")

    self.tcp:send(request)

    -- Read the response (we just need to confirm the 101 status)
    self.tcp:settimeout(5)
    local line, err = self.tcp:receive("*l")
    if not line then
        if self.onError then self.onError("handshake failed: " .. tostring(err)) end
        return false
    end

    if not line:match("101") then
        if self.onError then self.onError("server rejected: " .. line) end
        return false
    end

    -- Read remaining headers until blank line
    while true do
        local hdr = self.tcp:receive("*l")
        if not hdr or hdr == "" then break end
    end

    self.tcp:settimeout(0)
    self.connected = true
    return true
end

--- Mask payload data (client -> server must be masked per RFC 6455).
local function maskPayload(data, maskKey)
    local masked = {}
    for i = 1, #data do
        local j = ((i - 1) % 4) + 1
        masked[i] = string.char(bit.bxor(data:byte(i), maskKey:byte(j)))
    end
    return table.concat(masked)
end

--- Send a text frame.
function WS:send(text)
    if not self.connected or not self.tcp then return false end

    local frame = {}
    -- FIN + text opcode
    frame[#frame + 1] = string.char(0x81)

    local len = #text
    -- Mask bit set (0x80) + length
    if len <= 125 then
        frame[#frame + 1] = string.char(0x80 + len)
    elseif len <= 65535 then
        frame[#frame + 1] = string.char(0x80 + 126)
        frame[#frame + 1] = string.char(bit.rshift(len, 8))
        frame[#frame + 1] = string.char(bit.band(len, 0xFF))
    end

    -- 4-byte random mask key
    local maskKey = string.char(
        math.random(0, 255), math.random(0, 255),
        math.random(0, 255), math.random(0, 255)
    )
    frame[#frame + 1] = maskKey
    frame[#frame + 1] = maskPayload(text, maskKey)

    local data = table.concat(frame)
    local ok, err = self.tcp:send(data)
    if not ok then
        self:_handleClose("send error: " .. tostring(err))
        return false
    end
    return true
end

--- Read available data (non-blocking). Call this in love.update().
function WS:update()
    if not self.connected or not self.tcp then return end

    -- Read as much as possible
    local chunk, err, partial = self.tcp:receive(4096)
    local data = chunk or partial
    if data and #data > 0 then
        self.buffer = self.buffer .. data
    end

    if err == "closed" then
        self:_handleClose("connection closed")
        return
    end

    -- Parse frames from buffer
    while #self.buffer >= 2 do
        local b1 = self.buffer:byte(1)
        local b2 = self.buffer:byte(2)
        local opcode = bit.band(b1, 0x0F)
        local masked = bit.band(b2, 0x80) ~= 0
        local payloadLen = bit.band(b2, 0x7F)

        local headerLen = 2
        if payloadLen == 126 then
            if #self.buffer < 4 then return end  -- need more data
            payloadLen = self.buffer:byte(3) * 256 + self.buffer:byte(4)
            headerLen = 4
        end

        if masked then headerLen = headerLen + 4 end

        local totalLen = headerLen + payloadLen
        if #self.buffer < totalLen then return end  -- need more data

        local payload
        if masked then
            local maskStart = headerLen - 4 + 1
            local maskKey = self.buffer:sub(maskStart, maskStart + 3)
            local raw = self.buffer:sub(headerLen + 1, totalLen)
            payload = maskPayload(raw, maskKey)
        else
            payload = self.buffer:sub(headerLen + 1, totalLen)
        end

        -- Consume the frame
        self.buffer = self.buffer:sub(totalLen + 1)

        if opcode == 0x01 then
            -- Text frame
            if self.onMessage then self.onMessage(payload) end
        elseif opcode == 0x08 then
            -- Close frame
            self:_handleClose("server closed connection")
            return
        elseif opcode == 0x09 then
            -- Ping -> send Pong
            self:_sendPong(payload)
        end
    end
end

function WS:_sendPong(data)
    if not self.tcp then return end
    local frame = string.char(0x8A, 0x80 + #data)
    local maskKey = string.char(
        math.random(0,255), math.random(0,255),
        math.random(0,255), math.random(0,255)
    )
    frame = frame .. maskKey .. maskPayload(data, maskKey)
    self.tcp:send(frame)
end

function WS:_handleClose(reason)
    self.connected = false
    if self.tcp then
        pcall(function() self.tcp:close() end)
        self.tcp = nil
    end
    if self.onClose then self.onClose(reason) end
end

function WS:close()
    if not self.connected then return end
    -- Send close frame
    if self.tcp then
        local frame = string.char(0x88, 0x80 + 0)
        local maskKey = string.char(
            math.random(0,255), math.random(0,255),
            math.random(0,255), math.random(0,255)
        )
        frame = frame .. maskKey
        pcall(function() self.tcp:send(frame) end)
    end
    self:_handleClose("client closed")
end

return WS
