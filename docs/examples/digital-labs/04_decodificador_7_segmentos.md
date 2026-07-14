# 04 Decodificador de 7 Segmentos

Práctica de contador decimal para exhibidor de 7 segmentos de 2 dígitos.

## Objetivo

Mostrar números de `00` a `99` usando el mapeo de segmentos identificado en la tarjeta.

## Demostración en Placa

El `top` multiplexa dos dígitos de 7 segmentos y muestra un contador decimal.

- `digit_en[0]` y `digit_en[1]` habilitan cada dígito en nivel bajo.
- `seg[7:0]` usa el orden `a,b,c,d,e,f,g,p` y enciende cada segmento con `0`.
- `key_reset_n` reinicia a `00` al presionar.
- `key_enable_n` suma una unidad por pulsación.

## Verilog

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulos reutilizables para la versión con contador.
- `src/top.v`: conexión Verilog.
- `src/top.vhd`: versión VHDL.

## Restricciones de Pines

El archivo `pins.cst` conecta los puertos del `top` con los pines fisicos de la tarjeta. En esta práctica se prueban 8 GPIO para segmentos y 2 GPIO para habilitar los dígitos.

| Señal | Segmento o función | Pin de tarjeta | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- | --- |
| `seg[7]` | `a` | GPIO 37 | 37 | `LVCMOS33` |
| `seg[6]` | `b` | GPIO 25 | 25 | `LVCMOS33` |
| `seg[5]` | `c` | GPIO 26 | 26 | `LVCMOS33` |
| `seg[4]` | `d` | GPIO 28 | 28 | `LVCMOS33` |
| `seg[3]` | `e` | GPIO 27 | 27 | `LVCMOS33` |
| `seg[2]` | `f` | GPIO 36 | 36 | `LVCMOS33` |
| `seg[1]` | `g` | GPIO 39 | 39 | `LVCMOS33` |
| `seg[0]` | `p` | GPIO 38 | 38 | `LVCMOS33` |
| `digit_en[0]` | decenas, activo en 0 | GPIO 31 | 31 | `LVCMOS33` |
| `digit_en[1]` | unidades, activo en 0 | GPIO 32 | 32 | `LVCMOS33` |

```text [pins.cst]
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;

IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "seg[7]" 37;
IO_PORT "seg[7]" IO_TYPE=LVCMOS33;

IO_LOC "seg[6]" 25;
IO_PORT "seg[6]" IO_TYPE=LVCMOS33;

IO_LOC "seg[5]" 26;
IO_PORT "seg[5]" IO_TYPE=LVCMOS33;

IO_LOC "seg[4]" 28;
IO_PORT "seg[4]" IO_TYPE=LVCMOS33;

IO_LOC "seg[3]" 27;
IO_PORT "seg[3]" IO_TYPE=LVCMOS33;

IO_LOC "seg[2]" 36;
IO_PORT "seg[2]" IO_TYPE=LVCMOS33;

IO_LOC "seg[1]" 39;
IO_PORT "seg[1]" IO_TYPE=LVCMOS33;

IO_LOC "seg[0]" 38;
IO_PORT "seg[0]" IO_TYPE=LVCMOS33;

IO_LOC "digit_en[0]" 31;
IO_PORT "digit_en[0]" IO_TYPE=LVCMOS33;

IO_LOC "digit_en[1]" 32;
IO_PORT "digit_en[1]" IO_TYPE=LVCMOS33;
```

## Código Fuente

El código completo está en:

- `digital-labs/04_decodificador_7_segmentos/src/top.v`
- `digital-labs/04_decodificador_7_segmentos/src/top.vhd`

Ambas versiones implementan antirrebote para `key_enable_n`, contador decimal `00` a `99` y multiplexado de unidades/decenas.

## Teoría Mínima

Esta versión usa el pinout ya identificado y activa segmentos/dígitos en nivel bajo.

## Procedimiento

1. Conecta `seg[7:0]` al display en orden `a,b,c,d,e,f,g,p`; cada segmento enciende al ir a `0`.
2. Conecta `digit_en[0]` y `digit_en[1]` a las habilitaciones de dígito activas en `0`.
3. Compila y carga.
4. Pulsa `key_enable_n` para avanzar el contador.
5. Presiona `key_reset_n` para volver a `00`.
6. Repite con VHDL si quieres comparar ambas implementaciones.

## Actividades

- Cambia el antirrebote ajustando `DEBOUNCE_MAX`.
- Cambia el orden del conteo para hacerlo descendente.
- Agrega una condición para detenerse en `99`.

## Entregable

Foto del display mostrando al menos tres valores distintos y explicación del mapeo de segmentos.
