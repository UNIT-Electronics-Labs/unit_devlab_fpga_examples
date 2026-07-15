# Practica 17: seno DAC con frecuencia seleccionable

Esta practica genera una onda sinusoidal con un DAC R-2R de 8 bits y permite
cambiar su frecuencia con los dos botones de la Tang Nano 9K.

- `key_down_n`: baja una frecuencia.
- `key_up_n`: sube una frecuencia.
- El display muestra el nivel `01` a `06`.
- Al encender inicia en `02`, equivalente a `1 kHz`.
- En los extremos, el contador se mantiene en `01` o `06`.

| Nivel | Frecuencia |
| --- | ---: |
| `01` | 500 Hz |
| `02` | 1 kHz |
| `03` | 1.5 kHz |
| `04` | 2 kHz |
| `05` | 3 kHz |
| `06` | 4 kHz |

## Compilar y cargar

```bash
cd digital-labs/17_dac_r2r_frecuencia
devlab build
devlab flash
```

Para VHDL:

```bash
devlab build -c devlab-vhdl.toml
```

## Funcionamiento

El generador usa DDS: un acumulador de fase de 32 bits avanza en cada ciclo del
reloj de 27 MHz y sus cinco bits superiores consultan una tabla de 32 muestras.
Esto mantiene buena precisión para las seis frecuencias y permite conservar una
fase continua al cambiar de nivel.

La red R-2R y el display conservan el pinout de la práctica 16. Conecta
`dac[7]` como MSB y `dac[0]` como LSB y mide la salida analógica con un
osciloscopio.
