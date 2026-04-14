# 架构理解

## 总体形态

当前目录不是开发态源码结构，而是一个已经打包完成的桌面应用发布目录。可以把它理解为：

1. Windows 启动层
2. Electron/Chromium 运行时层
3. 应用业务层
4. 浏览器自动化辅助层

## 主要组件

### 1. Windows 启动层

- `Moyaclaw.exe` 是面向用户的主启动程序。
- 根目录同时存在 Electron 常见运行时依赖，例如 `ffmpeg.dll`、`libEGL.dll`、`libGLESv2.dll`、`vulkan-1.dll` 等。

### 2. Electron/Chromium 运行时层

- `resources/app.asar` 是主业务代码与静态资源的封装载体。
- `locales/`、`resources.pak`、`snapshot_blob.bin`、`v8_context_snapshot.bin` 等共同构成 Electron 运行时资源。

### 3. 应用业务层

- 业务逻辑主体当前被封装在 `resources/app.asar` 中。
- `resources/app.asar.unpacked/` 暴露了部分运行时依赖，当前可确认包含：
  - `better-sqlite3`
  - `jszip`
  - `@lancedb/lancedb`
- 这说明应用很可能同时涉及本地数据库、压缩处理和向量/检索相关能力。

### 4. 浏览器自动化辅助层

- `file/chrome/` 下存在内置 Chrome、`chromedriver.exe`、代理程序及版本化浏览器目录。
- `file/opencli-extension/manifest.json` 显示存在一个名为 `OpenCLI` 的浏览器扩展，具备 `debugger`、`tabs`、`cookies` 等权限。
- 从当前目录结构看，桌面应用可能集成了浏览器自动化能力。

## 更新链路

- `resources/app-update.yml` 当前配置为通用更新源：
  - `provider: generic`
  - `url: http://43.242.194.25:8081/static/updates/`
- 这表示应用更新并未直接绑定 GitHub Releases，而是依赖外部静态更新源。

## 当前限制

- 当前仓库缺少原始源码入口文件，如根目录 `package.json`、构建脚本或项目级依赖描述。
- 因此后续若需要做深度修改，优先路径应是解包 `app.asar` 或回溯原始源码仓库，而不是直接在发布目录中猜测开发结构。
