# Install & first-run setup (PTBS)

Clean install for Raspberry Pi OS / Debian **arm64**. The script downloads `ptbs_arm64.deb` and installs it. It does not install Rust. The station starts with RF off so the dashboard is reachable; the Setup wizard finishes SoapySDR, the driver and RF, and cannot be skipped.

A Pi already running 0.4.7 is not upgraded by this script. Export a `.bptbs`, stop that station, then install PTBS and import the backup.

## One-command install

```bash
curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash
```

Beta: `curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/beta/contrib/install/install-ptbs.sh | sudo env PTBS_BRANCH=beta bash`

### What the script does

1. Installs `curl` if it is missing. No Rust and no SoapySDR.
2. Downloads `ptbs_arm64.deb` and `ptbs.sha256` from `latest-stable` (or `latest-beta`) and checks the checksum.
3. Installs the package. It contains `/usr/local/bin/ptbs`, `/usr/local/lib/libtetra-codec.so`, the systemd unit, the setup helper, a sudoers drop-in limited to that helper, and the NetworkManager Wi-Fi drop-in.
4. On first boot the package writes `/etc/ptbs/config.toml` with `phy_io.backend = "None"`, dashboard `admin` / `1234` on HTTP 80 and HTTPS 443, `config.toml.fallback` and `setup.json`.
5. Enables and starts `ptbs.service`.

Dispatch loads `/usr/local/lib/libtetra-codec.so` from the package. The wizard does not download the codec. SDR drivers stay in the Setup wizard.

### Wi-Fi resilience (Raspberry Pi)

Stations that reach the dashboard only over Wi-Fi can look “dead” when the association drops (GUI unreachable, radio still in LST) even though PTBS is running. Install applies `/etc/NetworkManager/conf.d/ptbs-wifi.conf` (`wifi.powersave=2`). The dashboard also:

- sets `autoconnect` + disables per-profile powersave when you Connect;
- uses `connection down` for Disconnect (does not inhibit NM autoconnect);
- runs a light watchdog that re-ups a saved profile if the link stays down while Wi-Fi radio is on.

Check on the Pi:

```bash
iw dev wlan0 get power_save
nmcli -f connection.autoconnect,802-11-wireless.powersave connection show <ssid>
```

OTA installs the same drop-in when the service runs as root. Manual fallback, from this repository:

```bash
sudo install -m 644 contrib/install/networkmanager/ptbs-wifi.conf \
  /etc/NetworkManager/conf.d/ptbs-wifi.conf
sudo systemctl reload NetworkManager
```

### Useful environment variables

| Variable | Meaning |
|---|---|
| `PTBS_BRANCH` | `main` (default) or `beta` |
| `PTBS_CHANNEL` | `stable` or `beta` |
| `PTBS_RELEASE` | Release tag override (`latest-stable` or `latest-beta`) |
| `PTBS_DEV=1` | Clone `/opt/ptbs` and install Rust |
| `PTBS_SKIP_TETRA_CODEC=1` | Skip the prebuilt voice library |
| `PTBS_DASH_PORTS` | `standard` (HTTP 80 → HTTPS 443) or `high` (HTTPS 8443 only). Prompted on a TTY when unset; only applies to **new** configs |
| `PTBS_SERVICE_USER` | Account named in sudoers for the setup helper (default `ptbs`). Reused if it already exists |

## First login

1. Open the URL printed by the installer:
   - **Standard:** `https://<pi-ip>/` (or `http://<pi-ip>/` — redirects to HTTPS)
   - **High port:** `https://<pi-ip>:8443/`
2. Log in with `admin` / `1234` (change password in System → Panel access when convenient)
3. The **Setup** wizard appears if `setup.json` has `setup_complete=false`
4. Steps: welcome → SDR scan / install driver (SXceiver or Lime) → RF/net/Brew (or defaults) → enable RF + restart → ensure systemd autostart → finish

You can switch presets later under **System → Panel access → Dashboard ports** (applies config and restarts the service). Existing installs keep their current ports until you change them.

## Degraded boot (no SDR)

If `backend = "None"` or SoapySDR open fails, the process **keeps running**. The dashboard exposes RF state in `/api/system` (`rf_status`: `online` | `offline` | `error` | `starting`) and shows a banner when RF is not online.

## Privileged helper

The dashboard never runs free-form shell. Driver install and systemd ensure go through:

`/usr/local/sbin/ptbs-setup-helper.sh`

Allowed actions: `install-driver sx|lime`, `enable-service`, `restart-service`.

**SXceiver (`sx`):** clones and builds [tejeez/sxxcvr](https://github.com/tejeez/sxxcvr) into `/opt/sxxcvr` (SoapySX module), then `ldconfig`. Override with `PTBS_SOAPY_SX_DIR` / `PTBS_SOAPY_SX_GIT` if needed. Hardware must be stacked on the Pi HAT for `SoapySDRUtil --find` / `--probe=driver=sx` to see it.

## Updating an existing PTBS install

Prefer **System → Update** on the dashboard. That downloads the release binary, checks SHA-256, and restarts. It does not compile. The voice library stays the one already installed from the package; from 0.5.4 the release no longer ships a loose `libtetra-codec.so`. Re-running `install-ptbs.sh` installs that package again and keeps `/etc/ptbs/config.toml`. To show the wizard again, set `"setup_complete": false` in `/etc/ptbs/setup.json`.

Moving a 0.4.7 station: export `.bptbs` there, stop that station, install PTBS, import under **System → Backup**.

## Station backup & profile packs

| Format | Where | Contents | Restart |
|--------|--------|----------|---------|
| `.bptbs` | **System → Backup** | Live config, profiles, setup/fallback, sibling TOMLs, Wi-Fi SSIDs+PSKs | Yes (import) |
| `.ptbs` | **Config → TMO profiles** | Cell/Brew profile tree only | No |

On station import the destination **OTA channel** is preserved; invalid `source_dir` from another machine is scrubbed. Wi-Fi networks are merged by SSID (existing PSKs updated; nothing deleted). Prefer a maintenance window before importing `.bptbs` onto a live cell.

## From 0.4.7

There is no OTA from 0.4.7 onto this repo. Install PTBS clean and import the `.bptbs`. The voice library comes in the same release as the binary.
