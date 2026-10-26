#!/usr/bin/env bash
set -euo pipefail

cat <<'EOF'
 recon-toolkit — AUTHORISED security testing only
 --------------------------------------------------
 Wrapper scripts are on PATH. Run any with -h for usage:
   dns-recon.sh        subdomain-enum.sh   port-scan.sh
   http-probe.sh       nuclei-scan.sh      tls-check.sh

 Outputs are written under /work (mount a host dir there).
 Export I_HAVE_AUTHORISATION=yes to enable the scripts.
EOF

exec "$@"
