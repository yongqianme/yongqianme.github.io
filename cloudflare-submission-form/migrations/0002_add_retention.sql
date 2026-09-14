ALTER TABLE submissions ADD COLUMN expires_at TEXT;
ALTER TABLE submissions ADD COLUMN inquiry_context TEXT;

UPDATE submissions
SET expires_at = datetime(created_at, '+365 days')
WHERE expires_at IS NULL;

CREATE INDEX IF NOT EXISTS submissions_expires_at_idx
  ON submissions(expires_at);
