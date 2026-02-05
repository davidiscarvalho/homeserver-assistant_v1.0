PRAGMA foreign_keys = ON;

-- METADATA
CREATE TABLE IF NOT EXISTS meta (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- USERS (service accounts, external identities)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT,
  api_key_hash TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- CORE: MEMORIES / FACTS
CREATE TABLE IF NOT EXISTS memories (
  id INTEGER PRIMARY KEY,
  kind TEXT NOT NULL CHECK(kind IN ('fact','knowledge','policy','config','note')),
  title TEXT,
  content TEXT NOT NULL,
  source TEXT,
  confidence REAL DEFAULT 1.0,
  tags TEXT,
  ref_path TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME
);

-- TASKS
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'todo' CHECK(status IN ('todo','in-progress','done','cancelled')),
  priority INTEGER DEFAULT 3,
  owner_id INTEGER,
  due_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME,
  source TEXT,
  FOREIGN KEY(owner_id) REFERENCES users(id)
);

-- HABITS
CREATE TABLE IF NOT EXISTS habits (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  target_type TEXT CHECK (target_type IN ('binary','count','duration')),
  target_value INTEGER,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS habit_events (
  id INTEGER PRIMARY KEY,
  habit_id INTEGER NOT NULL,
  value INTEGER,
  note TEXT,
  source TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(habit_id) REFERENCES habits(id)
);

-- DECISIONS
CREATE TABLE IF NOT EXISTS decisions (
  id INTEGER PRIMARY KEY,
  context TEXT,
  decision TEXT,
  rationale TEXT,
  made_by TEXT,
  autonomy_level TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ACTIONS / EXECUTION RECORDS
CREATE TABLE IF NOT EXISTS actions (
  id INTEGER PRIMARY KEY,
  action_type TEXT NOT NULL,
  params TEXT,
  initiated_by TEXT,
  decision_id INTEGER,
  status TEXT NOT NULL DEFAULT 'queued' CHECK(status IN ('queued','running','success','failed','cancelled')),
  result TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  started_at DATETIME,
  finished_at DATETIME,
  FOREIGN KEY(decision_id) REFERENCES decisions(id)
);

-- EVENT LOG
CREATE TABLE IF NOT EXISTS events (
  id INTEGER PRIMARY KEY,
  event_type TEXT,
  payload TEXT,
  source TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- INTEGRATIONS
CREATE TABLE IF NOT EXISTS integrations (
  id INTEGER PRIMARY KEY,
  name TEXT,
  kind TEXT,
  config TEXT,
  enabled INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- AUDIT & CHANGE LOGS
CREATE TABLE IF NOT EXISTS audit_logs (
  id INTEGER PRIMARY KEY,
  object_type TEXT,
  object_id INTEGER,
  action TEXT,
  performed_by TEXT,
  reason TEXT,
  before TEXT,
  after TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- PROJECTIONS (track last-run times)
CREATE TABLE IF NOT EXISTS projections (
  name TEXT PRIMARY KEY,
  last_run DATETIME,
  last_error TEXT
);

-- MIGRATIONS
CREATE TABLE IF NOT EXISTS schema_migrations (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_events_created_at ON events(created_at);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_habit_events_on_habit_created ON habit_events(habit_id, created_at);
