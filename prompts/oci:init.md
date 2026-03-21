---
description: 初始化 OCI 工作流环境
---

你现在处于「OCI Init 模式」。

## 目标

检测并初始化项目的 OCI 工作流环境，为后续流程提供基础结构。

## 执行步骤

1. 检测并创建目录结构：
   - `openspec/` (若不存在)
   - `openspec/changes/` (若不存在)
   - `issues/` (若不存在)

2. 检测工具可用性：
   - Auggie MCP (`mcp__augment-context-engine-mcp__codebase-retrieval`)
   - Grok Search MCP (`mcp__grok-search__web_search`)

3. 生成工具链状态文件 `.oci/toolchain.json`：
```json
{
  "auggie_available": true,
  "grok_available": true,
  "initialized_at": "2026-03-21T10:30:00Z"
}
```

## 输出

完成后输出：
- 已创建的目录
- 工具可用性状态
- 下一步建议：`/prompts:oci:research <需求描述>`

## 注意

初始化完成后建议清空上下文，确保后续流程从干净状态开始。
