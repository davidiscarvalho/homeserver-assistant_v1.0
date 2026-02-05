# Research Notes

Canonical freeform research notes live here.

## Convention
- One file per research item.
- Filename: `YYYY-MM-DD--slug.md`
- Include:
  - source URL(s)
  - summary
  - tags (e.g., `#research`)
  - wikilinks (e.g., `[[projects/openclaw]]`)

If a research note should be indexed structurally, add a corresponding row in SQLite `memories` with `kind='knowledge'` and `ref_path` pointing to the note.
