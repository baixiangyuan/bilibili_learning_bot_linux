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
  # Termux：python-docx 依赖 lxml，需 libxml2/libxslt 头文件（Termux 包内含头部）
  install_pkgs python ffmpeg patchelf build-essential pkg-config libxml2 libxslt
  # Termux 以预编译 .deb 形式提供 Python 原生包（含 pydantic-core / Pillow / lxml / cryptography /
  # aiohttp 等 Rust·C 扩展），可直接复用，避免 pip 在 Android 上从源码编译
  # （PyPI 没有 Android 平台的预编译 wheel，会退回源码构建并索要 Rust 工具链）。
  echo "==> 安装 Termux 预编译 Python 原生包"
  for p in python-pillow python-lxml python-cryptography python-pydantic python-cffi \
           python-aiohttp python-yarl python-multidict python-frozenlist python-aiosignal \
           python-async-timeout python-attrs python-reportlab python-bcrypt; do
    $PKG install -y "$p" 2>/dev/null || \
      echo "⚠️  预编译包 $p 不可用，将回退到 pip 源码编译（可能需要 rust 工具链）"
  done
else
  # lxml（python-docx 间接依赖）编译需要 libxml2-dev / libxslt1-dev
  install_pkgs python3 python3-venv python3-pip ffmpeg patchelf build-essential pkg-config libxml2-dev libxslt1-dev
fi

echo "==> 创建虚拟环境"
VENV_DIR=".build-venv"
if [ -d "$VENV_DIR" ]; then
  echo "    已存在 $VENV_DIR，跳过创建。"
  if [ "$IS_TERMUX" -eq 1 ]; then
    if ! grep -q "include-system-site-packages = true" "$VENV_DIR/pyvenv.cfg" 2>/dev/null; then
      echo "    ⚠️  Termux 下需继承系统预编译包，但现有 venv 未开启 system-site-packages。"
      echo "       请先执行： rm -rf $VENV_DIR  再重新运行本脚本。"
    fi
  fi
else
  if [ "$IS_TERMUX" -eq 1 ]; then
    # 关键：Termux 的预编译原生包装在系统 site-packages，必须继承才能被复用，
    # 否则 pip 仍会去 PyPI 拉 manylinux wheel 并触发源码编译。
    python3 -m venv --system-site-packages "$VENV_DIR"
  else
    python3 -m venv "$VENV_DIR"
  fi
fi
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

echo "==> 安装 Python 依赖"
pip install -U pip wheel setuptools

if [ "$IS_TERMUX" -eq 1 ]; then
  # Termux：去掉版本锁，优先复用上面装好的预编译包（它们的版本已满足 >= 约束），
  # 避免 pip 去拉 manylinux-only 的精确版本而触发源码编译。
  REQ_RELAXED="$APP_DIR/.requirements-termux.txt"
  grep -vE '^\s*#|^\s*$' requirements.txt | sed -E 's/(==|>=|<=|~=|!=)[^[:space:]]*//' > "$REQ_RELAXED"
  echo "    已生成放宽版本约束的清单： $REQ_RELAXED"
  pip install -r "$REQ_RELAXED"
else
  pip install -r requirements.txt
fi

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
