/**
 * SHAKTI Backend Configuration
 * Centralized, validated environment configuration.
 */

const path = require('path');
require('dotenv').config();

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  host: process.env.HOST || '0.0.0.0',
  apiPrefix: '/api/v1',

  // Security & Cryptography
  jwtSecret: process.env.JWT_SECRET || 'shakti_super_secure_jwt_secret_vault_2026',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  duressPin: '0000', // Hardcoded safety specification: Duress PIN for silent emergency decoy
  bcryptSaltRounds: 10,
  twilioAccountSid: process.env.TWILIO_ACCOUNT_SID || '',
  twilioAuthToken: process.env.TWILIO_AUTH_TOKEN || '',
  twilioVerifyServiceSid: process.env.TWILIO_VERIFY_SERVICE_SID || '',
  demoOtpEnabled: process.env.DEMO_OTP_ENABLED === 'true',
  demoOtpCode: process.env.DEMO_OTP_CODE || '123456',

  // Database Storage
  databaseUrl: process.env.DATABASE_URL || '',
  supabaseUrl: process.env.SUPABASE_URL || '',
  supabaseServiceRoleKey: process.env.SUPABASE_SERVICE_ROLE_KEY || '',
  evidenceBucket: process.env.SUPABASE_EVIDENCE_BUCKET || 'evidence-vault',
  dataDir: path.resolve(__dirname, '../../data'),
  dbFilePath: path.resolve(__dirname, '../../data/shakti_store.json'),

  // Emergency SLA & Escalation
  slaAckTimeoutMs: 2 * 60 * 1000, // 2 minutes before Tier 2 escalation
  telemetryStreamMaxBatch: 100,
  maxPayloadSizeBytes: 15 * 1024 * 1024, // 15MB for evidence chunks

  // WebSockets
  wsHeartbeatIntervalMs: 30000,
};

module.exports = config;
