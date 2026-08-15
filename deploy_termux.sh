#!/data/data/com.termux/files/usr/bin/bash
# BiliLearn Termux installer. Run with: bash deploy_termux.sh
set -eu

say() { printf '\n[BiliLearn] %s\n' "$*"; }
fail() { printf '\n[BiliLearn] ERROR: %s\n' "$*" >&2; exit 1; }

# The deployment artifact is a bootstrapper. It never assumes the sender's
# Windows checkout exists on the Android device.
REPO_URL="${BILILEARN_REPO_URL:-https://github.com/xiaoyaya191/bilibili_learning_bot.git}"
INSTALL_DIR="${BILILEARN_INSTALL_DIR:-$HOME/bililearn}"
BRANCH="${BILILEARN_BRANCH:-main}"

case "$(uname -o 2>/dev/null || true)" in
  Android*) ;;
  *) fail "This installer is for Termux on Android. Use start.sh on Linux/macOS." ;;
esac

say "Step 1/5: checking Termux environment"
command -v pkg >/dev/null 2>&1 || fail "Termux pkg was not found. Install the official Termux app first."
if ! command -v python >/dev/null 2>&1; then
  say "Python is missing and will be installed during deployment."
fi

printf 'Environment check passed. Deploy BiliLearn now? [y/N] '
read -r deploy
case "$deploy" in y|Y|yes|YES) ;; *) say "Deployment cancelled. Nothing was changed."; exit 0;; esac

cat <<'NOTICE'

This project operates a Bilibili account and may send messages or comments when
you enable those features. It is for learning and personal use. You are
responsible for account actions and platform rules.
NOTICE
printf 'Type 我同意 to continue: '
read -r consent
CONSENT_TEXT='我同意'
[ "$consent" = "$CONSENT_TEXT" ] || fail "Consent did not match. Installation was not started."

say "Step 2/5: installing required Termux packages"
pkg update -y
pkg install -y python git ffmpeg libjpeg-turbo

say "Step 3/5: pulling source from GitHub"
if [ -d "$INSTALL_DIR/.git" ]; then
  git -C "$INSTALL_DIR" fetch origin "$BRANCH"
  git -C "$INSTALL_DIR" checkout "$BRANCH"
  git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
elif [ -e "$INSTALL_DIR" ]; then
  fail "Install directory exists but is not a Git checkout: $INSTALL_DIR"
else
  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi
ROOT="$INSTALL_DIR"
cd "$ROOT"

say "Step 4/5: preparing Python environment"
python -m pip install --upgrade pip wheel setuptools
# The main requirements are intentionally retained. Optional desktop-only
# modules may fail on Android without blocking the web panel and basic flows.
python -m pip install -r requirements.txt || say "Some optional packages were skipped on Termux. Check requirements.txt if a feature reports a missing dependency."

say "Step 5/5: starting the local web panel"
export BILI_DISCLAIMER_SKIP=1
export BILI_WEB_AUTO_OPEN=0
export BILI_TRAY_DISABLED=1
export WEB_HOST=127.0.0.1
python web_panel.py
