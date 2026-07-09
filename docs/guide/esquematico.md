# Esquemático de la Tarjeta

El curso incluye el esquemático de referencia de la Tang Nano 9K para revisar conexiónes fisicas antes de cambiar un `pins.cst` o conectar hardware externo.

## Archivo

- [Abrir esquemático Tang Nano 9K](/guide/Tang_Nano_9k_3672_Schematic.pdf)

## Para Qué Usarlo

Usa el esquemático cuando necesites confirmar:

- Que pin físico corresponde a un LED, botón, reloj o conector.
- Que banco de la FPGA alimenta una señal.
- Que voltaje corresponde al `IO_TYPE` usado en el `.cst`.
- Si una señal es activa en alto o activa en bajo.
- Si un botón o entrada necesita `PULL_MODE=UP`.

## Relación con `pins.cst`

El esquemático muestra la conexión electrica real de la tarjeta. El archivo `pins.cst` traduce esa conexión a restricciones para el toolchain Gowin.

```text
HDL top port  ->  pins.cst  ->  pin FPGA  ->  circuito en esquemático
```

Ejemplo:

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;
```

En este caso el puerto HDL `clk` queda asignado al pin físico 52. Antes de usarlo en otro diseño, confirma en el esquemático que ese pin corresponde al reloj de la tarjeta y que el banco usa el voltaje esperado.

## Checklist al Cambiar Pines

1. Localiza el recurso en el esquemático: LED, botón, conector o reloj.
2. Anota el pin físico de la FPGA.
3. Revisa el voltaje del banco.
4. Actualiza `IO_LOC` con el número de pin.
5. Actualiza `IO_TYPE` con el estándar eléctrico correcto.
6. Usa sufijo `_n` si la señal es activa en bajo.
7. Compila con `devlab build` antes de cargar en placa.

## Referencias del Curso

- [Archivos CST](./cst.md)
- [Ruta del curso](./curso.md)
- [Digital Labs](../examples/digital-labs/index.md)
