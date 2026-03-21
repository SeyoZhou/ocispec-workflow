#!/usr/bin/env python3
import argparse
import csv
import json
from pathlib import Path

MODERN_HEADER = [
    "id",
    "priority",
    "phase",
    "area",
    "title",
    "description",
    "acceptance_criteria",
    "test_mcp",
    "review_initial_requirements",
    "review_regression_requirements",
    "dev_state",
    "review_initial_state",
    "review_regression_state",
    "owner",
    "refs",
    "notes",
]

LEGACY_HEADER = [
    "id",
    "priority",
    "phase",
    "area",
    "title",
    "description",
    "acceptance_criteria",
    "test_mcp",
    "review_initial_requirements",
    "review_regression_requirements",
    "dev_state",
    "review_initial_state",
    "review_regression_state",
    "git_state",
    "owner",
    "refs",
    "notes",
]

STATE_VALUES = {"未开始", "进行中", "已完成"}


def main():
    parser = argparse.ArgumentParser(description="Validate OCI issues CSV and summarize progress.")
    parser.add_argument("csv_path", help="Path to the CSV snapshot")
    args = parser.parse_args()

    csv_path = Path(args.csv_path).expanduser().resolve()
    raw = csv_path.read_bytes()
    has_bom = raw.startswith(b"\xef\xbb\xbf")

    with csv_path.open("r", encoding="utf-8-sig", newline="") as fh:
        reader = csv.DictReader(fh)
        header = reader.fieldnames or []
        rows = list(reader)

    if header == MODERN_HEADER:
        schema = "modern"
    elif header == LEGACY_HEADER:
        schema = "legacy"
    else:
        schema = "invalid"

    invalid_state_rows = []
    closed = 0
    for index, row in enumerate(rows, start=2):
        invalid_fields = [
            field for field in ("dev_state", "review_initial_state", "review_regression_state")
            if row.get(field, "") not in STATE_VALUES
        ]
        if invalid_fields:
            invalid_state_rows.append({"line": index, "fields": invalid_fields, "id": row.get("id", "")})
        if (
            row.get("dev_state") == "已完成"
            and row.get("review_initial_state") == "已完成"
            and row.get("review_regression_state") == "已完成"
        ):
            closed += 1

    print(json.dumps({
        "path": str(csv_path),
        "has_bom": has_bom,
        "header": header,
        "schema": schema,
        "rows": len(rows),
        "closed_loop_complete": closed,
        "remaining": len(rows) - closed,
        "invalid_state_rows": invalid_state_rows,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
