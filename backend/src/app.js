/**
 * SHAKTI Express Application Setup
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const apiRoutes = require('./routes/api.routes');
const { errorHandler, notFoundHandler } = require('./middlewares/errorHandler');
const config = require('./config');

const app = express();

// Security Headers
app.use(helmet({
  contentSecurityPolicy: false, // Permissive for local dev & mobile embedding
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));

// CORS Configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Idempotency-Key', 'X-Client-Platform', 'X-App-Version'],
  maxAge: 86400,
}));

// Body Parsers
app.use(express.json({ limit: config.maxPayloadSizeBytes }));
app.use(express.urlencoded({ extended: true, limit: config.maxPayloadSizeBytes }));

// Health Check Direct Shortcut
app.get('/health', (req, res) => res.redirect(`${config.apiPrefix}/health`));

// API Routes
app.use(config.apiPrefix, apiRoutes);

// Fallback & 404
app.use(notFoundHandler);

// Centralized Error Handling
app.use(errorHandler);

module.exports = app;
