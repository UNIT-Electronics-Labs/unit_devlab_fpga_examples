# Digital Labs

Practicas separadas en Verilog para sistemas digitales.

Cada practica conserva la misma estructura plana que los ejemplos simples:

- `top.v`
- `top.vhd`
- `Makefile`
- `README.md`
- `pins.cst`
- `digital_labs.v`

`top.vhd` es la version VHDL autocontenida. `top.v` y `digital_labs.v` son la version Verilog local de cada practica.

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

## Compilar una practica

```bash
make -C digital-labs/01_sumador_n_bits
```

Por defecto compila VHDL. Para compilar Verilog:

```bash
make -C digital-labs/01_sumador_n_bits HDL=verilog
```

## Compilar todas

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
