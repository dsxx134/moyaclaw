# Moyaclaw

这个仓库用于托管 `D:\moyaclaw` 的发布快照与工程说明。

## 说明

- 当前默认分支只保存文档与工程记忆文件。
- 完整的应用目录不会直接提交到 Git 历史中。
- 整个发布目录将作为 GitHub Release 资产上传，避免触发普通 Git 的大文件限制。
- 当前 GitHub 仓库为公开仓库。

## 当前快照

- 产品名：`Moyaclaw`
- 版本：`7.6.13.0`
- 目录来源：`D:\moyaclaw`
- 发布形式：完整目录归档作为 Release 附件
- GitHub 仓库：`https://github.com/dsxx134/moyaclaw`
- 当前 Release：`v7.6.13-full-2026-04-14`

## app.asar 下载

- 原始 `app.asar` 约 `498 MB`
- 已额外提供 `app.asar.zip`，压缩后约 `210 MB`
- 已额外提供分卷：
  - `app.asar.zip.part01`
  - `app.asar.zip.part02`
  - `app.asar.zip.part03`
- 恢复说明见 `DOWNLOAD_APP_ASAR.md`

## 仓库内容

- `AGENTS.md`：项目协作规则
- `ARCHITECTURE.md`：架构理解
- `DOWNLOAD_APP_ASAR.md`：`app.asar` 分卷下载与恢复说明
- `MEMORY.md`：长期经验
- `DECISIONS.md`：技术决策
- `TASKS.md`：后续待办
- `UPLOAD_TO_GITHUB.md`：上传策略说明
