---
name: "oci:workflow"
description: Show the full OCI workflow overview. Use when the user says workflow, oci:workflow, or asks about the overall OCISpec flow.
---

# OCI Workflow Overview

## Flow

```
/oci:init → /oci:research → /oci:plan → /oci:openspec_to_csv → /oci:csv_execute
```

Each stage produces persisted files; the next stage reads them to continue.

## Stages

| Stage | Command | Input | Output | Code? |
|---|---|---|---|---|
| Init | `/oci:init` | — | directories + `.oci/toolchain.json` | No |
| Research | `/oci:research <req>` | requirement or existing source | `openspec/proposal.md` | No |
| Plan | `/oci:plan <path>` | proposal | enriched proposal + design + tasks | No |
| CSV Gen | `/oci:openspec_to_csv <path>` | proposal / change / plan | `issues/YYYY-MM-DD_HH-mm-ss-<slug>.csv` | No |
| Execute | `/oci:csv_execute <csv>` | one CSV snapshot | updated CSV + implementation code | Yes |

## Design principles

1. **Planning and execution are separate**: research and plan never write implementation code.
2. **Acceptance criteria are front-loaded**: defined at CSV generation time, not during execution.
3. **State is externalized**: the CSV file is the state machine — no dependency on conversation window.
4. **Tool-call budget**: 5–8 calls per exploration round to prevent unbounded search.
5. **Proactive ambiguity detection**: pause and mark open questions instead of guessing.

## Usage

```bash
# 1. Initialize
/oci:init

# 2. Research requirement
/oci:research "实现用户认证功能"

# 3. Freeze plan
/oci:plan openspec/proposal.md

# 4. Generate CSV
/oci:openspec_to_csv openspec/proposal.md

# 5. Execute
/oci:csv_execute issues/2026-03-21_10-30-00-auth.csv
```
