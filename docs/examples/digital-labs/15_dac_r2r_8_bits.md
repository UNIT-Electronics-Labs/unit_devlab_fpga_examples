# 15 DAC R-2R de 8 bits

Practica para generar rampa, seno y cuadrada en una salida DAC R-2R conectada a GPIO.

## Objetivo

Generar tres formas de onda para comprobar que los 8 bits cambian y que la red R-2R produce una salida analogica:

- Modo 0: rampa de `0x00` a `0xFF`.
- Modo 1: seno con tabla de 32 muestras.
- Modo 2: cuadrada entre `0x00` y `0xFF`.
- `key_enable_n`: cambia de modo en cada pulsacion.
- `key_reset_n`: regresa a rampa y reinicia la fase.
- Las tres formas apuntan a `1 kHz`.
- Por el divisor entero del reloj, la rampa queda cerca de `1004 Hz` y seno/cuadrada cerca de `1001 Hz`.

## Demostracion en Placa

```bash
cd digital-labs/15_dac_r2r_8_bits
devlab build
devlab flash
```

Al cargar la practica inicia en rampa. Cada pulsacion de `key_enable_n` cambia a seno, cuadrada y de vuelta a rampa. Si mides la salida analogica del R-2R con osciloscopio, debes ver la forma seleccionada.

## VHDL

```bash
cd digital-labs/15_dac_r2r_8_bits
devlab build -c devlab-vhdl.toml
```

## Pinout

La salida esta ordenada de MSB a LSB para conectar la red R-2R.

| Senal | Funcion | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- |
| `dac[7]` | MSB | 51 | `LVCMOS33` |
| `dac[6]` | bit 6 | 42 | `LVCMOS33` |
| `dac[5]` | bit 5 | 41 | `LVCMOS33` |
| `dac[4]` | bit 4 | 35 | `LVCMOS33` |
| `dac[3]` | bit 3 | 40 | `LVCMOS33` |
| `dac[2]` | bit 2 | 39 | `LVCMOS33` |
| `dac[1]` | bit 1 | 34 | `LVCMOS33` |
| `dac[0]` | LSB | 33 | `LVCMOS33` |

```text [pins.cst]
IO_LOC "dac[7]" 51;
IO_PORT "dac[7]" IO_TYPE=LVCMOS33;

IO_LOC "dac[6]" 42;
IO_PORT "dac[6]" IO_TYPE=LVCMOS33;

IO_LOC "dac[5]" 41;
IO_PORT "dac[5]" IO_TYPE=LVCMOS33;

IO_LOC "dac[4]" 35;
IO_PORT "dac[4]" IO_TYPE=LVCMOS33;

IO_LOC "dac[3]" 40;
IO_PORT "dac[3]" IO_TYPE=LVCMOS33;

IO_LOC "dac[2]" 39;
IO_PORT "dac[2]" IO_TYPE=LVCMOS33;

IO_LOC "dac[1]" 34;
IO_PORT "dac[1]" IO_TYPE=LVCMOS33;

IO_LOC "dac[0]" 33;
IO_PORT "dac[0]" IO_TYPE=LVCMOS33;
```

## Teoria Minima

Una red R-2R suma corrientes ponderadas por bit. El MSB aporta la mitad del rango, el siguiente bit aporta un cuarto, y asi sucesivamente. Con 8 bits se obtienen 256 niveles teoricos.

La rampa usa 256 pasos por ciclo. El seno y la cuadrada usan 32 muestras por ciclo. Con reloj de `27 MHz`, los divisores enteros usados dejan las tres formas alrededor de `1 kHz`.

## Actividades

- Mide la salida analogica del R-2R con osciloscopio en los tres modos.
- Confirma que el MSB y LSB estan conectados en el orden esperado.
- Usa `key_reset_n` para regresar a rampa si pierdes el modo actual.

## Nota de Pines

La lista original tenia 9 valores y pines repetidos. Para compilar esta practica se usaron 8 pines unicos: `51, 42, 41, 35, 40, 39, 34, 33`.
