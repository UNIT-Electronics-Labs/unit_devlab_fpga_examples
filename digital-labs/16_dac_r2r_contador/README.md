# Practica 16: DAC R-2R con contador de modo

Esta practica combina el DAC R-2R de 8 bits con un display de dos digitos.

- `01`: rampa triangular.
- `02`: diente de sierra.
- `03`: cuadrada.
- `04`: sinusoidal.
- `key_enable_n`: cambia de modo en cada pulsacion.
- `key_reset_n`: regresa a `01`.
- El DAC genera la senal al mismo tiempo que el display muestra el modo.

Compilar y cargar:

```bash
cd digital-labs/16_dac_r2r_contador
devlab build
devlab flash
```

Para probar VHDL:

```bash
devlab build -c devlab-vhdl.toml
```

## Conexion

El display usa el pinout validado en la practica 04. El DAC usa el pinout de la practica 15, pero `dac[2]` se movio a GPIO30 para evitar conflicto con `seg[1]` en GPIO39.

| Senal | Funcion | Pin FPGA |
| --- | --- | --- |
| `dac[7]` | MSB | 51 |
| `dac[6]` | bit 6 | 42 |
| `dac[5]` | bit 5 | 41 |
| `dac[4]` | bit 4 | 35 |
| `dac[3]` | bit 3 | 40 |
| `dac[2]` | bit 2 | 30 |
| `dac[1]` | bit 1 | 34 |
| `dac[0]` | LSB | 33 |
| `seg[7:0]` | segmentos | 37,25,26,28,27,36,39,38 |
| `digit_en[0]` | decenas | 31 |
| `digit_en[1]` | unidades | 32 |

## Frecuencia

Las formas apuntan a `1 kHz`. Por divisores enteros del reloj de `27 MHz`, la frecuencia queda cercana a `1 kHz`.
