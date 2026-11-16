const pool = require('../db/client');

class EvidenceRepository {
  async registerManifest(userId, manifest) {
    const client = await pool.connect();

    try {
      await client.query('BEGIN');

      const incident = await client.query(
        `SELECT id
         FROM incidents
         WHERE id = $1 AND user_id = $2`,
        [manifest.incidentId, userId],
      );

      if (incident.rowCount === 0) {
        await client.query('ROLLBACK');
        return null;
      }

      const totalBytes = manifest.items.reduce(
        (sum, item) => sum + item.fileSizeBytes,
        0,
      );
      const manifestResult = await client.query(
        `INSERT INTO evidence_manifests (incident_id, user_id, sealed_at, total_bytes)
         VALUES ($1, $2, $3, $4)
         RETURNING id, incident_id, status, sealed_at, total_bytes, created_at`,
        [
          manifest.incidentId,
          userId,
          manifest.sealedAt ? new Date(manifest.sealedAt) : new Date(),
          totalBytes,
        ],
      );

      const manifestRow = manifestResult.rows[0];
      const items = [];
      for (const item of manifest.items) {
        const itemResult = await client.query(
          `INSERT INTO evidence_items (
             manifest_id, file_type, file_name, file_reference, sha256_digest,
             file_size_bytes, captured_at, encryption_algo
           )
           VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
           RETURNING id, file_type, file_name, file_reference, sha256_digest,
                     file_size_bytes, captured_at, encryption_algo, status, verified_at`,
          [
            manifestRow.id,
            item.fileType,
            item.fileName,
            item.fileReference || null,
            item.sha256Digest.toLowerCase(),
            item.fileSizeBytes,
            item.capturedAt ? new Date(item.capturedAt) : null,
            item.encryptionAlgo || 'AES-256-GCM',
          ],
        );
        items.push(this.mapItem(itemResult.rows[0]));
      }

      await client.query('COMMIT');
      return {
        manifestId: manifestRow.id,
        incidentId: manifestRow.incident_id,
        items,
        totalBytes: Number(manifestRow.total_bytes),
        sealedAt: manifestRow.sealed_at,
        status: manifestRow.status,
      };
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getManifestsForIncident(incidentId, userId) {
    const result = await pool.query(
      `SELECT
         m.id AS manifest_id, m.incident_id, m.status AS manifest_status,
         m.sealed_at, m.total_bytes,
         i.id, i.file_type, i.file_name, i.file_reference, i.sha256_digest,
         i.file_size_bytes, i.captured_at, i.encryption_algo, i.status, i.verified_at
       FROM evidence_manifests m
       JOIN evidence_items i ON i.manifest_id = m.id
       JOIN incidents incident ON incident.id = m.incident_id
       WHERE m.incident_id = $1 AND incident.user_id = $2
       ORDER BY m.created_at DESC, i.verified_at ASC`,
      [incidentId, userId],
    );

    const manifests = new Map();
    for (const row of result.rows) {
      if (!manifests.has(row.manifest_id)) {
        manifests.set(row.manifest_id, {
          manifestId: row.manifest_id,
          incidentId: row.incident_id,
          items: [],
          totalBytes: Number(row.total_bytes),
          sealedAt: row.sealed_at,
          status: row.manifest_status,
        });
      }
      manifests.get(row.manifest_id).items.push(this.mapItem(row));
    }
    return [...manifests.values()];
  }

  async getFirstItemForIncident(incidentId, userId, fileType) {
    const manifests = await this.getManifestsForIncident(incidentId, userId);
    for (const manifest of manifests) {
      const item = manifest.items.find(
        (candidate) => !fileType || candidate.fileType === fileType,
      );
      if (item) return item;
    }
    return null;
  }

  mapItem(row) {
    return {
      id: row.id,
      fileType: row.file_type,
      fileName: row.file_name,
      fileReference: row.file_reference,
      sha256Digest: row.sha256_digest,
      fileSizeBytes: Number(row.file_size_bytes),
      capturedAt: row.captured_at,
      encryptionAlgo: row.encryption_algo,
      status: row.status,
      verifiedAt: row.verified_at,
    };
  }
}

module.exports = new EvidenceRepository();
