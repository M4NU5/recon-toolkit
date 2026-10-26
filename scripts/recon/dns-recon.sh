#!/usr/bin/env bash
# DNS reconnaissance: common records plus an AXFR zone-transfer check.
source "$(dirname "$0")/../lib/common.sh"

usage() {
  cat <<'EOF'
Usage: dns-recon.sh <domain>

Collects common DNS records (A, AAAA, MX, NS, TXT, SOA, CNAME, CAA) and checks
each nameserver for an open AXFR zone transfer.

Env:
  OUT_DIR                 base output directory (default ./out)
  I_HAVE_AUTHORISATION    must be "yes" to run
EOF
}

[[ $# -eq 1 && "$1" != "-h" && "$1" != "--help" ]] || { usage; exit 1; }
domain="$1"
require_scope_ack
need dig

outdir="$(make_outdir "$domain")"
log "DNS recon for $domain -> $outdir"

for rr in A AAAA MX NS TXT SOA CNAME CAA; do
  dig +nocmd "$domain" "$rr" +noall +answer >> "$outdir/records.txt" || true
done
ok "records -> $outdir/records.txt"

# Try a zone transfer against each authoritative nameserver.
mapfile -t nameservers < <(dig +short NS "$domain")
for ns in "${nameservers[@]}"; do
  [[ -n "$ns" ]] || continue
  log "AXFR check against $ns"
  axfr="$outdir/axfr-${ns%.}.txt"
  if dig +nocmd AXFR "$domain" "@${ns%.}" +noall +answer > "$axfr" 2>/dev/null && [[ -s "$axfr" ]]; then
    warn "possible zone transfer from $ns -> $axfr"
  else
    rm -f "$axfr"
  fi
done
ok "done"
