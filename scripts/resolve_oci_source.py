#!/usr/bin/env python3
import argparse
import json
from pathlib import Path
from typing import Optional


def latest_file(paths):
    files = [p for p in paths if p.is_file()]
    if not files:
        return None
    return max(files, key=lambda p: p.stat().st_mtime)


def latest_change(changes_dir: Path):
    if not changes_dir.is_dir():
        return None
    candidates = [
        p for p in changes_dir.iterdir()
        if p.is_dir() and p.name != "archive"
    ]
    if not candidates:
        return None
    return max(candidates, key=lambda p: p.stat().st_mtime)


def detect_from_path(path: Path):
    if path.is_dir():
        if (path / "proposal.md").exists():
            change_id = path.name if path.parent.name == "changes" else None
            return {
                "mode": "change_dir",
                "source_path": str(path.resolve()),
                "change_id": change_id,
            }
        return {
            "mode": "directory",
            "source_path": str(path.resolve()),
            "change_id": None,
        }

    name = path.name
    parts = path.parts
    if "changes" in parts and name in {"proposal.md", "design.md", "tasks.md"}:
        idx = parts.index("changes")
        if idx + 1 < len(parts):
            change_dir = Path(*parts[:idx + 2])
            return {
                "mode": "change_dir",
                "source_path": str(change_dir.resolve()),
                "change_id": change_dir.name,
            }

    if name == "proposal.md" and path.parent.name == "openspec":
        return {
            "mode": "proposal_doc",
            "source_path": str(path.resolve()),
            "change_id": None,
        }

    if path.suffix.lower() == ".md":
        mode = "plan_doc" if path.parent.name == "plan" else "markdown_doc"
        return {
            "mode": mode,
            "source_path": str(path.resolve()),
            "change_id": None,
        }

    if path.suffix.lower() == ".csv":
        return {
            "mode": "issues_csv",
            "source_path": str(path.resolve()),
            "change_id": None,
        }

    return {
        "mode": "file",
        "source_path": str(path.resolve()),
        "change_id": None,
    }


def resolve(project_root: Path, raw: Optional[str]):
    result = {
        "project_root": str(project_root.resolve()),
        "input": raw or "",
        "mode": None,
        "source_path": None,
        "change_id": None,
        "detected_from": None,
    }

    if raw:
        candidate = Path(raw).expanduser()
        if not candidate.is_absolute():
            candidate = (project_root / candidate).resolve()

        if candidate.exists():
            detected = detect_from_path(candidate)
            result.update(detected)
            result["detected_from"] = "explicit_path"
            return result

        change_dir = project_root / "openspec" / "changes" / raw
        if change_dir.is_dir():
            result.update({
                "mode": "change_dir",
                "source_path": str(change_dir.resolve()),
                "change_id": raw,
                "detected_from": "change_id",
            })
            return result

        result["mode"] = "unresolved"
        result["detected_from"] = "missing_explicit_input"
        return result

    change_dir = latest_change(project_root / "openspec" / "changes")
    if change_dir is not None:
        result.update({
            "mode": "change_dir",
            "source_path": str(change_dir.resolve()),
            "change_id": change_dir.name,
            "detected_from": "latest_change",
        })
        return result

    proposal_doc = project_root / "openspec" / "proposal.md"
    if proposal_doc.is_file():
        result.update({
            "mode": "proposal_doc",
            "source_path": str(proposal_doc.resolve()),
            "detected_from": "root_proposal",
        })
        return result

    plan_doc = latest_file((project_root / "plan").glob("*.md")) if (project_root / "plan").is_dir() else None
    if plan_doc is not None:
        result.update({
            "mode": "plan_doc",
            "source_path": str(plan_doc.resolve()),
            "detected_from": "latest_plan",
        })
        return result

    result["mode"] = "unresolved"
    result["detected_from"] = "none"
    return result


def main():
    parser = argparse.ArgumentParser(description="Resolve OCI workflow input into a normalized source.")
    parser.add_argument("input", nargs="?", default="", help="change id, path, or empty for auto-detect")
    parser.add_argument("--cwd", default=".", help="project root to inspect")
    args = parser.parse_args()

    project_root = Path(args.cwd).expanduser().resolve()
    resolved = resolve(project_root, args.input or None)
    print(json.dumps(resolved, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
