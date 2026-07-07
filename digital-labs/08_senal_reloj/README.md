# Practica 08: Senal de reloj

Compilar con DevLab:

```bash
cd digital-labs/08_senal_reloj
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/08_senal_reloj
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/08_senal_reloj
```

Esta practica divide el reloj principal y lo muestra en el LED.
