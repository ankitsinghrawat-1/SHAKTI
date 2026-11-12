const crypto = require('crypto');
const pool = require('../db/client');

function mapIncident(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    idempotencyKey: row.idempotency_key,
    userId: row.user_id,
    userName: row.user_name,
    source: row.source,
    severity: row.severity,
    status: row.status,
    receiptId: row.receipt_id,
    deviceSequence: row.device_sequence,
    isCovert: row.is_covert,
    triggerLocation: {
      latitude: row.latitude,
      longitude: row.longitude,
      accuracy: row.accuracy,
      speed: row.speed,
    },
    createdAt: row.created_at,
    serverReceivedAt: row.server_received_at,
    resolvedAt: row.resolved_at,
    resolutionReason: row.resolution_reason,
    lastAcknowledgedAt: row.last_acknowledged_at,
  };
}

class IncidentRepository {
  async findById(id, userId) {
    const result = await pool.query(
      `SELECT *
       FROM incidents
       WHERE id = $1 AND (user_id = $2 OR user_id IS NULL)`,
      [id, userId || null],
    );
    return mapIncident(result.rows[0]);
  }

  async createIncident({
    incidentId,
    idempotencyKey,
    source,
    userId,
    userName,
    latitude,
    longitude,
    accuracy,
    speed,
    severity,
    deviceSequence,
    isCovert,
  }) {
    const effectiveKey = idempotencyKey || incidentId;
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const existing = await client.query(
        `SELECT *
         FROM incidents
         WHERE idempotency_key = $1 OR id = $2
         LIMIT 1
         FOR UPDATE`,
        [effectiveKey, incidentId],
      );

      if (existing.rowCount > 0) {
        await client.query('COMMIT');
        return { incident: mapIncident(existing.rows[0]), isReplay: true };
      }

      const receiptId = `RCPT-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
      const inserted = await client.query(
        `INSERT INTO incidents (
           id, user_id, idempotency_key, source, user_name, severity, receipt_id,
           device_sequence, is_covert, latitude, longitude, accuracy, speed
         )
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
         RETURNING *`,
        [
          incidentId,
          userId || null,
          effectiveKey,
          source || 'appSosButton',
          userName || 'Citizen',
          severity || 'Urgent',
          receiptId,
          deviceSequence || 1,
          Boolean(isCovert),
          latitude,
          longitude,
          accuracy || null,
          speed || null,
        ],
      );

      if (latitude !== undefined && longitude !== undefined) {
        await client.query(
          `INSERT INTO incident_locations
             (incident_id, latitude, longitude, accuracy, speed, provider, captured_at)
           VALUES ($1, $2, $3, $4, $5, 'GNSS', $6)`,
          [
            incidentId,
            latitude,
            longitude,
            accuracy || 0,
            speed || 0,
            new Date(),
          ],
        );
      }

      await client.query('COMMIT');
      return { incident: mapIncident(inserted.rows[0]), isReplay: false };
    } catch (error) {
      await client.query('ROLLBACK');

      if (error.code === '23505') {
        const existing = await pool.query(
          `SELECT *
           FROM incidents
           WHERE idempotency_key = $1 OR id = $2
           LIMIT 1`,
          [effectiveKey, incidentId],
        );
        if (existing.rowCount > 0) {
          return { incident: mapIncident(existing.rows[0]), isReplay: true };
        }
      }

      throw error;
    } finally {
      client.release();
    }
  }

  async addTelemetry(incidentId, points, userId) {
    const incident = await this.findById(incidentId, userId);
    if (!incident) {
      return null;
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      for (const point of points) {
        await client.query(
          `INSERT INTO incident_locations
             (incident_id, latitude, longitude, accuracy, speed, altitude, bearing, provider, captured_at)
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
          [
            incidentId,
            point.latitude,
            point.longitude,
            point.accuracy || 0,
            point.speed || 0,
            point.altitude || 0,
            point.bearing || 0,
            point.provider || 'GNSS',
            point.timestamp ? new Date(point.timestamp) : new Date(),
          ],
        );
      }
      await client.query('COMMIT');
      return points.length;
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async countLocations(incidentId, userId) {
    const incident = await this.findById(incidentId, userId);
    if (!incident) {
      return null;
    }

    const result = await pool.query(
      'SELECT COUNT(*)::int AS count FROM incident_locations WHERE incident_id = $1',
      [incidentId],
    );
    return result.rows[0].count;
  }

  async recordAcknowledgement(incidentId, userId, { actorName, ackType, notes }) {
    const incident = await this.findById(incidentId, userId);
    if (!incident) {
      return null;
    }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      const result = await client.query(
        `INSERT INTO incident_acknowledgements (incident_id, actor_name, ack_type, notes)
         VALUES ($1, $2, $3, $4)
         RETURNING id, incident_id, actor_name, ack_type, notes, acknowledged_at`,
        [incidentId, actorName || 'Verified Guardian', ackType || 'RESPONDING', notes || ''],
      );
      await client.query(
        `UPDATE incidents
         SET status = 'RECIPIENT_ACKNOWLEDGED', last_acknowledged_at = NOW()
         WHERE id = $1`,
        [incidentId],
      );
      await client.query('COMMIT');

      const row = result.rows[0];
      return {
        id: row.id,
        incidentId: row.incident_id,
        actorName: row.actor_name,
        ackType: row.ack_type,
        notes: row.notes,
        acknowledgedAt: row.acknowledged_at,
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async resolveIncident(incidentId, userId, reason) {
    const result = await pool.query(
      `UPDATE incidents
       SET status = 'RESOLVED', resolved_at = NOW(), resolution_reason = $3
       WHERE id = $1 AND (user_id = $2 OR user_id IS NULL)
       RETURNING *`,
      [incidentId, userId || null, reason || 'Incident resolved safely'],
    );
    return mapIncident(result.rows[0]);
  }
}

module.exports = new IncidentRepository();
