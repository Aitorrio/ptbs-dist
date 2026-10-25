# Changelog — PTBS

Notas para operadores. El dashboard OTA muestra las secciones posteriores a tu versión actual.

## v0.6.36 — La credencial de PTMS se queda en el campo

Al apagar el núcleo, la credencial sigue en el fichero. En la pestaña se ve enmascarada, como la contraseña de Brew: déjala así para no cambiarla. La página avisa de que guardar apagado devuelve la radio a los perfiles activos.

## v0.6.35 — La ficha de inicio usa la frecuencia que está en el aire

La portadora, el MCC y el MNC ya salían del aire. La frecuencia de transmisión, la de recepción y el dúplex seguían siendo los del arranque del panel. Ahora las tres salen de la portadora que está radiando.

Al deshabilitar PTMS se vuelven a aplicar el perfil de celda y el de Brew que estaban activos, y la radio arranca de nuevo con ellos.

## v0.6.34 — La celda se entera si el núcleo se calla

Si PTMS deja de contestar, la sesión cae en unos quince segundos: el aire anuncia site trunking y Salud marca el backhaul PTCP caído. Aprovisionar dice si ha escrito la ficha, si ya no hay sesión o si no ha podido.

## v0.6.33 — El aire se entera de que el núcleo está unido

El enlace repite al aire, cada dos segundos, si la sesión con PTMS sigue abierta. Con eso el SYSINFO anuncia red y Salud deja de marcar el backhaul PTCP como caído. Brew sigue usando su propio bit cuando la celda va sola.

## v0.6.32 — Con el núcleo unido, la celda no anuncia site trunking

Si la sesión con PTMS está abierta, el aire anuncia servicios de red y Salud muestra el backhaul PTCP en orden. Si el enlace cae, entonces sí es site trunking. Un Brew que quede en el fichero no manda mientras la celda esté en el núcleo.

## v0.6.31 — La celda cuenta al núcleo lo que ocurre en su aire

Un walkie que se registra, un PTT de grupo y un SDS a un ISSI de otra celda salen hacia el núcleo por la sesión que ya está abierta. Al unirse, la celda informa de los ISSI que ya tiene.

## v0.6.30 — El núcleo lleva la celda

Desde 0.5.5 la estación pasa a cuatro unidades, el núcleo PTMS administra la celda y el SDS dice si el walkie lo recibió. Esto es el resultado. Las notas de más abajo cuentan cada corte.

La estación son cuatro unidades: el panel, el enlace con el núcleo, la sincronización y el aire. Si la radio cae, el panel sigue. Aplicar ya no reinicia las cuatro ni cierra la página.

- Vecinas, identidad, lista blanca y la portadora extra, cuando está en «Solo cuando hay uso», entran sin tirar la estación.
- Un cambio de SDR, de tasa, de portadora principal, de dúplex, de Brew, de PPM, de ganancias o de antenas recicla solo el aire.
- Reiniciar, en Sistema, para las cuatro. Parar en suave deja el panel y detiene el aire. Iniciar levanta otra vez el aire, sin la pantalla de «Reiniciando…».
- Una configuración que no arrancaría no sustituye a la que está emitiendo. Si el fichero quedó inválido y existe la copia anterior, el arranque la restaura.

El núcleo administra la identidad, las vecinas y la lista blanca, y la estación las anuncia en el aire.

- En PTMS se indican el host, el puerto, el nombre de celda y la credencial. Al guardar se abre la sesión sin reiniciar el panel.
- Si el MCC, el MNC, el área, el colour code o la portadora no coinciden con lo que ya está en el aire, guarda la ficha y se reinicia para anunciarla. Con dos portadoras no se retoca el sintonizador.
- Mientras está unida no se editan DGNA, las integraciones, el despacho ni Configuración. U-Status sigue en Sistema. Ethernet, el SDR, la pila del reloj, la cuenta del panel y la actualización se siguen editando aquí.
- Se suelta al apagar PTMS en la propia estación. Una caída del enlace, un rechazo o un reinicio no devuelven esa administración a la Pi.
- Inicio enseña el núcleo, el estado y si la ficha está al día. La página de PTMS muestra señalización, SDS, voz y si la celda es conforme. Aprovisionar vuelve a escribir la ficha.
- Cada 15 segundos, y al momento si cambia el aire, el cumplimiento o una alarma, la estación informa al núcleo.
- En el ordenador esa página usa el ancho de la pantalla y los campos quedan con margen. En el móvil cada campo va en su línea.

La voz ya no pasa por centralita. No hay SIP ni teléfonos Snom: sale por Brew o por PTCP.

- La consola LST del panel vuelve a hablar con la del aire cuando el perfil Despacho LST está seleccionado.
- «Solo cuando hay uso» enciende la portadora extra con la llamada y la apaga al quedar libre.
- Si la lista de grupos no cabe en un mensaje, la estación confirma los grupos ya aceptados y pide el resto. El walkie sigue oyendo el grupo en el que estaba después de reiniciar la radio.
- La recuperación proactiva sigue apagada. La reactiva, encendida, pide el registro cuando el walkie transmite.

El SDS espera al walkie y el registro dice en qué quedó.

- Al enviarlo desde el panel o el despacho, la fila aparece al momento. Sale cuando el walkie vuelve al canal de control, también con el grupo en llamada. Al grupo le llega una copia a cada radio afiliada.
- El estado puede ser enviado, entregado, leído, inalcanzable o rechazado. Entregado es que lo recibió. Leído, que lo abrió. Un acuse posterior no quita el leído. Inalcanzable es que el ISSI no está registrado, el grupo no tiene nadie, o el walkie no volvió al canal a tiempo. Rechazado es que estaba y lo rechazó.
- Un SDS a un ISSI que estuvo en esta celda dentro de las horas de retención se guarda y sale cuando vuelve a registrarse, en la trama en la que está escuchando. Si nunca estuvo, o ese tiempo ya pasó, queda inalcanzable. Esas horas son la vida del mensaje y la ventana de «estuvo aquí». El grupo no se guarda. Con PTMS unido, la celda no retiene.
- De walkie a walkie, si el destino no está en la celda, se entrega a Brew. Si Brew confirma la entrega, queda entregado o leído y no se guarda. Si no confirma en medio minuto, o confirma que no se entregó, se retiene cuando ese ISSI sigue dentro de las horas. Si no, queda inalcanzable.
- El mapa de ubicación muestra las posiciones LIP que el registro recibe.

Otras diferencias al pasar de 0.5.5.

- La tarjeta se llama Conexión y dice si el protocolo es Brew o PTCP. El estado del aire está en la barra. Aplicar confirma con «Aplicado, en el aire.»
- En Red, cada interfaz muestra su MAC. Expulsar llega a la celda también con Brew, con el despacho o en solitario. La lista blanca en caliente echa a los ISSI que ya no caben.
- Un SDS de texto del panel, de DAPNET o de una alarma ya no muestra un recuadro al principio. En dos portadoras, un acceso que se cuela en la segunda sin llamada no se contesta. Si Brew rechaza una orden, el registro enseña el motivo.
- Un perfil nuevo sale vacío. «Configuración inicial» se puede omitir. En una Pi 5, Sensores del sistema puede cargar la pila del reloj, ML-2020 o LIR2032.
- En el móvil, los perfiles rápidos de Inicio ocupan otra vez todo el ancho de la tarjeta.

## v0.6.28 — El registro sigue el acuse de Brew

Un SDS de walkie a walkie que sale por Brew queda enviado hasta que vuelve el informe. Si Brew confirma la entrega, pasa a entregado o leído y no se guarda. Si no confirma en medio minuto, o confirma que no se entregó, se retiene cuando ese ISSI sigue dentro de las horas. Si no sigue en esa ventana, queda inalcanzable. La casilla de copia ya no está.

## v0.6.27 — El SDS entre walkies y el mapa LIP

Un SDS de un walkie a otro, si el destino no está en la celda, se entrega a Brew y queda enviado. Si Brew no lo acepta y ese ISSI estuvo aquí dentro de las horas de retención, se guarda hasta que vuelva. Si nunca estuvo, o ese tiempo ya pasó, queda inalcanzable. Esas horas son también la ventana en la que el ISSI cuenta como visto. La casilla nueva guarda además una copia cuando Brew acepta y no confirma. El mapa de ubicación vuelve a mostrar las posiciones LIP que el registro ya recibe.

## v0.6.26 — El SDS retenido sale cuando el walkie ya escucha

Un SDS guardado espera a que el walkie termine de registrarse y sale en la trama en la que está escuchando. El registro pasa a enviado en ese momento. Un silencio del enlace entre el panel y la radio ya no se toma por una desconexión.

## v0.6.25 — El retén de SDS ya no corta el envío

Activar o desactivar el retén solo cambia esa sección de la configuración. El SDS sigue saliendo, y apagar el retén no deja el envío mudo hasta reiniciar. En el despacho, la lista de SDS se actualiza sola mientras la página está abierta.

## v0.6.24 — El SDS espera al walkie que ya estuvo aquí

Un SDS a un ISSI que no está en línea se guarda si ese ISSI ya se registró en esta celda, y sale cuando vuelve a registrarse. Si nunca estuvo aquí, queda inalcanzable. El retén se enciende en Configuración: tiempo de guarda, ISSI vistos, mensajes retenidos y vaciar el depósito. El ajuste viaja en el .bptbs y no va ligado a los perfiles. Con PTMS unido, la celda no retiene.

Un walkie en ahorro de energía solo escucha a ratos. El SDS sale en uno de esos momentos. Si aun así no confirma la trama, el registro pasa a inalcanzable.

## v0.6.23 — El SDS distingue entregado, leído e inalcanzable

El registro y el despacho marcan enviado, entregado, leído, inalcanzable y rechazado según el informe del walkie. Entregado es que lo recibió; leído, que lo abrió. Un acuse de recepción posterior no quita el leído. Inalcanzable es que el ISSI no está registrado, el grupo no tiene nadie afiliado, o el walkie no volvió al canal de control a tiempo. Rechazado es que el walkie estaba y lo rechazó, por memoria llena o por codificación.

## v0.6.22 — El SDS del panel queda anotado al enviarlo

Al mandar un SDS desde el panel, la fila aparece al momento en el registro y en la lista del despacho, también si sale como 9999. La orden ya no se pierde si el enlace con el servicio de radio se reconecta.

## v0.6.21 — El SDS del despacho llega y se lee la conversación

Un SDS desde Inicio o desde el despacho espera a que el walkie vuelva al canal de control, también con el grupo en llamada. Al grupo le llega una copia a cada radio afiliada.

En el despacho, la lista se llama SDS y muestra lo que envías junto a lo que recibes. El registro distingue enviado, entregado y rechazado según el acuse del walkie.

## v0.6.20 — Tras reiniciar la radio, el grupo sigue confirmado

Si la lista de grupos no cabe en un mensaje, la estación confirma los grupos que ya aceptó en el registro y pide el resto en trozos. El walkie no se queda sin oír el grupo en el que estaba, y no hace falta cambiar de grupo y volver.

La ayuda de la recuperación aclara que el registro vive en el servicio de radio. Reiniciar solo ese servicio lo vacía aunque el panel y el enlace sigan. La casilla proactiva sigue apagada. La reactiva, encendida, pide el registro cuando el walkie transmite.

## v0.6.19 — Cada enlace enseña su MAC

En Red, cada tarjeta de interfaz muestra la dirección MAC debajo del nombre y antes del estado.

## v0.6.18 — En el móvil, Inicio vuelve a ocupar la tarjeta

En Inicio, los perfiles rápidos y los botones Aplicar y Más ajustes ocupan otra vez todo el ancho de la tarjeta. Ya no se quedan en una columna estrecha a la izquierda.

## v0.6.17 — El texto llega limpio y la segunda portadora no se confunde

Un SDS de texto del panel, de DAPNET o de una alarma ya no muestra un recuadro al principio. En una celda de dos portadoras, la primera deja de salir deformada. Un acceso que se cuela en la segunda sin llamada ya no se contesta, y el terminal no se registra en bucle; si ese intervalo tiene una llamada, la señalización sigue. Si Brew rechaza una orden, el registro enseña el motivo y no solo el tamaño.

## v0.6.16 — Sin centralita en la celda

La celda ya no lleva centralita SIP ni avisos a teléfonos Snom. La voz y la señalización salen solo por Brew o por PTCP.

## v0.6.15 — La celda informa al núcleo

Cada 15 segundos, y al momento si cambia el aire, el cumplimiento o una alarma, la estación manda por PTCP cómo está: si es conforme y por qué, la radio, cuántas radios y llamadas hay, la salud, las IP y la temperatura.

## v0.6.14 — El núcleo se ve, y se puede volver a aprovisionar

La tarjeta del núcleo deja de ser tres líneas. Enseña señalización, SDS, voz y si la celda está conforme con la ficha. Aprovisionar vuelve a escribir esa ficha; el enlace lo comprueba solo cada medio minuto. El icono de PTMS ya no es el de Red.

## v0.6.13 — Con el núcleo, Inicio enseña el enlace

Si la celda la lleva el PTMS, la tarjeta de perfiles de Inicio pasa a mostrar el núcleo, el estado y si la ficha está al día. DGNA, las integraciones, el despacho y Configuración quedan en una página en blanco con el aviso en el centro. La franja azul desaparece.

## v0.6.12 — La BS vuelve al salir de la suspensión

Al iniciar, el aire y Brew ya se veían, pero la conexión de la BS se quedaba apagada hasta recargar. El panel no se había ido: solo faltaba encender otra vez esa lámpara.

## v0.6.11 — Iniciar no reinicia el panel

Suspender para el aire y el panel sigue. Iniciar arranca otra vez esa unidad, sin la pantalla de «Reiniciando…». Si esa pantalla se abre y el panel no se va, se cierra sola.

## v0.6.10 — U-Status vuelve a su sitio

En Sistema, el control remoto queda debajo del acceso al panel y la copia de seguridad al final. La tarjeta recupera la fila de código, acción y quitar, también en el móvil. Desaparece la lista vieja de perfiles de config: los perfiles de verdad siguen en Configuración. Un cambio en caliente que no entra en el aire deja rastro en el registro, y expulsar ya no puede trabarse con el candado de la lista.

## v0.6.9 — Expulsar llega a la celda

La orden de expulsar solo estaba enchufada con el núcleo PTCP. Con Brew, con el despacho o en solitario se perdía, y la lista blanca en caliente tampoco podía echar al que ya estaba registrado. Ahora la celda la recibe siempre y manda al terminal a registrarse otra vez.

## v0.6.8 — Los cambios en caliente llegan al aire

La lista blanca se aplica en el aire y echa a los ISSI que ya no caben. La ficha de acceso lee esa misma lista. El tope de registros sigue al cambio sin reiniciar. PPM, ganancias y antenas reciclan el aire, porque el SDR solo las lee al abrirse.

## v0.6.7 — El estado del aire vive en la barra

El aviso «RF apagada: el aire se está refrescando» desaparece. El estado del aire queda en la fila donde antes ponía SDR, y en ningún otro sitio. Aplicar confirma con «Aplicado, en el aire.» bajo la barra, sin el texto verde de los perfiles. El config.toml en bruto se guarda y se aplica con un solo botón.

## v0.6.6 — La consola LST vuelve, y Aplicar avisa

La consola LST del panel habla con la consola del aire. Con el perfil Despacho LST seleccionado vuelve a abrirse. La franja de «Sola, en el aire» desaparece. Aplicar deja el botón en «Aplicando…» con el círculo de espera y, al terminar, un aviso en la esquina superior derecha: verde si entró, rojo si no.

## v0.6.5 — Conexión, portadora bajo demanda y celda gestionada

Cerrar la página ya no pinta el enlace como caído. La tarjeta se llama Conexión y, debajo, dice si el protocolo es Brew o PTCP. La franja deja de repetir la portadora extra y la identidad. Reiniciar y actualizar recargan la página cuando vuelve el panel. Dentro de doble portadora, «Solo cuando hay uso» enciende la extra con la llamada y la apaga al quedar libre. Con la celda en PTMS no se editan DGNA, las integraciones, el despacho ni Configuración. U-Status pasa a Sistema y sigue disponible. La difusión de SDS en vivo pasa a Configuración.

## v0.6.4 — La ficha, el punto y el registro coinciden

El punto del perfil aplicado se actualiza al pulsar Aplicar, sin recargar la página. La ficha de Brew sigue la misma foto que la franja: si el enlace está arriba, no dice «sin conexión». El registro en vivo vuelve a mostrar las líneas del aire.

## v0.6.3 — El panel sigue al aire

Reciclar la radio ya no deja el panel en «en espera». Ese aviso solo sale si paras la radio desde el panel. La franja, el aviso de RF y la pastilla de la izquierda muestran lo que está radiando: si Brew está arriba se ve, y si no está configurado Salud no dice que el enlace está conectado. Al caer el aire se borra el espectro y las radios de la sesión anterior; al volver, el MCCH y el resto salen de la misma foto.

## v0.6.2 — Aplicar muestra los parámetros

Aplicar ya no se queda en «el aire no lo confirma». En cuanto la estación acepta el cambio, la ficha muestra MCC, MNC, portadora, frecuencias, vecinas y lista de acceso. La franja de arriba enseña la identidad que está radiando. El aviso de que el aire se recicla se apaga cuando la radio vuelve a responder.

## v0.6.1 — Aplicar no cierra el panel

Aplicar deja de reiniciar las cuatro unidades. La página sigue. Vecinas, identidad, lista blanca y el resto entran en el aire. Un cambio de SDR, de tasa, de portadora, de dúplex o de Brew recicla solo el aire.

PTMS se aplica en el enlace, no en el panel. El formulario muestra la sesión de ese enlace. Reiniciar, en Sistema, sigue siendo el que para las cuatro unidades. Cambiar el puerto del panel recarga la página; la radio sigue.

## v0.6.0 — La estación ya no es un solo proceso

El panel, el enlace con PTMS, la sincronización y el aire son cuatro unidades. Si la radio cae, el panel y la sesión siguen. Si caen ellos, la celda sigue con el último ajuste aplicado.

La sincronización es la única que escribe la configuración. Un documento que no arrancaría no sustituye al que está emitiendo. Vecinas, lista blanca, identidad y la portadora de más (si está en modo bajo demanda) entran sin reiniciar la estación. Un cambio de SDR, de tasa de muestreo o de portadora principal recicla solo el aire.

Con PTMS enganchado, el registro, la llamada, la voz, el SDS y el aviso de cambio de celda llegan al aire. Sin PTMS, la celda sigue sola o por Brew. El panel muestra el modo de la celda y las alarmas activas, y no da un cambio por hecho hasta que el aire lo confirma.

Reiniciar desde el panel recicla las cuatro unidades. Parar en suave deja el panel y detiene el aire. El micrófono de la consola local sigue en el aire: el PTT de esa página del panel todavía no cruza al proceso de la radio.

## v0.5.13 — La ficha ya no deja la estación sin panel

Guardar las vecinas del núcleo encima de la lista que ya tenía la estación producía un TOML que no arrancaba. Sin ese fichero no salen el panel ni la radio. Esa escritura ya no se hace si el resultado no vuelve a parsear.

Si el fichero principal quedó inválido y existe la copia anterior (`config.toml.ptms.bak`), el arranque la restaura y sigue.

## v0.5.12 — La celda unida no vuelve a administración local

Al quedar unida, la estación recuerda que el núcleo administra la identidad, las vecinas y la lista blanca. Eso se ve en el panel y no se edita. Una caída del enlace, un rechazo momentáneo o un reinicio no devuelve esa config a la Pi. Se suelta al apagar PTMS en la propia estación.

Ethernet, el SDR, la pila del reloj, la cuenta del panel y la actualización siguen editándose aquí. Guardar la gestión remota sin que el núcleo conteste no administra la celda.

Al aplicar la ficha, la estación se la confirma al núcleo. Si no coincide, el panel de PTMS la marca no conforme.

## v0.5.11 — La ficha del núcleo sale al aire

Con la sesión PTCP unida, la estación anuncia la ficha que manda el núcleo: identidad, vecinas y lista blanca. Las vecinas salen en el siguiente `D-NWRK-BROADCAST`, con salto no anunciado, igual que las celdas vecinas aisladas. La lista blanca entra al momento; vacía sigue siendo red abierta.

Si el MCC, el MNC, el área, el colour code o la portadora no coinciden con lo que ya está en el aire, la estación guarda la ficha y se reinicia para anunciarla. Con dos portadoras activas no se retoca el sintonizador.

## v0.5.10 — PTMS en el panel

En Sistema, debajo de Red, está PTMS. Desde ahí se indica el núcleo, el puerto, el nombre de celda y la credencial. Al guardar, la estación abre la sesión PTCP sin reiniciar. La ficha se muestra en la misma página.

## v0.5.9 — Gestión remota

La estación puede unirse a un núcleo PTMS. En el panel está en Sistema → Gestión remota. En la config es `[gestion_remota]`: activado, host, puerto, nombre de celda y credencial. No entra en los perfiles TMO Cell ni en los de Brew.

Con la gestión remota encendida, el enlace con el núcleo es solo PTCP y el perfil Brew no se usa para ese enlace. La estación manda su nombre y su credencial, recibe la ficha (identidad, vecinas y lista blanca) y la enseña. Esa ficha todavía no se aplica a la celda ni se anuncia en el aire. Si la gestión remota está apagada, la estación sigue como hasta ahora.

## v0.5.8 — Carga de la pila RTC

En una Pi 5, Sensores del sistema puede encender o apagar la carga de la pila del reloj. Hay que elegir la pila: ML-2020 a 3,0 V o LIR2032 a 4,2 V. Sin pila detectada, la carga no se enciende. El ajuste se guarda y entra al reiniciar la Pi.

## v0.5.7 — Perfil nuevo

Al añadir un perfil TMO Cell o Brew, el formulario sale vacío. Los números en gris son un ejemplo, no un valor. «Copiar de Vivo» sigue trayendo la config en vivo, y hay que guardar para conservarlo.

## v0.5.6 — Asistente

La bienvenida, la comprobación de internet, SoapySDR, la elección de placa, el arranque automático y el cierre explican el paso con menos jerga.

«Valores de fábrica» pasa a ser «Configuración inicial». Se puede omitir, o introducir MCC, MNC, área, portadora y Brew. Eso se guarda en la config en vivo, no en un perfil.

En un perfil TMO Cell o Brew, «Copiar de Vivo» rellena el formulario con lo que ese perfil admite de la config en vivo. Hay que guardar para conservarlo. Al editar, pide confirmación antes de pisar lo que ya hay.

Añadir un perfil abre el formulario con valores de partida y el nombre vacío. No reutiliza el perfil elegido. Si ese nombre ya existe, no lo sobrescribe.

## v0.5.5 — µCell en el asistente

La placa [µCell BB](https://store.fredcorp.cc/shop/%CE%BCcell-bb-2) usa el driver `mucell`, no el del SXceiver. Si el escaneo no ve ninguna radio, el asistente ofrece SXceiver, Lime y µCell. Elegir una tarjeta ya no recarga el paso.

- Instala el overlay y SoapyMuCell desde [mu-cell-bb-drivers](https://github.com/Jankyneering/mu-cell-bb-drivers). Al terminar, la Pi se reinicia para que el overlay cargue y la página vuelve sola.
- La cadena que queda guardada es `driver=mucell`. Las ganancias de partida son las del SXceiver.

## v0.5.4 — Panel en el móvil

En el móvil, «Datos de la estación TETRA» queda en su propia línea. Debajo van, cada una en la suya, las celdas vecinas y la retención. El texto de acceso de registro ya no se monta sobre la pastilla Abierto.

- El release deja de incluir `libtetra-codec.so` suelto. La voz sigue dentro del paquete `.deb`. Una estación que ya tiene la librería no la vuelve a bajar al actualizar.

## v0.5.3 — Celdas vecinas aisladas

Cada estación puede anunciar hasta siete celdas vecinas. El móvil ve esas portadoras y puede registrarse en ellas si el área de localización es distinta. No hay una gestión central: al salir de la celda, la llamada en curso se corta.

- La lista está en Identidad TETRA, tanto en la config en vivo como en los perfiles TMO.
- Los umbrales de reselección salen a 10, 6, 6 y 6 dB. Cada uno se puede devolver a ese valor.
- Sin vecinas, el móvil no tiene roaming.
- El panel de actualización muestra estas notas y titula el diálogo «Actualización OTA».

## v0.5.2 — El asistente termina la instalación

El paquete `.deb` es el producto: programa, codec de voz, servicio, helper y configuración con la radio apagada. El script solo descarga ese paquete y lo instala. El asistente del panel, que no se puede omitir, hace el resto.

- Orden del asistente: internet, SoapySDR, radio conectada, driver (SXceiver o Lime), valores de fábrica, arranque automático y Finalizar. Finalizar enciende la radio y reinicia.
- SoapySDR y el driver no van dentro del paquete. Si `SoapySDRUtil` falta, el asistente lo instala. Un `--find` sin radios ya no se confunde con la utilidad ausente.
- La voz LST va dentro del `.deb`. El fichero suelto `libtetra-codec.so` sigue en el release para que una 0.5.1 pueda actualizarse; se retira en 0.5.4.
- Panel inicial `admin` / `1234`, HTTP 80 y HTTPS 443. Sin pregunta de puerto.
- El paquete depende de la librería SoapySDR. Sin ella el servicio no arranca y el panel no abre. SoapySDRUtil y el driver siguen en el asistente.

## v0.5.1 — Cuenta auxiliar `ptbs`

La cuenta que crea el instalador para el helper del asistente se llama `ptbs`, igual que el producto. Si ya existe (por ejemplo en Raspberry Pi Imager), se reutiliza. El servicio sigue arrancando como root.

- Instalación y OTA salen del repo público `Aitorrio/ptbs-dist` (`latest-stable` / `latest-beta`).
- El README público es la guía de uso: instalación, asistente, perfiles, ajustes, despacho y copias. El instalador vive solo en ese repo.
- Los binarios de release se compilan con LTO, `codegen-units = 1` y símbolos eliminados. Un panic de un paquete sigue contenido: no aborta el proceso.

## v0.5.0 — PTBS (Personal Tetra Base Station)

Corte de instalación. Una estación 0.4.7 no se actualiza por OTA: se instala PTBS limpio y, si hace falta, se importa un `.bptbs`.

- Producto **PTBS**, binario `/usr/local/bin/ptbs`, unit `ptbs.service`, checkout opcional `/opt/ptbs`.
- OTA descarga el asset del release `latest-stable` (canal stable / rama `main`) o `latest-beta` (canal beta), comprueba SHA-256 e instala. Si la descarga falla, no se compila en la Pi.
- `install-ptbs.sh` instala el binario sin Rust. Rust queda en el perfil `PTBS_DEV=1`.
- UI: idiomas **es** / **en**, temas oscuro y claro, preferencias de tema e idioma en el mismo menú en PC y móvil.
- El import `.bptbs` acepta copias 0.4.7 (`format` / `format_version`; el nombre de producto no se exige).
- El binario publicado no lleva `--features asterisk`. La voz del despacho carga `libtetra-codec.so` del mismo release (`/usr/local/lib`), sin compilar en la Pi.
- Canal **beta** sigue el release `latest-beta` (rama `beta`). Canal **stable** sigue `latest-stable` (rama `main`).

## v0.4.7 — Copia de estación (.bptbs) y pack de perfiles (.ptbs)

Respaldar o clonar una estación sin copiar a mano `/etc/ptbs`, y compartir solo perfiles Cell/Brew entre Pis.

- **Sistema → Copia de seguridad**: exportar/importar `.bptbs` (config viva, perfiles, setup/fallback, TOMLs hermanos, Wi-Fi SSID+PSK). Al importar se conserva el canal OTA local, se limpia `source_dir` inválido, se fusionan redes Wi-Fi por SSID y se reinicia.
- **Config → perfiles TMO**: exportar/importar `.ptbs` (solo árbol de perfiles). Sin reinicio automático — usa Aplicar y reiniciar para ponerlos al aire.
- APIs autenticadas `GET/POST /api/station|profiles/export|import` (ZIP, hasta 32 MiB en estación).
- Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.4.6 — LST: RX verde / double-PTT solo con tráfico real

LED RX y oferta de interrupción (doble PTT) solo cuando otro interlocutor tiene el suelo vivo en el TG TX. Late-entry en hangtime ya no pinta verde ni deja el TG “pillado”.

- `OngoingGroupCall` con `tx_active=false`: ignorado (sin `rx` / sin LED).
- `CallEnded`: limpia RX de inmediato.
- Fin de PTT propio (`NetworkCallEnd`): limpia RX/preempt del TG TX.
- Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.4.5 — LST: sin double-PTT tras cambio de TG en hangtime

Si un MS entra por late-entry durante hangtime (`tx_active=false`), el despacho armaba RX “verde” que `tx_gssi_busy` trataba como suelo ocupado; al liberar la llamada Network no llegaba `CallEnded` a LST → primer PTT denied / hace falta preempt.

- Hangtime late-entry: LED verde con `floor_live=false` (no bloquea PTT).
- `release_group_call` notifica siempre `CallEnded` a Brew/LST (`IfGroupRoutable`).
- `CallEnded` limpia RX hangtime-only.

## v0.4.4 — Puertos del dashboard: presets y binds estables

Elección de puertos sin pelear con nginx/apache ni spamear ERROR en el log.

- Instalador (SSH/TTY): pregunta **Estándar (80→443)** o **Puerto alto (solo HTTPS 8443)**; `PTBS_DASH_PORTS=standard|high` sin TTY. Configs existentes no se tocan.
- Sistema → Acceso al panel: selector de preset + Apply & Restart (nueva URL tras reinicio).
- `port = 0` desactiva el redirect HTTP. Migración OTA solo si `port = 8080` sin `https_port`.
- Listeners legacy 8080/8443 solo en layout :443, fail-soft (sin reintentos infinitos). Bind canónico: conflicto → hint + retry 60s.
- Validado en campo. Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.4.3 — LST SDS: ocultar ACK de entrega en el log

- Los SDS-TL SHORT REPORT (confirmación de entrega del MS) ya no se registran en el log/inbox SDS.
- Evita la fila fantasma `[text]` justo después de un SDS enviado desde el despacho.
- Validado en campo (MS↔despacho privado/grupo, origen `operator_issi`). Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.4.2 — LST SDS: identidad despachador y ACK

SDS de despacho LST deja de fingir entrega a 9999 y usa la ISSI del operador.

- Con LST activo, SDS del roster/panel salen con `source_issi = operator_issi` (no 9999).
- SDS entrantes al `operator_issi` se absorben con SDS-TL SHORT REPORT (el walkie deja de marcar error de envío).
- Se elimina la absorción ciega de SDS-DATA a 9999: ruta estándar (local / Brew / undeliverable). WX y U-STATUS a 9999 sin cambios.
- Inbox LST: solo privados destinados al despachador (sin filtro dual 9999).

## v0.4.1 — Brew WiFi: leave mid-QSO como Ethernet

Misma lógica Ethernet/WiFi; con latencia WiFi el MS podía seguir como owner Local mientras Brew hablaba, y rojo/cambio de TG tumbaba el circuito (media huérfana + U-SETUP encima).

- Al preempt de Brew, ownership Local→Network.
- U-DISCONNECT del owner solo soft-leave si Brew tiene el suelo (D-RELEASE personal; grupo vivo).
- Sin listeners + Brew activo → Hold / LATE ENTRY (también si origin aún Local).
- Release Local con brew_uuid → NetworkCallEnd antes de cerrar circuito (anti-zombie DL).
- Owner con suelo local: teardown ETSI sin cambios.
- Validado en campo (WiFi Hold → LATE ENTRY). Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.4.0 — Red host, Dual Carrier GUI y canal estable

Salto menor de serie (aún sin rebrand a PTBS): nuevas capacidades de red en la GUI y consolidación de lo validado en beta.

### Página Red (antes WiFi)

- Menú **Red** con icono híbrido Ethernet+WiFi (superpuestos, estilo LST).
- Sección **Enlaces**: interfaces ethernet/wifi con IP(s) y badge de **ruta por defecto**.
- Gestión de perfiles **Ethernet** (conectar / desconectar) vía NetworkManager.
- WiFi (conexión actual, redes guardadas, disponibles) en **una sola tarjeta** con separadores.
- Estados NM y perfil «Wired connection» traducidos al idioma de la GUI.
- API `/api/network/*` (overview + ethernet); `/api/wifi/*` sin cambios.

### U-STATUS (walkie → ISSI 9999)

- `ip` / `info` listan **todas** las IPs de host (`eth0=…*`, `wlan0=…`; `*` = ruta por defecto).
- Respuesta **multilínea** (CR/LF admitidos en SDS de texto).
- Enumeración rápida con `getifaddrs` (sin `nmcli` en el hilo de radio — evita caída del stack).

### Dual Carrier (TMO Cell)

- Configuración Dual Carrier en GUI (Config → Advanced RF), límite al passband de Fs.
- Home / BTS Details: estado Activo/Apagado, mini-tiles secondary, orden MCCH/BCCH.

### Repo / OTA

- Eliminado el workflow de sync con upstream PTBS (force-push a `main`).
- Promovido a canal **stable** (`main`); `beta` al mismo tip.

## v0.3.47 — U-STATUS IP multilínea

- El SDS de texto admite CR/LF (antes se filtraban).
- Status IP: `Host IP` y cada interfaz en su línea (`eth0=…*`, `wlan0=…`).
- Página Red + fixes U-STATUS IP (v0.3.44–0.3.47) promovidos a canal **stable** (`main`).

## v0.3.46 — Fix: U-STATUS IP no bloquea el stack

- El Status/info de IP ya no llama a `nmcli` en el hilo de radio (provocaba «Too late to produce TX block» y caída del stack).
- Lista IPs con `getifaddrs` + `primary_ip()` (rápido, como el Status de temperatura).

## v0.3.45 — Red: icono, i18n NM y WiFi unificado

- Icono de menú Red: jack Ethernet y arcos WiFi superpuestos (estilo LST), arcos más anchos.
- Sección de página «Red» (antes «Integraciones»); WiFi en una sola tarjeta con separadores.
- Estados NM (`connected`, …) y perfil «Wired connection» traducidos al idioma de la GUI.

## v0.3.44 — Página Red: Ethernet + WiFi

- La pestaña **WiFi** pasa a llamarse **Red** (icono híbrido Ethernet+WiFi).
- Nueva sección **Enlaces**: todas las interfaces ethernet/wifi con IP y badge de **ruta por defecto**.
- Gestión de perfiles **Ethernet** (conectar / desconectar) vía NetworkManager.
- El bloque WiFi (conexión, guardadas, escaneo) se mantiene debajo.
- U-STATUS `ip` / `info` listan las IPs por interfaz (`eth0=…* wlan0=…`; `*` = ruta por defecto).

## v0.3.43 — Dual Carrier: bordes de mini-tiles + promoción estable

- Marcos de Carrier / TX / RX / Duplex dentro de Dual Carrier un poco más oscuros (mejor contraste).
- Dual Carrier GUI (v0.3.38–0.3.43) promovido a canal **stable** (`main`).

## v0.3.42 — Dual Carrier: mismo fondo que el resto

- La tarjeta Dual Carrier usa el mismo fondo plano (tema light) que Registration Access / tiles BTS.

## v0.3.41 — Dual Carrier: una sola tarjeta

- Carrier / TX / RX / shift del secondary van **dentro** de la tarjeta Dual Carrier (sin caja aparte).
- Estado: **Activo** (verde negrita) / **Apagado** (naranja negrita); se quita el texto «carrier secundario #…».

## v0.3.40 — Dual Carrier UI: orden TS + mini-tiles

- En BTS Details, la fila **MCCH (main)** va arriba y el **BCCH secondary** debajo.
- Las mini-tiles del secondary (carrier, TX, RX, shift) aparecen **bajo Dual Carrier** cuando está activo (Home ya las rellena).

## v0.3.39 — Fix OTA: encoding en server.rs

- Corrige literales UTF-8 corruptos en el detector de mojibake del dashboard que impedían compilar `tetra-entities` en OTA (v0.3.38).

## v0.3.38 — Dual Carrier en TMO Cell (GUI)

- Dual Carrier se configura en **Config → Advanced RF** (checkbox bajo Main carrier; el secondary solo aparece si está ON).
- El secondary se **limita al passband** de la Fs real del SDR (o 600 kHz por defecto); al activar se guardan Fs + centros midway en TOML y perfil Cell.
- En **TETRA BTS Details**: botón «Configurar…» (sin switch) y **mini-tiles** del secondary (nº, TX, RX, shift) cuando está activo.

## v0.3.37 — Overflow mid-report → D-ATTACH inmediato

- Si el U-ATTACH trae *group report not complete* y >12 GSSI (MXP600), tras el ACK de 12 se afilia el resto con **D-ATTACH SwMI** en el acto (no se pide otro group report).
- Si el amendment siguiente llega truncado (`BufferEnded` al parsear), se usa el resto guardado del PDU anterior para el mismo D-ATTACH.

## v0.3.36 — Fallback SwMI attach si el MS no multipasa

- Tras group report (§16.8.3), si el MXP600 vuelve a mandar >12 GSSI en un solo U-ATTACH (no hace amendment multipaso), la BTS afilia el resto y envía **D-ATTACH amend** SwMI (§16.8.1) con esos GSSI. IOP puede ignorarlo; si sigue en 12, limitar scan a ≤12.

## v0.3.35 — Afiliación multipaso ETSI (§16.8.3)

- Si un U-ATTACH trae más de **12** GSSI (p. ej. scan list MXP600), tras el ACK de los 12 la BTS pide **group report** SwMI (EN 300 392-2 §16.8.3) para que el MS re-afilie en varios mensajes (detach-all + amendments).
- Log corregido: ya no dice que el MS reintentará solo. Validar en aire: scan >12 → más de 12 en «Grupos afiliados». Si el MS no multipasa tras el report, limitar scan a ≤12.

## v0.3.34 — Restart recovery en Config

- Interruptor **Restart recovery (proactive)** en Advanced network/timers (config en vivo + perfil TMO Cell), con ayuda «?». Default **off**. Tras Aplicar y reiniciar con el check activo, la BTS re-registra ISSIs cacheados sin tocar el walkie. La recuperación reactiva (al PTT/TG) sigue ON en el motor.

## v0.3.33 — Pending-tail quiet 400 ms

- Ajuste fino: quiet post-drenado Brew **400 ms** (antes 550) tras `GROUP_IDLE`.

## v0.3.32 — Brew: no cortar la última sílaba al soltar PTT remoto

- Tras `GROUP_IDLE` se **aplaza siempre** el `NetworkCallEnd` (aunque el jitter Brew esté vacío) para que UMAC termine de radiar los últimos TCH.
- Quiet post-drenado ~**400 ms** (ajustado en 0.3.33; era 550 / antes 150); evita que el hangtime “se trague” la cola y la suelte al abrir el siguiente PTT.

## v0.3.31 — Brew late entry: audio DL + Hold al salir del TG

- **Audio Brew:** las llamadas de red nuevas abren el circuito en **SwMI** (antes LocalLoopback, pensado para LST; el audio remoto no salía al aire).
- **Cambio de TG mid-QSO:** si el último walkie deja el GSSI, la sesión Brew se **retiene** (Hold) en lugar de End; al volver a afiliar se remonta + D-SETUP.

## v0.3.30 — Fix OTA compile (late entry)

- Visibilidad de `push_control` entre módulos CMCE + match exhaustivo en UMAC para los nuevos SAP de late entry (build release fallaba en 0.3.29).

## v0.3.29 — Late entry usable (QSO a medias)

- **Brew:** si llega GROUP_TX sin walkies afiliados, la llamada se **retiene** (pending) en lugar de tirarse; al primer Affiliate se monta circuito + D-SETUP + audio.
- **Affiliate / cambio de TG:** D-SETUP inmediato si ya hay QSO en ese GSSI (no esperar ~5 s).
- **Despacho LST:** al afiliar un TG con QSO activo, la consola engancha RX (`rx_gssi` verde + audio) sin textos nuevos.
- **`late_entry_supported`** por defecto **true** en `[cell_info]`; checkbox en Config (celda Advanced) junto a System-wide services.

## v0.3.28 — Site trunking suave (estilo DIMETRA / TIP)

- Tras un blip de Brew **ya no** se expulsa a todos los walkies con `D-LOCATION-UPDATE-COMMAND`.
- Al reconectar: resync de suscriptores al core (REGISTER/AFFILIATE); COMMAND solo **bajo demanda** a un ISSI si falla un setup vía Brew en la ventana de soft-recovery.
- Histéresis de backhaul (default **3 s**): blips cortos de 4G/5G no cambian el menú “solo área local”. Las llamadas Brew se liberan al instante; los grupos locales en la celda siguen.
- Nuevo `[brew] backhaul_hysteresis_secs` (0..=60).

## v0.3.27 — TetraPack: no re-registro en la primera GROUP_TX

- Si el core no anuncia versión en el handshake (TetraPack), la primera llamada con mnemonic ya no dispara `BrewReconnected` / `D-LOCATION-UPDATE-COMMAND`.
- Ese barrido solo ocurre tras un disconnect→reconnect real del backhaul (sigue cubriendo PTT denegado tras blip).

## v0.3.26 — OTA: RF OFF al empezar

- Al iniciar una actualización OTA se apaga el SDR de inmediato (antes de compilar), para que las radios pierdan la celda limpiamente. El reinicio final vuelve a abrir RF desde config.

## v0.3.25 — Modal Ubicación LIP (móvil)

- En cada radio solo queda el botón **Centrar** (se quita el texto “Centrar todos” duplicado en la tarjeta).
- El botón superior **Centrar todos** va centrado, más grande y en negrita.
- Título del modal alineado en vertical con el botón de cerrar (móvil y PC).

## v0.3.24 — Fix OTA: préstamo en lip_forward_issi

- Corrige E0716 en `brew_routable` (temporary dropped while borrowed) que bloqueaba el build OTA de 0.3.23.

## v0.3.23 — Reenvío LIP → Brew + dashboard estable

- **Brew:** en Advanced (perfil y ajustes en vivo), **Reenvío de LIP** + **ISSI de destino** justo bajo RSSI export. Cada LIP UL (PID 10) se reenvía a ese ISSI por Brew, digan lo que digan las radios.
- **Dashboard:** el WebSocket ya no ocupa un slot del tope de 32 conexiones HTTP; evita que, pasado un rato, API/WS fallen con timeout y haya que reiniciar.

## v0.3.22 — Ubicación LIP: Centrar todos solo donde toca

- Se quita **Centrar todos** del encabezado del modal.
- En escritorio sigue en la cabecera de la columna de acciones; en móvil, entre el mapa y las tarjetas.
- El **Centrar** por radio no cambia.

## v0.3.21 — Audio LST adaptativo + Geo sin fugas

- **PCM DL:** solo con despacho tomado. En llamada/RX activo vuelve a **80 ms** (latencia); en idle baja a **500 ms**.
- **Ubicación LIP:** al cerrar el modal se destruye el mapa Leaflet (deja de pedir tiles OSM) y no se vuelve a consultar `/api/lst/positions` hasta reabrir.
- Modal Geo: se elimina la barra redundante (Centrar todos + estado ISSI); **Centrar** / **Centrar todos** centrados en la columna de acciones (en móvil, Centrar todos pasa al encabezado).

## v0.3.20 — Dashboard más ligero (Pi)

- Tope de **32** conexiones HTTP(S) concurrentes: evita que el poll agresivo / reintentos tumben el proceso (ERR_CONNECTION_RESET).
- Menos re-renders por RSSI (debounce 250 ms); timers de timeslots 150→250 ms.
- Callsigns / LST status / Geo / service: no martillean la API si la pestaña está en segundo plano o el enlace está caído.

## v0.3.19 — Modal Ubicación LIP

- Título **Ubicación LIP** (antes Geo LIP).
- **Centrar todos** pasa al encabezado de la columna de acciones; en móvil se muestra encima de la tabla (el thead se apila).
- Se elimina Refresh (el modal ya refresca cada 5 s).
- Cierre (×) ya no se superpone con el separador del título en móvil.

## v0.3.18 — Filtro por tipo en Registro SDS

- Selector Todos / LIP / Texto / Estado / Concat / Home / Otros junto a Exportar.
- Se elimina Actualizar: el log se carga al abrir la pestaña y llega en vivo por WebSocket.

## v0.3.17 — Ubicación en Inicio (sin LST)

- Botón **Ubicación** en la tarjeta Radios registrados (Inicio): mismo modal Geo LIP que en LST.
- El almacén de posiciones LIP vive en el dashboard (no depende del perfil LST Dispatch).

## v0.3.16 — Botón Ubicación en roster LST

- El botón **Ubicación** pasa a la tarjeta Radios online (sustituye el Refresh manual, redundante con el poll automático).

## v0.3.15 — Marcador Geo LIP

- Pin de mapa propio (CSS, color accent del dashboard); ya no depende de las PNG rotas de Leaflet/CDN.
- Indicativo RadioID correcto en la tabla Geo.

## v0.3.14 — Geo LIP en despacho LST

- Las posiciones LIP decodificadas (SDS PID 10, UL) alimentan el almacén LST (`note_position`).
- Botón **Geo** en la consola LST: modal con tabla + mapa OpenStreetMap (Leaflet lazy, solo al abrir).
- Se ignoran coords 0,0 (handshake de inicialización). Requiere perfil LST Dispatch activo.

## v0.3.13 — LIP decode + Miura restante

- **LIP:** se decodifican informes cortos (SDS PID 10) a `LIP position: lat, lon` (ETSI TS 100 392-18-1). GeoAlarm/Telegram y el log SDS dejan de ver el payload vacío.
- **Miura (resto):** `mon_pattern` / MPN 1 en channel allocation (PTT largo Sepura); D-RELEASE también por FACCH en el timeslot de tráfico.

## v0.3.12 — Canal estable en `main`

- El canal **Estable** sigue la rama git **`main`**.

## v0.3.1

- **Grupos afiliados:** el panel del chevron (›) ya no desaparece al instante. Se queda abierto hasta cerrarlo (×, clic fuera, Escape o de nuevo el chevron). Antes lo cerraban el refresco del roster, el scroll y un timer de 3,5 s; el `title` nativo del botón también confundía en móvil.

## v0.3.0

Lanzamiento estable (canal OTA **Estable** / rama `main`). Consolida el trabajo de la línea 0.2.4–0.2.41: despacho LST en producción, preempt de PTT, dashboard HTTPS canónico y correcciones de campo.

### Actualización desde 0.2.x (estable)

- OTA a **Estable** / `main` o reinstalar con `install-ptbs.sh` (no sobrescribe `config.toml` existente).
- Al arrancar, si el dashboard seguía en puertos antiguos (`port = 8080`), se migra a `port = 80` + `https_port = 443`. Abre **`https://<IP>/`**.
- Redirecciones silenciosas en `:8080` / `:8443` se mantienen solo por compatibilidad de marcadores viejos; **instalación e interfaz ya no anuncian esos puertos**.
- Codec de voz LST: si falta, el OTA ofrece rebuild con libtetra-codec (sin SSH).

### Despacho LST (consola local)

- Consola bajo Integraciones: claim de sesión, ISSI despachador, lista de escaneo multi-TG, PTT (ratón/táctil/espacio), SDS, roster, actividad e inbox SDS.
- Llamadas privadas simplex/dúplex (salientes y entrantes); modal/franja de llamada.
- Audio ACELP vía codec OTA; dashboard canónico en HTTPS `:443` (HTTP `:80` redirige).
- **Preempt / interrupción:** PTT LST puede quitar el suelo a un MS local (deny → oferta → Ready al UL quiet); sin teardown de circuito; sin flicker de display Motorola tras Ready.
- Tras PTT de grupo, el dial privado SX/DX ya no queda bloqueado como “Establecida” con el GSSI.
- Modal de llamada entrante solo en el navegador que tiene el despacho tomado (no molesta a otros agentes del dashboard).

### Dashboard / Config / red

- Dashboard HTTPS `:443` + redirect HTTP `:80` (instalador y docs alineados).
- Ayuda «?» en Config (timers TETRA/Brew); whitelist ISSI en perfil Cell; fix TOML con 2+ ISSIs (evita arranque en fallback).
- Wi‑Fi resiliencia (NM drop-in, autoconnect, watchdog) desde 0.2.2–0.2.3.
- Pulidos UX LST/móvil, iconos de navegación, perfiles Cell × Brew.

### Limpieza en 0.3.0

- Eliminado el botón “Abrir consola segura (HTTPS)” del despacho (la UI ya sirve en HTTPS).
- Mensajes de instalador / README / example_config sin publicar `:8080` / `:8443`.

## v0.2.7

- **LST Dispatch:** admit group `NetworkCallStart` without Brew (inbound gate). Join solo selecciona GSSI; PTT abre/cierra la llamada. SDS usa el ISSI del despacho (`source_issi` / `dest_is_group`). Privadas: media ready, duplex UL, errores visibles.

## v0.2.6

- Fix LST PTT borrow-checker errors so `tetra-entities` compiles on OTA.

## v0.2.5

- Fix OTA build: import `CfgLstDispatch` / `apply_lst_dispatch_patch` in tetra-config.

## v0.2.4

- **Despacho LST / LST Dispatch:** consola local bajo Integraciones (mic/altavoz del navegador). Perfil Brew inmutable “Despacho LST”, 1 sesión, XOR con Brew real. Grupo + privadas simplex/dúplex + SDS + roster; codec de voz si el build incluye `asterisk`.

## v0.2.3

- OTA / arranque aplican solos el drop-in NetworkManager `ptbs-wifi.conf` (powersave off): **no hace falta SSH**.

## v0.2.2

- **WiFi resiliencia:** Disconnect usa `connection down` (ya no inhibe autoconnect). Al conectar se fuerza autoconnect + powersave off en el perfil. Watchdog ligero re-sube un perfil guardado si el enlace cae con la radio WiFi encendida.
- Instalador: drop-in NetworkManager `ptbs-wifi.conf` (`wifi.powersave=2`). Docs de comprobación en install-and-setup.

## v0.2.1

- Config U-STATUS: en PC los comandos vuelven a una sola fila (código | acción | Quitar); el layout móvil compacto no cambia.

## v0.2.0

Lanzamiento estable con cambios de producto (no solo parches). Canal OTA **Estable** (`ptbs`).

- **Dashboard móvil:** shell, System/OTA/Setup, tablas, RF/Health, Config, DGNA/Geoalarm/Wi‑Fi e integraciones usables en teléfono (PC sin cambios de layout salvo lo acordado).
- **OTA más robusto:** modal al instante, checks coalescidos y en caché, purge de `.git` vacío, mensajes claros, espera post-reinicio que exige “caída → subida” y lleva a login cuando hay auth (evita SPA “fuera de línea”).
- **Config / perfiles:** timers de Advanced network con reset a default (vacío = default del motor); Live y perfiles Cell comparten la misma semántica de persistencia.
- **Home:** perfiles rápidos Cell × Brew; pulidos de UI (Save al pie, mensajes vacíos, U-STATUS compacto, etc.).

## v0.1.57

- Instalador alineado con OTA: fetch con refspec + reintentos, `reset --hard`, y `ota_channel` según `PTBS_BRANCH`.
- README / docs de instalación actualizados (comando curl desde la rama `main`).

## v0.1.56

- OTA: reintentos de `git fetch` ante cortes TLS/red (p. ej. GnuTLS en Pi).

## v0.1.55

- Paso Progreso OTA: estado superior corto, tip distinto bajo la barra y tiempo transcurrido en negrita.

## v0.1.54

- Novedades humanas en la pantalla de actualización (CHANGELOG / Releases).
- El banner de “actualización disponible” abre directamente el resumen de cambios.
- Modal OTA con indicador de pasos más claro (canal → novedades → progreso).

## v0.1.53

- Corrección de compilación en el helper de permisos OTA (`append` / `&str`).

## v0.1.52

- Tras sincronizar el código como root, se ajusta la propiedad de todo el árbol de fuentes
  (no solo `target/`) para que `cargo` como usuario `bts` no falle en `Cargo.lock`.

## v0.1.51

- Al cambiar de canal (p. ej. a Beta), el fetch crea correctamente `origin/<rama>`
  para que la actualización no falle con “unknown revision”.

## v0.1.50

- Diálogo OTA en tres pasos: elegir canal, ver novedades y confirmar, luego progreso.
- El selector de canal se guarda y sigue alimentando el badge / banner automático.

## v0.1.49

- Corrección de un error de compilación en la configuración del canal OTA.

## v0.1.48

- Canales OTA **Estable** (`ptbs`) y **Beta** (`beta`).
- Sincronización segura con `git reset --hard` (recupera force-push) manteniendo `target/`
  para builds incrementales.
- Si el binario ya coincide con HEAD, no se recompila ni se reinicia en falso.
