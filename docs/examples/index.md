# Ejemplos

Este repositorio agrupa ejemplos basicos y practicas de sistemas digitales para FPGA Gowin. La referencia actual usa el dispositivo `GW1NR-LV9QN88PC6/I5`, pero la tarjeta target se puede cambiar ajustando `pins.cst` y la seccion `[flash]` de DevLab.

Repositorio fuente:
[UNIT-Electronics-Labs/unit_devlab_fpga_examples](https://github.com/UNIT-Electronics-Labs/unit_devlab_fpga_examples)

Los ejemplos básicos viven en carpetas de primer nivel (`blink/`, `and/`, `or/`, `not/`). Las prácticas completas del curso están en `digital-labs/`.

```text
unit_devlab_fpga_examples/
|-- blink/
|-- and/
|-- or/
|-- not/
`-- digital-labs/
    |-- 01_sumador_n_bits/
    |-- 02_restador_n_bits/
    |-- ...
    `-- 14_maquina_mealy/
```

## Básicos

- [Blink](./basic/blink.md): contador con reloj y LED.
- [AND](./basic/and.md): compuerta AND con dos entradas.
- [OR](./basic/or.md): compuerta OR con dos entradas.
- [NOT](./basic/not.md): inversor con una entrada.

## Digital Labs

- [Indice de practicas](./digital-labs/index.md)

## Flujo Recomendado

```bash
cd and
devlab build
devlab flash
```

Para VHDL:

```bash
devlab build -c devlab-vhdl.toml
```
