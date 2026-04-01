---
name: "oci:plan"
description: Freeze a proposal into a zero-decision executable plan. Use when the user says plan, oci:plan, or wants to finalize an implementation plan from an existing proposal.
argument-hint: "<change-id | proposal.md | leave empty for auto-detect>"
---

# Stage: Plan

Goal: converge the proposal into a mechanically executable plan. No important decision may remain unfrozen before entering the CSV execution phase. Do NOT implement code.

## Input resolution

Run the helper first:

```bash
python3 _shared/scripts/resolve_oci_source.py "$ARGUMENTS" --cwd .
```

Supported sources:

- `openspec/changes/<change-id>/`
- `openspec/proposal.md`
- Any explicit `proposal.md`

## Mandatory rules

1. Read the existing proposal first, then add design and tasks. Never rewrite from scratch.
2. Any ambiguity that affects the implementation route MUST be marked in `## 待确认问题`. "Decide at implementation time" is forbidden.
3. Plan phase writes documents only — no implementation code.
4. Standard change mode: update `proposal.md`, `design.md`, `tasks.md`, and `specs/*/spec.md` as needed.
5. Single-document proposal mode: enrich the same document with zero-decision task flow, PBT, and success criteria.

## Zero-decision checklist

Before outputting the plan, every item below must have a clear answer:

- [ ] Is each task's input file path specific to `path:line` or an unambiguous module name?
- [ ] Can each task's acceptance criteria be verified by a command or assertion?
- [ ] Are there any "decide based on actual situation" expressions? (If yes → not frozen, mark in `## 待确认问题`)
- [ ] Are inter-task dependencies explicitly declared?
- [ ] Are there any "might need" vague scopes? (If yes → converge or mark)

If any item fails, add `## 待确认问题` and pause.

## Minimum deliverables

The plan must freeze at least:

- Explicit scope boundary and non-goals
- Key technical decisions with parameters
- File/module-level impact scope
- Executable phased task flow
- Acceptance criteria
- Key regression checkpoints
- PBT or system invariants (when applicable)

## Recommended structure for single-document proposal

Enrich with these sections:

```markdown
## 零决策任务流

## PBT（Property-Based Testing）属性

## 成功判据

## 风险与缓解
```

## Interaction rules — must ask the user first when

1. Two or more implementation routes are viable but have different impacts.
2. Success criteria cannot be inferred from existing documents.
3. Paths, module names, or interface names in the document are not specific enough.
4. The plan would expand scope beyond what the user explicitly requested.

## Conversation output

Report:
- Updated document paths
- Key decisions frozen this round
- Unresolved questions (if any)
- Whether the plan is ready for CSV generation
- Next step: `/oci:openspec_to_csv <path-or-change-id>`
