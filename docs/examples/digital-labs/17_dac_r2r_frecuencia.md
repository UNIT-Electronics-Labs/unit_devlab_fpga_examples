# Práctica 17: seno DAC con frecuencia seleccionable

## Objetivo

Generar una onda sinusoidal en el DAC R-2R de 8 bits y controlar su frecuencia
con los dos botones de la Tang Nano 9K: 500 Hz, 1 kHz, 1.5 kHz, 2 kHz, 3 kHz
o 4 kHz. Estas
frecuencias son apropiadas para observarse con un osciloscopio de 250 kS/s.

## Controles

- `key_down_n` (GPIO3): baja un nivel.
- `key_up_n` (GPIO4): sube un nivel.
- El display muestra el nivel seleccionado de `01` a `06`.
- El nivel inicial es `02 = 1 kHz`.
- El contador se detiene al llegar al mínimo o al máximo.

| Display | Frecuencia nominal | Incremento DDS |
| --- | ---: | ---: |
| `01` | 500 Hz | 79 536 |
| `02` | 1 kHz | 159 073 |
| `03` | 1.5 kHz | 238 609 |
| `04` | 2 kHz | 318 146 |
| `05` | 3 kHz | 477 219 |
| `06` | 4 kHz | 636 291 |

## Flujo DDS

El acumulador de fase se actualiza en cada ciclo del reloj de 27 MHz:

```text
botones -> índice 01..06 -> incremento de fase
                                  |
reloj 27 MHz -> acumulador DDS -> LUT seno de 32 muestras -> DAC R-2R
```

La relación utilizada es:

```text
incremento = redondear(f_salida * 2^32 / 27 000 000)
```

Con una captura de 250 kS/s, el osciloscopio obtiene aproximadamente 500
muestras por periodo a 500 Hz, 250 a 1 kHz, 167 a 1.5 kHz, 125 a 2 kHz,
83 a 3 kHz y 62 a 4 kHz.

## Pinout

| Señal | Función | Pin FPGA |
| --- | --- | ---: |
| `clk` | Reloj de 27 MHz | 52 |
| `key_down_n` | Disminuir frecuencia | 3 |
| `key_up_n` | Aumentar frecuencia | 4 |
| `dac[7:0]` | DAC, de MSB a LSB | 51, 42, 41, 35, 40, 30, 34, 33 |
| `seg[7:0]` | Segmentos | 37, 25, 26, 28, 27, 36, 39, 38 |
| `digit_en[1:0]` | Selección de dígito | 32, 31 |

## Compilar

```bash
cd digital-labs/17_dac_r2r_frecuencia
devlab build
devlab flash
```

Para compilar la versión VHDL:

```bash
devlab build -c devlab-vhdl.toml
```

## Prueba sugerida

1. Conecta el osciloscopio a la salida de la red R-2R y comparte tierra.
2. Verifica que al encender el display indique `02` y se midan cerca de 1 kHz.
3. Pulsa el botón de incremento y compara cada nivel con la tabla.
4. Usa el botón de decremento hasta regresar a `01 = 500 Hz`.

::: warning Salida analógica
La salida GPIO es una aproximación escalonada de ocho bits. Usa una red R-2R
con valores adecuados y, si necesitas una senoide más limpia, agrega un filtro
pasa-bajas y un buffer; no conectes una carga de baja impedancia directamente.
:::
