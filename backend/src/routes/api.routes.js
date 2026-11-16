/**
 * SHAKTI Master API Router
 * Implements versioned routes with schema validation, auth guards, and real-time triggers.
 */

const express = require('express');
const router = express.Router();

const { validate } = require('../middlewares/validate');
const { requireAuth, optionalAuth } = require('../middlewares/auth');
const schemas = require('../schemas');
const store = require('../db/storage');
const userRepo = require('../repositories/user.repository');
const incidentRepo = require('../repositories/incident.repository');
const guardianRepo = require('../repositories/guardian.repository');
const evidenceRepo = require('../repositories/evidence.repository');
const storageService = require('../services/storage.service');
const hazardRepo = require('../repositories/hazard.repository');
const outboxService = require('../services/outbox.service');
const realtimeHub = require('../websocket/server');
const config = require('../config');
const pool = require('../db/client');
const otpService = require('../services/otp.service');

// 1. Health & Telemetry Check
router.get('/health', async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT
         (SELECT COUNT(*) FROM incidents WHERE status <> 'RESOLVED') AS active_incidents,
         (SELECT COUNT(*) FROM incidents) AS total_incidents,
         (SELECT COUNT(*) FROM users) AS total_users,
         (SELECT COUNT(*) FROM guardians) AS total_guardians`,
    );
    const counts = result.rows[0];
    res.status(200).json({
      status: 'UP',
      service: 'SHAKTI Unified Safety Backend (Zero-Flaw Production Core)',
      version: '2.0.0',
      timestamp: new Date().toISOString(),
      metrics: {
        activeIncidents: Number(counts.active_incidents),
        totalIncidents: Number(counts.total_incidents),
        totalUsers: Number(counts.total_users),
        totalGuardians: Number(counts.total_guardians),
        outboxQueued: store.state.deliveryAttempts.filter(d => d.status === 'QUEUED').length,
      },
    });
  } catch (err) {
    next(err);
  }
});

// 2. Auth: Register
router.post('/auth/register', validate(schemas.RegisterSchema), async (req, res, next) => {
  try {
    const { name, phone, email, pin } = req.body;
    const existing = await userRepo.findByPhone(phone);
    if (existing) {
      return res.status(409).json({ error: 'User with this phone number already exists.' });
    }

    const user = await userRepo.createUser({ name, phone, email, pin });
    try {
      await otpService.sendVerification(user.phone);
    } catch (err) {
      await userRepo.deletePendingUser(user.id);
      throw err;
    }

    res.status(201).json({
      message: config.demoOtpEnabled
        ? 'Demo verification code generated. Check the backend console.'
        : 'Verification code sent to the registered phone number.',
      verificationRequired: true,
      demoOtp: config.demoOtpEnabled ? config.demoOtpCode : undefined,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        shieldId: user.shieldId,
      },
    });
  } catch (err) {
    next(err);
  }
});

// 3. Auth: Verify phone ownership
router.post('/auth/verify-phone', validate(schemas.VerifyPhoneSchema), async (req, res, next) => {
  try {
    const { phone, code } = req.body;
    const user = await userRepo.findByPhone(phone);
    if (!user || user.isActive) {
      return res.status(400).json({ error: 'No pending phone verification was found.' });
    }

    const approved = await otpService.checkVerification(user.phone, code);
    if (!approved) {
      return res.status(400).json({ error: 'Invalid or expired verification code.' });
    }

    const verifiedUser = await userRepo.markPhoneVerified(user.id);
    const token = userRepo.generateToken(verifiedUser, false);
    return res.status(200).json({
      message: 'Phone number verified successfully.',
      token,
      verificationRequired: false,
      user: {
        id: verifiedUser.id,
        name: verifiedUser.name,
        phone: verifiedUser.phone,
        email: verifiedUser.email,
        shieldId: verifiedUser.shieldId,
      },
    });
  } catch (err) {
    next(err);
  }
});

// 4. Auth: Resend phone verification code
router.post('/auth/resend-phone-code', validate(schemas.RegisterSchema.pick({ phone: true })), async (req, res, next) => {
  try {
    const user = await userRepo.findByPhone(req.body.phone);
    if (!user || user.isActive) {
      return res.status(400).json({ error: 'No pending phone verification was found.' });
    }
    await otpService.sendVerification(user.phone);
    return res.status(200).json({
      message: 'A new verification code was sent.',
      verificationRequired: true,
    });
  } catch (err) {
    next(err);
  }
});

// 5. Auth: Login & Duress Detection
router.post('/auth/login', validate(schemas.LoginSchema), async (req, res, next) => {
  try {
    const { identifier, pin } = req.body;

    // SECTION 18 DURESS PROTOCOL:
    // If Duress PIN ('0000') is entered, authenticate immediately into a decoy profile.
    // Behind the scenes, flag the token as covert and trigger a silent covert emergency.
    if (pin === config.duressPin) {
      console.warn('[SHAKTI SECURITY ALERT] Duress PIN entered! Triggering Covert Decoy Mode.');

      const decoyUser = {
        id: 'usr-duress-decoy',
        name: 'Citizen Guest',
        phone: identifier,
        shieldId: 'SH-DECOY-00',
      };

      const decoyToken = userRepo.generateToken(decoyUser, true);

      // Silently open high-priority covert incident
      await incidentRepo.createIncident({
        incidentId: `inc-duress-${Date.now()}`,
        source: 'DURESS_COVERT_PIN',
        userId: null,
        userName: 'Citizen (Duress Alert)',
        severity: 'CRITICAL',
        isCovert: true,
      });
      outboxService.triggerImmediate();

      return res.status(200).json({
        token: decoyToken,
        isCovertMode: true,
        message: 'Duress Decoy Profile Authenticated.',
        user: decoyUser,
      });
    }

    // Normal Login
    const user = await userRepo.findByIdentifier(identifier);
    if (!user) {
      return res.status(401).json({ error: 'Invalid phone, email or 4-digit PIN.' });
    }
    if (!user.isActive || !user.phoneVerifiedAt) {
      return res.status(403).json({
        error: 'Phone number verification is required before login.',
        code: 'PHONE_NOT_VERIFIED',
      });
    }

    const isMatch = await userRepo.verifyPin(user, pin);
    if (!isMatch) {
      return res.status(401).json({ error: 'Invalid phone, email or 4-digit PIN.' });
    }

    const token = userRepo.generateToken(user, false);
    res.status(200).json({
      token,
      isCovertMode: false,
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        shieldId: user.shieldId,
      },
    });
  } catch (err) {
    next(err);
  }
});

// 4. Auth: Profile Me
router.get('/auth/me', requireAuth, async (req, res, next) => {
  try {
    const user = await userRepo.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'Authenticated user was not found.' });
    }

    return res.status(200).json({
      user: {
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        shieldId: user.shieldId,
      },
    });
  } catch (err) {
    next(err);
  }
});

// 5. Guardians: Get
router.get('/guardians', requireAuth, async (req, res, next) => {
  try {
    const guardians = await guardianRepo.getAll(req.user.id);
    res.status(200).json({
      guardians,
      total: guardians.length,
    });
  } catch (err) {
    next(err);
  }
});

// 6. Guardians: Add
router.post('/guardians', requireAuth, validate(schemas.AddGuardianSchema), async (req, res, next) => {
  try {
    const guardian = await guardianRepo.add(req.user.id, req.body);
    res.status(201).json({ guardian });
  } catch (err) {
    next(err);
  }
});

// 7. Incidents: Create Emergency Incident (Zero Data Loss + Absolute Idempotency)
router.post('/incidents', requireAuth, validate(schemas.CreateIncidentSchema), async (req, res, next) => {
  try {
    const idempotencyKey = req.headers['x-idempotency-key'] || req.body.incidentId;
    const userId = req.user.id;
    const userName = req.body.userName || req.user.name;

    const result = await incidentRepo.createIncident({
      incidentId: req.body.incidentId,
      idempotencyKey,
      source: req.body.source,
      userId,
      userName,
      latitude: req.body.latitude,
      longitude: req.body.longitude,
      accuracy: req.body.accuracy,
      speed: req.body.speed,
      severity: req.body.severity,
      deviceSequence: req.body.deviceSequence,
      isCovert: req.body.isCovert || (req.user ? req.user.isCovertMode : false),
    });

    if (result.isReplay) {
      return res.status(200).json({
        message: 'Idempotent replay: Incident already recorded by server.',
        incident: result.incident,
        serverReceived: true,
        receiptId: result.incident.receiptId,
      });
    }

    // Trigger async outbox dispatch & broadcast via WebSocket
    outboxService.triggerImmediate();
    realtimeHub.broadcastIncident(result.incident);

    res.status(201).json({
      message: 'Emergency SOS incident accepted and safely recorded by server.',
      serverReceived: true,
      incident: result.incident,
      receiptId: result.incident.receiptId,
    });
  } catch (err) {
    next(err);
  }
});

// 8. Incidents: Get Authenticated User History
router.get('/incidents', requireAuth, async (req, res, next) => {
  try {
    const incidents = await incidentRepo.getAll(req.user.id);
    return res.status(200).json({
      incidents,
      total: incidents.length,
    });
  } catch (err) {
    next(err);
  }
});

// 9. Incidents: Get Status
router.get('/incidents/:id', requireAuth, async (req, res) => {
  const incident = await incidentRepo.findById(req.params.id, req.user.id);
  if (!incident) {
    return res.status(404).json({ error: 'Incident record not found.' });
  }

  // Attach location breadcrumbs & evidence summary
  const locationFixCount = await incidentRepo.countLocations(req.params.id, req.user.id);
  const manifests = await evidenceRepo.getManifestsForIncident(incident.id, req.user.id);

  res.status(200).json({
    incident: {
      ...incident,
      locationFixCount,
      evidenceManifests: manifests,
    },
  });
});

// 10. Incidents: Stream Location Telemetry
router.post('/incidents/:id/locations', requireAuth, validate(schemas.BatchTelemetrySchema), async (req, res, next) => {
  try {
    const incidentId = req.params.id;
    const { points } = req.body;

    const fixes = await incidentRepo.addTelemetry(incidentId, points, req.user.id);
    if (fixes === null) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }

    // Broadcast latest fix over WebSockets to guardians
    if (points.length > 0) {
      realtimeHub.broadcastLocation(incidentId, points[points.length - 1]);
    }

    res.status(200).json({
      message: `Accepted ${points.length} telemetry points.`,
      receivedCount: points.length,
      timestamp: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
});

// 11. Incidents: Acknowledge (Guardian / 112 Confirmation)
router.post('/incidents/:id/acknowledgements', requireAuth, validate(schemas.AcknowledgeIncidentSchema), async (req, res, next) => {
  try {
    const incidentId = req.params.id;
    const ack = await incidentRepo.recordAcknowledgement(incidentId, req.user.id, req.body);
    if (!ack) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }

    realtimeHub.broadcastAcknowledgement(incidentId, ack);

    res.status(201).json({
      message: 'Acknowledgement recorded successfully.',
      acknowledgement: ack,
    });
  } catch (err) {
    next(err);
  }
});

// 12. Incidents: Resolve Emergency with PIN verification
router.post('/incidents/:id/resolve', requireAuth, validate(schemas.ResolveIncidentSchema), async (req, res, next) => {
  try {
    const incidentId = req.params.id;
    const { pin, reason } = req.body;

    const user = await userRepo.findById(req.user.id);
    const isValidPin = await userRepo.verifyPin(user, pin);

    if (!isValidPin) {
      return res.status(403).json({ error: 'Invalid security PIN. Cannot resolve emergency incident.' });
    }

    const resolved = await incidentRepo.resolveIncident(incidentId, req.user.id, reason);
    if (!resolved) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }

    realtimeHub.broadcastResolution(incidentId, reason);

    res.status(200).json({
      message: 'Emergency incident safely resolved and sealed.',
      incident: resolved,
    });
  } catch (err) {
    next(err);
  }
});

// 13. Evidence: Register Manifest (SHA-256 Verified)
router.post('/evidence/manifest', requireAuth, validate(schemas.EvidenceManifestSchema), async (req, res, next) => {
  try {
    const sealed = await evidenceRepo.registerManifest(req.user.id, req.body);
    if (!sealed) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }
    res.status(201).json({
      message: 'Evidence manifest cryptographically registered and sealed.',
      manifestId: sealed.manifestId,
      status: sealed.status,
      storedItems: sealed.items.length,
      totalBytes: sealed.totalBytes,
    });
  } catch (err) {
    next(err);
  }
});

// 14. Evidence: Authorize a direct upload to the private Supabase bucket
router.post('/evidence/upload-url', requireAuth, async (req, res, next) => {
  try {
    const { incidentId, fileName } = req.body;
    if (
      typeof incidentId !== 'string' ||
      incidentId.length === 0 ||
      typeof fileName !== 'string' ||
      fileName.length === 0
    ) {
      return res.status(400).json({
        error: 'incidentId and fileName are required.',
      });
    }

    const incident = await incidentRepo.findById(incidentId, req.user.id);
    if (!incident) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }

    const upload = await storageService.createEvidenceUploadUrl({
      userId: req.user.id,
      incidentId,
      fileName,
    });
    return res.status(201).json(upload);
  } catch (err) {
    next(err);
  }
});

// 15. Evidence: Authorize a temporary download URL for owned evidence
router.get('/evidence/incidents/:incidentId/download-url', requireAuth, async (req, res, next) => {
  try {
    const incident = await incidentRepo.findById(req.params.incidentId, req.user.id);
    if (!incident) {
      return res.status(404).json({ error: 'Incident record not found.' });
    }

    const fileType = req.query.fileType ? String(req.query.fileType) : undefined;
    const item = await evidenceRepo.getFirstItemForIncident(
      req.params.incidentId,
      req.user.id,
      fileType,
    );
    if (!item || !item.fileReference) {
      return res.status(404).json({ error: 'Requested evidence file was not found.' });
    }

    const download = await storageService.createEvidenceDownloadUrl(
      item.fileReference,
    );
    return res.status(200).json({
      ...download,
      fileName: item.fileName,
      fileType: item.fileType,
      sha256Digest: item.sha256Digest,
    });
  } catch (err) {
    next(err);
  }
});

// 16. Public Safety: Nearby Alerts
router.get('/nearby-alerts', async (req, res) => {
  const alerts = await hazardRepo.getNearbyAlerts();
  res.status(200).json({
    alerts,
    total: alerts.length,
  });
});

// 17. Community Hazard Reports
router.post('/reports/hazard', optionalAuth, validate(schemas.HazardReportSchema), async (req, res, next) => {
  try {
    const report = await hazardRepo.createHazardReport(req.body, req.user?.id);
    res.status(201).json({
      message: 'Community hazard report submitted and published to local radius.',
      report,
    });
  } catch (err) {
    next(err);
  }
});

// 18. Customer Feedback
router.post('/feedback', optionalAuth, validate(schemas.FeedbackSchema), async (req, res, next) => {
  try {
    const saved = await hazardRepo.recordFeedback(req.body, req.user?.id);
    res.status(201).json({
      message: 'Feedback received. Thank you for contributing to safety.',
      id: saved.id,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
