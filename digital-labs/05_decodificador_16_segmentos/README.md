# Practica 05: Decodificador a exhibidor de 16 segmentos

Compilar con DevLab:

```bash
cd digital-labs/05_decodificador_16_segmentos
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/05_decodificador_16_segmentos
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/05_decodificador_16_segmentos
```

Esta practica instancia `sixteen_segment_decoder`.

El `top` actual muestra en `led_n` uno de los segmentos decodificados.
