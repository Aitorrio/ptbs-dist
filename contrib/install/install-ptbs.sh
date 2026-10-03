#!/usr/bin/env bash
# Front door for PTBS. The .deb is the product; this script downloads it,
# installs it, and prints where the panel is. The setup wizard finishes
# SoapySDR, the radio driver, autostart and RF.
#
#   curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash
#
#   PTBS_BRANCH=beta   install latest-beta (default: stable / latest-stable)
set -euo pipefail

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "$(id -u)" -ne 0 ]]; then
  die "hay que ser root. Ejemplo: curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash"
fi

BRANCH="${PTBS_BRANCH:-main}"
case "$BRANCH" in
  main) TAG="latest-stable"; CANAL="estable" ;;
  beta) TAG="latest-beta"; CANAL="beta" ;;
  *) die "PTBS_BRANCH debe ser main o beta" ;;
esac

ARCH="$(uname -m)"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then
  die "el paquete publicado es aarch64 (hay $ARCH)"
fi

cat << 'EOF'

  ____  _____ ____  ____
 |  _ \|_   _| __ )/ ___|
 | |_) | | | |  _ \___ \
 |  __/  | | | |_) |___) |
 |_|     |_| |____/|____/

  Personal Tetra Base Station

EOF

export DEBIAN_FRONTEND=noninteractive
log "Preparando el sistema…"
apt-get update -qq
apt-get install -y -qq ca-certificates curl >/tmp/ptbs-apt.err 2>&1 \
  || { cat /tmp/ptbs-apt.err >&2; die "no se pudo instalar curl"; }

BASE="https://github.com/Aitorrio/ptbs-dist/releases/download/${TAG}"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

log "Descargando PTBS…"
CURL=(curl -fL --retry 3 --retry-delay 2)
if [[ -t 1 ]]; then
  "${CURL[@]}" -# -o "$WORKDIR/ptbs_arm64.deb" "${BASE}/ptbs_arm64.deb" \
    || die "no se pudo bajar el paquete"
else
  "${CURL[@]}" -sS -o "$WORKDIR/ptbs_arm64.deb" "${BASE}/ptbs_arm64.deb" \
    || die "no se pudo bajar el paquete"
fi
"${CURL[@]}" -fsSL -o "$WORKDIR/ptbs.sha256" "${BASE}/ptbs.sha256" \
  || die "no se pudo bajar la suma"

log "Comprobando la suma…"
(
  cd "$WORKDIR"
  grep 'ptbs_arm64.deb$' ptbs.sha256 | sha256sum -c -
) || die "la suma no coincide — no se ha instalado nada"

log "Instalando…"
apt-get install -y -qq "$WORKDIR/ptbs_arm64.deb" >/tmp/ptbs-apt.err 2>&1 \
  || { cat /tmp/ptbs-apt.err >&2; die "no se pudo instalar el paquete"; }

log "Arrancando…"
systemctl enable --now ptbs.service >/dev/null 2>&1 || true

IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
IP="${IP:-<ip-de-la-pi>}"

printf '\n'
printf '  ┌──────────────┬──────────────────────────────────────────┐\n'
printf '  │ %-12s │ %-40s │\n' "Panel" "https://${IP}/"
printf '  │ %-12s │ %-40s │\n' "Usuario" "admin"
printf '  │ %-12s │ %-40s │\n' "Contraseña" "1234"
printf '  │ %-12s │ %-40s │\n' "Config" "/etc/ptbs/config.toml"
printf '  │ %-12s │ %-40s │\n' "Servicio" "ptbs.service"
printf '  │ %-12s │ %-40s │\n' "Canal" "${CANAL}"
printf '  └──────────────┴──────────────────────────────────────────┘\n'
printf '\n  El asistente del panel termina la instalación.\n'
printf '  No se puede omitir: sin él la estación no queda en el aire.\n\n'
