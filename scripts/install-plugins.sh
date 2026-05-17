#!/usr/bin/env bash
#
# install-plugins.sh — declaratively enable VibecoSwagaTemplate plugins in
# ~/.claude/settings.json. Plugins install globally (~/.claude/plugins/) and
# auto-update on `claude` startup.
#
# Usage: ./scripts/install-plugins.sh
#
# Requires: jq.
#
# How it works:
#   1. Merges `enabledPlugins` entries into ~/.claude/settings.json
#      (backing up first). Claude Code reads this on startup and
#      auto-fetches missing plugins.
#   2. Prints a one-time list of marketplaces you need to register manually
#      via `/plugin marketplace add <source>` inside `claude` (there is no
#      scriptable CLI for marketplace registration as of this writing).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_FILE="${REPO_ROOT}/.claude-plugins.json"
SETTINGS_FILE="${HOME}/.claude/settings.json"
BACKUP_FILE="${HOME}/.claude/settings.json.bak.$(date +%Y%m%d-%H%M%S)"

# Plugin → marketplace mapping (most are claude-plugins-official; overrides here).
declare -A PLUGIN_MARKETPLACE=(
  ["claude-mem"]="thedotmack"
  ["reflexion"]="context-engineering-kit"
  ["context-mode"]="context-mode"
  ["ui-ux-pro-max"]="claude-code-templates"
)

# Plugins NOT distributed via Claude Code marketplaces (npm CLIs, manual installs).
# Skipped from settings.json patch; user is told how to install separately.
declare -A SKIP_PLUGINS=(
  ["gsd"]="npx get-shit-done-cc --claude --global"
)

# Marketplaces that are NOT pre-registered by default. User must add manually.
# Format: "<marketplace-id>:<source-to-add>"
declare -A MARKETPLACE_SOURCE=(
  ["thedotmack"]="thedotmack/claude-mem"
  ["context-engineering-kit"]="context-engineering-kit/claude-plugins"
  ["context-mode"]="mksglu/context-mode"
  ["claude-code-templates"]="davila7/claude-code-templates"
)

# --- Sanity checks ---

if [[ ! -f "${PLUGINS_FILE}" ]]; then
  echo "error: ${PLUGINS_FILE} not found" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "error: 'jq' not installed. brew install jq" >&2
  exit 1
fi

mkdir -p "${HOME}/.claude"
if [[ ! -f "${SETTINGS_FILE}" ]]; then
  echo "{}" >"${SETTINGS_FILE}"
fi

# --- Build the enabledPlugins patch ---

required_plugins=()
optional_plugins=()
while IFS=$'\t' read -r name required; do
  if [[ "${required}" == "true" ]]; then
    required_plugins+=("${name}")
  else
    optional_plugins+=("${name}")
  fi
done < <(jq -r '.plugins[] | [.name, (.required // false | tostring)] | @tsv' "${PLUGINS_FILE}")

# Build a JSON object of "name@marketplace": true for required plugins.
patch="{}"
for plugin in "${required_plugins[@]}"; do
  if [[ -n "${SKIP_PLUGINS[$plugin]:-}" ]]; then
    continue
  fi
  marketplace="${PLUGIN_MARKETPLACE[$plugin]:-claude-plugins-official}"
  key="${plugin}@${marketplace}"
  patch=$(jq -n --argjson p "${patch}" --arg k "${key}" '$p + {($k): true}')
done

# --- Merge into ~/.claude/settings.json (preserving existing keys) ---

cp "${SETTINGS_FILE}" "${BACKUP_FILE}"
echo "==> Backed up settings to: ${BACKUP_FILE}"

jq --argjson patch "${patch}" \
   '.enabledPlugins = ((.enabledPlugins // {}) + $patch)' \
   "${SETTINGS_FILE}" >"${SETTINGS_FILE}.tmp"
mv "${SETTINGS_FILE}.tmp" "${SETTINGS_FILE}"

echo "==> Enabled in ${SETTINGS_FILE}:"
for plugin in "${required_plugins[@]}"; do
  if [[ -n "${SKIP_PLUGINS[$plugin]:-}" ]]; then
    continue
  fi
  marketplace="${PLUGIN_MARKETPLACE[$plugin]:-claude-plugins-official}"
  echo "    ✓ ${plugin}@${marketplace}"
done

# --- Tell user which marketplaces still need a manual one-time add ---

needed_marketplaces=()
for plugin in "${required_plugins[@]}"; do
  if [[ -n "${SKIP_PLUGINS[$plugin]:-}" ]]; then
    continue
  fi
  marketplace="${PLUGIN_MARKETPLACE[$plugin]:-claude-plugins-official}"
  if [[ -n "${MARKETPLACE_SOURCE[$marketplace]:-}" ]]; then
    # Check if marketplace is already in known_marketplaces.json
    if [[ -f "${HOME}/.claude/known_marketplaces.json" ]] \
       && jq -e --arg m "${marketplace}" 'has($m)' "${HOME}/.claude/known_marketplaces.json" >/dev/null 2>&1; then
      continue
    fi
    needed_marketplaces+=("${marketplace}")
  fi
done

# Dedupe.
if (( ${#needed_marketplaces[@]} > 0 )); then
  echo ""
  echo "==> One-time marketplace registration required."
  echo "    Open \`claude\` and run these commands once:"
  echo ""
  printf '%s\n' "${needed_marketplaces[@]}" | sort -u | while read -r mp; do
    echo "    /plugin marketplace add ${MARKETPLACE_SOURCE[$mp]}"
  done
fi

# --- Optional plugins (printed, not installed) ---

if (( ${#optional_plugins[@]} > 0 )); then
  echo ""
  echo "==> Optional plugins (skipped; enable manually if you want them):"
  for plugin in "${optional_plugins[@]}"; do
    marketplace="${PLUGIN_MARKETPLACE[$plugin]:-claude-plugins-official}"
    echo "    /plugin install ${plugin}@${marketplace}"
  done
fi

# --- Skipped plugins (npm CLIs, etc.) ---

if (( ${#SKIP_PLUGINS[@]} > 0 )); then
  echo ""
  echo "==> Install separately (not Claude Code marketplace plugins):"
  for plugin in "${!SKIP_PLUGINS[@]}"; do
    echo "    • ${plugin}: ${SKIP_PLUGINS[$plugin]}"
  done
fi

echo ""
echo "==> Done. Now run \`claude\` once — it will auto-fetch enabled plugins."
echo "    Restore the previous settings with: mv ${BACKUP_FILE} ${SETTINGS_FILE}"
