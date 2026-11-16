const { createClient } = require('@supabase/supabase-js');
const config = require('../config');

let client;

function getClient() {
  if (!config.supabaseUrl || !config.supabaseServiceRoleKey) {
    throw new Error(
      'Supabase Storage is not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.',
    );
  }

  client ??= createClient(config.supabaseUrl, config.supabaseServiceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
  return client;
}

class StorageService {
  async createEvidenceUploadUrl({ userId, incidentId, fileName }) {
    const safeFileName = fileName.replace(/[^a-zA-Z0-9._-]/g, '_');
    const path = `${userId}/${incidentId}/${Date.now()}-${safeFileName}`;
    const { data, error } = await getClient()
      .storage
      .from(config.evidenceBucket)
      .createSignedUploadUrl(path);

    if (error) {
      throw error;
    }

    return {
      bucket: config.evidenceBucket,
      path,
      signedUrl: data.signedUrl,
      token: data.token,
    };
  }

  async createEvidenceDownloadUrl(fileReference, expiresIn = 300) {
    if (!fileReference) {
      throw new Error('Evidence file reference is missing.');
    }

    const { data, error } = await getClient()
      .storage
      .from(config.evidenceBucket)
      .createSignedUrl(fileReference, expiresIn);

    if (error) {
      throw error;
    }

    return {
      bucket: config.evidenceBucket,
      path: fileReference,
      signedUrl: data.signedUrl,
      expiresIn,
    };
  }
}

module.exports = new StorageService();
