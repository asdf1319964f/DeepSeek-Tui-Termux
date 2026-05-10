# DeepSeek TUI · Termux 一键安装

把 [DeepSeek TUI](https://platform.deepseek.com) 转译/移植到多平台后的 **Termux 构建版本**，5–10 分钟在 Android 手机上跑起 DeepSeek 命令行对话环境。

> **说明**：TUI 本体由上游 `deepseek-tui` 转译而来，本仓库做的是**多平台移植 + Termux 打包分发**。
> 目前已构建的版本：Linux / macOS / Windows / Termux(aarch64-android)，**GitHub 仅发布 Termux 版**，其他平台见文末。

**首发**：[linux.do](https://linux.do/)

---

## 装完之后你会得到

- ✅ Termux 基础环境（curl / git / python）
- ✅ Zsh + Oh-My-Zsh + agnoster 主题
- ✅ DeepSeek TUI 预编译二进制（无需编译，1 分钟装好）
- ✅ 可选：API Key 快速配置

---

## 快速开始

### 1. 下载安装包

把以下两个文件放到同一个目录：

- `deepseek-tui-termux-bin-*.tar.gz`（从 [Releases](https://github.com/asdf1319964f/DeepSeek-Tui-Termux/releases) 下载）
- `install.sh`（一键安装脚本）

### 2. 运行安装脚本

```bash
bash install.sh
```

脚本会自动：

- 检测 Termux 环境
- 安装依赖和 Zsh 配置
- 解压并安装 `deepseek` / `deepseek-tui` 命令
- 询问是否配置 API Key

### 3. 启动

```bash
deepseek
```

首次使用如果没有 API Key，会提示你配置。

---

## 配置 API Key

### 方式一：安装时粘贴

脚本第 5 步会询问，直接粘贴即可。

### 方式二：命令行配置

```bash
deepseek auth set --provider deepseek
```

按提示输入从 [platform.deepseek.com](https://platform.deepseek.com) 获取的 API Key。

### 方式三：直接写配置文件

```bash
mkdir -p ~/.deepseek
cat > ~/.deepseek/config.toml << 'EOF'
api_key = "你的API密钥"
default_text_model = "deepseek-v3"
provider = "deepseek"
EOF
```

---

## 常用命令

| 命令 | 作用 |
|------|------|
| `deepseek` | 启动 TUI 界面 |
| `deepseek --version` | 查看版本 |
| `deepseek auth status` | 检查 API Key 是否生效 |
| `deepseek auth set --provider deepseek` | 重新配置 API Key |

---

## 注意事项

- 仅在 **Termux** 中运行，不适用于普通 Linux / macOS（其他平台见文末）
- 安装时会申请存储权限（`termux-setup-storage`），点「允许」即可
- Oh-My-Zsh 安装后当前 shell 不会立即切换，重新打开 Termux 或执行 `exec zsh -l` 即可

---

## 卸载

```bash
rm -f $PREFIX/bin/deepseek $PREFIX/bin/deepseek-tui
rm -rf ~/.deepseek
# 如需同时清理 zsh 配置（可选）
rm -rf ~/.oh-my-zsh
```

---

## 常见问题

**提示「不是 Termux 环境」**
请确保在 Termux 应用中运行脚本。

**没找到 tar.gz 包**
把 `deepseek-tui-termux-bin-*.tar.gz` 放到和 `install.sh` 相同的文件夹。

**切换 Zsh 后找不到 deepseek**
重启 Termux 或执行 `source ~/.zshrc`，zsh 会自动加载 `$PREFIX/bin` 路径。

**第一次启动慢**
首次启动要加载模型列表和配置，大概 10 秒，之后秒开。

---



## 致谢

- 上游项目：[DeepSeek TUI](https://platform.deepseek.com)（本仓库基于其转译/移植）
- 首发社区：[linux.do](https://linux.do/)
