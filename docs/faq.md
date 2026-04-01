# FAQ

## Q1: 什么是 RPI 理论？

**RPI (Research-Plan-Implementation)** 是一种编码理论，核心思想是**关注点隔离**：

- **Research**: 将模糊需求转化为结构化约束集
- **Plan**: 将约束集转化为零歧义执行序列
- **Implementation**: 纯机械执行（无即时判断）

每个阶段结束后清空上下文，让 AI 的有效上下文被极致利用。

---

## Q2: 为什么要"零决策执行"？

**决策成本 >> 执行成本**。

让 AI 同时"想要做什么"和"怎么做"会导致：
- 决策摩擦（即时判断）
- 代码质量不稳定
- 需求漂移

把决策前置到 Plan 阶段，Execute 阶段只需读取 spec 按步完成。

---

## Q3: 必须安装 Auggie MCP 吗？

不是必须的，但强烈推荐。

- 有 Auggie: 语义检索 + 并行探索，效率更高
- 无 Auggie: 降级到 Grep + Glob，仍可运行

---

## Q4: CSV 为什么不包含 `git_state`？

**默认不提交**是设计原则。

- 提交是高风险操作，需要用户明确授权
- CSV 状态机只管理开发和验收状态
- 若需提交，用户手动执行 `git commit`

---

## Q5: 什么是"受限验收"？

当环境/权限阻止真实测试时：
- ❌ 不声称"测试通过"
- ✅ 在 `notes` 中标记：
  - `validation_limited:<原因>`
  - `manual_test:<建议命令>`
  - `evidence:<替代证据>`
  - `risk:<low|medium|high>`

透明化风险，而不是隐藏问题。

---

## Q6: 如何处理 `## 待确认问题`？

Research 或 Plan 阶段遇到歧义时会标记：

```markdown
## 待确认问题

### Q1: [问题简述]
- 当前发现: [具体情况]
- 需要确认: [具体问题]
- 影响范围: [如果不确认会影响什么]
```

**处理流程**:
1. 用户阅读并回答问题
2. 重新运行当前阶段命令（带上答案）
3. AI 更新文档并继续

---

## Q7: 可以跳过某个阶段吗？

**不建议**。

每个阶段都有明确的产出和验证点：
- 跳过 Research → 约束不清晰 → Plan 阶段会卡住
- 跳过 Plan → 决策未冻结 → Execute 阶段会频繁"实现时再决定"

---

## Q8: 如何接入多模型协作？

当前版本是单模型流程，但预留了扩展点：

1. 在对应 SKILL.md 中补充模型路由逻辑
2. 调用 Codex MCP 或 Gemini MCP
3. 聚合多模型输出

参考 GuDaStudio/commands 的实现。

---

## Q9: 工具调用预算是什么？

Research 阶段限制 **5-8 次工具调用**。

**原因**:
- 防止 AI 无限探索代码库
- 5 次内未找到答案 → 说明任务定义有问题
- 强制 AI 标记 `## 待确认问题` 而不是猜测

---

## Q10: 与 GuDaStudio/commands 的主要区别？

| 特性 | GuDaStudio | OCISpec |
|------|-----------|---------|
| 目标用户 | Claude Code | Codex / Claude Code |
| 交互方式 | `AskUserQuestion` | 文档标记暂停 |
| 脚本辅助 | ❌ 无 | ✅ Python 脚本 |
| 多模型协作 | ✅ 内置 | ⚠️ 可扩展 |
| CSV 状态机 | ✅ 含 `git_state` | ✅ 不含（更简洁） |

OCISpec 更适合 Codex 独立运行和自动化场景。

---

## Q11: 为什么仓库不再提供 `/prompts:oci:*`？

因为仓库已经切换到独立 skill 分发，每个阶段一个独立 skill。

这样做有两个目的：

1. 项目共享路径更稳定，直接对齐 Codex / Claude Code 的 skill 机制
2. 不再维护一套 prompt 兼容层，避免文档和安装方式分叉

现在统一使用：

- `./install.sh --user`
  - 安装各 skill 到 `~/.codex/skills/`（如 `oci:init/`、`oci:research/` 等）
- `./install.sh --project`
  - 安装到 `./.codex/skills/`
- 使用方式
  - `/oci:init`、`/oci:research "需求"` 等

安装后仍然需要重启 Codex / Claude Code，让它重新发现 skill。
