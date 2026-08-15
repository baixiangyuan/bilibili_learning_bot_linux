#!/usr/bin/env bash
#
# termux_install.sh —— 在 Termux (Android) 上一键安装并运行 bilibili_learning_bot
#
# 用法（在 bilibili_learning_bot 项目根目录执行）：
#   bash termux_install.sh
#
# 流程：检测环境 → 询问是否安装（必须输入「我同意」才继续）→
#       安装系统依赖 → 创建虚拟环境 → pip 安装 requirements.txt → 提示运行方式
#
# 说明：Termux 上以「无头模式」运行最稳（--serve 只起 Web 面板，不依赖桌面托盘/gi）。
#       桌面托盘所需的 pystray/gi 在 Termux 上通常不可用，因此默认不装、不构建 GUI。
#
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

# ───────── 1. 检测环境 ─────────
echo "==> 检测运行环境"
IS_TERMUX=0
if [ -n "${TERMUX_VERSION:-}" ] || [[ "${PREFIX:-}" == *com.termux* ]]; then
  IS_TERMUX=1
fi

echo "  环境:        $([ "$IS_TERMUX" -eq 1 ] && echo "Termux (${TERMUX_VERSION:-})" || echo "非 Termux ($(uname -s))")"
echo "  架构:        $(uname -m)"
if command -v python3 >/dev/null 2>&1; then
  echo "  Python:      $(python3 --version 2>&1)"
else
  echo "  Python:      未安装"
fi
if [ -f requirements.txt ]; then
  echo "  项目:        requirements.txt 存在 ✔"
else
  echo "  项目:        ⚠ 当前目录未找到 requirements.txt，请 cd 到项目根目录再运行"
fi

if [ "$IS_TERMUX" -ne 1 ]; then
  echo ""
  echo "⚠️  当前不是 Termux 环境。本脚本按 Termux 的 pkg 包管理器编写；"
  echo "    在其它 Linux 发行版上请改用 build_linux.sh。"
fi

# ───────── 2. 询问是否安装（必须输入「我同意」）─────────
echo ""
echo "────────────────────────────────────────────────────"
echo "  是否安装 bilibili_learning_bot 运行环境？"
echo "  将执行：更新包索引、安装 python/ffmpeg/patchelf、"
echo "  创建虚拟环境并 pip 安装 requirements.txt，"
echo "  完成后提示如何以无头模式启动 Web 面板。"
echo "────────────────────────────────────────────────────"
printf "请输入「我同意」以继续（其他任意输入将取消）："
read -r CONFIRM
if [ "${CONFIRM:-}" != "我同意" ]; then
  echo "未输入「我同意」，已取消安装。"
  exit 0
fi

# ───────── 3. 安装 ─────────
# Termux 用 pkg；非 Termux 退化到 apt-get（便于在其它 Debian 系上复用同一脚本）
if [ "$IS_TERMUX" -eq 1 ]; then
  PKG="pkg"
else
  PKG="sudo apt-get"
fi

echo "==> 更新包索引"
$PKG update || echo "⚠️  包索引更新返回非零，继续尝试安装..."

install_pkgs() {
  local attempt
  for attempt in 1 2 3; do
    if $PKG install -y "$@"; then
      return 0
    fi
    echo "⚠️  安装第 $attempt 次失败（可能是镜像临时抽风），3 秒后重试..." >&2
    sleep 3
  done
  echo "❌ 安装多次失败，请检查网络后手动执行： $PKG install -y $*" >&2
  return 1
}

echo "==> 安装系统依赖"
if [ "$IS_TERMUX" -eq 1 ]; then
  install_pkgs python ffmpeg patchelf build-essential
else
  install_pkgs python3 python3-venv python3-pip ffmpeg patchelf build-essential
fi

echo "==> 创建虚拟环境"
VENV_DIR=".build-venv"
if [ -d "$VENV_DIR" ]; then
  echo "    已存在 $VENV_DIR，跳过创建。"
else
  python3 -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "==> 安装 Python 依赖"
pip install -U pip wheel setuptools
pip install -r requirements.txt

echo ""
echo "──────────────────────── 安装完成 ────────────────────────"
echo "  启动无头 Web 面板（默认 http://127.0.0.1:18083）："
echo "      source $VENV_DIR/bin/activate"
echo "      python desktop_app.py --serve"
echo ""
echo "  可选：想打包成可执行文件（实验性，Termux 上可能需排错）："
echo "      pip install pyinstaller"
echo "      pyinstaller --noconfirm --clean BiliLearn.spec"
echo "──────────────────────────────────────────────────────────"
