#!/usr/bin/env bash
# Shared helpers for toolkit scripts. Source this at the top of each script.

set -euo pipefail

# Colours (disabled when stdout is not a terminal).
if [[ -t 1 ]]; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'; C_BLU=$'\033[34m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_RST=""
fi

log()  { printf '%s[*]%s %s\n' "$C_BLU" "$C_RST" "$*" >&2; }
ok()   { printf '%s[+]%s %s\n' "$C_GRN" "$C_RST" "$*" >&2; }
warn() { printf '%s[!]%s %s\n' "$C_YEL" "$C_RST" "$*" >&2; }
err()  { printf '%s[-]%s %s\n' "$C_RED" "$C_RST" "$*" >&2; }
die()  { err "$*"; exit 1; }

# Fail early if a required tool is missing.
need() { command -v "$1" >/dev/null 2>&1 || die "required tool not found: $1"; }

# Create and print a per-run output directory: ${OUT_DIR:-./out}/<target>-<ts>.
make_outdir() {
  local target="${1:-scan}" safe ts base
  safe="$(printf '%s' "$target" | tr -c 'a-zA-Z0-9.-' '_')"
  ts="$(date -u +%Y%m%dT%H%M%SZ)"
  base="${OUT_DIR:-./out}/${safe}-${ts}"
  mkdir -p "$base"
  printf '%s\n' "$base"
}

# Gate every script behind an explicit authorisation acknowledgement.
require_scope_ack() {
  if [[ "${I_HAVE_AUTHORISATION:-}" != "yes" ]]; then
    warn "Only run this against systems you are authorised to test."
    warn "Set I_HAVE_AUTHORISATION=yes to confirm scope and continue."
    exit 2
  fi
}
