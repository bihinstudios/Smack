const fs = require('fs');
let data = fs.readFileSync('character.lua', 'utf8');

const loadRe = /for _, f in ipairs\(frames\) do[\s\S]*?end\n\s+end/;
const loadRep = `for _, f in ipairs(frames) do
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
    end`;
data = data.replace(loadRe, loadRep);

fs.writeFileSync('character.lua', data);
