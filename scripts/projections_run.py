#!/usr/bin/env python3

import datetime
import json
import os
import sqlite3
import sys
from pathlib import Path


def utc_iso() -> str:
    return datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"


def repo_root() -> Path:
    return Path(__file__).resolve().parents[1]


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def upsert_projection_status(conn: sqlite3.Connection, name: str, last_run: str, last_error: str | None) -> None:
    conn.execute(
        "INSERT INTO projections(name, last_run, last_error) VALUES(?,?,?) "
        "ON CONFLICT(name) DO UPDATE SET last_run=excluded.last_run, last_error=excluded.last_error",
        (name, last_run, last_error),
    )


def render_projection(name: str, title: str, db_rel: str, rows: list[sqlite3.Row]) -> str:
    now = utc_iso()

    lines: list[str] = []
    lines.append(f"# {title} (Generated)")
    lines.append("")
    lines.append(f"Generated at: {now}")
    lines.append(f"Source DB: {db_rel}")
    lines.append(f"Projection: {name}")
    lines.append("")

    if not rows:
        lines.append("## Items")
        lines.append("- (none)")
        lines.append("")
        return "\n".join(lines)

    if name == "tasks_backlog":
        lines.append("## Top Tasks")
        for r in rows:
            due = r["due_at"] if "due_at" in r.keys() and r["due_at"] else "-"
            lines.append(
                f"- [P{r['priority']}] (task:{r['id']}) \"{r['title']}\" — due {due} — status: {r['status']}"
            )
        lines.append("")
        return "\n".join(lines)

    if name == "decisions_recent":
        lines.append("## Decisions")
        for r in rows:
            made_by = r["made_by"] if r["made_by"] else "-"
            autonomy = r["autonomy_level"] if r["autonomy_level"] else "-"
            ts = r["created_at"] if r["created_at"] else "-"
            decision = r["decision"] if r["decision"] else "-"
            lines.append(f"- (decision:{r['id']}) {ts} — {decision} — made_by: {made_by} — autonomy: {autonomy}")
        lines.append("")
        return "\n".join(lines)

    if name == "system_events_24h":
        lines.append("## Events")
        for r in rows:
            ts = r["created_at"] if r["created_at"] else "-"
            et = r["event_type"] if r["event_type"] else "-"
            src = r["source"] if r["source"] else "-"
            preview = r["payload_preview"] if r["payload_preview"] else ""
            preview = preview.replace("\n", " ")
            lines.append(f"- (event:{r['id']}) {ts} — {et} — source: {src} — {preview}")
        lines.append("")
        return "\n".join(lines)

    if name == "audit_changes_24h":
        lines.append("## Audit Entries")
        for r in rows:
            ts = r["created_at"] if r["created_at"] else "-"
            obj = f"{r['object_type']}:{r['object_id']}" if r["object_type"] else "-"
            actor = r["performed_by"] if r["performed_by"] else "-"
            reason = r["reason"] if r["reason"] else "-"
            lines.append(f"- (audit:{r['id']}) {ts} — {r['action']} {obj} — by {actor} — reason: {reason}")
        lines.append("")
        return "\n".join(lines)

    if name == "research_index":
        lines.append("## Research Items")
        for r in rows:
            ts = r["created_at"] if r["created_at"] else "-"
            title = r["title"] if r["title"] else "-"
            src = r["source"] if r["source"] else "-"
            ref = r["ref_path"] if r["ref_path"] else "-"
            lines.append(f"- (memory:{r['id']}) {ts} — {title} — {src} — ref: `{ref}`")
        lines.append("")
        return "\n".join(lines)

    # Fallback: dump columns as a simple table.
    cols = rows[0].keys()
    lines.append("## Rows")
    lines.append("| " + " | ".join(cols) + " |")
    lines.append("|" + "|".join(["---"] * len(cols)) + "|")
    for r in rows:
        lines.append("| " + " | ".join([str(r[c] if r[c] is not None else "") for c in cols]) + " |")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    root = repo_root()
    db_path = Path(os.environ.get("BRAIN_DB_PATH", root / "state" / "brain.db"))

    manifest_path = root / "brain" / "db" / "projections" / "manifest.json"
    if not manifest_path.exists():
        print(f"ERROR: projections manifest not found: {manifest_path}", file=sys.stderr)
        return 1

    if not db_path.exists():
        print(f"ERROR: DB not found at {db_path} (run 'make db-init')", file=sys.stderr)
        return 1

    manifest = json.loads(read_text(manifest_path))
    projections = manifest.get("projections", [])
    if not projections:
        print("ERROR: no projections defined in manifest", file=sys.stderr)
        return 1

    db_rel = os.path.relpath(str(db_path), str(root))

    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row

    any_error = False
    for p in projections:
        name = p["name"]
        title = p.get("title", name)
        query_rel = p["query"]
        out_rel = p["output"]

        query_path = manifest_path.parent / query_rel
        out_path = root / out_rel

        run_ts = utc_iso()
        last_error: str | None = None

        try:
            sql = read_text(query_path)
            rows = conn.execute(sql).fetchall()
            content = render_projection(name, title, db_rel, rows)
            write_text(out_path, content)
        except Exception as e:
            last_error = f"{type(e).__name__}: {e}"
            any_error = True
        finally:
            upsert_projection_status(conn, name, run_ts, last_error)
            conn.commit()

        if last_error is None:
            print(f"OK: {name} -> {out_rel}")
        else:
            print(f"FAIL: {name}: {last_error}", file=sys.stderr)

    conn.close()
    return 1 if any_error else 0


if __name__ == "__main__":
    raise SystemExit(main())
