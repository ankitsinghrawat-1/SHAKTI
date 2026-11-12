/**
 * SHAKTI WebSocket Real-Time Broadcast Hub
 *
 * Provides sub-50ms live coordinate streaming, telemetry updates,
 * and responder acknowledgement notifications to mobile apps and dispatchers.
 */

const { WebSocketServer, WebSocket } = require('ws');

class RealtimeHub {
  constructor() {
    this.wss = null;
    this.subscriptions = new Map(); // incidentId -> Set<WebSocket>
  }

  attach(httpServer) {
    this.wss = new WebSocketServer({ server: httpServer, path: '/ws/live' });

    this.wss.on('connection', (ws, req) => {
      ws.isAlive = true;
      ws.on('pong', () => { ws.isAlive = true; });

      console.log(`[SHAKTI WebSocket] Client connected from ${req.socket.remoteAddress}`);

      ws.on('message', (message) => {
        try {
          const data = JSON.parse(message.toString());
          if (data.action === 'subscribe' && data.incidentId) {
            if (!this.subscriptions.has(data.incidentId)) {
              this.subscriptions.set(data.incidentId, new Set());
            }
            this.subscriptions.get(data.incidentId).add(ws);
            ws.send(JSON.stringify({ type: 'SUBSCRIBED', incidentId: data.incidentId }));
          } else if (data.action === 'ping') {
            ws.send(JSON.stringify({ type: 'pong', timestamp: Date.now() }));
          }
        } catch (e) {
          // ignore malformed ws message
        }
      });

      ws.on('close', () => {
        for (const [incId, clients] of this.subscriptions.entries()) {
          clients.delete(ws);
          if (clients.size === 0) {
            this.subscriptions.delete(incId);
          }
        }
      });
    });

    // Heartbeat check every 30s
    this.heartbeatInterval = setInterval(() => {
      if (!this.wss) return;
      this.wss.clients.forEach(ws => {
        if (!ws.isAlive) return ws.terminate();
        ws.isAlive = false;
        ws.ping();
      });
    }, 30000);

    console.log('[SHAKTI WebSocket] Real-time stream listening on /ws/live');
  }

  broadcast(message) {
    if (!this.wss) return;
    const raw = JSON.stringify(message);
    this.wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(raw);
      }
    });
  }

  broadcastIncident(incident) {
    this.broadcast({
      type: 'INCIDENT_ACTIVE',
      incident,
    });
  }

  broadcastLocation(incidentId, locationPoint) {
    const payload = {
      type: 'LOCATION_TELEMETRY',
      incidentId,
      location: locationPoint,
      timestamp: new Date().toISOString(),
    };

    // Send to specific incident subscribers and general listeners
    const subscribers = this.subscriptions.get(incidentId);
    if (subscribers) {
      const raw = JSON.stringify(payload);
      subscribers.forEach(ws => {
        if (ws.readyState === WebSocket.OPEN) ws.send(raw);
      });
    }

    this.broadcast(payload);
  }

  broadcastAcknowledgement(incidentId, ack) {
    this.broadcast({
      type: 'ACKNOWLEDGEMENT_RECEIVED',
      incidentId,
      acknowledgement: ack,
    });
  }

  broadcastResolution(incidentId, reason) {
    this.broadcast({
      type: 'INCIDENT_RESOLVED',
      incidentId,
      reason,
    });
  }
}

module.exports = new RealtimeHub();
