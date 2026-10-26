#!/usr/bin/env bash
# TLS/SSL configuration check via sslscan, plus testssl.sh when available.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: tls-check.sh <host[:port]>

Checks TLS configuration, supported protocols, cipher suites and certificate
details. Uses sslscan; also runs testssl.sh when present. Defaults to port 443
when no port is given.

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -eq 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
target="$1"
require_scope_ack

outdir="$(make_outdir "$target")"
log "TLS check for $target -> $outdir"

if command -v sslscan >/dev/null 2>&1; then
  sslscan --no-colour "$target" | tee "$outdir/sslscan.txt" >/dev/null
  ok "sslscan -> $outdir/sslscan.txt"
fi
if command -v testssl.sh >/dev/null 2>&1; then
  testssl.sh --quiet --color 0 "$target" > "$outdir/testssl.txt" 2>&1 || true
  ok "testssl -> $outdir/testssl.txt"
fi
