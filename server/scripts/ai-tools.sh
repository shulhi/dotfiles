#!/usr/bin/env bash
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"
install_ai_tools() {
  if [[ ${SKIP_CLAUDE:-0} != 1 ]]; then
    log 'Installing Claude Code CLI'
    if ! have claude; then
      download https://claude.ai/install.sh "$TMP_WORK/claude-install.sh"
      bash "$TMP_WORK/claude-install.sh"
    fi
    claude --version
  fi
  if [[ ${SKIP_CODEX:-0} != 1 ]]; then
    log 'Installing OpenAI Codex CLI'
    if ! have codex; then
      download https://chatgpt.com/codex/install.sh "$TMP_WORK/codex-install.sh"
      CODEX_NON_INTERACTIVE=1 CODEX_INSTALL_DIR="$LOCAL_BIN" sh "$TMP_WORK/codex-install.sh"
    fi
    codex --version
  fi
}
install_ai_tools
