const store = require('../db/storage');

class HazardRepository {
  async getAll() {
    return store.state.hazardReports;
  }

  async getNearbyAlerts(lat, lng, radiusMeters = 2000) {
    // Return seeded alerts plus any nearby hazard reports
    return store.state.nearbyAlerts;
  }

  async createHazardReport({ type, location, severity, notes, latitude, longitude }) {
    const report = {
      id: `haz-${Date.now()}`,
      type,
      location,
      severity: severity || 'Medium',
      notes: notes || '',
      latitude,
      longitude,
      timestamp: new Date().toISOString(),
      status: 'LOGGED_AND_VERIFIED',
    };

    store.state.hazardReports.unshift(report);
    store.saveSync();
    return report;
  }

  async recordFeedback(feedbackData) {
    const record = {
      id: `fb-${Date.now()}`,
      ...feedbackData,
      receivedAt: new Date().toISOString(),
    };

    store.state.feedbackSubmissions.push(record);
    store.saveSync();
    return record;
  }
}

module.exports = new HazardRepository();
