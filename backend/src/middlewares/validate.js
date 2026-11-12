/**
 * Zod validation middleware for SHAKTI API.
 * Validates incoming request payloads before they reach business logic.
 */

function validate(schema, source = 'body') {
  return (req, res, next) => {
    try {
      const parsed = schema.safeParse(req[source]);
      if (!parsed.success) {
        const issues = parsed.error.issues.map(issue => ({
          field: issue.path.join('.'),
          message: issue.message,
        }));

        return res.status(400).json({
          error: 'Validation failed',
          details: issues,
        });
      }

      // Replace with sanitized & typed data
      req[source] = parsed.data;
      next();
    } catch (err) {
      next(err);
    }
  };
}

module.exports = { validate };
