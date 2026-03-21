---
description: 将 OpenSpec change、proposal 或 plan 转成可持久化 issues CSV 快照
argument-hint: "<change-id|change-dir|proposal.md|plan.md>"
---

你现在处于「OCI OpenSpec -> CSV 模式」。

目标：把规划产物转换成唯一命名、可持续维护的 `issues/*.csv` 快照，并把这份 CSV 作为后续执行闭环的唯一状态源。

## 第一步：解析输入来源

优先运行：

```bash
python3 ~/.codex/skills/oci-openspec-csv/scripts/resolve_oci_source.py "$ARGUMENTS" --cwd .
```

支持来源：

1. 标准 OpenSpec change 目录
2. 标准 change 目录里的 `proposal.md`
3. 独立 `openspec/proposal.md`
4. `plan/*.md`
5. 留空自动选择：最新 active change，其次根级 `openspec/proposal.md`，最后最新 `plan/*.md`

若无法确定来源，先问用户，不要猜。

## 第二步：按来源读取上下文

### A. `change_dir`

按顺序读取：

1. `proposal.md`
2. `design.md`（若存在）
3. `tasks.md`（若存在）
4. `specs/*/spec.md`（若存在）

### B. `proposal_doc`

读取单文档 proposal，并重点提取：

- 需求概述
- 显式约束
- 文件清单或影响范围
- 零决策任务流
- PBT
- 成功判据
- 风险与缓解

### C. `plan_doc`

读取 plan 文档，并结合 `📎 参考` 的少量必要文件补足 area、验收和回归要求。

## 第三步：生成 CSV

CSV 使用以下规范表头：

```text
id,priority,phase,area,title,description,acceptance_criteria,test_mcp,review_initial_requirements,review_regression_requirements,dev_state,review_initial_state,review_regression_state,owner,refs,notes
```

不包含 `git_state` 字段（默认不提交）。

字段要求：

- `id`: 使用稳定前缀和递增编号，便于插入任务
- `priority`: `P0|P1|P2`
- `area`: `backend|frontend|both|infra`
- `acceptance_criteria`: 来自成功判据、PBT、Scenario、Validation Criteria
- `test_mcp`: 至少明确一个默认执行器
- `refs`: 不能为空，尽量使用 `path:line`
- `notes`: 可以写 `picked_reason`、依赖、待澄清项

默认状态：

- `dev_state=未开始`
- `review_initial_state=未开始`
- `review_regression_state=未开始`

## 提取映射

### 从标准 OpenSpec change

- `proposal/design/specs/tasks` 共同决定 `description`、`acceptance_criteria`、`review_*`、`refs`

### 从单文档 proposal

- `零决策任务流` -> 任务行
- `成功判据` + `PBT` -> `acceptance_criteria` 和 `review_regression_requirements`
- `显式约束` + `风险与缓解` -> `review_initial_requirements` / `notes`
- `文件清单` -> `area` 和 `refs`

### 从 plan

- Phase/步骤 -> 任务行
- 风险与注意事项 -> `review_*` / `notes`
- 参考文件 -> `refs`

## 文件要求

1. 输出目录：`issues/`
2. 文件名：`issues/YYYY-MM-DD_HH-mm-ss-<slug>.csv`
3. 编码：UTF-8 with BOM
4. 不要创建或更新 `issues/issues.csv`
5. 所有字段统一用双引号包裹，内部双引号做 CSV 转义

## 完成后的对话输出

只输出：

- 生成的 CSV 路径
- 任务总数
- 是否使用了标准 change / proposal / plan 模式
- 任何风险或待确认项
- 下一步建议：`/prompts:oci:csv_execute <snapshot.csv>`
