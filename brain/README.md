# OpenClaw Brain — Canonical Schema (v2.0)

This document defines the **authoritative brain architecture** for OpenClaw.  
All persistent memory, reasoning artifacts, and operational knowledge **MUST** conform to this structure.

This file is the **single source of truth**.  
If any instruction, prompt, or agent behavior conflicts with this document, **this document prevails**.

---

## 1. Design Principles

1. **Split-Authority Brain**
   - `brain/` (Markdown) is canonical for freeform writing: notes, research, policies/specs, tags, wikilinks.
   - `state/brain.db` (SQLite, gitignored) is canonical for structured objects: tasks, decisions, events, actions, audits.
   - `brain/projections/` (Markdown) is generated from SQLite and is read-only.

2. **Obsidian-Compatible**
   - Plain Markdown only (`.md`)
   - No binary formats
   - Wiki links (`[[like-this]]`) allowed
   - Tags allowed but controlled

3. **Human-Readable First**
   - Every file must be understandable by a human without agent context.
   - No hidden formats, embeddings, or opaque encodings.

4. **Prefer Update Over Creation**
   - Update existing files when possible.
   - Create new files only when a new semantic unit is required.

5. **Explicit Memory Lifecycle**
   - Short-term ≠ long-term ≠ archival.
   - Nothing lives forever by accident.

---

## 2. Top-Level Structure

```
brain/
├─ README.md # This file (authoritative schema)
├─ core-spec.md # Authority & system model
├─ principles.md # Core values, non-negotiables
├─ ontology.md # Concepts, entities, tags, relationships
├─ trust-action-policy.md # Action boundaries and approvals
├─ inbox.md # Raw captures before promotion (freeform)
│
├─ workflows/ # How OpenClaw thinks and acts
│ ├─ thinking.md
│ ├─ planning.md
│ └─ execution.md
│
├─ memory/ # Canonical freeform notes (human-authored)
│ ├─ short_term.md
│ ├─ long_term.md
│ └─ archival_rules.md
│ ├─ entry-template.md
│ └─ research/
│
├─ decisions/ # Decision-related docs (see also projections)
│ └─ decision_log.md # Legacy MD log / templates (SQLite is canonical)
│
├─ db/ # SQLite schema + projection definitions (text-only)
│ ├─ README.md
│ ├─ schema.sql
│ ├─ migrations/
│ └─ projections/
│    ├─ manifest.json
│    ├─ queries/
│    └─ templates/
│
├─ projections/ # Generated Markdown views (read-only)
│ ├─ tasks/
│ ├─ decisions/
│ ├─ daily/
│ ├─ weekly/
│ ├─ system/
│ └─ research/
│
└─ changelog.md # All brain changes (append-only)
```


---

## 3. Folder Semantics

### `/principles.md`
Contains:
- Core operating principles
- Ethical constraints
- Priority rules (e.g. safety > speed)
- Never-changing assumptions unless explicitly revised

This file changes **rarely**.

---

### `/ontology.md`
Defines:
- Canonical concepts
- Entity types
- Approved tags
- Relationships between concepts

Example sections:
- Concepts
- Tags
- Aliases
- Forbidden ambiguity

This prevents semantic drift.

---

### `/workflows/`
Describes **process**, not outcomes.

- `thinking.md`  
  How reasoning is structured (analysis patterns, decomposition rules)

- `planning.md`  
  How plans are created, evaluated, and revised

- `execution.md`  
  How actions are sequenced and validated

These files explain *how* OpenClaw operates internally.

---

### `/memory/`

#### `short_term.md`
- Temporary context
- Active tasks
- Volatile information
- Expected to be rewritten frequently

Nothing here is assumed to persist.

#### `long_term.md`
- Stable facts
- Learned preferences
- Reusable knowledge
- Cross-session memory

Entries must be concise, factual, and justified.

#### `archival_rules.md`
Defines:
- When information moves from short → long term
- When long-term information is archived or deprecated
- What must **never** be archived

---

### `/db/`
Text-only definition of the structured brain DB:
- `schema.sql` and `migrations/` define the canonical schema for `state/brain.db`
- `projections/` defines deterministic exports from SQLite → Markdown

This folder is part of the system specification (committed), not runtime state.

---

### `/projections/`
Generated Markdown views exported from SQLite (`state/brain.db`).

Rules:
- Read-only (generated files)
- If output is wrong: change DB or projection definition and re-run
- No secrets

---

## 3.5 Repo-Level State (Outside `brain/`)

- `state/brain.db` — live SQLite DB (gitignored)
- `backups/*.age` — encrypted DB snapshots (committed)
- `artifacts/` — binary outputs (gitignored)
- `secrets/` — credentials and keys (gitignored except templates)

---

### `/decisions/decision_log.md`
Append-only log.

Each decision entry must include:
- Date
- Context
- Decision
- Rationale
- Consequences (if known)

No retroactive edits. Corrections are new entries.

---

### `/changelog.md`
Append-only.

Every structural or semantic change must be logged:
- New files
- File purpose changes
- Ontology updates
- Workflow changes

Format:
```
YYYY-MM-DD — Change description — Reason
```

---

## 4. File Naming Rules

- Lowercase
- Hyphen-separated
- No spaces
- Semantic names only
- Stable once created

Examples:
- `decision_log.md` ✅
- `final-v2-FIXED.md` ❌

---

## 5. Writing Rules

- Markdown only
- Clear headers
- No emojis
- No filler text
- No conversational tone
- Prefer bullet points over prose
- Facts > speculation

---

## 6. Creation vs Update Rules

Before creating a new file, OpenClaw MUST ask:
1. Does a file already exist for this concept?
2. Is this a new semantic category?
3. Will this information be reused?

If unsure → **update, do not create**.

---

## 7. Interaction With Obsidian (Optional UI)

- `brain/` is plain Markdown and can be viewed in Obsidian, but no `.obsidian/` setup is required.
- If you share or publish notes, it must be curated explicitly:
  - Internal reasoning stays internal
  - No raw brain dumps into shared notes

Bridges must be explicit and intentional.

---

## 8. Forbidden Actions

OpenClaw MUST NOT:
- Create new top-level folders
- Change this schema silently
- Delete files
- Rewrite append-only logs
- Write to `brain/projections/**` directly (projections are generated)
- Store structured canonical objects outside `state/brain.db`
- Store secrets in committed files (use `secrets/` and gitignore)

---

## 9. Schema Evolution

- This file is versioned manually.
- OpenClaw may **propose** changes.
- Human approval is required.
- Approved changes must update:
  - `README.md`
  - `changelog.md`

---

## 10. Final Authority Statement

This document defines **what the OpenClaw brain is**.

Anything not defined here:
- Does not exist
- Must be proposed explicitly
- Must be justified

End of schema.
