# Practica 15: DAC R-2R de 8 bits

Esta practica genera tres formas de onda para validar una salida DAC R-2R de 8 bits.

- Modo 0: rampa de `0x00` a `0xFF`.
- Modo 1: seno con tabla de 32 muestras.
- Modo 2: cuadrada entre `0x00` y `0xFF`.
- `key_enable_n`: cambia de modo en cada pulsacion.
- `key_reset_n`: regresa a rampa y reinicia la fase.
- Las tres formas apuntan a `1 kHz`.
- Por el divisor entero del reloj, la rampa queda cerca de `1004 Hz` y seno/cuadrada cerca de `1001 Hz`.

Compilar y cargar:

```bash
cd digital-labs/15_dac_r2r_8_bits
devlab build
devlab flash
```

Para probar VHDL:

```bash
devlab build -c devlab-vhdl.toml
```

## Conexion R-2R

Conecta `dac[7]` como MSB y `dac[0]` como LSB. Mide la salida analogica de la red R-2R con osciloscopio. Al cargar inicia en rampa; cada pulsacion de `key_enable_n` cambia a seno, cuadrada y de vuelta a rampa.

| Senal | Funcion | Pin FPGA |
| --- | --- | --- |
| `dac[7]` | MSB | 51 |
| `dac[6]` | bit 6 | 42 |
| `dac[5]` | bit 5 | 41 |
| `dac[4]` | bit 4 | 35 |
| `dac[3]` | bit 3 | 40 |
| `dac[2]` | bit 2 | 39 |
| `dac[1]` | bit 1 | 34 |
| `dac[0]` | LSB | 33 |

Nota: la lista original tenia 9 valores y pines repetidos. Esta version usa 8 pines unicos para un DAC de 8 bits: `51, 42, 41, 35, 40, 39, 34, 33`.
