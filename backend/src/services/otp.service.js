const config = require('../config');

function assertConfigured() {
  if (
    !config.twilioAccountSid ||
    !config.twilioAuthToken ||
    !config.twilioVerifyServiceSid
  ) {
    const error = new Error('Twilio Verify is not configured on the backend.');
    error.statusCode = 503;
    error.code = 'OTP_PROVIDER_NOT_CONFIGURED';
    throw error;
  }
}

async function callTwilio(path, body) {
  assertConfigured();
  const credentials = Buffer.from(
    `${config.twilioAccountSid}:${config.twilioAuthToken}`,
  ).toString('base64');
  const response = await fetch(
    `https://verify.twilio.com/v2/Services/${config.twilioVerifyServiceSid}/${path}`,
    {
      method: 'POST',
      headers: {
        Authorization: `Basic ${credentials}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams(body),
    },
  );
  const payload = await response.json();
  if (!response.ok) {
    const error = new Error(payload.message || 'OTP provider request failed.');
    error.statusCode = response.status >= 400 && response.status < 500 ? 400 : 502;
    error.code = 'OTP_PROVIDER_ERROR';
    throw error;
  }
  return payload;
}

async function sendVerification(phone) {
  if (config.demoOtpEnabled) {
    console.warn(`[SHAKTI DEMO] OTP for ${phone}: ${config.demoOtpCode}`);
    return { status: 'pending', demo: true };
  }
  return callTwilio('Verifications', { To: phone, Channel: 'sms' });
}

async function checkVerification(phone, code) {
  if (config.demoOtpEnabled) {
    return code === config.demoOtpCode;
  }
  const result = await callTwilio('VerificationCheck', { To: phone, Code: code });
  return result.status === 'approved';
}

module.exports = {
  sendVerification,
  checkVerification,
};
