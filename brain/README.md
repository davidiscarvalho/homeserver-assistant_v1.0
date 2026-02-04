# OpenClaw Brain — Canonical Schema (v1.0)

This document defines the **authoritative brain architecture** for OpenClaw.  
All persistent memory, reasoning artifacts, and operational knowledge **MUST** conform to this structure.

This file is the **single source of truth**.  
If any instruction, prompt, or agent behavior conflicts with this document, **this document prevails**.

---

## 1. Design Principles

1. **Filesystem = Brain**
   - Knowledge is stored as Markdown files.
   - Folders define semantic boundaries.
   - File paths are meaningful and stable.

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
├─ principles.md # Core values, non-negotiables
├─ ontology.md # Concepts, entities, tags, relationships
├─ inbox.md # Raw captures before promotion
│
├─ workflows/ # How OpenClaw thinks and acts
│ ├─ thinking.md
│ ├─ planning.md
│ └─ execution.md
│
├─ memory/ # Persistent memory layers
│ ├─ short_term.md
│ ├─ long_term.md
│ └─ archival_rules.md
│ └─ entry-template.md
│ └─ entry-template.md
│
├─ decisions/ # Logged decisions with rationale
│ └─ decision_log.md
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

## 7. Interaction With Obsidian-Shared Vault

- Files under `brain/` are **internal**
- Shared Obsidian vault is **external-facing**
- Knowledge may be summarized or linked, but:
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
- Store memory outside this structure

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
