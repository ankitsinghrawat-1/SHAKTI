CREATE TABLE IF NOT EXISTS incidents (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  idempotency_key TEXT NOT NULL UNIQUE,
  source TEXT NOT NULL DEFAULT 'appSosButton',
  user_name TEXT NOT NULL DEFAULT 'Citizen',
  severity TEXT NOT NULL DEFAULT 'Urgent',
  status TEXT NOT NULL DEFAULT 'SERVER_RECEIVED',
  receipt_id TEXT NOT NULL UNIQUE,
  device_sequence INTEGER NOT NULL DEFAULT 1,
  is_covert BOOLEAN NOT NULL DEFAULT FALSE,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  accuracy DOUBLE PRECISION,
  speed DOUBLE PRECISION,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  server_received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  resolved_at TIMESTAMPTZ,
  resolution_reason TEXT,
  last_acknowledged_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS incidents_user_id_created_at_idx
  ON incidents (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS incident_locations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id TEXT NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  accuracy DOUBLE PRECISION NOT NULL DEFAULT 0,
  speed DOUBLE PRECISION NOT NULL DEFAULT 0,
  altitude DOUBLE PRECISION NOT NULL DEFAULT 0,
  bearing DOUBLE PRECISION NOT NULL DEFAULT 0,
  provider TEXT NOT NULL DEFAULT 'GNSS',
  captured_at TIMESTAMPTZ,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS incident_locations_incident_id_idx
  ON incident_locations (incident_id, recorded_at);

CREATE TABLE IF NOT EXISTS incident_acknowledgements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id TEXT NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  actor_name TEXT NOT NULL,
  ack_type TEXT NOT NULL,
  notes TEXT NOT NULL DEFAULT '',
  acknowledged_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
