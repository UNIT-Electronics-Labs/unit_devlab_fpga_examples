# Practica 14: Maquina Mealy

Compilar con DevLab:

```bash
cd digital-labs/14_maquina_mealy
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/14_maquina_mealy
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/14_maquina_mealy
```

Implementa un detector de secuencia `101` con salida tipo Mealy.
