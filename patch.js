const fs = require('fs');

let content = fs.readFileSync('d:/Smack/character.lua', 'utf8');

let lines = content.split('\n');
for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('6')) {
        let match = lines[i].match(/^(\s*\{)(.*?)(\},?)$/);
        if (match) {
            let rowStr = match[2];
            let row = rowStr.split(',').map(s => parseInt(s.trim()));
            let col = row.indexOf(6);
            if (col !== -1 && row.length === 18) {
                // Eye & Nose
                row[col - 3] = 1;
                row[col - 2] = 2;
                row[col - 1] = 4;
                row[col] = 6;
                row[col + 1] = 4;
                row[col + 2] = 4;
                row[col + 3] = 1;
                lines[i] = match[1] + row.join(',') + match[3];

                // Hood depth
                let aboveMatch = lines[i - 1].match(/^(\s*\{)(.*?)(\},?)$/);
                if (aboveMatch) {
                    let rowA = aboveMatch[2].split(',').map(s => parseInt(s.trim()));
                    rowA[col - 3] = 1;
                    rowA[col - 2] = 2;
                    rowA[col - 1] = 5;
                    rowA[col] = 5;
                    rowA[col + 1] = 5;
                    rowA[col + 2] = 2;
                    rowA[col + 3] = 1;
                    lines[i - 1] = aboveMatch[1] + rowA.join(',') + aboveMatch[3];
                }

                // Jaw
                let belowMatch = lines[i + 1].match(/^(\s*\{)(.*?)(\},?)$/);
                if (belowMatch) {
                    let rowB = belowMatch[2].split(',').map(s => parseInt(s.trim()));
                    rowB[col - 3] = 1;
                    rowB[col - 2] = 1;
                    rowB[col - 1] = 5;
                    rowB[col] = 4;
                    rowB[col + 1] = 4;
                    rowB[col + 2] = 1;
                    rowB[col + 3] = 0;
                    lines[i + 1] = belowMatch[1] + rowB.join(',') + belowMatch[3];
                }
            }
        }
    }
}
content = lines.join('\n');

const punch2Original = /Character\.frames\["punch_2"\] = \{\s*(?:\{[0-9, ]+\},?\s*){20}\}/g;
const punch2New = `Character.frames["punch_2"] = {
    {0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,1,2,2,3,3,2,1,0,0,0},
    {0,0,0,0,0,0,0,0,1,2,5,5,5,2,1,0,0,0},
    {0,0,0,0,0,0,0,0,1,4,6,4,4,4,1,0,0,0},
    {0,0,0,0,0,0,0,0,1,1,5,4,4,2,1,0,0,0},
    {0,0,0,0,0,0,0,1,2,2,2,2,1,1,1,0,0,0},
    {0,0,0,0,0,0,1,2,3,3,2,2,2,2,2,4,4,1},
    {0,0,0,1,1,1,1,2,2,3,2,2,2,2,2,4,4,1},
    {0,0,0,1,2,4,4,1,2,2,2,2,1,1,1,1,1,1},
    {0,0,0,1,2,4,4,1,2,2,2,1,0,0,0,0,0,0},
    {0,0,0,0,1,1,1,1,2,2,2,1,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,2,2,2,2,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,2,2,1,2,2,1,0,0,0,0,0},
    {0,0,0,0,1,2,2,1,0,1,2,2,2,1,0,0,0,0},
    {0,0,0,1,2,2,1,0,0,0,1,2,2,1,0,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,0,1,2,2,1,0,0,0},
    {0,1,2,2,1,0,0,0,0,0,0,1,2,2,1,0,0,0},
    {1,2,2,1,0,0,0,0,0,0,0,0,1,2,2,1,0,0},
    {1,2,1,0,0,0,0,0,0,0,0,0,0,1,2,2,1,0},
    {1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0}
}`;
content = content.replace(punch2Original, punch2New);

const lowKick2Original = /Character\.frames\["low_kick_2"\] = \{\s*(?:\{[0-9, ]+\},?\s*){20}\}/g;
const lowKick2New = `Character.frames["low_kick_2"] = {
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,2,3,3,2,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,5,5,5,2,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,4,6,4,4,4,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,1,5,4,4,2,1,0,0,0,0,0,0},
    {0,0,0,0,1,2,2,2,2,1,1,1,0,0,0,0,0,0},
    {0,0,0,1,2,3,3,2,2,2,1,1,1,0,0,0,0,0},
    {0,0,1,1,1,2,3,3,2,2,2,2,2,1,0,0,0,0},
    {0,0,1,2,4,4,1,3,2,2,3,3,2,1,0,0,0,0},
    {0,0,1,2,4,4,1,2,2,2,2,2,1,0,0,0,0,0},
    {0,0,0,1,1,1,1,2,2,1,1,1,0,0,0,0,0,0},
    {0,0,0,0,0,1,2,2,1,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,1,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0},
    {0,1,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0},
    {1,1,1,1,2,2,2,2,2,2,2,2,2,2,4,4,1,0},
    {0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}
}`;
content = content.replace(lowKick2Original, lowKick2New);

// Replace idle hands globally where we find them
// Old row 6 (hands closed):
content = content.replace(/\{0,0,0,1,1,1,0,1,2,2,2,1,0,1,1,1,0,0\},/g, '{0,1,1,1,1,1,0,1,2,2,2,1,0,1,1,1,1,0},');
// Old row 7 (hands middle):
content = content.replace(/\{0,0,1,4,4,4,1,1,2,2,2,1,1,4,4,5,1,0\},/g, '{0,1,2,4,4,1,1,1,2,2,2,1,1,2,4,4,1,0},');
// Old row 8 (hands bottom):
content = content.replace(/\{0,0,1,5,4,1,2,2,3,3,2,2,1,5,4,1,0,0\},/g, '{0,1,2,4,4,1,2,2,3,3,2,2,1,2,4,4,1,0},');
// And the frame end row 9 (closing glove) for the right hand
content = content.replace(/\{0,0,0,1,1,2,3,3,2,2,3,3,2,1,1,0,0,0\},/g, '{0,0,0,1,1,1,3,3,2,2,3,3,2,1,1,1,1,0},');

// For idle_3 which has a slightly different row 7:
content = content.replace(/\{0,0,0,1,4,4,4,1,1,3,3,3,1,1,4,4,5,1\},/g, '{0,0,1,2,4,4,1,1,1,3,3,3,1,1,2,4,4,1},');
// idle_3 row 8:
content = content.replace(/\{0,0,0,1,5,4,1,2,3,3,3,3,2,1,5,4,1,0\},/g, '{0,0,1,2,4,4,1,2,3,3,3,3,2,1,2,4,4,1},');
// idle_3 row 9:
content = content.replace(/\{0,0,0,0,1,1,2,3,3,3,3,3,2,1,1,0,0,0\},/g, '{0,0,0,1,1,1,2,3,3,3,3,3,2,1,1,1,1,0},');

fs.writeFileSync('d:/Smack/character.lua', content, 'utf8');
console.log('Patched with Node!');