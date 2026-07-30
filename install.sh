#!/usr/bin/env bash
# Installs the Claude Quota SwiftBar plugin.
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
    echo "macOS only." >&2
    exit 1
fi

if [ ! -d "/Applications/SwiftBar.app" ]; then
    if ! command -v brew >/dev/null; then
        echo "Homebrew is required to install SwiftBar: https://brew.sh" >&2
        exit 1
    fi
    echo "Installing SwiftBar..."
    brew install --cask swiftbar
fi

PLUGIN_DIR=$(defaults read com.ameba.SwiftBar PluginDirectory 2>/dev/null || true)
if [ -z "$PLUGIN_DIR" ]; then
    PLUGIN_DIR="$HOME/.swiftbar"
    defaults write com.ameba.SwiftBar PluginDirectory -string "$PLUGIN_DIR"
fi
mkdir -p "$PLUGIN_DIR"

# Copy the plugin from a local checkout, or download it when piped (curl | bash)
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || true)
if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/claude-quota.5m.py" ]; then
    cp "$SCRIPT_DIR/claude-quota.5m.py" "$PLUGIN_DIR/"
else
    curl -fsSL \
        "https://raw.githubusercontent.com/grzegorz-raczek-unit8/claude-quota/main/claude-quota.5m.py" \
        -o "$PLUGIN_DIR/claude-quota.5m.py"
fi
chmod +x "$PLUGIN_DIR/claude-quota.5m.py"

# Run the plugin once now, so the Keychain permission dialog (if any)
# appears here in the terminal session rather than surprising the user
# after install. Reads and the token-refresh write both go through
# /usr/bin/security, so one "Always Allow" covers both.
echo
echo "Running the plugin once to warm up Keychain access."
echo "If a Keychain dialog appears, click 'Always Allow'."
"$PLUGIN_DIR/claude-quota.5m.py" >/dev/null || true

open -a SwiftBar

# Launch SwiftBar at login so the gauges survive a reboot
if ! osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null | grep -q "SwiftBar"; then
    osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/SwiftBar.app", hidden:false}' >/dev/null 2>&1 \
        || echo "Could not add SwiftBar to Login Items — enable 'Launch at Login' in SwiftBar's preferences instead." >&2
fi

echo
echo "Installed to $PLUGIN_DIR/claude-quota.5m.py"
