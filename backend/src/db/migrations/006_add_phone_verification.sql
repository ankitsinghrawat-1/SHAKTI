ALTER TABLE users
  ADD COLUMN IF NOT EXISTS phone_verified_at TIMESTAMPTZ;

UPDATE users
SET phone_verified_at = COALESCE(phone_verified_at, created_at)
WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS users_phone_verified_idx
  ON users (phone_verified_at);
