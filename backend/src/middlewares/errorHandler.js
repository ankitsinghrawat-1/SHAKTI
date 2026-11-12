/**
 * Global Error Handler for SHAKTI API.
 * Guarantees that unhandled errors, bad JSON, or syntax anomalies do not crash
 * the process or leak internal server stack traces to clients.
 */

function errorHandler(err, req, res, next) {
  // Log full error on server
  console.error(`[SHAKTI ERROR] ${req.method} ${req.originalUrl}:`, err);

  // Handle Bad JSON body syntax
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      error: 'Malformed JSON payload in request body.',
    });
  }

  // Handle Payload Too Large
  if (err.type === 'entity.too.large' || err.status === 413) {
    return res.status(413).json({
      error: 'Request payload exceeds maximum allowed size.',
    });
  }

  const statusCode = err.statusCode || err.status || 500;
  const message = statusCode === 500 ? 'Internal server error occurred.' : err.message;

  res.status(statusCode).json({
    error: message,
    code: err.code || 'INTERNAL_ERROR',
    timestamp: new Date().toISOString(),
  });
}

function notFoundHandler(req, res) {
  res.status(404).json({
    error: 'Endpoint not found',
    path: req.originalUrl,
    method: req.method,
    apiDocs: '/api/v1/health',
  });
}

module.exports = {
  errorHandler,
  notFoundHandler,
};
