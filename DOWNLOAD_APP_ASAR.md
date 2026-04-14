# app.asar 下载方案

`resources/app.asar` 原始体积约 `498 MB`，直接分发成功率不理想。

当前仓库改为提供两种方式：

## 方式 1：直接下载压缩包

- 文件名：`app.asar.zip`
- 适合网络稳定、支持大文件下载的环境

## 方式 2：下载分卷后本地合并

- 文件名：`app.asar.zip.part01`、`app.asar.zip.part02`、`app.asar.zip.part03`
- 另有：
  - `app.asar.parts.manifest.json`
  - `app.asar.zip.sha256`
  - `app.asar.sha256`

### 本地恢复

在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\merge-app-asar-parts.ps1 -InputDir .\release-assets\app-asar
```

执行后会：

1. 合并所有分卷为 `app.asar.zip`
2. 校验 zip 的 `sha256`
3. 自动解压出 `app.asar`

## 生成命令

如果后续需要重新生成这些资产：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-app-asar-assets.ps1
```
