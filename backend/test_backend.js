const assert = require('node:assert/strict');
const app = require('./src/app');
const config = require('./src/config');
const pool = require('./src/db/client');

async function request(server, path, options = {}) {
  return fetch(`http://127.0.0.1:${server.address().port}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });
}

async function run() {
  const server = await new Promise((resolve) => {
    const instance = app.listen(0, () => resolve(instance));
  });

  try {
    const health = await request(server, `${config.apiPrefix}/health`);
    assert.equal(health.status, 200);
    const healthBody = await health.json();
    assert.equal(healthBody.status, 'UP');
    assert.equal(typeof healthBody.metrics.totalUsers, 'number');

    const incidentsWithoutAuth = await request(
      server,
      `${config.apiPrefix}/incidents`,
    );
    assert.equal(incidentsWithoutAuth.status, 401);

    const evidenceWithoutAuth = await request(
      server,
      `${config.apiPrefix}/evidence/manifest`,
      {
        method: 'POST',
        body: JSON.stringify({}),
      },
    );
    assert.equal(evidenceWithoutAuth.status, 401);

    const invalidHazard = await request(
      server,
      `${config.apiPrefix}/reports/hazard`,
      {
        method: 'POST',
        body: JSON.stringify({ type: 'x' }),
      },
    );
    assert.equal(invalidHazard.status, 400);

    const missingRoute = await request(server, `${config.apiPrefix}/missing`);
    assert.equal(missingRoute.status, 404);

    console.log('Backend smoke tests passed.');
  } finally {
    await new Promise((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
    await pool.end();
  }
}

run().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
