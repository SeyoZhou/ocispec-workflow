---
description: 以 issues CSV 为唯一状态源执行实现、Review 和自验收闭环
argument-hint: "<issues CSV 文件路径>"
---

你现在处于「OCI CSV 执行模式」。

目标：以用户传入的这一份 CSV 为唯一边界与状态源，持续推进 issue 的完整闭环：实现 -> Review -> 自我验收。默认不做 git commit。

## 启动前检查

如果可用，先运行：

```bash
python3 ~/.codex/skills/oci-openspec-csv/scripts/validate_issues_csv.py "$ARGUMENTS"
```

CSV 必须包含以下表头：
```text
id,priority,phase,area,title,description,acceptance_criteria,test_mcp,review_initial_requirements,review_regression_requirements,dev_state,review_initial_state,review_regression_state,owner,refs,notes
```

不包含 `git_state` 字段（默认不提交）。

## 核心规则

1. 只处理用户传入的这一个 CSV 文件。
2. 任何超出当前行边界的需求变更，先写回 CSV，再改代码。
3. 每次只锁定一行或一组紧密相关的行，优先收敛半成品和阻塞链路。
4. 多步任务必须使用 `update_plan` 跟踪进度。
5. 能跑测试就跑测试；不能跑时必须把受限验收信息写入 `notes`。
6. 不擅自创建新的汇总 CSV，不自动同步 `issues/issues.csv`。
7. 默认不做 git commit；只有用户明确要求时才进入提交动作。

## 任务选择顺序

优先级建议：

1. `dev_state=进行中`
2. `dev_state=已完成` 但 Review 未完成
3. `P0`
4. 可解除阻塞的 `P1`
5. 其他未完成项

锁定任务后，在 `notes` 追加：

```text
picked_reason:<一句话解释为何先做这条>
```

## 执行闭环

对每条选中的 issue 按顺序执行：

1. 读取该行和最小必要上下文
2. 将 `dev_state`、`review_initial_state` 置为 `进行中` 并写回 CSV
3. 实现代码和必要文档同步
4. 按 `review_initial_requirements` 做开发中 Review
5. 按 `acceptance_criteria` 和 `test_mcp` 做验证
6. 按 `review_regression_requirements` 做回归检查
7. 完成后写回：
   - `dev_state=已完成`
   - `review_initial_state=已完成`
   - `review_regression_state=已完成`
   - `notes` 追加 `done_at:`、`evidence:`、必要时 `manual_test:` / `validation_limited:` / `risk:`

## 受限验收

如果环境、权限或依赖阻止真实测试：

- 不要声称“测试通过”
- 在 `notes` 中补充：
  - `validation_limited:<原因>`
  - `manual_test:<建议命令或步骤>`
  - `evidence:<已完成的替代证据>`
  - `risk:<low|medium|high> <说明>`

## 结束输出

每处理完一条或一轮后，输出：

- 本次处理的 `id/title`
- 已完成条数 / 剩余条数
- 阻塞项（若有）
- 关键改动文件与 `path:line`
- 实际运行的测试
- 若受限验收，列出未运行测试与原因
