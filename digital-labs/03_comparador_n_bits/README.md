# Practica 03: Comparador binario de N bits

Compilar con DevLab:

```bash
cd digital-labs/03_comparador_n_bits
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/03_comparador_n_bits
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/03_comparador_n_bits
```

Esta practica instancia `nbit_comparator`.

Salida:

- `led_n`: encendido cuando `a == b`
