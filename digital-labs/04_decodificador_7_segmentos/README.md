# Practica 04: Decodificador a exhibidor de 7 segmentos

Compilar con DevLab:

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/04_decodificador_7_segmentos
```

Esta practica instancia `seven_segment_decoder`.

El `top` actual muestra en `led_n` el segmento `a` del numero formado con dos entradas.
