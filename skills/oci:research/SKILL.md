---
name: "oci:research"
description: Research a requirement into an OpenSpec-style proposal with constraints, risks, and open questions. Use when the user says research, oci:research, or wants to analyze a requirement before planning.
argument-hint: "<requirement description or existing proposal/change-id>"
---

# Stage: Research

Goal: research the requirement thoroughly, then persist constraints, status-quo, risks, open questions, and success-criteria hints into an OpenSpec-style proposal. Do NOT implement code.

## Input resolution

Run the helper first:

```bash
python3 _shared/scripts/resolve_oci_source.py "$ARGUMENTS" --cwd .
```

If the helper is unavailable, resolve in this order:

1. `openspec/changes/<change-id>/`
2. `openspec/proposal.md`
3. `plan/*.md`
4. Raw natural-language requirement

Default output locations:

- Standard change mode: update `openspec/changes/<change-id>/proposal.md`
- Single-document mode: update `openspec/proposal.md`

## Mandatory rules

1. Search the codebase first, form judgements second. Prefer semantic retrieval tools; never guess without evidence.
2. Research phase produces proposals and constraints only — no implementation code, no CSV.
3. If a proposal/design/tasks document already exists, read it first and update incrementally. Do not rewrite content the user has already confirmed.

## Ambiguity detection triggers

You MUST mark `## 待确认问题` and pause when any of these apply:

1. The core entity/module in the requirement has multiple candidate implementations in the codebase.
2. Constraints are mutually exclusive (e.g. "fast" vs "memory-efficient" with no stated priority).
3. Success criteria cannot be inferred from the requirement (e.g. "optimize performance" with no baseline metric).
4. Impact scope crosses multiple subsystems but boundaries are unclear.
5. Multiple viable technical approaches exist but the requirement states no preference.

Mark format:

```markdown
## 待确认问题

### Q1: [short summary]
- 当前发现: [specifics]
- 需要确认: [exact question]
- 影响范围: [what breaks if left unconfirmed]
```

## Research workflow

### 1. Parallel codebase exploration (tool-call budget: 5–8)

Launch in parallel:
- Auggie MCP semantic retrieval: requirement keywords
- Grep: core entity/function names (if known)
- Glob: related file patterns (e.g. `**/auth/*.py`)

If 5 calls yield no clear answer → mark `## 待确认问题`.

### 2. Distill constraint set

Extract from codebase and requirement:
- Requirement goals
- Existing structure and conventions
- Hard constraints (non-negotiable)
- Soft constraints (trade-offs allowed)
- Dependencies and risks
- Open questions (if any)
- Success-criteria hints

### 3. Write proposal document

If critical ambiguity exists, mark it in `## 待确认问题` explicitly. Never defer decisions to "implementation time".

## Proposal minimum structure

If the target document lacks structure, fill in at least these sections:

```markdown
# OpenSpec Proposal: <title>

## 需求概述

## 当前代码与现状

## 显式约束

## 风险与依赖

## 待确认问题

## 成功判据提示
```

## Conversation output

Report only:
- Updated proposal path
- Key constraints added or confirmed this round
- Questions still requiring user confirmation (if any)
- Next step: `/oci:plan <path-or-change-id>`
