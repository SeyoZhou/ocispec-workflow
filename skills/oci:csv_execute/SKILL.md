---
name: "oci:csv_execute"
description: Execute implementation, review, and validation from an issues CSV snapshot. Use when the user says csv_execute, oci:csv_execute, or wants to implement work tracked in a CSV file.
argument-hint: "<issues CSV file path>"
---

# Stage: CSV Execute

Goal: use the provided CSV file as the only boundary and status source; drive each issue through the full closed loop: implement → review → validate. Do not git commit by default.

## Pre-flight check

If available, validate first:

```bash
python3 _shared/scripts/validate_issues_csv.py "$ARGUMENTS"
```

Required CSV header (16 columns, no `git_state`):

```text
id,priority,phase,area,title,description,acceptance_criteria,test_mcp,review_initial_requirements,review_regression_requirements,dev_state,review_initial_state,review_regression_state,owner,refs,notes
```

## Core rules

1. Only process the single CSV file the user provided.
2. Any scope change beyond the current row's boundary must be written back to the CSV before changing code.
3. Lock one row (or a tightly related group) at a time; prioritize closing half-finished items and unblocking chains.
4. Multi-step tasks must use `update_plan` to track progress.
5. Run tests when possible; when not possible, record the limitation in `notes` (see "Limited validation" below).
6. Do not create new summary CSVs or auto-sync `issues/issues.csv`.
7. Do not git commit unless the user explicitly requests it.

## Task selection priority

Pick the next task in this order:

1. `dev_state=进行中` (resume in-progress work)
2. `dev_state=已完成` but review incomplete
3. `P0` tasks
4. `P1` tasks that unblock others
5. Remaining incomplete items

After locking a task, append to `notes`:

```text
picked_reason:<one-line reason for picking this row>
```

## Execution closed loop (per issue)

Execute in order for each selected issue:

1. Read the row and minimal necessary context.
2. Set `dev_state` and `review_initial_state` to `进行中`; write back to CSV.
3. Implement code and sync necessary documentation.
4. Review against `review_initial_requirements`.
5. Validate against `acceptance_criteria` and `test_mcp`.
6. Regression check against `review_regression_requirements`.
7. On completion, write back:
   - `dev_state=已完成`
   - `review_initial_state=已完成`
   - `review_regression_state=已完成`
   - Append to `notes`: `done_at:`, `evidence:`, and when needed `manual_test:` / `validation_limited:` / `risk:`

## Limited validation

When environment, permissions, or dependencies prevent real testing:

- Do NOT claim "tests passed".
- Add to `notes`:
  - `validation_limited:<reason>`
  - `manual_test:<suggested command or steps>`
  - `evidence:<alternative evidence completed>`
  - `risk:<low|medium|high> <explanation>`

## Conversation output (after each row or batch)

Report:
- Processed `id` / `title`
- Completed count / remaining count
- Blockers (if any)
- Key changed files with `path:line`
- Tests actually run
- If validation was limited: list unrun tests and reason
