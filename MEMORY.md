# 长期经验

## GitHub 上传限制

- 当前目录总大小约为 `1.19 GB`。
- 多个关键文件超过 GitHub 普通 Git 单文件 `100 MB` 限制，当前已确认包括：
  - `resources/app.asar`：约 `475.54 MB`
  - `file/chrome/119.0.6045.123/chrome.dll`：约 `203.72 MB`
  - `Moyaclaw.exe`：约 `182.04 MB`
  - `resources/app.asar.unpacked/node_modules/@lancedb/lancedb/node_modules/@lancedb/lancedb-win32-x64-msvc/lancedb.win32-x64-msvc.node`：约 `143.94 MB`
- 结论：不能直接把整个目录按普通 Git 仓库原样推送到 GitHub。

## 环境能力边界

- 当前环境可用：`git`、`python`
- 当前环境不可用或未安装：`gh`、`node`、`npm`、`git lfs`、`7z`
- 结论：如果要完整上传大体积产物，需要优先考虑：
  - 先安装 `git-lfs`
  - 或用脚本生成 GitHub 可接受的分卷归档
  - 或只上传可读源码/解包内容

## 项目识别经验

- 当根目录以 `.exe`、`.dll`、`.pak`、`app.asar` 为主，且没有顶层 `package.json` 时，应优先把它视为“发布目录”而非“源码仓库”。
- `app.asar.unpacked` 中暴露出来的依赖有助于快速判断应用能力边界，即使主业务代码仍在 `app.asar` 内部。

## 发布链路线索

- 当前应用更新源配置在 `resources/app-update.yml`，使用 `generic` provider，而不是 GitHub Releases。
- 这意味着“上传到 GitHub”更像是代码/归档托管行为，不会自动接入现有应用更新链路。

## 已验证的发布方案

- 已成功创建并公开仓库 `dsxx134/moyaclaw`。
- 已验证“轻量默认分支 + 完整目录 Release 附件”方案可行。
- 已成功上传：
  - `moyaclaw-7.6.13-full-2026-04-14.tar`
  - `moyaclaw-7.6.13-full-2026-04-14.tar.sha256`
- 结论：对于此类大体积发布目录，优先把完整快照放到 Release，而不是尝试直接进入 Git 历史。

## app.asar 分发经验

- `resources/app.asar` 原始大小约 `498642204` 字节，直接分发不友好。
- 将 `app.asar` 压缩为 `zip` 后，体积降到约 `219811454` 字节。
- 再按 `95 MB` 分卷后，可以稳定拆成 3 个下载片段：
  - `app.asar.zip.part01`
  - `app.asar.zip.part02`
  - `app.asar.zip.part03`
- 分卷恢复后重新解压，得到的 `app.asar` 与原文件 `sha256` 一致。
- 结论：对这个仓库里的 `app.asar`，最稳妥的分发方式是“zip 压缩 + 95MB 分卷 + manifest + 恢复脚本”。
