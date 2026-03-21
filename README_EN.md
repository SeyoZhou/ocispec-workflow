# OCISpec Workflow

**Codex-Native Command-Driven Development Flow Based on RPI Theory**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

English | [简体中文](./README.md)

---

## Overview

**OCISpec Workflow** is a command-driven development flow that runs independently on Codex without Claude-specific tools. Built on **RPI (Research-Plan-Implementation) theory**, it integrates OpenSpec specifications and CSV state machines to achieve a complete loop from requirements to implementation.

### Key Features

- ✅ **Codex Native**: Runs independently without Claude-specific tools
- ✅ **Proactive Ambiguity Detection**: Pauses and marks unclear points instead of guessing
- ✅ **Parallel Codebase Exploration**: Auggie + Grep + Glob in parallel
- ✅ **Zero-Decision Execution**: All decisions frozen in Plan phase, Implementation is purely mechanical
- ✅ **CSV State Machine**: State externalized to files, independent of conversation windows
- ✅ **Transparent Limited Validation**: `validation_limited` + `manual_test` + `risk` markers

### Command Set

| Command | Function |
|---------|----------|
| `/prompts:oci:init` | Initialize environment and detect tool availability |
| `/prompts:oci:research` | Transform requirements into constraint sets |
| `/prompts:oci:plan` | Generate zero-decision execution plan |
| `/prompts:oci:openspec_to_csv` | Convert to executable CSV |
| `/prompts:oci:csv_execute` | Execute implementation and validation loop |

---

## Quick Start

### Prerequisites

- [Codex](https://codex.storage/) or [Claude Code](https://docs.claude.com/docs/claude-code)
- [Auggie MCP](https://docs.augmentcode.com/context-services/mcp/quickstart-claude-code) (optional, for semantic search)

### Installation

**Linux / macOS**

```bash
# User-level installation (all projects)
./install.sh --user

# Project-level installation (current project only)
./install.sh --project

# Custom path
./install.sh --target /custom/path
```

**Windows (PowerShell)**

```powershell
# User-level installation
.\install.ps1 -User

# Project-level installation
.\install.ps1 -Project

# Custom path
.\install.ps1 -Target "C:\custom\path"
```

### Verify Installation

After starting Codex, type `/prompts:oci` to see available commands.

---

## Usage Flow

```bash
# 1. Initialize environment
/prompts:oci:init

# 2. Research requirements
/prompts:oci:research "Implement user authentication"
# If ## Open Questions exist → confirm with user and re-run

# 3. Generate plan
/prompts:oci:plan openspec/proposal.md
# If ## Open Questions exist → confirm with user and re-run

# 4. Generate CSV
/prompts:oci:openspec_to_csv openspec/proposal.md

# 5. Execute implementation
/prompts:oci:csv_execute issues/2026-03-21_10-30-00-auth.csv
```

---

## Core Design Principles

### 1. Separation of Concerns

Each phase produces persistent files; next phase reads and continues. Don't let AI "think and do" simultaneously.

### 2. Upfront Acceptance Criteria

`acceptance_criteria` determined during CSV generation phase. Execution phase cannot redefine "what is done".

### 3. State Externalization

CSV file is the state machine, independent of conversation windows. Can close and resume anytime.

### 4. Tool Call Budget

Research phase limited to 5-8 tool calls to prevent infinite codebase exploration.

### 5. Proactive Ambiguity Detection

Mark `## Open Questions` in documents when encountering unclear points. No guessing or "decide during implementation".

---

## Comparison with GuDaStudio/commands

| Feature | GuDaStudio | OCISpec |
|---------|-----------|---------|
| Script Assistance | ❌ None | ✅ `resolve_oci_source.py` |
| Codex Independent | ❌ Depends on Claude | ✅ Fully independent |
| Multi-model Collaboration | ✅ Codex+Gemini | ❌ Single model (extensible) |
| CSV State Machine | ✅ With `git_state` | ✅ Without (cleaner) |
| Limited Validation | ⚠️ Basic | ✅ More comprehensive |

---

## Documentation

- [Complete Workflow](./docs/workflow.md)
- [Design Principles](./docs/design-principles.md)
- [FAQ](./docs/faq.md)

---

## License

This project is licensed under the [MIT License](./LICENSE).

---

## Acknowledgments

Inspired by [GuDaStudio/commands](https://github.com/GuDaStudio/commands) and [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec).
