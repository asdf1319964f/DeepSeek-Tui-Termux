DeepSeek TUI — Termux 一键安装

在你的 Android 手机上，5–10 分钟把 Termux 变成 DeepSeek 命令行对话环境。

装完之后你会得到

· ✅ Termux 基础环境（curl / git / python）
· ✅ Zsh + Oh-My-Zsh + agnoster 主题（终端更好用）
· ✅ DeepSeek TUI 预编译二进制（不用等编译，1 分钟装好）
· ✅ 可选：API Key 快速配置

---

快速开始（三步）

1. 下载安装包

把以下文件放到同一个目录：

· deepseek-tui-termux-bin-*.tar.gz（从 Release 下载）
· install.sh（一键安装脚本）

2. 运行安装脚本

```bash
bash install.sh
```

脚本会：

· 自动检测 Termux 环境
· 安装依赖和 Zsh 配置
· 解压并安装 deepseek / deepseek-tui 命令
· 询问是否配置 API Key

3. 启动

```bash
deepseek
```

首次使用如果没有 API Key，会提示你配置。

---

配置 API Key（重要）

方式一：安装时粘贴

脚本第 5 步会直接询问，粘贴即可。

方式二：手动配置

```bash
deepseek auth set --provider deepseek
```

按提示输入从 platform.deepseek.com 获取的 API Key。

方式三：直接写配置文件

```bash
mkdir -p ~/.deepseek
cat > ~/.deepseek/config.toml << EOF
api_key = "你的API密钥"
default_text_model = "deepseek-v3"
provider = "deepseek"
EOF
```

---

常用命令

命令 作用
deepseek 启动 TUI 界面
deepseek --version 查看版本
deepseek auth status 检查 API Key 是否生效
deepseek auth set --provider deepseek 重新配置 API Key

---

注意

· 仅在 Termux 中运行，不适用于普通 Linux / macOS
· 安装时会申请存储权限（termux-setup-storage），点「允许」即可
· 脚本会自动安装 Oh-My-Zsh，当前 shell 不会立即切换，重新打开 Termux 或执行 exec zsh -l 即可生效

---

如何卸载

```bash
rm -f $PREFIX/bin/deepseek $PREFIX/bin/deepseek-tui
rm -rf ~/.deepseek ~/.oh-my-zsh
```

（Zsh 和主题可保留，不影响）

---

常见问题

提示“不是 Termux 环境”

请确保在 Termux 应用中运行脚本。

没找到 tar.gz 包

把 deepseek-tui-termux-bin-*.tar.gz 放到和 install.sh 相同的文件夹。

切换 Zsh 后找不到 deepseek

重启 Termux 或执行：

```bash
source ~/.zshrc
```

Zsh 会自动加载 $PREFIX/bin 路径。

