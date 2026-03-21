---
description: OCI 工作流完整流程说明
---

# OCI 工作流

完整的需求到实现闭环流程。

## 流程概览

```
init → research → plan → openspec_to_csv → csv_execute
```

## 各阶段说明

### 1. `/prompts:oci:init`

初始化项目环境，创建必要目录结构，检测工具可用性。

**输出**: `.oci/toolchain.json` + 目录结构

**下一步**: `/prompts:oci:research <需求>`

---

### 2. `/prompts:oci:research <需求描述>`

将模糊需求转化为结构化约束集。

**核心能力**:
- 并行代码库探索（Auggie + Grep + Glob）
- 主动识别歧义并标记 `## 待确认问题`
- 工具调用预算：5-8 次

**输出**: `openspec/proposal.md` 或 `openspec/changes/<id>/proposal.md`

**下一步**:
- 若有 `## 待确认问题` → 用户确认后重新运行 research
- 若无歧义 → `/prompts:oci:plan <proposal-path>`

---

### 3. `/prompts:oci:plan <proposal-path>`

将约束集转化为零决策执行序列。

**核心能力**:
- 零决策检查清单（确保无"实现时再决定"）
- 补充 design.md / tasks.md（标准 change 模式）
- 补充零决策任务流 + PBT（单文档模式）

**输出**:
- 标准模式: `proposal.md` + `design.md` + `tasks.md`
- 单文档模式: `proposal.md`（含零决策任务流）

**下一步**: `/prompts:oci:openspec_to_csv <proposal-path>`

---

### 4. `/prompts:oci:openspec_to_csv <proposal-path>`

将规划文档转换为可执行的 issues CSV。

**输出**: `issues/YYYY-MM-DD_HH-mm-ss-<slug>.csv`

**下一步**: `/prompts:oci:csv_execute <csv-path>`

---

### 5. `/prompts:oci:csv_execute <csv-path>`

以 CSV 为唯一状态源执行实现、Review 和验收闭环。

**核心能力**:
- 状态机驱动（dev → review_initial → review_regression）
- 受限验收机制（`validation_limited` + `manual_test` + `risk`）
- 默认不提交（无 `git_state` 字段）

**输出**: 更新后的 CSV + 实现代码

---

## 关键设计原则

1. **规划和执行分离**: 每个阶段产出落盘文件，下一阶段读取继续
2. **验收标准前置**: acceptance_criteria 在 CSV 生成阶段确定
3. **状态外化**: CSV 文件即状态机，不依赖对话窗口
4. **工具调用预算**: 5-8 次上限，防止无限探索
5. **主动歧义识别**: 遇到模糊点暂停标记，不猜测

---

## Codex 独立运行

所有 prompts 已移除 Claude 特有工具（如 `AskUserQuestion`），改为：
- 在文档中标记 `## 待确认问题`
- 输出明确的暂停点和下一步建议

Codex 可以完全独立走通整个流程。
