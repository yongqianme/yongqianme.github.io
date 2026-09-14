CREATE TABLE IF NOT EXISTS submissions (
  id TEXT PRIMARY KEY,
  created_at TEXT NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  company TEXT NOT NULL,
  robot_workflow TEXT NOT NULL,
  business_impact TEXT,
  decision_deadline TEXT,
  available_evidence TEXT,
  referral TEXT,
  locale TEXT NOT NULL CHECK (locale IN ('en', 'zh')),
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'reviewing', 'qualified', 'closed'))
);

CREATE INDEX IF NOT EXISTS submissions_created_at_idx
  ON submissions(created_at DESC);

CREATE INDEX IF NOT EXISTS submissions_status_idx
  ON submissions(status, created_at DESC);
