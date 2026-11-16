const pool = require('../db/client');

class HazardRepository {
  async getAll() {
    const result = await pool.query(
      `SELECT id, type, location, severity, notes, latitude, longitude,
              status, created_at
       FROM hazard_reports
       ORDER BY created_at DESC`,
    );
    return result.rows.map(this.mapHazard);
  }

  async getNearbyAlerts() {
    return this.getAll();
  }

  async createHazardReport(
    { type, location, severity, notes, latitude, longitude },
    userId,
  ) {
    const result = await pool.query(
      `INSERT INTO hazard_reports (
         user_id, type, location, severity, notes, latitude, longitude
       )
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING id, type, location, severity, notes, latitude, longitude,
                 status, created_at`,
      [
        userId || null,
        type,
        location,
        severity || 'Medium',
        notes || '',
        latitude ?? null,
        longitude ?? null,
      ],
    );
    return this.mapHazard(result.rows[0]);
  }

  async recordFeedback({ type, message, rating, deviceInfo }, userId) {
    const result = await pool.query(
      `INSERT INTO feedback_submissions (
         user_id, type, message, rating, device_info
       )
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, type, message, rating, device_info, received_at`,
      [
        userId || null,
        type || 'general',
        message,
        rating ?? null,
        deviceInfo || null,
      ],
    );
    return result.rows[0];
  }

  mapHazard(row) {
    return {
      id: row.id,
      type: row.type,
      location: row.location,
      severity: row.severity,
      notes: row.notes,
      latitude: row.latitude,
      longitude: row.longitude,
      status: row.status,
      timestamp: row.created_at,
    };
  }
}

module.exports = new HazardRepository();
