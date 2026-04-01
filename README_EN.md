# OCISpec Workflow

**Codex-Native Development Workflow Based on RPI Theory**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

English | [简体中文](./README.md)

---

## Overview

**OCISpec Workflow** is a skill-based development flow that runs independently on Codex without Claude-specific tools. Built on **RPI (Research-Plan-Implementation) theory**, it integrates OpenSpec specifications and CSV state machines to achieve a complete loop from requirements to implementation.

### Key Features

- ✅ **Codex Native**: Runs independently without Claude-specific tools
- ✅ **Proactive Ambiguity Detection**: Pauses and marks unclear points instead of guessing
- ✅ **Parallel Codebase Exploration**: Auggie + Grep + Glob in parallel
- ✅ **Zero-Decision Execution**: All decisions frozen in Plan phase, Implementation is purely mechanical
- ✅ **CSV State Machine**: State externalized to files, independent of conversation windows
- ✅ **Transparent Limited Validation**: `validation_limited` + `manual_test` + `risk` markers

### Commands

| Command | Function |
|---------|----------|
| `/oci:init` | Initialize environment and detect tool availability |
| `/oci:research` | Transform requirements into constraint sets |
| `/oci:plan` | Generate zero-decision execution plan |
| `/oci:openspec_to_csv` | Convert to executable CSV |
| `/oci:csv_execute` | Execute implementation and validation loop |
| `/oci:workflow` | Show full workflow overview |

---

## Quick Start

### Prerequisites

- [Codex](https://developers.openai.com/codex) or [Claude Code](https://docs.claude.com/docs/claude-code)
- [Auggie MCP](https://docs.augmentcode.com/context-services/mcp/quickstart-claude-code) (optional, for semantic search)

### Installation

**Linux / macOS**

```bash
# User-level installation: install each skill to $CODEX_HOME/skills/
./install.sh --user

# Project-level installation: install to ./.codex/skills/ in this repo
./install.sh --project

# Custom CODEX_HOME root
./install.sh --target ~/.codex
```

### Verify Installation

- Restart Codex / Claude Code after installation
- Type `/oci:init`

---

## Usage Flow

```bash
# 1. Initialize environment
/oci:init

# 2. Research requirement
/oci:research "Implement user authentication"

# 3. Freeze plan
/oci:plan openspec/proposal.md

# 4. Generate CSV
/oci:openspec_to_csv openspec/proposal.md

# 5. Execute implementation
/oci:csv_execute issues/2026-03-21_10-30-00-auth.csv
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
