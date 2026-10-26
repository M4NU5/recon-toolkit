# recon-toolkit

A containerised reconnaissance and scanning toolkit for authorised security
testing. Built on `kali-rolling` with a curated tool set and a handful of
wrapper scripts, so you can pull one image and start work instead of
assembling tools under pressure.

## Authorised use only

Run this against systems you own or have written permission to test. The
wrapper scripts refuse to run until you set `I_HAVE_AUTHORISATION=yes`, which is
a prompt to confirm scope, not a substitute for it. You are responsible for
staying in scope and within the law.

## What's in it

Wrapper scripts live on `PATH`; run any with `-h` for usage.

| Script | Purpose | Key tools |
| --- | --- | --- |
| `dns-recon.sh` | DNS records + zone-transfer check | dig |
| `subdomain-enum.sh` | Passive subdomain discovery, resolved | subfinder, amass, dnsx |
| `port-scan.sh` | Service/version port scan | nmap |
| `http-probe.sh` | Live-host probing + fingerprinting | httpx, whatweb |
| `nuclei-scan.sh` | Template-based vulnerability scan | nuclei |
| `tls-check.sh` | TLS config and certificate review | sslscan, testssl.sh |

The full tool set is listed in [`config/tools.list`](config/tools.list),
grouped by capability. The ProjectDiscovery suite is installed as a whole via
`pdtm`; run `pdtm -list` in the container to see every PD tool.

## Build

```sh
make build
# or: docker build -t recon-toolkit .
```

The ProjectDiscovery tool versions are pinned as `ARG`s in the `Dockerfile`.
Check them against current releases and bump deliberately before building.

## Run

Mount a host directory at `/work` so scan outputs survive the container:

```sh
mkdir -p out
docker run --rm -it -v "$PWD/out:/work" -e I_HAVE_AUTHORISATION=yes recon-toolkit

# inside the container
port-scan.sh example.com
subdomain-enum.sh example.com
```

Each script writes to `./out/<target>-<timestamp>/` under `/work`.

## Layout

```
Dockerfile          curated image build
entrypoint.sh       banner + shell
scripts/
  lib/common.sh     shared helpers (logging, output dirs, scope gate)
  recon/            dns, subdomains, ports, http
  scan/             nuclei, tls
config/tools.list   the tool set, with notes
.github/workflows/  lint + build/push to GHCR
```

## Extending

Add a script under `scripts/recon/` or `scripts/scan/`, source
`../lib/common.sh`, and call `require_scope_ack` before it touches a target.
Keep targets as arguments. Never hard-code one.

## License

MIT. See [`LICENSE`](LICENSE).
