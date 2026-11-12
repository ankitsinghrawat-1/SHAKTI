const pool = require('../db/client');

class GuardianRepository {
  async getAll(userId) {
    const result = await pool.query(
      `SELECT id, name, phone, role, priority_tier, is_official, status, created_at, updated_at
       FROM guardians
       WHERE user_id = $1
       ORDER BY priority_tier ASC, created_at ASC`,
      [userId],
    );
    return result.rows.map((row) => this.mapGuardian(row));
  }

  async findById(id, userId) {
    const result = await pool.query(
      `SELECT id, name, phone, role, priority_tier, is_official, status, created_at, updated_at
       FROM guardians
       WHERE id = $1 AND user_id = $2`,
      [id, userId],
    );
    return this.mapGuardian(result.rows[0]);
  }

  async add(userId, { name, phone, role, priorityTier, isOfficial }) {
    const result = await pool.query(
      `INSERT INTO guardians (user_id, name, phone, role, priority_tier, is_official)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, name, phone, role, priority_tier, is_official, status, created_at, updated_at`,
      [
        userId,
        name,
        phone,
        role || 'Guardian • Tier 2',
        priorityTier || 2,
        Boolean(isOfficial),
      ],
    );
    return this.mapGuardian(result.rows[0]);
  }

  mapGuardian(row) {
    if (!row) {
      return null;
    }

    return {
      id: row.id,
      name: row.name,
      phone: row.phone,
      role: row.role,
      priorityTier: row.priority_tier,
      isOfficial: row.is_official,
      status: row.status,
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}

module.exports = new GuardianRepository();
