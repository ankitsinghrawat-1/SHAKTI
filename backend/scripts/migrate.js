const fs = require('fs/promises');
const path = require('path');
const pool = require('../src/db/client');

const migrationsDirectory = path.resolve(__dirname, '../src/db/migrations');

async function runMigrations() {
  const client = await pool.connect();

  try {
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        name TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const migrationFiles = (await fs.readdir(migrationsDirectory))
      .filter((file) => file.endsWith('.sql'))
      .sort();

    for (const migrationFile of migrationFiles) {
      const applied = await client.query(
        'SELECT 1 FROM schema_migrations WHERE name = $1',
        [migrationFile],
      );

      if (applied.rowCount > 0) {
        continue;
      }

      const sql = await fs.readFile(
        path.join(migrationsDirectory, migrationFile),
        'utf8',
      );

      await client.query('BEGIN');
      try {
        await client.query(sql);
        await client.query(
          'INSERT INTO schema_migrations (name) VALUES ($1)',
          [migrationFile],
        );
        await client.query('COMMIT');
        console.log(`Applied migration: ${migrationFile}`);
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      }
    }

    console.log('Database migrations complete.');
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations().catch((error) => {
  console.error(`Database migration failed: ${error.message}`);
  process.exitCode = 1;
});
