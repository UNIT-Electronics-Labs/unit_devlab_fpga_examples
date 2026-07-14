# Digital Labs

Practicas separadas para sistemas digitales con la misma estructura DevLab
que los ejemplos basicos del repositorio.

Cada practica usa:

- `devlab.toml`: build Verilog por defecto.
- `devlab-vhdl.toml`: build VHDL explicito.
- `src/top.v`: top-level Verilog.
- `src/top.vhd`: version VHDL autocontenida.
- `src/digital_labs.v`: modulos Verilog de apoyo.
- `pins.cst`: restricciones de pines Gowin CST.
- `Makefile`: compatibilidad para Linux.

## Practicas

Combinacionales:

- `01_sumador_n_bits`
- `02_restador_n_bits`
- `03_comparador_n_bits`
- `04_decodificador_7_segmentos`
- `05_decodificador_16_segmentos`
- `06_restador_a_7_segmentos`
- `07_alu_n_bits`

Secuenciales:

- `08_senal_reloj`
- `09_contador_ascendente`
- `10_contador_descendente`
- `11_contador_ascendente_descendente`
- `12_contador_arranque_paro_reset`
- `13_maquina_moore`
- `14_maquina_mealy`
- `15_dac_r2r_8_bits`
- `16_dac_r2r_contador`

## Requisitos

- Python 3.11+
- devlab-fpga instalado: `pip install devlab-fpga`
- OSS CAD Suite instalado por devlab con `devlab install`

## Compilar una practica con DevLab

Desde la carpeta de la practica:

```bash
cd digital-labs/01_sumador_n_bits
devlab build
devlab flash
```

`devlab.toml` compila Verilog por defecto para mantener el flujo portable
entre Linux, Windows y macOS. Para probar VHDL explicitamente:

```bash
devlab build -c devlab-vhdl.toml
```

## Compatibilidad Make/Linux

```bash
make -C digital-labs/01_sumador_n_bits
```

Por defecto el `Makefile` compila VHDL. Para compilar Verilog:

```bash
make -C digital-labs/01_sumador_n_bits HDL=verilog
```

## Compilar todas con Make/Linux

```bash
make digital-labs
```

Cada practica genera su propio bitstream:

```text
digital-labs/<practica>/build/top.fs
```

## Pines comunes

Cada practica incluye su propio `pins.cst`:

- `clk`: pin 52
- `key_reset_n`: pin 3
- `key_enable_n`: pin 4
- `led_n`: pin 16

En practicas combinacionales, `key_reset_n` y `key_enable_n` se reutilizan como entradas binarias simples.
