#!/usr/bin/env bash
# Install PTBS on Raspberry Pi OS / Debian arm64 from a prebuilt binary.
# Does not install Rust or compile the station. SDR drivers stay as apt packages.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash
#
# Env:
#   PTBS_BRANCH          main (stable, default) or beta
#   PTBS_CHANNEL         stable or beta (overrides the branch→channel map)
#   PTBS_RELEASE         release tag (default: latest-stable or latest-beta)
#   PTBS_REPO_SLUG       distribution repo (default: Aitorrio/ptbs-dist)
#   PTBS_SOURCE_SLUG     private source checkout for PTBS_DEV (default: Aitorrio/ptbs)
#   PTBS_BIN             install path (default: /usr/local/bin/ptbs)
#   PTBS_CFG_DIR         default: /etc/ptbs
#   PTBS_DEV=1           also clone sources to /opt/ptbs and install Rust (developers)
#   PTBS_SKIP_TETRA_CODEC=1  do not install the prebuilt voice library
#   PTBS_DASH_PORTS      standard (80→443) or high (HTTPS 8443 only)
set -euo pipefail

log() { echo "==> $*"; }
warn() { echo "WARNING: $*" >&2; }
die() { echo "ERROR: $*" >&2; exit 1; }

if [[ "$(id -u)" -ne 0 ]]; then
  die "run as root (sudo bash)"
fi

BRANCH="${PTBS_BRANCH:-main}"
case "$BRANCH" in
  main|beta) ;;
  *) die "PTBS_BRANCH must be main or beta (got $BRANCH)" ;;
esac

OTA_CHANNEL="${PTBS_CHANNEL:-stable}"
[[ "$BRANCH" == "beta" ]] && OTA_CHANNEL="${PTBS_CHANNEL:-beta}"
case "$OTA_CHANNEL" in
  stable|beta) ;;
  *) die "PTBS_CHANNEL must be stable or beta" ;;
esac

REL_TAG="${PTBS_RELEASE:-latest-stable}"
[[ "$OTA_CHANNEL" == "beta" && -z "${PTBS_RELEASE:-}" ]] && REL_TAG="latest-beta"

SLUG="${PTBS_REPO_SLUG:-Aitorrio/ptbs-dist}"
SOURCE_SLUG="${PTBS_SOURCE_SLUG:-Aitorrio/ptbs}"
BIN_PATH="${PTBS_BIN:-/usr/local/bin/ptbs}"
CFG_DIR="${PTBS_CFG_DIR:-/etc/ptbs}"
CFG_PATH="${CFG_DIR}/config.toml"
UNIT_NAME="ptbs.service"
HELPER_DST="/usr/local/sbin/ptbs-setup-helper.sh"
SUDOERS_DST="/etc/sudoers.d/ptbs-setup"
SERVICE_USER="${PTBS_SERVICE_USER:-ptbs}"
SRC_ROOT="${PTBS_SRC:-/opt/ptbs}"
RAW="https://raw.githubusercontent.com/${SLUG}/${BRANCH}"
ASSET_BASE="https://github.com/${SLUG}/releases/download/${REL_TAG}"

ARCH="$(uname -m)"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
  die "the published binary is aarch64 (found $ARCH). Use PTBS_DEV=1 to build from source on this host."
fi

if ! id "$SERVICE_USER" >/dev/null 2>&1; then
  log "Creating user $SERVICE_USER"
  useradd -m -s /bin/bash "$SERVICE_USER" || true
fi

export DEBIAN_FRONTEND=noninteractive
log "Installing runtime packages (no Rust toolchain)"
apt-get update -qq
apt-get install -y --no-install-recommends \
  ca-certificates curl python3 soapysdr-tools \
  || apt-get install -y ca-certificates curl python3 soapysdr-tools

for p in soapysdr-module-lms7 soapysdr0.8-module-lms7; do
  if apt-cache show "$p" >/dev/null 2>&1; then
    apt-get install -y "$p" || true
  fi
done

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

log "Downloading ${REL_TAG}/ptbs and libtetra-codec.so"
curl -fL --retry 3 --retry-delay 2 -o "$WORKDIR/ptbs" "${ASSET_BASE}/ptbs" \
  || die "could not download ${ASSET_BASE}/ptbs"
if [[ "${PTBS_SKIP_TETRA_CODEC:-0}" != "1" ]]; then
  curl -fL --retry 3 --retry-delay 2 -o "$WORKDIR/libtetra-codec.so" "${ASSET_BASE}/libtetra-codec.so" \
    || die "could not download ${ASSET_BASE}/libtetra-codec.so"
fi
curl -fL --retry 3 --retry-delay 2 -o "$WORKDIR/ptbs.sha256" "${ASSET_BASE}/ptbs.sha256" \
  || die "could not download ${ASSET_BASE}/ptbs.sha256"
(
  cd "$WORKDIR"
  if [[ "${PTBS_SKIP_TETRA_CODEC:-0}" == "1" ]]; then
    grep ' ptbs$' ptbs.sha256 | sha256sum -c -
  else
    sha256sum -c ptbs.sha256
  fi
) || die "SHA-256 mismatch — nothing installed"
install -m 755 "$WORKDIR/ptbs" "$BIN_PATH"
log "Installed $BIN_PATH"
if [[ "${PTBS_SKIP_TETRA_CODEC:-0}" != "1" ]]; then
  install -d -m 755 /usr/local/lib
  install -m 644 "$WORKDIR/libtetra-codec.so" /usr/local/lib/libtetra-codec.so
  echo "/usr/local/lib" >/etc/ld.so.conf.d/ptbs.conf
  ldconfig || true
  log "Installed /usr/local/lib/libtetra-codec.so"
fi

fetch_raw() {
  local rel="$1" dest="$2"
  curl -fsSL --retry 3 --retry-delay 2 -o "$dest" "${RAW}/${rel}" \
    || die "could not download ${RAW}/${rel}"
}

DASH_PORTS_PRESET="${PTBS_DASH_PORTS:-}"
DASH_HTTP_PORT=80
DASH_HTTPS_PORT=443

choose_dashboard_ports() {
  local choice=""
  if [[ -n "$DASH_PORTS_PRESET" ]]; then
    choice="$DASH_PORTS_PRESET"
  elif [[ -t 0 ]]; then
    echo
    echo "Dashboard HTTPS ports (LST microphone requires HTTPS):"
    echo "  1) Standard — HTTP :80 redirects to HTTPS :443"
    echo "  2) High port — HTTPS :8443 only"
    read -r -p "Choose [1/2] (default 1): " choice || true
    case "${choice:-1}" in
      2|high|HIGH) choice="high" ;;
      *) choice="standard" ;;
    esac
  else
    choice="standard"
  fi
  case "${choice,,}" in
    high|2)
      DASH_PORTS_PRESET="high"
      DASH_HTTP_PORT=0
      DASH_HTTPS_PORT=8443
      ;;
    *)
      DASH_PORTS_PRESET="standard"
      DASH_HTTP_PORT=80
      DASH_HTTPS_PORT=443
      ;;
  esac
  log "Dashboard ports preset: ${DASH_PORTS_PRESET} (HTTP ${DASH_HTTP_PORT}, HTTPS ${DASH_HTTPS_PORT})"
}

mkdir -p "$CFG_DIR"
if [[ ! -f "$CFG_PATH" ]]; then
  choose_dashboard_ports
  log "Writing initial $CFG_PATH (backend=None, admin/1234, ota_channel=${OTA_CHANNEL})"
  fetch_raw "example_config/config.toml" "$CFG_PATH"
  python3 - "$CFG_PATH" "$OTA_CHANNEL" "$DASH_HTTP_PORT" "$DASH_HTTPS_PORT" <<'PY'
import sys, re
path, ota_channel, http_port, https_port = sys.argv[1:5]
text = open(path, encoding="utf-8").read()
text = re.sub(r'(?m)^backend\s*=\s*".*"', 'backend = "None"', text, count=1)
if re.search(r'(?m)^#?\s*service_name\s*=', text):
    text = re.sub(r'(?m)^#?\s*service_name\s*=.*', 'service_name = "ptbs"', text, count=1)
else:
    text = 'service_name = "ptbs"\n' + text
has_live_dashboard = bool(re.search(r'(?m)^\[dashboard\]\s*$', text))
dash = (
    '\n[dashboard]\n'
    'bind = "0.0.0.0"\n'
    f'port = {http_port}\n'
    f'https_port = {https_port}\n'
    'username = "admin"\n'
    'password = "1234"\n'
    f'ota_channel = "{ota_channel}"\n'
)
if not has_live_dashboard:
    text = text.rstrip() + "\n" + dash
open(path, "w", encoding="utf-8").write(text)
PY
  cp "$CFG_PATH" "${CFG_PATH}.fallback"
else
  log "Keeping existing $CFG_PATH"
fi

if [[ ! -f "${CFG_PATH}.fallback" ]]; then
  cp "$CFG_PATH" "${CFG_PATH}.fallback"
  log "Created ${CFG_PATH}.fallback"
fi

if [[ ! -f "${CFG_DIR}/setup.json" ]]; then
  cat >"${CFG_DIR}/setup.json" <<'EOF'
{
  "setup_complete": false,
  "skipped": false,
  "version": 1
}
EOF
fi

fetch_raw "contrib/install/ptbs-setup-helper.sh" "$HELPER_DST"
chmod 755 "$HELPER_DST"
cat >"$SUDOERS_DST" <<EOF
# Setup wizard helper only (no free shell).
${SERVICE_USER} ALL=(root) NOPASSWD: ${HELPER_DST}
Defaults!${HELPER_DST} !requiretty
EOF
chmod 440 "$SUDOERS_DST"
visudo -cf "$SUDOERS_DST" >/dev/null || die "invalid sudoers drop-in"

NM_WIFI_DST="/etc/NetworkManager/conf.d/ptbs-wifi.conf"
if command -v nmcli >/dev/null 2>&1 || [[ -d /etc/NetworkManager ]]; then
  install -d -m 755 /etc/NetworkManager/conf.d
  fetch_raw "contrib/install/networkmanager/ptbs-wifi.conf" "$NM_WIFI_DST"
  chmod 644 "$NM_WIFI_DST"
  if systemctl is-active --quiet NetworkManager 2>/dev/null; then
    systemctl reload NetworkManager 2>/dev/null || true
  fi
fi

if [[ "${PTBS_DEV:-0}" == "1" ]]; then
  log "PTBS_DEV=1 — cloning sources and installing Rust for the service user"
  apt-get install -y --no-install-recommends git build-essential pkg-config libssl-dev cmake || true
  if [[ ! -x "$(getent passwd "$SERVICE_USER" | cut -d: -f6)/.cargo/bin/cargo" ]]; then
    sudo -u "$SERVICE_USER" bash -lc 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable'
  fi
  if [[ ! -d "$SRC_ROOT/.git" ]]; then
    git clone --depth 1 --branch "$BRANCH" "https://github.com/${SOURCE_SLUG}.git" "$SRC_ROOT"
  fi
  chown -R "$SERVICE_USER:$SERVICE_USER" "$SRC_ROOT" || true
fi

UNIT_DST="/etc/systemd/system/${UNIT_NAME}"
cat >"$UNIT_DST" <<EOF
[Unit]
Description=PTBS Personal Tetra Base Station
Documentation=https://github.com/${SLUG}
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=300
StartLimitBurst=10

[Service]
Type=simple
User=root
Environment=PTBS_SERVICE_UNIT=${UNIT_NAME}
Environment=PTBS_SERVICE_USER=${SERVICE_USER}
Environment=PTBS_SETUP_HELPER=${HELPER_DST}
Environment=LD_LIBRARY_PATH=/usr/local/lib
ExecStart=${BIN_PATH} ${CFG_PATH}
CPUSchedulingPolicy=fifo
CPUSchedulingPriority=73
KillSignal=SIGINT
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now "$UNIT_NAME"

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
IP="${IP:-<pi-ip>}"

echo
echo "────────────────────────────────────────────────────────"
echo " PTBS installed"
if [[ "${DASH_HTTPS_PORT:-443}" == "443" ]]; then
  echo " Dashboard:  https://${IP}/  (HTTP :80 redirects to HTTPS)"
else
  echo " Dashboard:  https://${IP}:${DASH_HTTPS_PORT}/"
fi
echo " Login:      admin / 1234"
echo " Config:     ${CFG_PATH}"
echo " Service:    ${UNIT_NAME}"
echo " Release:    ${REL_TAG}  (${OTA_CHANNEL})"
echo " RF starts disabled (backend=None) until Setup finishes."
echo " Import a PTBS .bptbs from System → Backup if you are moving a station."
echo "────────────────────────────────────────────────────────"
