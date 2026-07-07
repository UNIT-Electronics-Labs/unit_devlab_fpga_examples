# Practica 02: Restador binario en paralelo de N bits

Compilar con DevLab:

```bash
cd digital-labs/02_restador_n_bits
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/02_restador_n_bits
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/02_restador_n_bits
```

Esta practica instancia `nbit_subtractor`.

Salida:

- `led_n`: `diff[0]`, activo bajo
