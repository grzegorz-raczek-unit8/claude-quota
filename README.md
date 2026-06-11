# claude-quota

Menu bar gauges for your Claude Code quota — one bar per account, like this:

![menu bar screenshot](docs/menubar.png)

*(dark menu bar shown — outlines, labels and the mascot follow the menu bar
appearance, so light mode gets black-on-light)*

- Each bar shows the **5-hour-window utilization** for one account, colored
  green / orange (≥70%) / red (≥90%).
- When the 5-hour window is fully used, the bar shows a **countdown until
  reset** (`4:28`) instead of the percentage.
- When the **weekly limit** is hit, the bar turns **black** with a countdown
  to the weekly reset (`2D`) — that's the harder cap, whatever the 5-hour
  window says.
- The dropdown lists full detail for every account inline: 5-hour and weekly
  windows, per-model windows where your plan reports them, extra-usage
  credits, and reset times.
- Refreshes every 5 minutes (SwiftBar filename convention) plus a manual
  "Refresh now" entry.

## Quick install

```sh
curl -fsSL https://raw.githubusercontent.com/grzegorz-raczek-unit8/claude-quota/main/install.sh | bash
```

Requires macOS and [Homebrew](https://brew.sh). When macOS shows a Keychain
permission dialog on the first refresh, click **Always Allow**.

## How it works

The plugin reads your Claude Code OAuth token from the macOS Keychain
(**read-only** — it never refreshes or rewrites tokens, so it can't log you
out) and queries the same usage endpoint that Claude Code's `/usage` screen
uses. No passwords, no scraping, no third-party services.

> **Note:** that endpoint is internal to Claude Code and undocumented, so a
> future Claude Code change may require a small fix here.

## Install from a checkout

```sh
git clone https://github.com/grzegorz-raczek-unit8/claude-quota.git
cd claude-quota
./install.sh
```

Either install path sets up [SwiftBar](https://github.com/swiftbar/SwiftBar)
via Homebrew if you don't have it, and adds it to your Login Items so the
gauges come back after a reboot. If an account shows ⚠, its token went
stale from disuse — run that `claude` CLI once and the widget recovers on the
next cycle.

## Accounts

By default the plugin auto-discovers accounts: every `~/.claude` /
`~/.claude-*` config directory that has a Claude Code Keychain entry gets a
bar, labeled by the directory suffix (`~/.claude-work` → `W`). A single
auto-discovered account shows no letter label — just the bar.

To pin or rename accounts (e.g. you use multiple `CLAUDE_CONFIG_DIR`s), create
`~/.config/claude-quota/accounts` with one `path [label]` per line
(single-word labels):

```
~/.claude-work Work
~/.claude-priv Priv
```

To hide an account's menu bar gauge (its dropdown detail stays), use
**Hide from menu bar** under that account's row in the dropdown — or edit
`~/.config/claude-quota/hidden` (one label per line).

Multiple accounts via `CLAUDE_CONFIG_DIR` look like this in your shell rc:

```sh
claude()      { CLAUDE_CONFIG_DIR="$HOME/.claude-work" command claude "$@"; }
claude-priv() { CLAUDE_CONFIG_DIR="$HOME/.claude-priv" command claude "$@"; }
```

## Uninstall

Delete `claude-quota.5m.py` from your SwiftBar plugin folder
(`~/.swiftbar` by default). If you no longer use SwiftBar, also remove it
from System Settings → General → Login Items.
