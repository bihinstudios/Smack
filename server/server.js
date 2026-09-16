const WebSocket = require('ws');

const PORT = process.env.PORT || 8080;
const wss = new WebSocket.Server({ port: PORT });

console.log(`====================================`);
console.log(` SMACK WEBSOCKET SERVER STARTED     `);
console.log(` Listening on port: ${PORT}         `);
console.log(`====================================`);

// Map roomCode -> { p1: ws, p2: ws }
const rooms = {};
// Map ws -> roomCode
const clientRooms = new Map();

function generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';
    for (let i = 0; i < 4; i++) {
        code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    if (rooms[code]) return generateRoomCode();
    return code;
}

wss.on('connection', (ws) => {
    console.log('New client connected.');

    ws.on('message', (message) => {
        const msg = message.toString().trim();

        if (msg === 'CREATE_ROOM') {
            const code = generateRoomCode();
            rooms[code] = { p1: ws, p2: null };
            clientRooms.set(ws, code);
            console.log(`Room created: ${code}`);
            ws.send(`ROOM_CREATED|${code}`);
            return;
        }

        if (msg.startsWith('JOIN_ROOM|')) {
            const code = msg.split('|')[1].toUpperCase();

            if (rooms[code]) {
                if (rooms[code].p2 === null) {
                    rooms[code].p2 = ws;
                    clientRooms.set(ws, code);
                    console.log(`Client joined room: ${code}. Match starting!`);
                    rooms[code].p1.send('MATCH|1');
                    rooms[code].p2.send('MATCH|2');
                } else {
                    ws.send('ERROR|ROOM_FULL');
                }
            } else {
                ws.send('ERROR|ROOM_NOT_FOUND');
            }
            return;
        }

        // Relay game state to opponent
        const roomCode = clientRooms.get(ws);
        if (roomCode && rooms[roomCode]) {
            const room = rooms[roomCode];
            if (room.p1 && room.p2) {
                const opponent = (ws === room.p1) ? room.p2 : room.p1;
                if (opponent.readyState === WebSocket.OPEN) {
                    opponent.send(msg);
                }
            }
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected.');
        const roomCode = clientRooms.get(ws);

        if (roomCode && rooms[roomCode]) {
            const room = rooms[roomCode];
            const opponent = (ws === room.p1) ? room.p2 : room.p1;

            if (opponent && opponent.readyState === WebSocket.OPEN) {
                opponent.send('DISCONNECT');
            }

            delete rooms[roomCode];
            if (opponent) clientRooms.delete(opponent);
        }
        clientRooms.delete(ws);
    });

    ws.on('error', (err) => {
        console.log('Socket error:', err.message);
    });
});
