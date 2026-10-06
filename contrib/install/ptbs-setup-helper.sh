#!/usr/bin/env bash
# Allowlisted privileged helper for the PTBS Setup wizard.
# Invoked only as: sudo -n /usr/local/sbin/ptbs-setup-helper.sh <action> [args]
# Never accept free-form shell from the dashboard.
set -euo pipefail

ACTION="${1:-}"
shift || true

SERVICE_UNIT="${PTBS_SERVICE_UNIT:-ptbs.service}"
SRC_ROOT="${PTBS_SRC:-/opt/ptbs}"
# Official SXceiver software tree (SoapySX lives in sxxcvr/SoapySX).
SOAPY_SX_GIT="${PTBS_SOAPY_SX_GIT:-https://github.com/tejeez/sxxcvr.git}"
SOAPY_SX_DIR="${PTBS_SOAPY_SX_DIR:-/opt/sxxcvr}"
# µCell BB: SoapyMuCell + device-tree overlay. Not the SXceiver module.
MUCELL_GIT="${PTBS_MUCELL_GIT:-https://github.com/Jankyneering/mu-cell-bb-drivers.git}"
MUCELL_DIR="${PTBS_MUCELL_DIR:-/opt/mu-cell-bb-drivers}"

log() { echo "[ptbs-setup-helper] $*"; }

die() { echo "[ptbs-setup-helper] ERROR: $*" >&2; exit 1; }

require_root() {
  if [[ "$(id -u)" -ne 0 ]]; then
    die "must run as root (via sudoers drop-in)"
  fi
}

# Resolve a directory that contains SoapySX/CMakeLists.txt (or is SoapySX itself).
resolve_soapysx_src() {
  local root="$1"
  if [[ -f "$root/SoapySX/CMakeLists.txt" ]]; then
    echo "$root/SoapySX"
    return 0
  fi
  if [[ -f "$root/CMakeLists.txt" ]]; then
    echo "$root"
    return 0
  fi
  return 1
}

ensure_soapysdr_util() {
  if command -v SoapySDRUtil >/dev/null 2>&1 || [[ -x /usr/bin/SoapySDRUtil || -x /usr/local/bin/SoapySDRUtil ]]; then
    return 0
  fi
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y soapysdr-tools \
    || apt-get install -y soapysdr0.8-tools \
    || die "could not install soapysdr-tools (SoapySDRUtil)"
  command -v SoapySDRUtil >/dev/null 2>&1 || [[ -x /usr/bin/SoapySDRUtil || -x /usr/local/bin/SoapySDRUtil ]] \
    || die "soapysdr-tools installed but SoapySDRUtil is not on PATH"
}

install_driver_lime() {
  echo "PHASE deps"
  ensure_soapysdr_util
  export DEBIAN_FRONTEND=noninteractive
  echo "PHASE install"
  apt-get update -qq
  # Package names vary across Debian/RPi OS releases.
  local pkgs=()
  for p in soapysdr-module-lms7 soapysdr0.8-module-lms7 soapysdr0.7-module-lms7 limesuite; do
    if apt-cache show "$p" >/dev/null 2>&1; then
      pkgs+=("$p")
    fi
  done
  if [[ ${#pkgs[@]} -eq 0 ]]; then
    die "no LimeSDR Soapy packages found in apt"
  fi
  apt-get install -y "${pkgs[@]}"
  log "LimeSDR modules installed: ${pkgs[*]}"
  SoapySDRUtil --info 2>/dev/null | head -n 20 || true
}

sx_module_present() {
  # Module on disk or factory advertised by SoapySDRUtil --info.
  local mod
  for mod in \
    /usr/local/lib/SoapySDR/modules0.8/libSXSupport.so \
    /usr/lib/aarch64-linux-gnu/SoapySDR/modules0.8/libSXSupport.so \
    /usr/lib/SoapySDR/modules0.8/libSXSupport.so; do
    [[ -f "$mod" ]] && return 0
  done
  SoapySDRUtil --info 2>/dev/null | grep -qE 'factories.*\bsx\b|Module found:.*libSXSupport' && return 0
  return 1
}

install_driver_sx() {
  ensure_soapysdr_util
  # Official flow from https://sxceiver.com/doc/getting-started and tejeez/sxxcvr.
  # If the module is already installed, succeed quickly — do NOT --probe while
  # ptbs holds the GPIO (that looks like a failure in the wizard).
  if sx_module_present; then
    echo "PHASE install"
    log "SXceiver Soapy module already installed"
    SoapySDRUtil --find 2>/dev/null | head -n 20 || true
    echo "OK: driver=sx ready (skip rebuild; device may be busy if RF is online)"
    return 0
  fi

  local candidates=(
    "$SOAPY_SX_DIR"
    /home/ptbs/sxxcvr
    /home/bts/sxxcvr
    /opt/sxxcvr
    /usr/local/src/sxxcvr
    /usr/local/src/SoapySX
  )
  local tree=""
  for d in "${candidates[@]}"; do
    if [[ -d "$d" ]] && resolve_soapysx_src "$d" >/dev/null; then
      tree="$d"
      break
    fi
  done

  echo "PHASE deps"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y --no-install-recommends \
    git make g++ cmake \
    libsoapysdr-dev libasound2-dev soapysdr-tools python3-soapysdr \
    || apt-get install -y git make g++ cmake libsoapysdr-dev libasound2-dev soapysdr-tools

  # Optional on some boards / Debian releases.
  apt-get install -y libgpiod-dev 2>/dev/null || true

  echo "PHASE clone"
  if [[ -z "$tree" ]]; then
    log "Cloning SXceiver software from $SOAPY_SX_GIT → $SOAPY_SX_DIR"
    mkdir -p "$(dirname "$SOAPY_SX_DIR")"
    rm -rf "$SOAPY_SX_DIR"
    git clone --depth 1 "$SOAPY_SX_GIT" "$SOAPY_SX_DIR"
    tree="$SOAPY_SX_DIR"
  else
    log "Using existing SXceiver tree at $tree"
    if [[ -d "$tree/.git" ]]; then
      git -C "$tree" pull --ff-only || true
    fi
  fi

  local src
  src="$(resolve_soapysx_src "$tree")" || die "SoapySX/CMakeLists.txt not found under $tree"

  echo "PHASE build"
  log "Building SoapySX in $src"
  cmake -S "$src" -B "$src/build" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$src/build" -j"$(nproc)"
  echo "PHASE install"
  cmake --install "$src/build"
  ldconfig || true

  sx_module_present || die "SoapySX built but libSXSupport.so / factory sx not found"

  log "SXceiver driver install finished"
  # --find is enough for the wizard; --probe fails if ptbs already owns GPIO.
  SoapySDRUtil --find 2>/dev/null | head -n 40 || true
  echo "OK: driver=sx installed"
}

mucell_overlay_present() {
  [[ -f /boot/firmware/overlays/mu-cell-bb_raspberrypi.dtbo || -f /boot/overlays/mu-cell-bb_raspberrypi.dtbo ]]
}

mucell_module_present() {
  local mod
  shopt -s nullglob
  local found=1
  for mod in \
    /usr/local/lib/SoapySDR/modules*/libMuCellSupport.so \
    /usr/lib/*/SoapySDR/modules*/libMuCellSupport.so \
    /usr/lib/SoapySDR/modules*/libMuCellSupport.so; do
    if [[ -f "$mod" ]]; then
      found=0
      break
    fi
  done
  shopt -u nullglob
  [[ "$found" -eq 0 ]] && return 0
  SoapySDRUtil --info 2>/dev/null | grep -qi 'mucell' && return 0
  return 1
}

install_driver_mucell() {
  ensure_soapysdr_util
  # Already built, and the Pi has loaded the HAT overlay: nothing to do.
  # Do not --probe while ptbs may hold the radio.
  if mucell_module_present && mucell_overlay_present && [[ -d /proc/device-tree/hat ]]; then
    echo "PHASE install"
    log "µCell driver and overlay already loaded"
    echo "OK: driver=mucell ready"
    return 0
  fi
  # Files are in place but the overlay is only read at boot.
  if mucell_module_present && mucell_overlay_present; then
    echo "PHASE install"
    log "µCell driver installed; the Pi still has to reboot"
    echo "NEED_REBOOT"
    echo "OK: driver=mucell installed"
    return 0
  fi

  echo "PHASE deps"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -qq
  apt-get install -y --no-install-recommends \
    git make g++ cmake device-tree-compiler \
    libsoapysdr-dev soapysdr-tools libasound2-dev python3-soapysdr \
    libssl-dev clang llvm-dev libclang-dev \
    || apt-get install -y git make g++ cmake device-tree-compiler \
      libsoapysdr-dev soapysdr-tools libssl-dev

  echo "PHASE clone"
  if [[ ! -d "$MUCELL_DIR/.git" ]]; then
    log "Cloning µCell drivers from $MUCELL_GIT → $MUCELL_DIR"
    mkdir -p "$(dirname "$MUCELL_DIR")"
    rm -rf "$MUCELL_DIR"
    git clone --depth 1 "$MUCELL_GIT" "$MUCELL_DIR"
  else
    log "Using existing µCell tree at $MUCELL_DIR"
    git -C "$MUCELL_DIR" pull --ff-only || true
  fi
  [[ -d "$MUCELL_DIR/SoapyMuCell" && -d "$MUCELL_DIR/raspberry-pi-drivers/mu-cell-bb-dts" ]] \
    || die "µCell tree is missing SoapyMuCell or the device-tree overlay"

  echo "PHASE overlay"
  log "Building µCell device-tree overlay"
  make -C "$MUCELL_DIR/raspberry-pi-drivers/mu-cell-bb-dts" overlay
  make -C "$MUCELL_DIR/raspberry-pi-drivers/mu-cell-bb-dts" install
  mucell_overlay_present || die "overlay build finished but mu-cell-bb_raspberrypi.dtbo was not installed"

  echo "PHASE build"
  log "Building SoapyMuCell"
  cmake -S "$MUCELL_DIR/SoapyMuCell" -B "$MUCELL_DIR/SoapyMuCell/build" -DCMAKE_BUILD_TYPE=Release
  cmake --build "$MUCELL_DIR/SoapyMuCell/build" -j"$(nproc)"
  echo "PHASE install"
  cmake --install "$MUCELL_DIR/SoapyMuCell/build"
  ldconfig || true
  mucell_module_present || die "SoapyMuCell built but the mucell factory was not found"

  # The overlay is read only at boot. https://github.com/Jankyneering/mu-cell
  echo "NEED_REBOOT"
  log "µCell driver installed; reboot the Pi before the board can be opened"
  echo "OK: driver=mucell installed"
}

enable_service() {
  # Idempotent: never restart a live station just to flip the enable bit.
  # (`enable --now` can disrupt an already-running unit mid-wizard.)
  systemctl enable "$SERVICE_UNIT"
  local enabled active
  enabled="$(systemctl is-enabled "$SERVICE_UNIT" 2>/dev/null || true)"
  active="$(systemctl is-active "$SERVICE_UNIT" 2>/dev/null || true)"
  echo "enabled=${enabled}"
  echo "active=${active}"
  if [[ "$enabled" != "enabled" ]]; then
    die "unit $SERVICE_UNIT is not enabled (got: ${enabled:-unknown})"
  fi
  log "autostart OK for $SERVICE_UNIT (enabled=${enabled}, active=${active})"
}

restart_service() {
  systemctl restart "$SERVICE_UNIT"
  log "restarted $SERVICE_UNIT"
}

require_root

case "$ACTION" in
  install-driver)
    driver="${1:-}"
    case "$driver" in
      sx) install_driver_sx ;;
      lime) install_driver_lime ;;
      mucell) install_driver_mucell ;;
      *) die "unknown driver '$driver' (sx|lime|mucell)" ;;
    esac
    ;;
  enable-service)
    enable_service
    ;;
  restart-service)
    restart_service
    ;;
  *)
    die "unknown action '$ACTION' (install-driver|enable-service|restart-service)"
    ;;
esac
