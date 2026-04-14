# GitHub 上传说明

## 当前状态

- 当前目录已初始化本地 Git 仓库，默认分支为 `main`。
- 当前目录总大小约 `1.19 GB`。
- 以下文件已确认超过 GitHub 普通 Git 单文件 `100 MB` 限制：
  - `resources/app.asar`：约 `475.54 MB`
  - `file/chrome/119.0.6045.123/chrome.dll`：约 `203.72 MB`
  - `Moyaclaw.exe`：约 `182.04 MB`
  - `resources/app.asar.unpacked/node_modules/@lancedb/lancedb/node_modules/@lancedb/lancedb-win32-x64-msvc/lancedb.win32-x64-msvc.node`：约 `143.94 MB`

## 结论

不能直接执行“`git add .` + `git push`”把整个目录原样推到普通 GitHub 仓库。

## 可选方案

### 方案 A：完整产物上传

适合目标：保留当前发布目录的全部内容。

可用做法：

1. 安装并使用 `git-lfs`
2. 或将目录打成多个小于 `100 MB` 的分卷归档，再上传到 GitHub

优点：

- 能保留当前目录的完整发布快照

代价：

- 体积大
- 上传时间长
- 需要额外处理大文件限制

### 方案 B：仅上传可读内容

适合目标：把可分析、可维护的内容放到 GitHub，避免大体积二进制。

可用做法：

1. 解包 `resources/app.asar`
2. 只上传解包后的业务内容、说明文档和必要脚本
3. 将 `.exe`、大型运行时资源和浏览器内核排除在仓库之外

优点：

- 更适合作为工程仓库长期维护
- 不容易触发 GitHub 大文件限制

代价：

- 不能完整还原当前发布目录
- 需要额外解包步骤

## 仍需确认的信息

- 目标 GitHub 仓库名称
- 仓库可见性：公开或私有
- 上传目标是“完整产物”还是“可读内容”
