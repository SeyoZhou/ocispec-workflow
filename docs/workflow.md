# OCISpec 工作流完整说明

## 流程概览

```
init → research → plan → openspec_to_csv → csv_execute
```

---

## 各阶段详解

### 1. Init - 环境初始化

**命令**: `/oci:init`

**目标**: 检测并初始化项目的 OCI 工作流环境。

**执行内容**:
- 创建 `openspec/`、`openspec/changes/`、`issues/` 目录
- 检测 Auggie MCP 和 Grok Search MCP 可用性
- 生成 `.oci/toolchain.json` 状态文件

**输出**:
```json
{
  "auggie_available": true,
  "grok_available": true,
  "initialized_at": "2026-03-21T10:30:00Z"
}
```

**下一步**: 清空上下文后运行 `/oci:research`

---

### 2. Research - 需求研究

**命令**: `/oci:research "<需求描述>"`

**目标**: 将模糊需求转化为结构化约束集。

**核心能力**:
- **并行代码库探索**（工具调用预算：5-8 次）
  - Auggie MCP 语义检索
  - Grep 精确匹配
  - Glob 文件扫描
- **主动歧义识别**
  - 遇到 5 类触发条件时标记 `## 待确认问题`
  - 不猜测、不"实现时再决定"

**输出**: `openspec/proposal.md` 或 `openspec/changes/<id>/proposal.md`

**文档结构**:
```markdown
# OpenSpec Proposal: <标题>

## 需求概述
## 当前代码与现状
## 显式约束
## 风险与依赖
## 待确认问题
## 成功判据提示
```

**下一步**:
- 若有 `## 待确认问题` → 用户确认后重新运行 `/oci:research`
- 若无歧义 → 运行 `/oci:plan`

---

### 3. Plan - 零决策计划

**命令**: `/oci:plan <proposal-path>`

**目标**: 将约束集转化为零决策执行序列。

**核心能力**:
- **零决策检查清单**（5 项检查）
  - 文件路径具体到 `path:line`
  - 验收标准可用命令验证
  - 无"根据实际情况决定"表述
  - 任务依赖显式声明
  - 无"可能需要"的模糊范围

**输出**:
- 标准模式: `proposal.md` + `design.md` + `tasks.md`
- 单文档模式: `proposal.md`（含零决策任务流 + PBT）

**下一步**: 运行 `/oci:openspec_to_csv`

---

### 4. OpenSpec to CSV - 转换为可执行任务

**命令**: `/oci:openspec_to_csv <proposal-path>`

**目标**: 将规划文档转换为可执行的 issues CSV。

**CSV 表头**:
```text
id,priority,phase,area,title,description,acceptance_criteria,test_mcp,review_initial_requirements,review_regression_requirements,dev_state,review_initial_state,review_regression_state,owner,refs,notes
```

**字段说明**:
- `id`: 稳定前缀 + 递增编号（如 `auth-001`）
- `priority`: `P0|P1|P2`
- `area`: `backend|frontend|both|infra`
- `acceptance_criteria`: 来自成功判据、PBT、Scenario
- `test_mcp`: 执行器（如 `AUTOSERVER`）
- `refs`: 必须非空，优先 `path:line`

**输出**: `issues/YYYY-MM-DD_HH-mm-ss-<slug>.csv`

**下一步**: 运行 `/oci:csv_execute`

---

### 5. CSV Execute - 执行与验收闭环

**命令**: `/oci:csv_execute <csv-path>`

**目标**: 以 CSV 为唯一状态源执行实现、Review 和验收闭环。

**状态机**:
```
dev_state: 未开始 → 进行中 → 已完成
review_initial_state: 未开始 → 进行中 → 已完成
review_regression_state: 未开始 → 已完成
```

**执行闭环**（每条 issue）:
1. 读取该行和最小必要上下文
2. 将状态置为 `进行中` 并写回 CSV
3. 实现代码和必要文档同步
4. 按 `review_initial_requirements` 做开发中 Review
5. 按 `acceptance_criteria` 和 `test_mcp` 做验证
6. 按 `review_regression_requirements` 做回归检查
7. 完成后写回状态和证据

**受限验收**:
若环境/权限阻止真实测试，在 `notes` 中补充：
- `validation_limited:<原因>`
- `manual_test:<建议命令>`
- `evidence:<替代证据>`
- `risk:<low|medium|high> <说明>`

**输出**: 更新后的 CSV + 实现代码

---

## 关键设计原则

### 1. 关注点隔离

每个阶段只做一件事：
- Research: 提炼约束
- Plan: 冻结决策
- Execute: 机械执行

### 2. 状态外化

CSV 文件即状态机，与代码同 commit，不依赖对话窗口。

### 3. 工具调用预算

Research 阶段 5-8 次上限，若未找到答案 → 标记 `## 待确认问题`。

### 4. 零决策执行

Plan 阶段必须消灭所有"实现时再决定"的点，Execute 阶段不做即时判断。

### 5. 受限验收透明化

不能跑测试时不声称"测试通过"，而是明确标记风险和替代证据。
