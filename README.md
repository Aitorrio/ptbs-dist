<div align="center">

### PTBS — Personal Tetra Base Station

Estación base TETRA para Raspberry Pi. Se instala el binario ya compilado y el resto se hace desde el panel web.

</div>

**PTBS 0.5.1** se instala limpio. Si vienes de otra estación, exporta un `.bptbs`, instala PTBS e impórtalo. No hay actualización encima de una instalación antigua.

Mantenido por **Aitor, EA4HBL**.

**Hardware probado:** LimeSDR Mini 2.0 · SXceiver · Motorola MXP600 · Motorola MTM800E · Motorola MTM5400

---

## Instalación

En **Raspberry Pi OS / Debian arm64**. El instalador baja el programa y el codec de voz. No instala Rust ni compila en la Pi.

Estable:

```bash
curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/main/contrib/install/install-ptbs.sh | sudo bash
```

Beta:

```bash
curl -fsSL https://raw.githubusercontent.com/Aitorrio/ptbs-dist/beta/contrib/install/install-ptbs.sh | sudo env PTBS_BRANCH=beta bash
```

Al terminar:

| | |
|---|---|
| Panel | `https://<ip-de-la-pi>/` (HTTP `:80` redirige a HTTPS) |
| Acceso inicial | `admin` / `1234` |
| Configuración | `/etc/ptbs/config.toml` y una reserva `.fallback` |
| Programa | `/usr/local/bin/ptbs` (`ptbs.service`) |
| Codec de voz | `/usr/local/lib/libtetra-codec.so` |

Los controladores del SDR (SXceiver o Lime) se instalan en el asistente. Detalle de variables y puertos: [`Docs/install-and-setup.md`](Docs/install-and-setup.md).

Volver a lanzar el instalador conserva `/etc/ptbs/config.toml` y no pisa `.fallback`. Sustituye el binario y el codec por el release del canal.

---

## Primer arranque

1. Abre la URL que imprime el instalador.
2. Entra con `admin` / `1234`. Cámbialos luego en **Sistema → Cuenta**.
3. Si el alta no está hecha, se abre el asistente (también está en la barra lateral).
4. En **Seleccionar SDR**, busca el hardware o instala el controlador **SXceiver** o **Lime**. Sigue por RF, red y Brew. Activa la RF y reinicia cuando quieras salir al aire.

La estación arranca con `phy_io.backend = "None"`. El panel responde aunque todavía no haya SDR.

---

## Qué puedes hacer

| | |
|---|---|
| Asistente de alta | Controladores SDR, RF, red y Brew desde el navegador |
| Configuración visual | Perfiles Celda × Brew, sin editar TOML a mano |
| Despacho LST | Voz de grupo y privada, y SDS, desde el navegador (HTTPS) |
| Control de acceso | Lista blanca de ISSI |
| Control remoto U-STATUS | Órdenes desde el walkie (`ip`, `temp`, `info`, `restart`…) |
| Sistema | Reinicio, suspensión, apagado, OTA y cuenta del panel |
| Aviso de actualización | Badge en la barra cuando el canal activo tiene un release nuevo |
| Idiomas | Español e inglés, en el ordenador y en el móvil |

| Página | Para qué |
|---|---|
| **Radios** | Terminales registrados, RSSI, kick / SDS, vista de ranuras |
| **DGNA** | Asignar y quitar grupos de conversación por el aire |
| **Llamadas / Last Heard / Log** | Tráfico en vivo y diagnóstico |
| **RF / Salud** | Espectro, constelación y salud de los subsistemas |
| **Config** | Perfiles TMO, ajustes en vivo, lista blanca, U-STATUS, TOML |
| **Sistema** | Métricas, control del servicio, OTA, cuenta, copia `.bptbs` |
| **Setup** | Repetir el asistente cuando haga falta |

---

## Ajustes

Abre **Config** en la barra. Usa los formularios; el TOML crudo queda para el final.

### Perfiles TMO (Celda × Brew)

1. Elige una **celda TMO** y una **red Brew** (o sin red).
2. **Añadir / Editar** abre la ficha completa. **Guardar** escribe solo el perfil: no reinicia.
3. **Aplicar y reiniciar** pone en el aire la pareja elegida.

Sirve para cambiar de red (celda local, BrandMeister, …) sin reescribir `config.toml`.

### Ajustes en vivo

**Ajustes en vivo** edita la estación que está corriendo: RF, red, Brew y lista blanca. Las frecuencias se escriben en **MHz** (coma o punto). Al salir del campo se normalizan a seis decimales, como en el CPS de Motorola (`432,2` → `432.200000`). En el fichero se guardan en **Hz**.

**Aplicar y reiniciar** escribe esos formularios en `/etc/ptbs/config.toml`. No actualiza el JSON del perfil.

En **Hardware RF** (cerrado por defecto) el identificador del SDR es de solo lectura: lo fija el asistente. PPM, antenas y ganancias dependen de ese controlador. Una ganancia que no pertenece a esa familia (por ejemplo `pad` de Lime en un SXceiver) se rechaza al guardar.

### Lista blanca de ISSI

Está dentro de la ficha de la **celda** y dentro de **Ajustes en vivo**. Lista vacía: red abierta. Con entradas, solo registran esas radios.

- En una ficha de perfil, **Guardar** deja la lista en ese perfil.
- En ajustes en vivo, **Aplicar y reiniciar** la escribe solo en la config activa.
- **Aplicar y reiniciar** en Perfiles pone en el aire la celda elegida, incluida su lista.

El control remoto U-STATUS es de toda la estación. No se guarda dentro de la celda ni de Brew.

### Control remoto (U-STATUS)

Autoriza radios y asocia códigos de estado a acciones: `ip`, `temp`, `info`, `restart`, `shutdown`, `kick_all`.

### TOML avanzado

Bajo **Avanzado**: aviso en rojo, luego **Guardar** y **Aplicar y reiniciar**. La referencia comentada está en [`example_config/config.toml`](example_config/config.toml).

### Temporizadores de llamada de grupo

En **Config → Red avanzada / temporizadores**, **Call timeout** es la duración máxima de una llamada de grupo (estilo ETSI T310), no de cada PTT. El hangtime mantiene la misma llamada entre turnos cortos, también en LST y Brew. Con el tope de unos 120 s una QSO larga puede acabar en PTT denegado: súbelo o pon **0** (sin límite). La ayuda de cada campo está en el **?**.

---

## Si la configuración se rompe

El panel valida antes de escribir en disco. Sin SDR, o con la RF apagada, el servicio sigue en pie para que puedas corregirlo desde el navegador.

Hay una reserva en `/etc/ptbs/config.toml.fallback`. El instalador la crea y el panel no la pisa al guardar. Si la config principal no parsea o no valida al arrancar, el servicio carga la reserva, abre el panel y muestra un aviso rojo.

Desde ahí, sin reinstalar: **Config → Aplicar y reiniciar** un perfil Celda × Brew que ya tuvieras, o arregla el formulario, el editor crudo o **Restaurar `.bak`**, y reinicia.

Cuando tengas una config en la que confíes:

```bash
sudo cp /etc/ptbs/config.toml /etc/ptbs/config.toml.fallback
```

---

## Sistema, OTA y copias

Reiniciar, suspender, apagar y actualizar están en **Sistema**, no en Config.

- **Reiniciar** — reinicio del servicio `ptbs`
- **Suspender** — la radio se detiene y el panel sigue; el botón pasa a **Iniciar**
- **Apagar** — apaga el equipo; normalmente hay que volver a darle corriente
- **Canal OTA** — **Estable** (`latest-stable`) o **Beta** (`latest-beta`). Se guarda en `[dashboard] ota_channel`
- **Actualizar** — baja el binario y `libtetra-codec.so` del release de ese canal, comprueba el SHA-256, los instala y reinicia. No compila en la Pi

Si el release del canal es más nuevo que el binario en marcha, o falta el codec, aparece un aviso arriba y una insignia en la barra lateral.

El diálogo de OTA tiene tres pasos: canal, novedades y progreso. **Ver todo** abre el registro completo. Deja la ventana abierta hasta que el servicio reinicie.

### Copias

- **Sistema → Copia de seguridad** — exporta o importa la estación (`.bptbs`): config viva, perfiles, reserva, y contraseñas Wi-Fi. Al importar se conserva el canal OTA de destino, se limpian rutas `source_dir` inválidas y se fusionan las redes Wi-Fi por SSID. Luego reinicia.
- **Config → perfiles TMO** — exporta o importa solo perfiles (`.ptbs`). No cambia la config viva ni reinicia; usa **Aplicar y reiniciar** para ponerlos al aire.

Un `.bptbs` lleva contraseñas de Wi-Fi y del panel. Trátalo como un secreto.

### Cuenta del panel

En **Sistema → Cuenta** se cambia el usuario y la contraseña del panel (los de `[dashboard]` en `config.toml`). Hace falta la contraseña actual. Si el panel estaba abierto, desde ahí se activa el acceso. El cambio es inmediato y te pide entrar de nuevo.

El alta deja `admin` / `1234`. Cámbialo en cuanto puedas.

---

## Canales

| Canal | Tag del release |
|---|---|
| Estable | `latest-stable` |
| Beta | `latest-beta` |

Esos son los únicos tags. Cada release lleva `ptbs`, `libtetra-codec.so`, `ptbs_arm64.deb` y `ptbs.sha256`. El binario no incluye el enlace de Asterisk; el despacho carga el codec al arrancar.

---

## Procedencia

PTBS lo desarrolla **Aitor, EA4HBL**.

Parte de la pila TETRA viene de proyectos anteriores. Sus licencias piden conservar los avisos de copyright. Están en [NOTICE](NOTICE): FlowStation (Razvan Zeces / YO6RZV) y tetra-bluestation (MidnightBlueLabs).

## Licencia

[Apache License 2.0](LICENSE).
