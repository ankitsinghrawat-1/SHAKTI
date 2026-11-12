const { Pool } = require('pg');
const config = require('../config');

if (!config.databaseUrl) {
  throw new Error('DATABASE_URL is required to connect to the database.');
}

const pool = new Pool({
  connectionString: config.databaseUrl,
  ssl: { rejectUnauthorized: false },
  max: 5,
  connectionTimeoutMillis: 10000,
  idleTimeoutMillis: 30000,
});

module.exports = pool;
