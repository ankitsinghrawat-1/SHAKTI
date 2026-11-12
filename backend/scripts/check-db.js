const pool = require('../src/db/client');

async function checkDatabase() {
  try {
    const result = await pool.query('SELECT NOW() AS current_time');
    console.log(`Database connection successful: ${result.rows[0].current_time.toISOString()}`);
  } finally {
    await pool.end();
  }
}

checkDatabase().catch((error) => {
  console.error(`Database connection failed: ${error.message}`);
  process.exitCode = 1;
});
