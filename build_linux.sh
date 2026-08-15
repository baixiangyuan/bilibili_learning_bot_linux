#!/usr/bin/env bash
#
# build_linux.sh —— 在 Kali / Debian / Ubuntu 上把 bilibili_learning_bot 打包成 Linux 可执行文件
#
# 用法（在项目根目录执行）：
#   chmod +x build_linux.sh
#   ./build_linux.sh
#
# 产物： ./dist/BiliLearn Web/BiliLearn Web   （ELF 可执行文件 + _internal 依赖目录）
#
# 运行：
#   桌面模式（有显示器）：   ./dist/BiliLearn\ Web/BiliLearn\ Web
#   无头服务模式（服务器）：  ./dist/BiliLearn\ Web/BiliLearn\ Web --serve
#
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

# root 直接执行，否则走 sudo
if command -v sudo >/dev/null 2>&1 && [ "$(id -u)" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "==> 工作目录: $APP_DIR"
python3 --version

echo "==> 安装系统依赖"
# 检测并提示已知的坏源（docker-ce 镜像指向 kali-rolling 会 404）
if grep -rIl "docker" /etc/apt/sources.list.d/ /etc/apt/sources.list 2>/dev/null \
   | xargs grep -Il "kali-rolling" 2>/dev/null | head -1 | grep -q .; then
    echo "⚠️  检测到 docker 相关源指向 kali-rolling（无效发行版），会导致 apt update 报错。"
    echo "    本项目依赖全部来自 kali-rolling，已正常获取，可忽略；"
    echo "    根治：把该源里的 kali-rolling 改成 bookworm，或删掉对应 .list 后 sudo apt-get update。"
fi
echo "    更新 apt 索引（第三方源报错可忽略，不影响本项目依赖）"
$SUDO apt-get update || {
    echo "⚠️  apt-get update 返回非零：通常是无关的第三方源（如 docker-ce 镜像）配置错误。"
    echo "    本项目依赖（python3-venv / pystray 后端 / ffmpeg 等）来自 kali-rolling 已正常获取，继续安装。"
}
$SUDO apt-get install -y \
    python3-venv python3-pip python3-dev build-essential patchelf \
    python3-gi gir1.2-gtk-3.0 libgirepository1.0-dev \
    libnotify-bin libgtk-3-0 libcurl4 ffmpeg
# AppIndicator 后端（Debian/Kali 可能已移除该包，缺失时 pystray 自动回退到 Gtk 状态图标）
$SUDO apt-get install -y gir1.2-appindicator3-0.1 2>/dev/null || \
    echo "⚠️  未安装 gir1.2-appindicator3-0.1（Debian/Kali 可能已移除），托盘将使用 Gtk 状态图标后端，功能不受影响。"

echo "==> 创建虚拟环境（--system-site-packages 以便收集 pystray 的 gi 后端）"
python3 -m venv --system-site-packages .build-venv
# shellcheck disable=SC1091
source .build-venv/bin/activate

echo "==> 升级 pip 并安装 Python 依赖"
pip install -U pip wheel setuptools
pip install pyinstaller
pip install -r requirements.txt

echo "==> 运行 PyInstaller 构建"
pyinstaller --noconfirm --clean BiliLearn.spec

echo "==> 完成，产物："
ls -lh "$APP_DIR/dist/BiliLearn Web/BiliLearn Web" 2>/dev/null || true

cat <<'NOTE'

──────────────────────── 运行说明 ────────────────────────
  • 桌面模式（有显示器）：  ./dist/BiliLearn\ Web/BiliLearn\ Web
      首次会拉起网页面板并放入系统托盘；有新版时弹原生提醒。
  • 无头模式（服务器/无桌面）： ./dist/BiliLearn\ Web/BiliLearn\ Web --serve
      只起 Web 面板（默认 http://127.0.0.1:18083），不创建托盘，适合后台运行。
      代码已自适应：检测到无 DISPLAY / WAYLAND_DISPLAY 会自动进入无头模式。

运行机依赖（仅桌面托盘模式需要）
  $SUDO apt-get install -y python3-gi gir1.2-gtk-3.0 libnotify-bin
  （AppIndicator 后端可选：gir1.2-appindicator3-0.1；缺失时自动回退 Gtk 状态图标）
  （无头 --serve 模式不依赖这些，纯服务器也能跑）

排错
  • 托盘启动失败：确认装了 gir1.2-appindicator3-1；或改用 --serve 无头模式。
  • 想看 Flask 日志：用终端运行即可；或把 BiliLearn.spec 里 EXE 的 console 改为
    True 后重新执行本脚本。
  • 新版本提醒弹窗依赖 zenity / notify-send；两者都没有时会在终端打印提醒。
──────────────────────────────────────────────────────────
NOTE
