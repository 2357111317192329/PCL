# Plain Craft Launcher

[![Stars](https://img.shields.io/github/stars/Meloong-Git/PCL?style=flat&logo=data:image/svg%2bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZlcnNpb249IjEiIHdpZHRoPSIxNiIgaGVpZ2h0PSIxNiI+PHBhdGggZD0iTTggLjI1YS43NS43NSAwIDAgMSAuNjczLjQxOGwxLjg4MiAzLjgxNSA0LjIxLjYxMmEuNzUuNzUgMCAwIDEgLjQxNiAxLjI3OWwtMy4wNDYgMi45Ny43MTkgNC4xOTJhLjc1MS43NTEgMCAwIDEtMS4wODguNzkxTDggMTIuMzQ3bC0zLjc2NiAxLjk4YS43NS43NSAwIDAgMS0xLjA4OC0uNzlsLjcyLTQuMTk0TC44MTggNi4zNzRhLjc1Ljc1IDAgMCAxIC40MTYtMS4yOGw0LjIxLS42MTFMNy4zMjcuNjY4QS43NS43NSAwIDAgMSA4IC4yNVoiIGZpbGw9IiNlYWM1NGYiLz48L3N2Zz4=&logoSize=auto&label=Stars&labelColor=444444&color=eac54f)](https://github.com/Meloong-Git/PCL/)
[![Issues](https://img.shields.io/github/issues/Meloong-Git/PCL?style=flat&label=Issues&labelColor=444444&color=1F883D)](https://github.com/Meloong-Git/PCL/issues)
[![哔哩哔哩](https://img.shields.io/badge/动态-BiliBili-00A4DB?style=flat&labelColor=444444&logoSize=auto)](https://space.bilibili.com/11343203/dynamic)
[![爱发电](https://img.shields.io/badge/赞助-爱发电-946ce6?style=flat&labelColor=444444&logoSize=auto)](https://meloong.com/afd/a/LTCat)

包含 PCL 的大部分源代码，包括 UI 库、动画模块、下载模块、Minecraft 启动模块等！<br/>
代码并不是实时更新的，它会在每次 PCL 发布更新时同步一次。<br/>
非常感谢社区的大力支持！

<br/>

### 相关资源
- [PCL 下载](https://meloong.com/pcl)：下载可免费使用的正式版 PCL！
- [PCL 功能投票](https://github.com/Meloong-Git/PCL/discussions/2)：来参加投票吧，开发者会优先处理票数较高的项目！
- [帮助文档库](https://github.com/LTCatt/PCL2Help)：PCL 内置帮助文档的存储库

<br/>

## 从源码编译

### 环境要求

| 软件 | 说明 |
| --- | --- |
| Windows 10 / 11 | PCL 是 WPF 程序，仅支持 Windows |
| Visual Studio 2022（含「.NET 桌面开发」工作负载） | 提供 MSBuild、VB / C# 编译器与 .NET Framework 4.8 目标包；也可改用 [Build Tools for Visual Studio 2022](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)，并勾选相同组件。若安装时漏勾该工作负载，`build.ps1` 会自动规避缺失的 SDK 组件 |
| [.NET SDK](https://dotnet.microsoft.com/download)（任意较新版本） | 用于还原 PCLCS 与 MeloongCore（SDK 风格项目）的 NuGet 包；`build.ps1` 也会借用其中的 MSBuild SDK 组件 |
| .NET Framework 4.8 运行时 | Windows 10 2004 及以上 / Windows 11 通常已自带 |

### 获取源代码

本仓库使用 Git 子模块引用 [MeloongCore](https://github.com/Meloong-Git/MeloongCore)，**必须一并获取**，否则会因缺少 `MeloongCore\Shared\MeloongCore.csproj`、`MeloongCore\Wpf\MeloongCore.Wpf.csproj` 而报「找不到项目文件」（MSB3202）。

方式一（推荐）：使用 Git 克隆并同时拉取子模块。

```powershell
git clone --recursive https://github.com/Meloong-Git/PCL.git
cd PCL
```

若已经克隆但忘了 `--recursive`，可补救：

```powershell
git submodule update --init --recursive
```

方式二：若通过 GitHub 的「Download ZIP」下载（ZIP 不包含子模块内容），需手动补上 MeloongCore：

1. 下载 [MeloongCore](https://github.com/Meloong-Git/MeloongCore) 的 ZIP 并解压；
2. 将其中的全部内容放入仓库根目录的 `MeloongCore` 文件夹中（该文件夹在 ZIP 下载后为空），确保最终存在 `MeloongCore\Shared\MeloongCore.csproj` 与 `MeloongCore\Wpf\MeloongCore.Wpf.csproj`。

### 编译步骤

推荐直接运行仓库根目录的 `build.ps1`。它会自动定位 .NET SDK 与 MSBuild、解除 ZIP 下载文件的「网际网络」标记、还原 NuGet 包，并处理 MSBuild 找不到 .NET SDK 等常见环境问题：

```powershell
# 在仓库根目录的 PowerShell 中直接执行；默认编译 Release，也可以加 -Configuration Debug / Snapshot
.\build.ps1
```

编译成功后，脚本会输出生成的 exe 路径（`Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe`）。

若提示「无法加载文件……在此系统上禁止运行脚本」，可改用：

```powershell
& "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

也可以手动编译（适用于 VS 安装完整、「Developer PowerShell for VS 2022」可用的环境）：

```powershell
# 1. 还原 NuGet 包（会同时还原 PCLCS 及其引用的 MeloongCore 项目）
dotnet restore PCLCS\PCLCS.csproj

# 2. 编译（以 Release 为例）
msbuild "Plain Craft Launcher 2\Plain Craft Launcher 2.vbproj" -p:Configuration=Release
```

若 `msbuild` 不在 PATH 中，可使用完整路径，例如：

```powershell
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" "Plain Craft Launcher 2\Plain Craft Launcher 2.vbproj" -p:Configuration=Release
```

> 注意：若 MSBuild 报 MSB4236（找不到 `Microsoft.NET.Sdk`），说明当前 VS 安装缺少 .NET SDK 的 MSBuild 组件，直接运行 `build.ps1` 即可自动规避；也可以在 Visual Studio Installer 中勾选「.NET 桌面开发」工作负载修复。

### 编译配置

解决方案提供三种配置：

| 配置 | 说明 |
| --- | --- |
| `Debug` | 开发用，定义 `SNAPSHOT` 常量，不优化，包含完整调试符号 |
| `Release` | 正式构建，定义 `RELEASE` 常量，开启优化 |
| `Snapshot` | 介于两者之间，定义 `SNAPSHOT` 常量并开启优化，不含调试符号 |

日常编译使用 `Release` 即可；将 `-p:Configuration=` 换成其他配置名即可编译对应版本。

### 生成产物

编译成功后，主要产物如下：

| 路径 | 说明 |
| --- | --- |
| `Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe` | **最终程序**（单文件即可运行）。所有第三方 DLL 及 PCLCS / MeloongCore 均已作为资源嵌入 exe，无需附带其他文件 |
| `Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe.config` | 程序配置文件（对应 `App.config`） |
| `Plain Craft Launcher 2\bin\Plain Craft Launcher 2.xml` | 程序集 XML 文档注释（可选，可不分发） |
| `Plain Craft Launcher 2\obj\<配置名>\Plain Craft Launcher 2.exe` | 编译中间输出，与 `bin` 中的 exe 相同；官方 CI 即从该路径取用作为构建产物 |
| `PCLCS\bin\PCLCS.dll` 等 | 中间类库产物：`PCLCS.dll`、`MeloongCore.dll`、`MeloongCore.Wpf.dll` 等，构建最终 exe 时会嵌入其中，无需单独分发 |

将 `Plain Craft Launcher 2\bin\Plain Craft Launcher 2.exe` 复制到任意位置即可运行。

### 开源版与正式版的差异

- 注册表写入 `HKCU\Software\PCLDebug`，与正式版数据隔离，互不影响；
- 微软登录需自行设置环境变量 `PCL_MS_CLIENT_ID`（OAuth Client ID），否则无法使用微软登录；
- CurseForge 下载需设置环境变量 `PCL_CURSEFORGE_API_KEY`，否则无法下载 CurseForge 资源；
- 不包含自动更新、赞助等级、云端配置等功能。

### 常见编译问题

| 问题 | 原因与解决办法 |
| --- | --- |
| 报「找不到一个或多个项目文件」（MSB3202），指向 `MeloongCore\...csproj` | 未获取 MeloongCore 子模块，参照上文「获取源代码」补齐 |
| `msbuild` 不是内部或外部命令 | MSBuild 不在 PATH 中，使用「Developer PowerShell for VS 2022」、上面给出的完整路径，或直接运行 `build.ps1` |
| `powershell` 不是内部或外部命令 | 系统 PATH 缺少 `System32\WindowsPowerShell`。在 PowerShell 中直接执行 `.\build.ps1`，或使用 `$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe` 的完整路径 |
| MSBuild 报找不到 SDK（MSB4236） | VS 安装缺少 .NET SDK 的 MSBuild 组件。运行 `build.ps1` 自动规避，或在 Visual Studio Installer 中勾选「.NET 桌面开发」工作负载修复 |
| 报 MSB3821：`Resources.resx` 位于 Internet 或受限区域 | 文件带有 ZIP 下载的「网际网络」标记。运行 `build.ps1` 会自动解除；手动处理可右键文件属性勾选「解除封鎖」，或执行 `Get-ChildItem -Recurse \| Unblock-File` |
| 还原 NuGet 包失败 | 检查网络；公司 / 学校网络可尝试更换 DNS 或使用代理 |
