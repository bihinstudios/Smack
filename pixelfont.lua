local PixelFont = {}

local CHAR_W = 5
local CHAR_H = 7
local pow2 = {16, 8, 4, 2, 1}

---------------------------------------------------------------
-- GLYPH DATA: each char = 7 rows of 5-bit values
-- Bit 4 (16) = leftmost pixel, Bit 0 (1) = rightmost pixel
---------------------------------------------------------------
local G = {}

-- Letters
G["A"] = {14,17,17,31,17,17,17}
G["B"] = {30,17,17,30,17,17,30}
G["C"] = {14,17,16,16,16,17,14}
G["D"] = {28,18,17,17,17,18,28}
G["E"] = {31,16,16,30,16,16,31}
G["F"] = {31,16,16,30,16,16,16}
G["G"] = {14,17,16,23,17,17,14}
G["H"] = {17,17,17,31,17,17,17}
G["I"] = {31,4,4,4,4,4,31}
G["J"] = {7,2,2,2,2,18,12}
G["K"] = {17,18,20,24,20,18,17}
G["L"] = {16,16,16,16,16,16,31}
G["M"] = {17,27,21,21,17,17,17}
G["N"] = {17,25,21,19,17,17,17}
G["O"] = {14,17,17,17,17,17,14}
G["P"] = {30,17,17,30,16,16,16}
G["Q"] = {14,17,17,17,21,18,13}
G["R"] = {30,17,17,30,20,18,17}
G["S"] = {14,17,16,14,1,17,14}
G["T"] = {31,4,4,4,4,4,4}
G["U"] = {17,17,17,17,17,17,14}
G["V"] = {17,17,17,17,10,10,4}
G["W"] = {17,17,17,21,21,21,10}
G["X"] = {17,17,10,4,10,17,17}
G["Y"] = {17,17,10,4,4,4,4}
G["Z"] = {31,1,2,4,8,16,31}

-- Digits
G["0"] = {14,17,19,21,25,17,14}
G["1"] = {4,12,4,4,4,4,14}
G["2"] = {14,17,1,6,8,16,31}
G["3"] = {14,17,1,6,1,17,14}
G["4"] = {2,6,10,18,31,2,2}
G["5"] = {31,16,30,1,1,17,14}
G["6"] = {14,16,16,30,17,17,14}
G["7"] = {31,1,2,4,8,8,8}
G["8"] = {14,17,17,14,17,17,14}
G["9"] = {14,17,17,15,1,1,14}

-- Punctuation & symbols
G[" "]  = {0,0,0,0,0,0,0}
G["."]  = {0,0,0,0,0,4,4}
G[","]  = {0,0,0,0,0,4,8}
G["!"]  = {4,4,4,4,4,0,4}
G["?"]  = {14,17,1,6,4,0,4}
G[":"]  = {0,4,4,0,4,4,0}
G["-"]  = {0,0,0,31,0,0,0}
G["_"]  = {0,0,0,0,0,0,31}
G["/"]  = {1,2,2,4,8,8,16}
G["("]  = {2,4,8,8,8,4,2}
G[")"]  = {8,4,2,2,2,4,8}
G["'"]  = {4,4,8,0,0,0,0}
G[">"]  = {8,4,2,1,2,4,8}
G["<"]  = {2,4,8,16,8,4,2}
G["%"]  = {9,9,2,4,8,18,18}
G["+"]  = {0,4,4,31,4,4,0}
G["="]  = {0,0,31,0,31,0,0}
G["*"]  = {0,10,4,31,4,10,0}

---------------------------------------------------------------
-- DRAW TEXT
---------------------------------------------------------------
function PixelFont.drawText(text, x, y, scale, color, spacing)
    scale = scale or 3
    spacing = spacing or 1
    color = color or {1, 1, 1, 1}

    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)

    local curX = x
    text = string.upper(text)

    for i = 1, #text do
        local ch = text:sub(i, i)
        local glyph = G[ch]
        if glyph then
            for row = 1, CHAR_H do
                local bits = glyph[row]
                if bits > 0 then
                    for col = 1, CHAR_W do
                        if math.floor(bits / pow2[col]) % 2 == 1 then
                            love.graphics.rectangle("fill",
                                curX + (col - 1) * scale,
                                y + (row - 1) * scale,
                                scale, scale)
                        end
                    end
                end
            end
        end
        curX = curX + (CHAR_W + spacing) * scale
    end

    love.graphics.setColor(1, 1, 1, 1)
end

---------------------------------------------------------------
-- MEASUREMENT HELPERS
---------------------------------------------------------------
function PixelFont.getTextWidth(text, scale, spacing)
    scale = scale or 3
    spacing = spacing or 1
    local len = #text
    if len == 0 then return 0 end
    return len * (CHAR_W + spacing) * scale - spacing * scale
end

function PixelFont.getTextHeight(scale)
    scale = scale or 3
    return CHAR_H * scale
end

---------------------------------------------------------------
-- ALIGNMENT HELPERS
---------------------------------------------------------------
function PixelFont.drawTextCentered(text, y, screenWidth, scale, color, spacing)
    local w = PixelFont.getTextWidth(text, scale, spacing)
    local x = math.floor((screenWidth - w) / 2)
    PixelFont.drawText(text, x, y, scale, color, spacing)
end

function PixelFont.drawTextRight(text, rightX, y, scale, color, spacing)
    local w = PixelFont.getTextWidth(text, scale, spacing)
    PixelFont.drawText(text, rightX - w, y, scale, color, spacing)
end

return PixelFont
