# Esquemático de la Tarjeta

El curso incluye el esquematico de referencia de la Tang Nano 9K para revisar conexiones fisicas antes de cambiar un `pins.cst` o conectar hardware externo.

## Archivo

- [Abrir esquematico Tang Nano 9K](/guide/Tang_Nano_9k_3672_Schematic.pdf)

## Para Qué Usarlo

Usa el esquematico cuando necesites confirmar:

- Que pin fisico corresponde a un LED, boton, reloj o conector.
- Que banco de la FPGA alimenta una senal.
- Que voltaje corresponde al `IO_TYPE` usado en el `.cst`.
- Si una senal es activa en alto o activa en bajo.
- Si un boton o entrada necesita `PULL_MODE=UP`.

## Relación con `pins.cst`

El esquematico muestra la conexion electrica real de la tarjeta. El archivo `pins.cst` traduce esa conexion a restricciones para el toolchain Gowin.

```text
HDL top port  ->  pins.cst  ->  pin FPGA  ->  circuito en esquematico
```

Ejemplo:

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;
```

En este caso el puerto HDL `clk` queda asignado al pin fisico 52. Antes de usarlo en otro diseno, confirma en el esquematico que ese pin corresponde al reloj de la tarjeta y que el banco usa el voltaje esperado.

## Checklist al Cambiar Pines

1. Localiza el recurso en el esquematico: LED, boton, conector o reloj.
2. Anota el pin fisico de la FPGA.
3. Revisa el voltaje del banco.
4. Actualiza `IO_LOC` con el numero de pin.
5. Actualiza `IO_TYPE` con el estandar electrico correcto.
6. Usa sufijo `_n` si la senal es activa en bajo.
7. Compila con `devlab build` antes de cargar en placa.

## Referencias del Curso

- [Archivos CST](./cst.md)
- [Ruta del curso](./curso.md)
- [Digital Labs](../examples/digital-labs/index.md)
