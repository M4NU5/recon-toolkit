#!/usr/bin/env bash
# Run nuclei against a target or list, keeping templates up to date.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: nuclei-scan.sh <url-or-file> [severity]

Runs nuclei against a single URL or a file of URLs. Optional severity filter
(default: critical,high,medium). Templates are refreshed on each run.

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -ge 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
input="$1"
severity="${2:-critical,high,medium}"
require_scope_ack
need nuclei

outdir="$(make_outdir "$(basename "$input")")"
log "nuclei scan ($severity) -> $outdir"

# Keep templates current; stay quiet if offline.
nuclei -update-templates -silent 2>/dev/null || warn "template update skipped"

target_flag="-u"
[[ -f "$input" ]] && target_flag="-l"

nuclei "$target_flag" "$input" -severity "$severity" -o "$outdir/nuclei.txt" -stats || true
ok "output -> $outdir/nuclei.txt"
