# DeepSeek-Tui-Termux

# DeepSeek-TUI Termux 版 使用说明书

> 适用版本：0.8.17 · ARM64 Android (Termux 0.118+) · 由本机 Termux 编译
>
> 本文是 Termux 端用户手册。开发者细节看 `docs/TERMUX.md`、`AGENTS.md`、`README.md`。

---

## 1. 拿到的文件清单

最新打包都在 **`/storage/emulated/0/Download/ces/arm-tui/`**：

| 文件 | 大小 | 用途 |
|---|---|---|
| `deepseek-tui-termux-bin-aarch64-android-0.8.17-20260508.tar.gz` | 16 MB | **预编译二进制**——不想自己编译就用这个 |
| `deepseek-tui-termux-src-0.8.17-20260508.tar.gz` | 2.5 MB | **源码包**——想改色/改代码就解这个 |
| `SHA256SUMS-20260508.txt` | — | 两个 tar 的 SHA-256 校验和 |
| `deepseek-tui/` | — | 已展开的源码目录（与 src tarball 同内容） |
| `deepseek-tui/bin/{deepseek,deepseek-tui}` | 7.2 + 30 MB | 已编译二进制（共享存储 noexec，需 cp） |

校验：
```bash
cd /storage/emulated/0/Download/ces/arm-tui
sha256sum -c SHA256SUMS-20260508.txt
```

---

## 2. 安装

### 方式 A · 直接装预编译（最快，1 分钟）

```bash
cd ~
tar xzf /storage/emulated/0/Download/ces/arm-tui/deepseek-tui-termux-bin-aarch64-android-0.8.17-20260508.tar.gz
cd deepseek-tui-termux-bin-aarch64-android-0.8.17-20260508
install -m 0755 bin/deepseek      $PREFIX/bin/deepseek
install -m 0755 bin/deepseek-tui  $PREFIX/bin/deepseek-tui
deepseek --version    # 看到 0.8.17 就成
```

### 方式 B · 从源码编译（要改色/调试时用，15–25 分钟）

```bash
pkg install -y rust binutils pkg-config openssl libsqlite git gh
cd ~
tar xzf /storage/emulated/0/Download/ces/arm-tui/deepseek-tui-termux-src-0.8.17-20260508.tar.gz
cd deepseek-tui-termux-src-0.8.17-20260508
bash install-termux.sh    # 自动 build + 装到 $PREFIX/bin
```

> ⚠ 源码目录**必须**在 Termux 原生分区（`$HOME` 下），不能直接在 `/storage/emulated/0/...` 编译——FUSE 是 noexec，cargo 跑不动 build 脚本。

---

## 3. 设置 API key

1. 浏览器打开 https://platform.deepseek.com/api_keys 申请 key（`sk-` 开头 32 位 hex）。
2. 终端跑：

```bash
deepseek auth set --provider deepseek
# 提示输入时粘贴完整 sk-... 回车
```

3. 验证：

```bash
deepseek auth status   # active source 应是 config，last4 跟 key 末四位一致
deepseek models        # 列出服务器返回的模型；返回 401 = key 错/过期
```

> ⚠ **不要**把 `api_key` 写进项目目录的 `.deepseek.toml` / `AGENTS.md` ——会被强制忽略并报警告。只能写 `~/.deepseek/config.toml` 或交给 `deepseek auth set` 管。

---

## 4. 启动与基本操作

```bash
deepseek                      # 在当前目录启动 TUI
cd ~/项目目录 && deepseek     # 把当前目录作为 workspace
deepseek --model auto         # 让模型自己选 v4-pro / v4-flash
```

| 按键 | 作用 |
|---|---|
| `Enter` | 提交输入 |
| `Esc` | 中断当前回合 / 关弹窗 |
| `Ctrl+C` | 软中断（连按两次彻底退出） |
| `Ctrl+D` | 退出 TUI |
| `Shift+Tab` | 切换思考强度：off → high → max |
| `/help` | 在 TUI 里看所有斜杠命令 |
| `/model auto` | 切回自动选模型 |
| `/sessions` | 列历史会话 |
| `/restore` | 撤销上一回合的工作区改动 |

**三种模式（左下角显示）**：
- **Plan** — 只读探索，不改文件、不跑命令
- **Agent** — 默认；改文件/跑命令前会问你审批
- **YOLO** — 全自动，**慎用**，建议在干净 git 工作区或临时目录用

---

## 5. 改字体颜色 ⭐

颜色没有运行时配置，必须改源码再编译。流程：

### 5.1 找到色板文件

```bash
cd ~/deepseek-tui-termux-src-0.8.17-20260508    # 或你的源码目录
nano crates/tui/src/palette.rs                   # 或 vim
```

文件顶部全是 `(R, G, B)` 元组常量，每个对应一个 token。**只改 RGB 值即可**，结构别动。

### 5.2 常用 token 对照（暗色主题在用的几个最显眼的）

| 常量 | 默认值 (RGB / 十六进制) | 视觉作用 |
|---|---|---|
| `DEEPSEEK_BLUE_RGB` | `(53, 120, 229)` `#3578E5` | **主标题、品牌色** |
| `DEEPSEEK_SKY_RGB` | `(106, 174, 242)` | 强调蓝（次级标题） |
| `DEEPSEEK_INK_RGB` | `(11, 21, 38)` `#0B1526` | 面板/侧栏底色 |
| `DEEPSEEK_SLATE_RGB` | `(18, 28, 46)` | 工具卡片底色 |
| `DEEPSEEK_RED_RGB` | `(226, 80, 96)` | 错误、失败状态 |
| `BORDER_COLOR_RGB` | `(42, 74, 127)` `#2A4A7F` | 所有边框 |
| `LIGHT_TEXT_BODY_RGB` | `(15, 23, 42)` | 正文文字（亮主题） |
| `LIGHT_TEXT_MUTED_RGB` | `(71, 85, 105)` | 辅助文字 |

> 还有大量 `LIGHT_*`、`STATUS_*`、`ACCENT_*`、`TEXT_*` 常量，名字基本自解释。打开 `palette.rs` 翻一遍 5 分钟搞定。

### 5.3 改完重编 + 替换

```bash
cd ~/deepseek-tui-termux-src-0.8.17-20260508
cargo build --release --bin deepseek-tui     # 改色只影响 tui 二进制，~2 min 增量
strip target/release/deepseek-tui
install -m 0755 target/release/deepseek-tui $PREFIX/bin/deepseek-tui
deepseek                                      # 看效果
```

### 5.4 实战示例：把品牌蓝改成绿

```rust
// crates/tui/src/palette.rs 第 5 行
pub const DEEPSEEK_BLUE_RGB: (u8, u8, u8) = (53, 180, 100);  // 改成 #35B464 翠绿
```

存盘 → cargo build → install → 启动，所有原本是 DeepSeek 蓝的标题/边框立刻变绿。

### 5.5 想要"亮色主题"

`Theme::dark()` 是写死的；要切亮色把 `crates/tui/src/deepseek_theme.rs:130` 的 `active_theme()` 改成返回一份 `Theme::light()`，并自己实现 `pub const fn light() -> Self { Self { ... } }` （把 `palette::DEEPSEEK_INK` 换成 `palette::LIGHT_SURFACE` 等等）。这是改造，不是配置——超出本说明书范围。

---

## 6. 常用配置（`~/.deepseek/config.toml`）

第一次启动会自动生成。常见字段：

```toml
provider = "deepseek"
model = "auto"             # auto | deepseek-v4-pro | deepseek-v4-flash
reasoning_effort = "auto"  # auto | off | low | medium | high | max

[notifications]
method = "auto"            # auto | osc9 | bel | off ；Termux 终端会响

[ui]
language = "zh-Hans"       # en | zh-Hans | ja | pt-BR
```

改完不需要重启进程，新会话生效。

---

## 7. Termux:API 集成（可选但推荐）

```bash
pkg install termux-api
# 再去 F-Droid 装「Termux:API」APK，否则 termux-* 命令会报错
```

装好后 TUI 会自动走：
- 复制粘贴 → Android 系统剪贴板（不再只能 OSC52）
- OAuth/链接打开 → 调起浏览器（默认浏览器/聊天工具）

不装也能用，只是剪贴板退化为 OSC52、链接需要手抄。

---

## 8. 常见问题

| 现象 | 原因 / 处理 |
|---|---|
| `HTTP 401 ... api key: xxxx is invalid` | key 撤销/过期/复制错。重新签发，再 `deepseek auth set` |
| `Expect rustls-platform-verifier to be initialized` | 你跑的是**旧的二进制**。装最新的（带 webpki-roots 修复） |
| `Permission denied` 执行 build-script | source 在 `/storage/emulated/0/...`。挪到 `$HOME` 下重编 |
| `command not found: deepseek` | `install` 步骤漏了。`ls $PREFIX/bin/deepseek*` 检查 |
| 启动后立即闪退、无报错 | `deepseek doctor` 看完整诊断；常见是 `~/.deepseek/config.toml` 损坏，删掉重新跑会自动重建 |
| 中文输入跳格 / 乱码 | Termux 字体不够宽。装 `pkg install termux-styling`，挑等宽 CJK 字体 |
| 想完全卸载 | `rm $PREFIX/bin/deepseek $PREFIX/bin/deepseek-tui && rm -rf ~/.deepseek` |

---

## 9. 升级到新版本

无自动更新（Bionic 跟官方 glibc 预编译不兼容，已禁用）。手动流程：

```bash
cd ~/你的源码目录
git pull                                         # 或重新解压新 tarball
cargo build --release --bin deepseek --bin deepseek-tui
strip target/release/deepseek*
install -m 0755 target/release/deepseek      $PREFIX/bin/
install -m 0755 target/release/deepseek-tui  $PREFIX/bin/
```

---

## 10. 联系/反馈

- 上游项目：https://github.com/Hmbown/DeepSeek-TUI
- Termux 适配相关问题在仓库 issue 里加 `[termux]` 前缀，并附上：
  ```bash
  uname -a
  echo $PREFIX
  rustc --version
  deepseek --version
  deepseek doctor 2>&1 | head -30
  ```
