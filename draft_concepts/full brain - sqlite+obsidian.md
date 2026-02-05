# OpenClaw Brain — v1.0 (Markdown Reference)

---

## Overview

This file documents the canonical **OpenClaw brain v1.0**: the SQLite schema (source-of-truth), strict write/read rules, and the projection jobs that export curated views into Markdown for human review. The SQLite DB is the single source of truth; Markdown files are generated projections (read-only for the agent).

---

# 1. Full OpenClaw Brain Schema (v1.0)

> Single-file SQLite DB: `brain.db`

### Purpose

Tables cover: entities (tasks, habits, memories), events/logs, decisions, actions, integrations, and audit/change trails.

### Schema (SQL)

```sql
-- METADATA
CREATE TABLE meta (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- USERS (service accounts, external identities)
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT,         -- e.g., owner, admin, agent
  api_key_hash TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- CORE: MEMORIES / FACTS
CREATE TABLE memories (
  id INTEGER PRIMARY KEY,
  kind TEXT NOT NULL CHECK(kind IN ('fact','knowledge','policy','config','note')),
  title TEXT,
  content TEXT NOT NULL,
  source TEXT,             -- e.g., "import", "manual", "inference"
  confidence REAL DEFAULT 1.0,
  tags TEXT,               -- comma-separated lightweight tags
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME
);

-- TASKS
CREATE TABLE tasks (
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
CREATE TABLE habits (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT,
  target_type TEXT CHECK (target_type IN ('binary','count','duration')),
  target_value INTEGER,   -- e.g., minutes, count
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE habit_events (
  id INTEGER PRIMARY KEY,
  habit_id INTEGER NOT NULL,
  value INTEGER,          -- normalized numeric value
  note TEXT,
  source TEXT,            -- automation|manual|inferred
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY(habit_id) REFERENCES habits(id)
);

-- DECISIONS (explicit human-level decisions)
CREATE TABLE decisions (
  id INTEGER PRIMARY KEY,
  context TEXT,           -- JSON or short text
  decision TEXT,          -- action chosen
  rationale TEXT,
  made_by TEXT,           -- user id or 'agent'
  autonomy_level TEXT,    -- e.g., report-only, suggest, auto
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ACTIONS / EXECUTION RECORDS
CREATE TABLE actions (
  id INTEGER PRIMARY KEY,
  action_type TEXT NOT NULL,
  params TEXT,            -- JSON
  initiated_by TEXT,      -- user id or 'agent'
  decision_id INTEGER,    -- if executed due to a decision
  status TEXT NOT NULL DEFAULT 'queued' CHECK(status IN ('queued','running','success','failed','cancelled')),
  result TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  started_at DATETIME,
  finished_at DATETIME,
  FOREIGN KEY(decision_id) REFERENCES decisions(id)
);

-- EVENT LOG (append-only ingestion)
CREATE TABLE events (
  id INTEGER PRIMARY KEY,
  event_type TEXT,
  payload TEXT,           -- JSON
  source TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- INTEGRATIONS
CREATE TABLE integrations (
  id INTEGER PRIMARY KEY,
  name TEXT,
  kind TEXT,              -- email, github, telegram, hetzner, home-server
  config TEXT,            -- encrypted JSON pointer or path
  enabled INTEGER DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- AUDIT & CHANGE LOGS
CREATE TABLE audit_logs (
  id INTEGER PRIMARY KEY,
  object_type TEXT,       -- table name
  object_id INTEGER,
  action TEXT,            -- insert, update, delete
  performed_by TEXT,      -- user or agent
  reason TEXT,
  before TEXT,            -- JSON snapshot (≤ 4000 chars recommended)
  after TEXT,             -- JSON snapshot
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- PROJECTIONS (track last-run times)
CREATE TABLE projections (
  name TEXT PRIMARY KEY,
  last_run DATETIME,
  last_error TEXT
);

-- INDEXES for performance
CREATE INDEX idx_events_created_at ON events(created_at);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_habit_events_on_habit_created ON habit_events(habit_id, created_at);
```

### File layout recommendation

```
openclaw/
├─ brain.db                # SQLite source of truth
├─ event_log.jsonl         # append-only raw events (also mirrored to events table)
├─ projections/            # generated Markdown views
│  ├─ daily/
│  ├─ weekly/
│  └─ decisions/
├─ backups/
└─ scripts/
```

---

# 2. Write / Read Rules (what OpenClaw may mutate)

> Rules express allowed mutations, required approvals, and safeties. All mutations must be logged to `audit_logs`.

### Global principles

* **Single source of truth:** `brain.db` is authoritative. All writes must be transactional.
* **Least privilege:** agent actions use dedicated service identity; external integrations use scoped tokens.
* **Append-first:** prefer insert of events; updates must include `reason` and be audited.
* **Decision linkage:** any autonomous action that changes external state must reference a `decisions` row (ID) with rationale and autonomy level.
* **Rate limits:** agent cannot perform >N state-changing actions per minute (configurable via `meta`).
* **Confidence threshold:** auto-execution requires confidence ≥ `meta:autonomy_confidence_threshold` (e.g., 0.9). Lower-confidence items are suggested only.

### Write rules (concrete)

* `events` — **agent may append** without approval. (source tagging required)
* `habit_events` — **agent may append** (source='automation') automatically.
* `tasks` — **agent may insert** tasks and update `status` only to `todo` or `in-progress`. **Marking `done` or `cancelled` requires either:** (a) owner user action, or (b) explicit `decisions` record with autonomy_level=`auto` and confidence ≥ threshold.
* `actions` — **agent may insert** new action records to request execution (queued). Changes to `actions.status` must be audited.
* `memories` — **agent may insert and update** with source='inference' but updates to `kind='policy'` or `kind='config'` require human review and a `decision`.
* `decisions` — **users only** create decisions of type `policy` or `autonomy_change`. Agents may create `decisions` but they must be flagged `made_by='agent'` and have `autonomy_level` set; these require a human review window unless autonomy policy explicitly allows immediate enactment.
* `integrations` — **agents may read** integration config pointers; **cannot write** credentials/configs. Admins only.
* `audit_logs` — **always** write on any change (agent and user).

### Read rules

* Agent may read any table required to perform tasks, except sensitive `integrations.config` payloads (agent receives an encrypted token holder with runtime decryption only).
* Reads that produce outbound summaries must respect redaction rules in `meta:redaction_policy` (PII sanitization).
* Exports to projections must sanitize secrets (no raw tokens or hashes in MD files).

### Escalation & approval flows

* Any proposed action changing external systems (email send, repo merge, server restart) must follow this sequence:

  1. Create a `decision` (agent or user) with context + rationale + autonomy_level.
  2. If autonomy_level == `suggest`, send for user approval (Telegram/Slack) with the decision ID and proposed `actions`.
  3. If autonomy_level == `auto` and confidence ≥ threshold, agent may queue the `action`. Action execution still logs to `audit_logs`.
  4. Execution failures must be recorded in `actions.result` and create a high-severity `events` entry.

### Safety sentinel rules

* No agent action can remove data from `audit_logs` or `events`.
* No direct writes to `integrations.config` from agent.
* Any action that would escalate agent privileges must be flagged, logged, and require human approval.

---

# 3. Projection Jobs (SQLite → MD)

> Projections are scheduled jobs that query SQLite and emit human-readable Markdown to `projections/`. All projections are read-only from the perspective of the agent.

### General projection design

* Each projection is a deterministic query + templating step.
* Every projection run writes a small header with: run timestamp, DB revision (`meta`), query hash, and provenance.
* Projections must redact secrets and trim long fields.
* Each projection logs runtime and errors in `projections` table.

### Recommended projections (initial set)

1. `daily-morning-brief.md` — morning digest used at 07:00
2. `weekly-habits-summary.md` — weekly habit analytics
3. `task-backlog.md` — prioritized tasks
4. `recent-decisions.md` — decisions made in last 7 days
5. `system-events-24h.md` — critical events in last 24h
6. `audit-changes-24h.md` — summary changelog for last 24h

### Example: morning brief SQL + MD template

**SQL (morning digest components)**

```sql
-- calendar placeholder: stored as memories(kind='fact', tags like 'calendar')
-- top tasks
SELECT id, title, priority, due_at FROM tasks
WHERE status != 'done'
ORDER BY priority ASC, due_at IS NULL, due_at
LIMIT 5;

-- unread emails: represented by events with event_type='email.received' AND payload JSON has 'unread'=1
SELECT payload FROM events
WHERE event_type='email.received' AND json_extract(payload, '$.unread') = 1
ORDER BY created_at DESC
LIMIT 5;

-- system health events: last 6 hours
SELECT payload FROM events
WHERE event_type LIKE 'system.%' AND created_at >= datetime('now','-6 hours')
ORDER BY created_at DESC
LIMIT 10;
```

**MD Template (`projections/daily/morning-YYYY-MM-DD.md`)**

```md
# Morning Brief — {{date}} (07:00)

**Source:** OpenClaw brain.db (rev {{meta_rev}})  
**Generated at:** {{run_ts}}

## 1) Calendar (next 24h)
{{#calendar_entries}}
- {{time}} — {{title}}
{{/calendar_entries}}

## 2) Top 5 tasks
{{#tasks}}
- [{{priority}}] {{title}} (due: {{due_at|date}}) — status: {{status}}
{{/tasks}}

## 3) Unread email heads (5)
{{#emails}}
- {{from}} — "{{subject}}" — {{snippet}}
{{/emails}}

## 4) Recent system health events (6h)
{{#system_events}}
- {{created_at}} — {{summary}} (severity: {{severity}})
{{/system_events}}

## Provenance
- query-hash: {{query_hash}}
- projection-run: {{run_ts}}
```

### Example: habit weekly summary SQL + template

**SQL**

```sql
-- weekly totals per habit
SELECT h.id, h.name,
  COUNT(e.id) AS events_count,
  SUM(e.value) AS total_value,
  MIN(e.created_at) AS first_event,
  MAX(e.created_at) AS last_event
FROM habits h
LEFT JOIN habit_events e ON e.habit_id = h.id
  AND e.created_at >= date('now','weekday 0','-6 days') -- last 7 days
GROUP BY h.id
ORDER BY events_count DESC;
```

**MD Template (`projections/weekly/habits-YYYY-WW.md`)**

```md
# Weekly Habit Summary — Week {{week}} ({{date_range}})

**Generated:** {{run_ts}}

| Habit | Events | Total | First | Last |
|-------|--------:|------:|-------|------:|
{{#rows}}
| {{name}} | {{events_count}} | {{total_value}} | {{first_event}} | {{last_event}} |
{{/rows}}

## Observations
- Streaks: {{streak_summary}}
- At-risk habits: {{at_risk_list}}
```

### Implementation examples

#### A) Shell + sqlite3 + template script (cron)

`/etc/cron.d/openclaw-projections`:

```
# Run morning brief at 07:00 Lisbon
0 7 * * * /usr/local/bin/openclaw_proj morning > /srv/openclaw/projections/daily/morning-$(date +\%F).md 2>>/var/log/openclaw/proj.log
```

`/usr/local/bin/openclaw_proj` (pseudo):

```bash
#!/usr/bin/env bash
mode="$1"
DB=/srv/openclaw/brain.db
case "$mode" in
  morning)
    sqlite3 -json "$DB" "<SQL for morning queries>" | /usr/local/bin/render_md morning_template > /srv/openclaw/projections/daily/morning-$(date +%F).md
    ;;
  weekly-habits)
    sqlite3 -json "$DB" "<SQL for weekly habits>" | /usr/local/bin/render_md weekly_habits_template > /srv/openclaw/projections/weekly/habits-$(date +%G-W%V).md
    ;;
esac
```

#### B) Python projection job (recommended for complex templates)

* Use a small script that:

  * opens `brain.db` with `sqlite3` or `aiosqlite`
  * runs parametrized queries
  * sanitizes fields (redact secrets)
  * renders a Jinja2 template
  * writes `projections/...` and updates `projections` table
  * writes to `event_log.jsonl` an entry about the run result

Snippet outline (not full code):

```python
import sqlite3, jinja2, json, pathlib, datetime
DB = '/srv/openclaw/brain.db'
def run_morning():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    tasks = conn.execute("...").fetchall()
    emails = conn.execute("...").fetchall()
    ctx = {'tasks': tasks, 'emails': emails, 'run_ts': datetime.datetime.utcnow().isoformat()}
    tpl = jinja2.Template(open('templates/morning.md.j2').read())
    out = tpl.render(**ctx)
    path = pathlib.Path('/srv/openclaw/projections/daily') / f"morning-{date.today()}.md"
    path.write_text(out)
    conn.execute("REPLACE INTO projections (name, last_run) VALUES (?, ?)", ('morning', ctx['run_ts']))
    conn.commit()
```

### Provenance & verifiability

* Every projection must include:

  * `meta.rev` (hash of relevant tables or `meta` value)
  * query hash
  * runtime duration and error if any
* Store last-run + error in `projections` table.

### Scheduling & retention

* Morning brief: daily (keep last 90 days)
* Weekly summaries: weekly (keep last 52)
* Audits/changes: daily (keep 365 or as policy requires)
* Implement a rotation job to archive old MD to `backups/` and prune DB indices if needed.

---

# Operational concerns & small checklist

* **Backups:** snapshot `brain.db` to `backups/brain-YYYYMMDD.db` nightly; rotate 30-day full, weekly monthly.
* **Encryption:** at rest encryption for backups. Do not export secrets to MD.
* **Access control:** restrict DB file to the OpenClaw system user; admin edits only via secure admin scripts.
* **Testing:** unit tests for projection rendering, plus a projection dry-run that writes to `projections/tmp/` and validates schema.
* **Monitoring:** project-run failures push `events` with `event_type='projection.fail'` and alert via Telegram.
* **Integrity check:** weekly job that runs `PRAGMA integrity_check;` and compares row counts against retention expectations.
* **Migration:** keep migration SQLs in `scripts/migrations/` with a `schema_version` stored in `meta`.

---

# Examples of queries you will likely need (copy-paste)

* `Recent high-severity system events (24h)`

```sql
SELECT created_at, json_extract(payload, '$.summary') AS summary, json_extract(payload,'$.severity') AS severity
FROM events
WHERE event_type LIKE 'system.%' AND created_at >= datetime('now','-1 day') AND json_extract(payload,'$.severity') = 'critical'
ORDER BY created_at DESC;
```

* `Top 10 open tasks`

```sql
SELECT id, title, priority, due_at, owner_id FROM tasks WHERE status != 'done' ORDER BY priority ASC, due_at IS NULL, due_at LIMIT 10;
```

* `Decisions in last 7 days`

```sql
SELECT id, created_at, made_by, autonomy_level, substr(rationale,1,200) AS rationale
FROM decisions
WHERE created_at >= datetime('now','-7 days') ORDER BY created_at DESC;
```

---

# Naming & folder conventions (projection outputs)

* `projections/daily/morning-YYYY-MM-DD.md`
* `projections/weekly/habits-YYYY-WW.md`
* `projections/decisions/recent-YYYY-MM-DD.md`
