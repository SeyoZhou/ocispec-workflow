# OCISpec Workflow

**基于 RPI 理论的 Codex 原生 Skill 工作流**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](./README_EN.md) | 简体中文

---

## 项目简介

**OCISpec Workflow** 是一套完全独立于 Claude、可在 Codex 上运行的 Skill 工作流。核心设计基于 **RPI (Research-Plan-Implementation) 编码理论**，融合 OpenSpec 规范和 CSV 状态机，实现从需求到实现的完整闭环。

### 核心特性

- ✅ **Codex 原生支持**：无需 Claude 特有工具，完全独立运行
- ✅ **主动歧义识别**：遇到模糊点暂停标记，不猜测
- ✅ **并行代码库探索**：Auggie + Grep + Glob 并行检索
- ✅ **零决策执行**：Plan 阶段冻结所有决策，Implementation 纯机械执行
- ✅ **CSV 状态机**：状态外化到文件，不依赖对话窗口
- ✅ **受限验收机制**：`validation_limited` + `manual_test` + `risk` 标记

### 命令集

| 命令 | 功能 |
|------|------|
| `/oci:init` | 初始化环境，检测工具可用性 |
| `/oci:research` | 将需求转化为约束集 |
| `/oci:plan` | 生成零决策执行计划 |
| `/oci:openspec_to_csv` | 转换为可执行 CSV |
| `/oci:csv_execute` | 执行实现与验收闭环 |
| `/oci:workflow` | 查看完整流程说明 |

---

## 快速开始

### 前置要求

- [Codex](https://developers.openai.com/codex) 或 [Claude Code](https://docs.claude.com/docs/claude-code)
- [Auggie MCP](https://docs.augmentcode.com/context-services/mcp/quickstart-claude-code) (可选，用于语义检索)

### 安装

**Linux / macOS**

```bash
# 用户级安装：安装各 skill 到 $CODEX_HOME/skills/
./install.sh --user

# 项目级安装：安装到当前仓库的 ./.codex/skills/
./install.sh --project

# 自定义 CODEX_HOME 根目录
./install.sh --target ~/.codex
```

### 验证安装

- 安装后重启 Codex / Claude Code
- 输入 `/oci:init`

---

## 使用流程

```bash
# 1. 初始化环境
/oci:init

# 2. 研究需求
/oci:research "实现用户认证功能"

# 3. 冻结计划
/oci:plan openspec/proposal.md

# 4. 生成 CSV
/oci:openspec_to_csv openspec/proposal.md

# 5. 执行实现
/oci:csv_execute issues/2026-03-21_10-30-00-auth.csv
```

---

## 核心设计原则

### 1. 规划和执行分离

每个阶段产出落盘文件，下一阶段读取继续。不让 AI "一边想一边做"。

### 2. 验收标准前置

`acceptance_criteria` 在 CSV 生成阶段确定，执行阶段不允许重新定义"什么叫做完"。

### 3. 状态外化

CSV 文件即状态机，不依赖对话窗口。任何时候能关掉、能续上。

### 4. 工具调用预算

Research 阶段 5-8 次工具调用上限，防止无限探索代码库。

### 5. 主动歧义识别

遇到模糊点在文档中标记 `## 待确认问题` 并暂停，不猜测或"实现时再决定"。

---

## 与 GuDaStudio/commands 的差异

| 特性 | GuDaStudio | OCISpec |
|------|-----------|---------|
| 脚本辅助 | ❌ 无 | ✅ `resolve_oci_source.py` |
| Codex 独立运行 | ❌ 依赖 Claude | ✅ 完全独立 |
| 多模型协作 | ✅ Codex+Gemini | ❌ 单模型（可扩展） |
| CSV 状态机 | ✅ 含 `git_state` | ✅ 不含（更简洁） |
| 受限验收 | ⚠️ 基础 | ✅ 更完善 |

---

## 文档

- [完整流程说明](./docs/workflow.md)
- [设计原则](./docs/design-principles.md)
- [FAQ](./docs/faq.md)

---

## 许可证

本项目采用 [MIT License](./LICENSE) 开源协议。

---

## 致谢

本项目受 [GuDaStudio/commands](https://github.com/GuDaStudio/commands) 和 [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) 启发。
