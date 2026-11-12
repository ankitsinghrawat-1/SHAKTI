const fs = require('fs');
const path = require('path');
const config = require('../config');

const emptyState = () => ({
  users: [],
  guardians: [],
  incidents: [],
  locationFixes: [],
  evidenceManifests: [],
  hazardReports: [],
  nearbyAlerts: [],
  feedbackSubmissions: [],
  deliveryAttempts: [],
  auditLogs: [],
  acknowledgements: [],
});

function loadState() {
  try {
    if (!fs.existsSync(config.dbFilePath)) {
      return emptyState();
    }

    return {
      ...emptyState(),
      ...JSON.parse(fs.readFileSync(config.dbFilePath, 'utf8')),
    };
  } catch (error) {
    throw new Error(`Unable to load local compatibility storage: ${error.message}`);
  }
}

const store = {
  state: loadState(),
  indexes: {},

  rebuildIndexes() {
    this.indexes.guardiansById = new Map(
      this.state.guardians.map((guardian) => [guardian.id, guardian]),
    );
    this.indexes.incidentsById = new Map(
      this.state.incidents.map((incident) => [incident.id, incident]),
    );
    this.indexes.incidentsByIdempotency = new Map(
      this.state.incidents
        .filter((incident) => incident.idempotencyKey)
        .map((incident) => [incident.idempotencyKey, incident]),
    );
  },

  saveSync() {
    fs.mkdirSync(path.dirname(config.dbFilePath), { recursive: true });
    fs.writeFileSync(config.dbFilePath, JSON.stringify(this.state, null, 2));
  },
};

store.rebuildIndexes();

module.exports = store;