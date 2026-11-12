const crypto = require('crypto');
const store = require('../db/storage');

class EvidenceRepository {
  async registerManifest(manifest) {
    const timestamp = new Date().toISOString();
    const manifestId = `man-${Date.now()}-${crypto.randomBytes(3).toString('hex')}`;

    const sealedManifest = {
      manifestId,
      incidentId: manifest.incidentId,
      items: manifest.items.map(item => ({
        ...item,
        status: 'SEALED_SERVER_VAULT',
        verifiedAt: timestamp,
      })),
      totalBytes: manifest.items.reduce((sum, item) => sum + (item.fileSizeBytes || 0), 0),
      sealedAt: manifest.sealedAt || timestamp,
      status: 'VERIFIED_SEALED',
    };

    store.state.evidenceManifests.push(sealedManifest);

    // Audit log
    store.state.auditLogs.push({
      id: `aud-${Date.now()}`,
      incidentId: manifest.incidentId,
      actor: 'EvidenceVault',
      action: 'EVIDENCE_SEALED',
      metadata: { manifestId, itemCount: manifest.items.length },
      timestamp: timestamp,
    });

    store.saveSync();
    return sealedManifest;
  }

  async getManifestsForIncident(incidentId) {
    return store.state.evidenceManifests.filter(m => m.incidentId === incidentId);
  }
}

module.exports = new EvidenceRepository();
