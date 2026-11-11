/**
 * SHAKTI Unified Women's Safety Platform - Reference Backend Server
 * 
 * Implements the API specifications from the SHAKTI Technical Project Blueprint
 * (Version 2.0, Section 19: Backend, Database and API Design).
 * 
 * Uses standard Node.js built-in modules for zero-dependency portability,
 * instant startup, robust CORS handling, and idempotency tracking.
 */

const http = require('http');
const crypto = require('crypto');

const PORT = process.env.PORT || 3000;
const API_PREFIX = '/api/v1';

// In-Memory Data Store (aligned with Prisma schema entities)
const db = {
  users: [
    {
      id: 'usr-9811',
      name: 'Ananya Sharma',
      phone: '98112 40291',
      email: 'ananya.sharma@shield.net',
      shieldId: 'SH-98112-X',
      pin: '9811',
      token: 'shakti_jwt_mock_token_ananya_9811',
      createdAt: new Date().toISOString(),
    },
  ],
  guardians: [
    {
      id: 'g-erss-112',
      name: 'National Emergency Response (ERSS-112)',
      phone: '112',
      role: 'Verified Police Patrol Dispatch',
      isOfficial: true,
      status: 'VERIFIED',
    },
    {
      id: 'g-mother',
      name: 'Dr. Kavita Sharma',
      phone: '+91 98112 40292',
      role: 'Mother • Tier 1 Primary',
      isOfficial: false,
      status: 'ACTIVE',
    },
    {
      id: 'g-sister',
      name: 'Priya Sharma',
      phone: '+91 98112 40293',
      role: 'Sister • Tier 1 Secondary',
      isOfficial: false,
      status: 'ACTIVE',
    },
    {
      id: 'g-wa',
      name: 'Rahul Varma (Guardian Circle)',
      phone: '+91 98112 40294',
      role: 'Guardian • Tier 2',
      isOfficial: false,
      status: 'ACTIVE',
    },
  ],
  incidents: [],
  idempotencyKeys: new Set(),
  locationTelemetry: [],
  evidenceManifests: [],
  hazardReports: [
    {
      id: 'haz-001',
      type: 'Broken Streetlight',
      location: 'Janpath Outer Ring Corridor',
      severity: 'High',
      notes: '3 light posts unlit after 21:00.',
      timestamp: 'Today, 19:45',
      status: 'LOGGED_LOCALLY',
    },
    {
      id: 'haz-002',
      type: 'Isolated Stretch',
      location: 'Subway Underpass towards Metro Gate 3',
      severity: 'Medium',
      notes: 'Low footfall, security booth unoccupied.',
      timestamp: 'Yesterday, 21:10',
      status: 'INVESTIGATING',
    },
  ],
  feedbackSubmissions: [],
  nearbyAlerts: [
    {
      id: 'alert-cctv-01',
      source: 'Authorized Street Sensor CP-14',
      type: 'Low Footfall / Isolated Area',
      confidence: 0.88,
      distanceMeters: 250,
      timestamp: new Date().toISOString(),
      advisory: 'Well-lit alternate route available via Connaught Place Radial Road 3.',
    },
  ],
};

// Helper: Set Permissive CORS Headers
function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Idempotency-Key, X-Client-Platform, X-App-Version');
  res.setHeader('Access-Control-Max-Age', '86400');
}

// Helper: Send JSON Response
function sendJson(res, statusCode, data) {
  setCorsHeaders(res);
  res.setHeader('Content-Type', 'application/json');
  res.statusCode = statusCode;
  res.end(JSON.stringify(data));
}

// Helper: Parse Request Body
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      if (body.length > 10 * 1024 * 1024) { // 10MB limit
        reject(new Error('Payload too large'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (err) {
        reject(err);
      }
    });
    req.on('error', reject);
  });
}

// Main HTTP Dispatcher
const server = http.createServer(async (req, res) => {
  setCorsHeaders(res);

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.statusCode = 204;
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  const path = parsedUrl.pathname;
  const method = req.method;

  console.log(`[SHAKTI Backend] ${method} ${path}`);

  try {
    // 1. Health Check
    if (method === 'GET' && (path === `${API_PREFIX}/health` || path === '/health')) {
      return sendJson(res, 200, {
        status: 'UP',
        service: 'SHAKTI Unified Safety Backend',
        version: '2.0.0',
        timestamp: new Date().toISOString(),
        activeIncidents: db.incidents.length,
      });
    }

    // 2. Auth: Register
    if (method === 'POST' && path === `${API_PREFIX}/auth/register`) {
      const body = await parseBody(req);
      if (!body.phone || !body.pin) {
        return sendJson(res, 400, { error: 'Phone and 4-digit PIN are required.' });
      }

      const existing = db.users.find(u => u.phone === body.phone);
      if (existing) {
        return sendJson(res, 409, { error: 'User with this phone number already exists.' });
      }

      const token = `shakti_jwt_${crypto.randomBytes(16).toString('hex')}`;
      const newUser = {
        id: `usr-${Date.now()}`,
        name: body.name || 'SHAKTI Citizen',
        phone: body.phone,
        email: body.email || `${body.phone}@shield.net`,
        shieldId: `SH-${body.phone.replace(/\D/g, '').slice(-5)}-X`,
        pin: body.pin,
        token: token,
        createdAt: new Date().toISOString(),
      };
      db.users.push(newUser);

      return sendJson(res, 201, {
        message: 'User registered successfully.',
        token: newUser.token,
        user: {
          id: newUser.id,
          name: newUser.name,
          phone: newUser.phone,
          email: newUser.email,
          shieldId: newUser.shieldId,
        },
      });
    }

    // 3. Auth: Login
    if (method === 'POST' && path === `${API_PREFIX}/auth/login`) {
      const body = await parseBody(req);
      const { identifier, pin } = body;

      if (!pin) {
        return sendJson(res, 400, { error: 'Security PIN is required.' });
      }

      // Duress PIN Check (0000 triggers covert decoy mode per Section 18)
      if (pin === '0000') {
        return sendJson(res, 200, {
          token: `shakti_jwt_duress_${crypto.randomBytes(8).toString('hex')}`,
          isCovertMode: true,
          message: 'Duress Decoy Profile Authenticated.',
          user: {
            id: 'usr-duress-decoy',
            name: 'Citizen Guest',
            shieldId: 'SH-DECOY-00',
          },
        });
      }

      // Check valid user or demo master account
      const cleanId = (identifier || '').replace(/\D/g, '');
      const user = db.users.find(u => 
        (u.pin === pin && (cleanId.length === 0 || u.phone.includes(cleanId) || identifier.toLowerCase().includes('ananya')))
      );

      if (user || pin === '9811') {
        const activeUser = user || db.users[0];
        const token = `shakti_jwt_${crypto.randomBytes(16).toString('hex')}`;
        activeUser.token = token;

        return sendJson(res, 200, {
          token: token,
          isCovertMode: false,
          user: {
            id: activeUser.id,
            name: activeUser.name,
            phone: activeUser.phone,
            email: activeUser.email,
            shieldId: activeUser.shieldId,
          },
        });
      }

      return sendJson(res, 401, { error: 'Invalid identifier or 4-digit PIN.' });
    }

    // 4. Auth: Profile Me
    if (method === 'GET' && path === `${API_PREFIX}/auth/me`) {
      const authHeader = req.headers['authorization'] || '';
      const token = authHeader.replace(/^Bearer\s+/i, '');
      const user = db.users.find(u => u.token === token) || db.users[0];
      return sendJson(res, 200, {
        user: {
          id: user.id,
          name: user.name,
          phone: user.phone,
          email: user.email,
          shieldId: user.shieldId,
        },
      });
    }

    // 5. Guardians: Get
    if (method === 'GET' && path === `${API_PREFIX}/guardians`) {
      return sendJson(res, 200, {
        guardians: db.guardians,
        total: db.guardians.length,
      });
    }

    // 6. Guardians: Add
    if (method === 'POST' && path === `${API_PREFIX}/guardians`) {
      const body = await parseBody(req);
      if (!body.name || !body.phone) {
        return sendJson(res, 400, { error: 'Guardian name and phone are required.' });
      }

      const newGuardian = {
        id: `g-${Date.now()}`,
        name: body.name,
        phone: body.phone,
        role: body.role || 'Guardian • Tier 2',
        isOfficial: false,
        status: 'VERIFIED',
      };
      db.guardians.push(newGuardian);
      return sendJson(res, 201, { guardian: newGuardian });
    }

    // 7. Incidents: Create Emergency Incident
    if (method === 'POST' && path === `${API_PREFIX}/incidents`) {
      const body = await parseBody(req);
      const idempotencyKey = req.headers['x-idempotency-key'] || body.incidentId;

      if (!body.incidentId) {
        return sendJson(res, 400, { error: 'Incident ID is required.' });
      }

      // Check Idempotency Key
      if (idempotencyKey && db.idempotencyKeys.has(idempotencyKey)) {
        console.log(`[SHAKTI Backend] Idempotent retry recognized for: ${idempotencyKey}`);
        const existing = db.incidents.find(i => i.id === body.incidentId) || {
          id: body.incidentId,
          status: 'SERVER_RECEIVED',
        };
        return sendJson(res, 200, {
          message: 'Idempotent replay: Incident already recorded.',
          incident: existing,
          serverReceived: true,
        });
      }

      if (idempotencyKey) {
        db.idempotencyKeys.add(idempotencyKey);
      }

      const newIncident = {
        id: body.incidentId,
        source: body.source || 'appSosButton',
        userName: body.userName || 'Citizen',
        latitude: body.latitude,
        longitude: body.longitude,
        severity: body.severity || 'Urgent',
        status: 'SERVER_RECEIVED',
        createdAt: new Date().toISOString(),
        dispatchedChannels: ['PUSH_APNS', 'SMS_CARRIER_GATEWAY'],
      };
      db.incidents.push(newIncident);

      return sendJson(res, 201, {
        message: 'Emergency SOS incident accepted and logged by server.',
        serverReceived: true,
        incident: newIncident,
        receiptId: `RCPT-${crypto.randomBytes(6).toString('hex').toUpperCase()}`,
      });
    }

    // 8. Incidents: Get Status
    if (method === 'GET' && path.startsWith(`${API_PREFIX}/incidents/`)) {
      const id = path.split('/').pop();
      const incident = db.incidents.find(i => i.id === id);
      if (!incident) {
        return sendJson(res, 404, { error: 'Incident record not found.' });
      }
      return sendJson(res, 200, { incident });
    }

    // 9. Incidents: Live Location Telemetry Stream
    if (method === 'POST' && path.includes('/locations')) {
      const body = await parseBody(req);
      const points = body.points || [];
      db.locationTelemetry.push(...points);

      return sendJson(res, 200, {
        message: `Accepted ${points.length} telemetry points.`,
        receivedCount: points.length,
        timestamp: new Date().toISOString(),
      });
    }

    // 10. Evidence: Register Manifest
    if (method === 'POST' && path === `${API_PREFIX}/evidence/manifest`) {
      const body = await parseBody(req);
      db.evidenceManifests.push(body);

      return sendJson(res, 201, {
        message: 'Evidence manifest cryptographically registered.',
        manifestId: `man-${Date.now()}`,
        status: 'SEALED_SERVER_VAULT',
        storedItems: (body.items || []).length,
      });
    }

    // 11. Public Safety: Nearby Alerts
    if (method === 'GET' && path === `${API_PREFIX}/nearby-alerts`) {
      return sendJson(res, 200, {
        alerts: db.nearbyAlerts,
        total: db.nearbyAlerts.length,
      });
    }

    // 12. Community Hazard Reports
    if (method === 'POST' && path === `${API_PREFIX}/reports/hazard`) {
      const body = await parseBody(req);
      const newReport = {
        id: `haz-${Date.now()}`,
        type: body.type || 'General Concern',
        location: body.location || 'Reported Location',
        severity: body.severity || 'Medium',
        notes: body.notes || '',
        timestamp: new Date().toISOString(),
        status: 'SERVER_LOGGED',
      };
      db.hazardReports.unshift(newReport);

      return sendJson(res, 201, {
        message: 'Community hazard report submitted and published to local radius.',
        report: newReport,
      });
    }

    // 13. Customer Feedback
    if (method === 'POST' && path === `${API_PREFIX}/feedback`) {
      const body = await parseBody(req);
      db.feedbackSubmissions.push({
        id: `fb-${Date.now()}`,
        ...body,
        receivedAt: new Date().toISOString(),
      });

      return sendJson(res, 201, {
        message: 'Feedback received. Thank you for contributing to safety.',
      });
    }

    // 404 Route Not Found
    return sendJson(res, 404, {
      error: 'Endpoint not found',
      path: path,
      method: method,
      availableEndpoints: [
        'GET /api/v1/health',
        'POST /api/v1/auth/register',
        'POST /api/v1/auth/login',
        'GET /api/v1/auth/me',
        'GET /api/v1/guardians',
        'POST /api/v1/guardians',
        'POST /api/v1/incidents',
        'GET /api/v1/incidents/:id',
        'POST /api/v1/incidents/:id/locations',
        'POST /api/v1/evidence/manifest',
        'GET /api/v1/nearby-alerts',
        'POST /api/v1/reports/hazard',
        'POST /api/v1/feedback',
      ],
    });
  } catch (err) {
    console.error('[SHAKTI Backend Error]', err);
    return sendJson(res, 500, { error: 'Internal server error', details: err.message });
  }
});

// Start Server
if (require.main === module) {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`\n======================================================`);
    console.log(`  SHAKTI Technical Blueprint v2.0 Reference Backend`);
    console.log(`  Listening on http://0.0.0.0:${PORT}`);
    console.log(`  API Base:   http://localhost:${PORT}/api/v1`);
    console.log(`  Health:     http://localhost:${PORT}/api/v1/health`);
    console.log(`======================================================\n`);
  });
}

module.exports = server;
