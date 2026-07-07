# Practica 13: Maquina Moore

Compilar con DevLab:

```bash
cd digital-labs/13_maquina_moore
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/13_maquina_moore
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/13_maquina_moore
```

Implementa un detector de secuencia `101` con salida tipo Moore.
