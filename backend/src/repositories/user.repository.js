const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const pool = require('../db/client');
const config = require('../config');

function mapUser(row) {
  if (!row) {
    return null;
  }

  return {
    id: row.id,
    name: row.name,
    phone: row.phone,
    email: row.email,
    shieldId: row.shield_id,
    pinHash: row.pin_hash,
    isActive: row.is_active,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}

async function findByPhone(phone) {
  const result = await pool.query(
    `SELECT id, name, phone, email, shield_id, pin_hash, is_active, created_at, updated_at
     FROM users
     WHERE phone = $1`,
    [phone],
  );
  return mapUser(result.rows[0]);
}

async function findByIdentifier(identifier) {
  const result = await pool.query(
    `SELECT id, name, phone, email, shield_id, pin_hash, is_active, created_at, updated_at
     FROM users
     WHERE phone = $1 OR LOWER(email) = LOWER($1)
     LIMIT 1`,
    [identifier],
  );
  return mapUser(result.rows[0]);
}

async function findById(id) {
  const result = await pool.query(
    `SELECT id, name, phone, email, shield_id, pin_hash, is_active, created_at, updated_at
     FROM users
     WHERE id = $1`,
    [id],
  );
  return mapUser(result.rows[0]);
}

async function createUser({ name, phone, email, pin }) {
  const pinHash = await bcrypt.hash(pin, config.bcryptSaltRounds);
  const phoneDigits = phone.replace(/\D/g, '');
  const shieldId = `SH-${phoneDigits.slice(-5)}-${crypto.randomBytes(2).toString('hex').toUpperCase()}`;

  const result = await pool.query(
    `INSERT INTO users (name, phone, email, pin_hash, shield_id)
     VALUES ($1, $2, NULLIF($3, ''), $4, $5)
     RETURNING id, name, phone, email, shield_id, pin_hash, is_active, created_at, updated_at`,
    [name, phone, email || '', pinHash, shieldId],
  );

  return mapUser(result.rows[0]);
}

async function verifyPin(user, pin) {
  if (!user || !user.pinHash) {
    return false;
  }
  return bcrypt.compare(pin, user.pinHash);
}

function generateToken(user, isCovertMode) {
  return jwt.sign(
    {
      sub: user.id,
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      shieldId: user.shieldId,
      isCovertMode: Boolean(isCovertMode),
    },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );
}

module.exports = {
  findByPhone,
  findByIdentifier,
  findById,
  createUser,
  verifyPin,
  generateToken,
};