ALTER TABLE submissions ADD COLUMN attachment_key TEXT;
ALTER TABLE submissions ADD COLUMN attachment_name TEXT;
ALTER TABLE submissions ADD COLUMN attachment_type TEXT;
ALTER TABLE submissions ADD COLUMN attachment_size INTEGER;

CREATE INDEX IF NOT EXISTS submissions_attachment_key_idx
  ON submissions(attachment_key)
  WHERE attachment_key IS NOT NULL;
