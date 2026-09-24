const fs = require('fs');
let data = fs.readFileSync('main.lua', 'utf8');

const bgLoadRe = /Character\.loadAssets\(\)/;
const bgLoadRep = `Character.loadAssets()\n    bgImage = love.graphics.newImage("Asset/Background.png")\n    bgImage:setFilter("linear", "linear")`;
data = data.replace(bgLoadRe, bgLoadRep);

const drawBgRe = /local function drawBackgroundEnvironment\(\)[\s\S]*?end\n\nlocal function drawDarkOverlay/;
const drawBgRep = `local function drawBackgroundEnvironment()
    love.graphics.setColor(1, 1, 1, 1)
    if bgImage then
        -- Draw stretched to fill the sky area, stopping at groundY (440)
        local sx = SCREEN_W / bgImage:getWidth()
        local sy = 440 / bgImage:getHeight()
        love.graphics.draw(bgImage, 0, 0, 0, sx, sy)
    end
end

local function drawDarkOverlay`;
data = data.replace(drawBgRe, drawBgRep);

// Remove drawTrees
const drawTreesRe = /local function drawTrees\(\)[\s\S]*?end/;
const drawTreesRep = ``;
data = data.replace(drawTreesRe, drawTreesRep);

const drawTreesCallRe = /drawTrees\(\)/g;
data = data.replace(drawTreesCallRe, ``);

fs.writeFileSync('main.lua', data);
