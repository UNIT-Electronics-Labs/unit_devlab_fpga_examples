# Practica 12: Contador con arranque, paro y reset

Compilar con DevLab:

```bash
cd digital-labs/12_contador_arranque_paro_reset
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/12_contador_arranque_paro_reset
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/12_contador_arranque_paro_reset
```

`key_enable_n` funciona como arranque/paro.
