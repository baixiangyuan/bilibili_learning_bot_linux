"""启动期更新检查（共享模块，跨平台）。

查询项目的更新服务器 gengxin.bxya.app/v{当前版本}，判断是否存在更新的已发布版本。
逻辑与 web_panel.py 的 /api/check-update 保持一致，供桌面启动器（原生弹窗）复用。
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
import threading
import urllib.request
from pathlib import Path

UPDATE_BASE = "https://gengxin.bxya.app"
REPOSITORY_URL = "https://github.com/xiaoyaya191/bilibili_learning_bot/releases"


def _has_desktop() -> bool:
    """检测当前是否有可用的桌面环境（决定是否弹原生窗 / 启动系统托盘）。"""
    if sys.platform == "win32":
        return True
    # Linux / macOS：存在 DISPLAY 或 WAYLAND_DISPLAY 才算有桌面
    return bool(os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"))


def _platform_popup(message, title="BiliLearn", kind="info") -> None:
    """跨平台原生弹窗。

    Windows 用 MessageBoxW；Linux / 其他平台依次尝试 zenity 弹窗、
    notify-send 桌面通知、tkinter 兜底，全部不可用则打印到控制台。
    """
    message = str(message)
    title = str(title)
    if sys.platform == "win32":
        try:
            import ctypes

            flags = 0x10 if kind == "error" else 0x40
            ctypes.windll.user32.MessageBoxW(None, message, title, flags)
            return
        except Exception:
            return
    # Linux / 其他：优先 zenity 弹窗（带换行）
    try:
        zenity = shutil.which("zenity")
        if zenity:
            subprocess.run(
                [zenity, "--" + ("error" if kind == "error" else "info"),
                 "--title", title, "--text", message, "--no-wrap"],
                timeout=15, check=False,
            )
            return
    except Exception:
        pass
    # notify-send 桌面通知
    try:
        ns = shutil.which("notify-send")
        if ns:
            urgency = "critical" if kind == "error" else "normal"
            subprocess.run([ns, "--urgency=" + urgency, title, message],
                           timeout=15, check=False)
            return
    except Exception:
        pass
    # tkinter 兜底（无桌面环境包时可能失败，忽略）
    try:
        import tkinter as tk
        from tkinter import messagebox

        root = tk.Tk()
        root.withdraw()
        if kind == "error":
            messagebox.showerror(title, message)
        else:
            messagebox.showinfo(title, message)
        root.destroy()
        return
    except Exception:
        pass
    # 实在没有 GUI，打印到控制台
    print(f"[{title}] {message}", file=sys.stderr)


def _resource_dir() -> Path:
    """项目根目录：frozen 时为 _MEIPASS，否则为 utils 的上一级。"""
    if getattr(sys, "frozen", False):
        return Path(getattr(sys, "_MEIPASS", Path(sys.executable).resolve().parent))
    return Path(__file__).resolve().parent.parent


def _data_dir() -> Path:
    """与 core.user_data.DATA_DIR 一致的跳过记录存放位置（跨平台统一）。"""
    from core.user_data import DATA_DIR

    return DATA_DIR


def get_local_version() -> str:
    verf = _resource_dir() / "VERSION"
    if verf.exists():
        return verf.read_text(encoding="utf-8", errors="replace").strip()
    return ""


def _skipped_version() -> str:
    try:
        f = _data_dir() / "skipped_version.json"
        if f.exists():
            d = json.loads(f.read_text(encoding="utf-8", errors="replace"))
            return str(d.get("version") or "").strip()
    except Exception:
        pass
    return ""


def _vnum(s: str) -> tuple:
    nums = re.findall(r"\d+", s)
    t = tuple(int(x) for x in nums[:3])
    return t + (0,) * (3 - len(t))


def check_for_update(timeout: int = 12) -> dict:
    """检查一次更新，返回状态字典。

    返回的键：ok, current_version, latest_version, update_available,
    skipped_version, release_name, release_body, release_url, message, error
    """
    current = get_local_version() or "3.1.3"
    ver = current if current.lower().startswith("v") else "v" + current
    url = f"{UPDATE_BASE}/{ver}"
    result = {
        "ok": True,
        "current_version": ver,
        "latest_version": "",
        "update_available": False,
        "skipped_version": _skipped_version(),
        "release_name": "",
        "release_body": "",
        "release_url": REPOSITORY_URL,
        "message": "当前已是最新版本",
        "error": "",
    }
    try:
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "BiliLearn/" + ver, "Accept": "application/json"},
        )
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = json.loads(resp.read().decode("utf-8", "replace"))
    except Exception as e:  # 网络异常：静默失败，不打扰用户
        result["error"] = "检查更新失败: " + str(e)
        result["message"] = "网络异常，无法连接更新服务器"
        return result

    latest = str(data.get("latest_version", "") or "")
    result["latest_version"] = latest
    result["release_name"] = str(data.get("release_name", "") or "")
    result["release_body"] = str(data.get("release_body", "") or "")
    result["release_url"] = str(data.get("release_url", "") or REPOSITORY_URL)

    have_update = bool(latest) and _vnum(latest) > _vnum(current)
    skipped = result["skipped_version"]
    # 该版本被用户跳过则不再提示（仍回传状态，便于前端判断）
    if have_update and skipped and _vnum(skipped) >= _vnum(latest):
        have_update = False
    result["update_available"] = have_update
    result["message"] = "发现新版本 " + latest if have_update else "当前已是最新版本"
    return result


def notify_update_popup() -> None:
    """后台线程入口：检查一次更新，有新版本则按平台弹原生窗提醒（无桌面则打印到控制台）。"""
    try:
        info = check_for_update()
    except Exception:
        return
    if not info.get("update_available"):
        return
    try:
        latest = info.get("latest_version", "")
        current = info.get("current_version", "")
        url = info.get("release_url") or REPOSITORY_URL
        body = (info.get("release_body") or "").strip().replace("\r", "")
        if len(body) > 600:
            body = body[:600] + "…"
        msg = (
            f"发现新版本 {latest}（当前 {current}）\n\n"
            + (body + "\n\n" if body else "")
            + f"下载 / 查看更新：\n{url}"
        )
        if _has_desktop():
            _platform_popup(msg, "BiliLearn 更新提醒", kind="info")
        else:
            print("【BiliLearn 更新提醒】" + msg, file=sys.stderr)
    except Exception:
        pass


def start_update_check() -> None:
    """启动一次后台更新检查（不阻塞调用方）。"""
    t = threading.Thread(target=notify_update_popup, daemon=True)
    t.start()


if __name__ == "__main__":
    import pprint

    pprint.pprint(check_for_update())
