/**
 * JWT Authentication & Duress State Middleware
 */

const jwt = require('jsonwebtoken');
const config = require('../config');

function extractToken(req) {
  const authHeader = req.headers['authorization'];
  if (authHeader && authHeader.startsWith('Bearer ')) {
    return authHeader.substring(7).trim();
  }
  return null;
}

function verifyToken(token) {
  try {
    return jwt.verify(token, config.jwtSecret);
  } catch (err) {
    return null;
  }
}

function requireAuth(req, res, next) {
  const token = extractToken(req);
  if (!token) {
    return res.status(401).json({
      error: 'Authentication required. Missing Bearer token in Authorization header.',
    });
  }

  const decoded = verifyToken(token);
  if (!decoded) {
    return res.status(401).json({
      error: 'Invalid, malformed or expired security token.',
    });
  }

  req.user = decoded;
  next();
}

function optionalAuth(req, res, next) {
  const token = extractToken(req);
  if (token) {
    const decoded = verifyToken(token);
    if (decoded) {
      req.user = decoded;
    }
  }
  next();
}

module.exports = {
  requireAuth,
  optionalAuth,
  verifyToken,
};
