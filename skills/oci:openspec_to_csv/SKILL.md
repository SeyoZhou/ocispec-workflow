---
name: "oci:openspec_to_csv"
description: Convert an OpenSpec proposal, change, or plan into a timestamped issues CSV snapshot. Use when the user says openspec_to_csv, oci:openspec_to_csv, or wants to generate an executable CSV from planning documents.
argument-hint: "<change-id | change-dir | proposal.md | plan.md>"
---

# Stage: OpenSpec to CSV

Goal: convert planning artifacts into a uniquely named, maintainable `issues/*.csv` snapshot that becomes the single source of truth for subsequent execution.

## Step 1: Resolve input source

Run the helper first:

```bash
python3 _shared/scripts/resolve_oci_source.py "$ARGUMENTS" --cwd .
```

Supported sources (in priority order when auto-detecting):

1. Standard OpenSpec change directory
2. `proposal.md` inside a change directory
3. `openspec/proposal.md` (root-level single doc)
4. `plan/*.md`
5. Auto-select: latest active change → root proposal → latest plan

If the source cannot be determined, ask the user. Do not guess.

## Step 2: Read context by source type

### A. `change_dir`

Read in order:
1. `proposal.md`
2. `design.md` (if exists)
3. `tasks.md` (if exists)
4. `specs/*/spec.md` (if exists)

### B. `proposal_doc`

Read the single document. Extract:
- 需求概述
- 显式约束
- File list / impact scope
- 零决策任务流
- PBT
- 成功判据
- 风险与缓解

### C. `plan_doc`

Read the plan document and supplement with a minimal set of referenced files for area, acceptance, and regression requirements.

## Step 3: Generate CSV

### Header (16 columns, no `git_state`)

```text
id,priority,phase,area,title,description,acceptance_criteria,test_mcp,review_initial_requirements,review_regression_requirements,dev_state,review_initial_state,review_regression_state,owner,refs,notes
```

### Field constraints

| Field | Rule |
|---|---|
| `id` | Stable prefix + incrementing number, leave gaps for later insertion |
| `priority` | `P0` / `P1` / `P2` |
| `phase` | Logical grouping / execution phase |
| `area` | `backend` / `frontend` / `both` / `infra` |
| `acceptance_criteria` | Derived from 成功判据, PBT, Scenario, Validation Criteria |
| `test_mcp` | At least one default executor specified |
| `refs` | Must not be empty; use `path:line` when possible |
| `notes` | May contain `picked_reason`, dependencies, open items |
| `dev_state` | Default: `未开始` |
| `review_initial_state` | Default: `未开始` |
| `review_regression_state` | Default: `未开始` |

### Extraction mapping

**From standard OpenSpec change:**
- `proposal/design/specs/tasks` jointly determine `description`, `acceptance_criteria`, `review_*`, `refs`

**From single-document proposal:**
- `零决策任务流` → task rows
- `成功判据` + `PBT` → `acceptance_criteria` and `review_regression_requirements`
- `显式约束` + `风险与缓解` → `review_initial_requirements` / `notes`
- File list → `area` and `refs`

**From plan:**
- Phase/steps → task rows
- Risks and notes → `review_*` / `notes`
- Referenced files → `refs`

## File requirements

1. Output directory: `issues/`
2. File name: `issues/YYYY-MM-DD_HH-mm-ss-<slug>.csv`
3. Encoding: UTF-8 with BOM
4. Do NOT create or update `issues/issues.csv`
5. All fields wrapped in double quotes; internal double quotes escaped per CSV spec

## Conversation output

Report only:
- Generated CSV path
- Total task count
- Source mode used (standard change / proposal / plan)
- Risks or open items
- Next step: `/oci:csv_execute <snapshot.csv>`
