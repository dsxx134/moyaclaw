# 项目协作规则

## 项目类型

- 当前仓库 `D:\moyaclaw` 是一个 Windows 平台的 Electron 打包产物快照，不是原始源码仓库。
- 主程序文件为 `Moyaclaw.exe`，文件描述为 `Moyaclaw-AI获客系统 - AI-powered customer acquisition desktop app`，版本为 `7.6.13.0`。
- 根目录包含大量二进制文件与运行时资源，默认应视为发布产物，避免做大规模直接修改。

## 目录观察

- `resources/app.asar`：主应用打包内容。
- `resources/app.asar.unpacked/`：解包后的原生模块与部分 Node 依赖。
- `file/chrome/`：内置浏览器运行时、驱动与相关资源。
- `file/opencli-extension/`：浏览器扩展，当前可见 `manifest.json` 为 MV3 结构。
- `locales/`：Electron/Chromium 语言包。

## 工作原则

- 只基于当前仓库文件建立理解，不假设存在未提供的源码工程。
- 对二进制产物优先做“旁路式”操作，例如补文档、补脚本、补上传说明，而不是直接改可执行文件。
- 任何涉及 GitHub 上传的操作，都必须先检查单文件大小与总目录体积。

## 常用检查命令

- `git status --short --branch`
- `Get-ChildItem -Recurse -File | Sort-Object Length -Descending | Select-Object -First 20 FullName,@{Name='SizeMB';Expression={[math]::Round($_.Length/1MB,2)}}`
- `(Get-Item 'Moyaclaw.exe').VersionInfo | Select-Object FileDescription,ProductName,ProductVersion,CompanyName`
- `Get-Content resources/app-update.yml`

## 当前环境结论

- 已在本地初始化 Git 仓库，默认分支为 `main`。
- 当前环境存在 `git` 与 `python`，但未发现 `gh`、`node`、`npm`、`git lfs`、`7z`。
- GitHub 账户侧可确认当前登录用户为 `dsxx134`。
