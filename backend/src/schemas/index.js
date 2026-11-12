const auth = require('./auth.schema');
const incident = require('./incident.schema');
const telemetry = require('./telemetry.schema');
const guardian = require('./guardian.schema');
const evidence = require('./evidence.schema');
const hazard = require('./hazard.schema');
const feedback = require('./feedback.schema');

module.exports = {
  ...auth,
  ...incident,
  ...telemetry,
  ...guardian,
  ...evidence,
  ...hazard,
  ...feedback,
};
