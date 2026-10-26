# syntax=docker/dockerfile:1
#
# recon-toolkit — minimal containerised reconnaissance and scanning toolkit
# for AUTHORISED security testing only.
#
# Built on kali-rolling for the packaged tool set, but installs only a curated
# subset — not the kali metapackages. Add tools deliberately; keep it lean.

FROM kalilinux/kali-rolling:latest

LABEL org.opencontainers.image.title="recon-toolkit" \
      org.opencontainers.image.description="Minimal recon and scanning toolkit for authorised security testing" \
      org.opencontainers.image.source="https://github.com/M4NU5/recon-toolkit" \
      org.opencontainers.image.licenses="MIT"

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/root/go \
    PATH="/opt/toolkit/scripts/recon:/opt/toolkit/scripts/scan:/root/go/bin:/usr/local/bin:${PATH}"

# --- Packaged tools (curated, not the full kali metapackages) ---------------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl wget git jq ripgrep tmux vim less \
      dnsutils whois netcat-traditional openssl libpcap-dev \
      nmap masscan whatweb wafw00f gobuster feroxbuster sslscan amass \
      sqlmap theharvester ffuf chromium \
      python3 python3-pip golang-go \
 && rm -rf /var/lib/apt/lists/*

# --- ProjectDiscovery: full stack via pdtm ----------------------------------
# pdtm (ProjectDiscovery Tool Manager) installs the whole PD suite in one go:
# subfinder, httpx, nuclei, dnsx, naabu, katana, tlsx, uncover, asnmap, and more.
# Trade-off: -install-all pulls the latest of each, so this is NOT version
# pinned. If you need reproducible builds, drop pdtm and install each tool with
# `go install ...@<version>` instead. naabu needs libpcap-dev (in the apt layer).
ARG PDTM_VERSION=latest
RUN go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@${PDTM_VERSION} \
 && /root/go/bin/pdtm -install-all -no-color \
 && cp -n /root/.pdtm/go/bin/* /usr/local/bin/ \
 && rm -rf /root/go/pkg /root/.cache

# --- Additional recon tooling (Go) ------------------------------------------
# Verify each module path on first build; some carry a /v2 or /v3 suffix and
# occasionally move. A failed line here only drops that one tool.
RUN go install -v github.com/lc/gau/v2/cmd/gau@latest \
 && go install -v github.com/tomnomnom/waybackurls@latest \
 && go install -v github.com/hahwul/dalfox/v2@latest \
 && go install -v github.com/sensepost/gowitness@latest \
 && go install -v github.com/gitleaks/gitleaks/v8@latest \
 && go install -v github.com/trufflesecurity/trufflehog/v3@latest \
 && go install -v github.com/tomnomnom/wappalyzer/cmd/wappalyzer@latest \
 && cp /root/go/bin/* /usr/local/bin/ \
 && rm -rf /root/go/pkg /root/.cache

# --- testssl.sh (pinned stable branch) --------------------------------------
ARG TESTSSL_BRANCH=3.2
RUN git clone --depth 1 --branch ${TESTSSL_BRANCH} \
      https://github.com/testssl/testssl.sh.git /opt/testssl \
 && ln -s /opt/testssl/testssl.sh /usr/local/bin/testssl.sh

# --- Toolkit scripts --------------------------------------------------------
COPY scripts/ /opt/toolkit/scripts/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && find /opt/toolkit/scripts -name '*.sh' -exec chmod +x {} +

# Outputs land here — mount a host directory at /work to keep them.
WORKDIR /work
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
