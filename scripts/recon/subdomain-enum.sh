#!/usr/bin/env bash
# Passive subdomain enumeration (subfinder + amass), resolved with dnsx.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: subdomain-enum.sh <domain>

Passive-only subdomain discovery via subfinder and amass, merged and
de-duplicated, then resolved with dnsx. Passive sources only — no brute force.

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -eq 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
domain="$1"
require_scope_ack

outdir="$(make_outdir "$domain")"
log "subdomain enum for $domain -> $outdir"

if command -v subfinder >/dev/null 2>&1; then
  subfinder -silent -d "$domain" >> "$outdir/raw.txt" || warn "subfinder failed"
fi
if command -v amass >/dev/null 2>&1; then
  amass enum -passive -d "$domain" >> "$outdir/raw.txt" 2>/dev/null || warn "amass failed"
fi

sort -u "$outdir/raw.txt" -o "$outdir/subdomains.txt" 2>/dev/null || : > "$outdir/subdomains.txt"
ok "$(wc -l < "$outdir/subdomains.txt") unique names -> $outdir/subdomains.txt"

if command -v dnsx >/dev/null 2>&1 && [[ -s "$outdir/subdomains.txt" ]]; then
  dnsx -silent -l "$outdir/subdomains.txt" -a -resp -o "$outdir/resolved.txt" || true
  ok "resolved -> $outdir/resolved.txt"
fi
