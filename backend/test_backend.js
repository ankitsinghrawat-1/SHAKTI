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

    const validFeedback = await request(
      server,
      `${config.apiPrefix}/feedback`,
      {
        method: 'POST',
        body: JSON.stringify({
          category: 'App Feedback',
          description: 'Great safety application test feedback',
          rating: 5,
        }),
      },
    );
    assert.equal(validFeedback.status, 201);

    // Test Registration, OTP Verification, and Guardian CRUD
    const testPhone = '+9199' + Date.now().toString().slice(-8);
    const regRes = await request(server, `${config.apiPrefix}/auth/register`, {
      method: 'POST',
      body: JSON.stringify({
        name: 'Automated Test User',
        phone: testPhone,
        email: `autotest_${Date.now()}@shakti.safety`,
        pin: '1234',
      }),
    });
    assert.ok(regRes.status === 201 || regRes.status === 200);

    const verifyRes = await request(server, `${config.apiPrefix}/auth/verify-phone`, {
      method: 'POST',
      body: JSON.stringify({
        phone: testPhone,
        code: config.demoOtpCode || '123456',
      }),
    });
    assert.equal(verifyRes.status, 200);
    const verifyBody = await verifyRes.json();
    const token = verifyBody.token;
    assert.ok(token, 'Should return JWT token after verification');

    // Add Guardian
    const addGuardianRes = await request(server, `${config.apiPrefix}/guardians`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}` },
      body: JSON.stringify({
        name: 'Pooja Verma',
        phone: '+919811299999',
        role: 'Sister • Tier 1',
        priorityTier: 1,
      }),
    });
    assert.equal(addGuardianRes.status, 201);
    const addGuardianBody = await addGuardianRes.json();
    assert.equal(addGuardianBody.guardian.name, 'Pooja Verma');
    assert.equal(addGuardianBody.guardian.phone, '+919811299999');
    const guardianId = addGuardianBody.guardian.id;

    // Get Guardians
    const getGuardiansRes = await request(server, `${config.apiPrefix}/guardians`, {
      method: 'GET',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert.equal(getGuardiansRes.status, 200);
    const getGuardiansBody = await getGuardiansRes.json();
    assert.ok(getGuardiansBody.guardians.some((g) => g.id === guardianId));

    // Delete Guardian
    const deleteGuardianRes = await request(server, `${config.apiPrefix}/guardians/${guardianId}`, {
      method: 'DELETE',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert.equal(deleteGuardianRes.status, 200);

    // Confirm Guardian is deleted
    const getAfterDeleteRes = await request(server, `${config.apiPrefix}/guardians`, {
      method: 'GET',
      headers: { Authorization: `Bearer ${token}` },
    });
    assert.equal(getAfterDeleteRes.status, 200);
    const getAfterDeleteBody = await getAfterDeleteRes.json();
    assert.ok(!getAfterDeleteBody.guardians.some((g) => g.id === guardianId));

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
