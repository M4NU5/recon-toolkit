#!/usr/bin/env bash
# Probe host(s) for live HTTP(S) services and fingerprint them.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: http-probe.sh <host-or-file>

Probes a single host or a file of hosts (one per line) with httpx, recording
status code, title, tech stack and server header. Falls back to whatweb when
httpx is unavailable.

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -eq 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
input="$1"
require_scope_ack

outdir="$(make_outdir "$(basename "$input")")"
list="$outdir/hosts.txt"
if [[ -f "$input" ]]; then cp "$input" "$list"; else printf '%s\n' "$input" > "$list"; fi
log "probing $(wc -l < "$list") host(s) -> $outdir"

if command -v httpx >/dev/null 2>&1; then
  httpx -silent -l "$list" -sc -title -tech-detect -server -o "$outdir/httpx.txt"
  ok "httpx -> $outdir/httpx.txt"
elif command -v whatweb >/dev/null 2>&1; then
  whatweb -i "$list" --log-brief "$outdir/whatweb.txt" || true
  ok "whatweb -> $outdir/whatweb.txt"
else
  die "no HTTP probe tool available (httpx/whatweb)"
fi
