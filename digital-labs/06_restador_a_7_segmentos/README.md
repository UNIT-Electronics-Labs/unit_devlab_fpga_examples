# Practica 06: Restador binario a exhibidor de 7 segmentos

Compilar con DevLab:

```bash
cd digital-labs/06_restador_a_7_segmentos
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/06_restador_a_7_segmentos
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/06_restador_a_7_segmentos
```

Esta practica instancia `subtract_to_7seg`.
