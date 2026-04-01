---
name: "oci:init"
description: Initialize OCI workflow environment. Use when the user says init, oci:init, or wants to set up the OCISpec directory structure and tool detection.
---

# Stage: Init

Goal: detect and initialize the OCI workflow environment for the current project.

## Steps

1. Create directories if missing:
   - `openspec/`
   - `openspec/changes/`
   - `issues/`

2. Detect tool availability:
   - Auggie MCP: `mcp__augment-context-engine-mcp__codebase-retrieval`
   - Grok Search MCP: `mcp__grok-search__web_search`

3. Write `.oci/toolchain.json`:

```json
{
  "auggie_available": true,
  "grok_available": true,
  "initialized_at": "2026-03-21T10:30:00Z"
}
```

## Output

Report:
- Created directories
- Tool availability status
- Next step: `/oci:research <requirement>`

After initialization, recommend clearing context to start subsequent stages cleanly.
