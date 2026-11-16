CREATE TABLE IF NOT EXISTS evidence_manifests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id TEXT NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'VERIFIED_SEALED',
  sealed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  total_bytes BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS evidence_manifests_incident_id_idx
  ON evidence_manifests (incident_id, created_at DESC);

CREATE TABLE IF NOT EXISTS evidence_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manifest_id UUID NOT NULL REFERENCES evidence_manifests(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_reference TEXT,
  sha256_digest TEXT NOT NULL CHECK (sha256_digest ~ '^[0-9a-fA-F]{64}$'),
  file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
  captured_at TIMESTAMPTZ,
  encryption_algo TEXT NOT NULL DEFAULT 'AES-256-GCM',
  status TEXT NOT NULL DEFAULT 'SEALED_SERVER_VAULT',
  verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
