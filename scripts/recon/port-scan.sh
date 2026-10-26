#!/usr/bin/env bash
# Port scan wrapper around nmap with sane defaults.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: port-scan.sh <target> [extra nmap args...]

Runs an nmap service/version scan against <target>. Defaults to the top 1000
TCP ports with service and default-script detection; pass extra nmap args to
override (e.g. -p- for all ports).

Examples:
  port-scan.sh example.com
  port-scan.sh 198.51.100.0/24 -p- --min-rate 2000

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -ge 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
target="$1"; shift
require_scope_ack
need nmap

outdir="$(make_outdir "$target")"
log "nmap scan of $target -> $outdir"

# -sV service/version detection, -sC default scripts, -oA all output formats.
nmap -sV -sC -oA "$outdir/nmap" "$@" "$target"
ok "output -> $outdir/nmap.{nmap,gnmap,xml}"
