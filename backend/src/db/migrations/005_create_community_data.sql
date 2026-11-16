CREATE TABLE IF NOT EXISTS hazard_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  type TEXT NOT NULL,
  location TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'Medium',
  notes TEXT NOT NULL DEFAULT '',
  latitude DOUBLE PRECISION CHECK (latitude BETWEEN -90 AND 90),
  longitude DOUBLE PRECISION CHECK (longitude BETWEEN -180 AND 180),
  status TEXT NOT NULL DEFAULT 'LOGGED_AND_VERIFIED',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS hazard_reports_created_at_idx
  ON hazard_reports (created_at DESC);

CREATE TABLE IF NOT EXISTS feedback_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE SET NULL,
  type TEXT NOT NULL DEFAULT 'general',
  message TEXT NOT NULL,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  device_info JSONB,
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
