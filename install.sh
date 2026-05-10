#!/usr/bin/env bash
set -euo pipefail

# ── DeepSeek TUI Termux 一键安装脚本 ──
# 放在同目录下：deepseek-tui-termux-bin-*.tar.gz

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
step() { echo -e "\n${BOLD}${CYAN}════ [$1/$2] $3 ════${NC}"; }
info() { echo -e "  ${CYAN}→${NC} $*"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
warn() { echo -e "  ${YELLOW}⚠${NC} $*"; }

TOTAL=5
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_TARBALL=$(ls "$SCRIPT_DIR"/deepseek-tui-termux-bin-*.tar.gz 2>/dev/null | head -1)

clear
cat << "EOF"
╔══════════════════════════════════════════════╗
║   DeepSeek TUI · Termux 一键安装             ║
║                                              ║
║   装好之后你会有：                            ║
║   · Termux 基础环境                          ║
║   · Zsh + Oh-My-Zsh + agnoster 主题          ║
║   · DeepSeek TUI（预编译，1 分钟）           ║
╚══════════════════════════════════════════════╝
EOF
echo

if [ ! -d /data/data/com.termux ]; then
    echo -e "  ${RED}✗${NC} 这不是 Termux 环境，脚本专为 Termux 设计"
    exit 1
fi

if [ -z "$BIN_TARBALL" ]; then
    echo -e "  ${RED}✗${NC} 没找到 deepseek-tui-termux-bin-*.tar.gz"
    echo -e "    把它放到 $SCRIPT_DIR 目录下再跑"
    exit 1
fi

echo -e "  ${YELLOW}?${NC} 开始安装？大概 5-10 分钟"
echo -en "  [Y/n] "; read -r ans
case "$ans" in n|N|no|NO) exit 0;; esac

# ── 1. Termux 基础 ──
step 1 $TOTAL "Termux 基础环境"
pkg update -y 2>&1 | tail -1
pkg install -y curl git openssh python3 2>&1 | tail -1
ok "基础包安装完成"

# ── 2. 存储权限 ──
step 2 $TOTAL "存储权限"
if [ ! -d "$HOME/storage/shared" ]; then
    echo "  termux-setup-storage 会弹系统权限窗口，点「允许」"
    termux-setup-storage 2>/dev/null || true
    echo -n "  按回车继续..."; read -r
fi
[ -d "$HOME/storage/shared" ] && ok "权限 OK" || warn "权限未确认，不影响使用"

# ── 3. Zsh ──
step 3 $TOTAL "Zsh + Oh-My-Zsh + agnoster 主题"
if ! command -v zsh &>/dev/null; then
    pkg install -y zsh 2>&1 | tail -1
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1 | tail -1
fi
if ! grep -q 'ZSH_THEME="agnoster"' "$HOME/.zshrc" 2>/dev/null; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$HOME/.zshrc" 2>/dev/null || cat > "$HOME/.zshrc" << 'Z'
export ZSH="$HOME/.oh-my-zsh"; ZSH_THEME="agnoster"; plugins=(git gitfast history)
source $ZSH/oh-my-zsh.sh
Z
fi
if [ "$SHELL" != "$(command -v zsh)" ]; then
    chsh -s zsh 2>/dev/null || echo -e 'export SHELL=$(command -v zsh)\nexec $(command -v zsh) -l' >> "$HOME/.profile"
    warn "重启 Termux 或执行 exec zsh -l 切换到 zsh"
fi
ok "zsh 配置完成"

# ── 4. DeepSeek TUI ──
step 4 $TOTAL "DeepSeek TUI（预编译二进制）"

if command -v deepseek &>/dev/null; then
    ok "deepseek 已安装: $(deepseek --version 2>/dev/null)"
else
    TMPDIR=$(mktemp -d)
    tar xzf "$BIN_TARBALL" -C "$TMPDIR"
    EXTRACTED=$(ls -d "$TMPDIR"/deepseek-tui-termux-bin-* 2>/dev/null | head -1)
    install -m 0755 "$EXTRACTED/bin/deepseek"     "$PREFIX/bin/deepseek"
    install -m 0755 "$EXTRACTED/bin/deepseek-tui" "$PREFIX/bin/deepseek-tui"
    rm -rf "$TMPDIR"
    ok "DeepSeek TUI 安装完成: $(deepseek --version 2>/dev/null)"
fi

# ── 5. API Key ──
step 5 $TOTAL "配置 API Key"

if deepseek auth status &>/dev/null 2>&1; then
    ok "API Key 已配置"
else
    echo ""
    echo "  去 https://platform.deepseek.com 注册 → 创建 API Key"
    echo -n "  粘贴你的 API Key 回车: "
    read -r api_key
    if [ -n "$api_key" ]; then
        mkdir -p "$HOME/.deepseek"
        cat > "$HOME/.deepseek/config.toml" << CFG
api_key = "$api_key"
default_text_model = "deepseek-v3"
provider = "deepseek"
auth_mode = "api_key"

[projects."$HOME"]
trust_level = "trusted"
CFG
        ok "API Key 已保存"
    else
        warn "未输入，稍后手动配置：deepseek auth set --provider deepseek"
    fi
fi

# ── 完成 ──
echo
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║         装好了！                     ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo "  启动：deepseek"
echo ""
echo "  说明书：cat $SCRIPT_DIR/USAGE-zh.md"
echo ""
if [ "$SHELL" != "$(command -v zsh)" ]; then
    echo "  切换到 zsh（或重启 Termux）：exec zsh -l"
fi
echo "" 
