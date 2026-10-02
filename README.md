<div align="center">

### PTBS — Personal Tetra Base Station

Software-defined TETRA base station for Raspberry Pi. Install the prebuilt binary; the dashboard does the rest.

</div>

**PTBS 0.5.1** is a clean install. Export a `.bptbs` from a station you are leaving, install PTBS, then import it.

---

## Installation

On **Raspberry Pi OS / Debian arm64**. The installer downloads a prebuilt binary and the voice codec. It does not install Rust.

```bash
curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash
```

Beta channel:

```bash
curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/beta/contrib/install/install-ptbs.sh | sudo env PTBS_BRANCH=beta bash
```

When it finishes:

| | |
|---|---|
| Dashboard | `https://<pi-ip>/` (HTTP `:80` redirects to HTTPS) |
| Default login | `admin` / `1234` |
| Config on disk | `/etc/ptbs/config.toml` |
| Binary | `/usr/local/bin/ptbs` (`ptbs.service`) |
| Voice codec | `/usr/local/lib/libtetra-codec.so` |

SDR drivers (SXceiver or Lime) stay in the Setup wizard. More detail: [`Docs/install-and-setup.md`](Docs/install-and-setup.md).

---

## Updates

In the dashboard, **System → Update** downloads the rolling release for the selected channel, checks SHA-256, and restarts. Nothing is compiled on the Pi.

| Channel | Release tag |
|---|---|
| Estable | `latest-stable` |
| Beta | `latest-beta` |

Each release carries `ptbs`, `libtetra-codec.so`, `ptbs_arm64.deb` and `ptbs.sha256`.

---

## Provenance

PTBS is developed by **Aitor, EA4HBL**.

Parts of the TETRA stack come from earlier projects. Their licenses require the original copyright and attribution notices to stay with the distributed files. Those notices are in [NOTICE](NOTICE): FlowStation (Razvan Zeces / YO6RZV) and tetra-bluestation (MidnightBlueLabs).

## License

[Apache License 2.0](LICENSE).
