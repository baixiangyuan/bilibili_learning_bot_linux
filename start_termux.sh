#!/usr/bin/env bash
#
# start_termux.sh —— 在 Termux (Android) 上启动 bilibili_learning_bot 的 Web 面板
#
# 用法（项目根目录）：
#   bash start_termux.sh            # 用默认端口 18083 启动
#   WEB_PORT=8080 bash start_termux.sh   # 指定端口
#
# 说明：Termux 无桌面环境，只以 --serve 无头模式拉起 Web 面板。
#   面板地址： http://127.0.0.1:18083  （手机本地浏览器打开；同 Wi-Fi 下其他设备访问用手机局域网 IP）
#   停止： 在终端按 Ctrl+C
#
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$APP_DIR"

VENV_DIR=".build-venv"
if [ ! -d "$VENV_DIR" ]; then
  echo "⚠️  未找到虚拟环境 $VENV_DIR，请先运行一次安装脚本："
  echo "      bash termux_install.sh"
  exit 1
fi

# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

PORT="${WEB_PORT:-18083}"
echo "==> 启动 Web 面板（无头 --serve），端口 $PORT"
echo "    本机浏览器打开： http://127.0.0.1:$PORT"
echo "    停止： Ctrl+C"
echo ""

exec python desktop_app.py --serve
