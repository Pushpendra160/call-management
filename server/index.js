const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
const app = express();
const http = require('http');
const WebSocket = require('ws');
const port = 3000;
require('dotenv').config();

// Middleware to parse JSON
app.use(express.json());

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log('Connected to MongoDB');
}).catch((error) => {
  console.error('Error connecting to MongoDB:', error);
});

// Define routes
app.use('/api/auth', authRoutes);

// Define a simple route
app.get('/', (req, res) => {
  res.send('Hello World!');
});
const server = http.createServer(app);
// Set up WebSocket server
// Create HTTP server


// Set up WebSocket server
const wss = new WebSocket.Server({ server });

const clients = {};

wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    const data = JSON.parse(message);

    switch (data.type) {
      case 'register':
        clients[data.username] = ws;
        break;
      case 'call':
        const target = clients[data.to];
        if (target) {
          target.send(JSON.stringify({ type: 'incoming_call', from: data.from, offer: data.offer }));
        }
        break;
      case 'answer':
        const caller = clients[data.to];
        if (caller) {
          caller.send(JSON.stringify({ type: 'call_answered', from: data.from, answer: data.answer }));
        }
        break;
      case 'candidate':
        const recipient = clients[data.to];
        if (recipient) {
          recipient.send(JSON.stringify({ type: 'candidate', candidate: data.candidate }));
        }
        break;
      case 'end_call':
        const endTarget = clients[data.to];
        if (endTarget) {
          endTarget.send(JSON.stringify({ type: 'end_call' }));
        }
        break;
      // Handle other signaling messages like ICE candidates, offer, and answer
    }
  });

  ws.on('close', () => {
    Object.keys(clients).forEach((key) => {
      if (clients[key] === ws) {
        delete clients[key];
      }
    });
  });
});



// Start the server
app.listen(3000, '0.0.0.0', () => {
  console.log('Server is running on http://0.0.0.0:3000');
  console.log('Signaling server running');
});

