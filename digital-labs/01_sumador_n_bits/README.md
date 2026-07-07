# Practica 01: Sumador binario en paralelo de N bits

Compilar con DevLab:

```bash
cd digital-labs/01_sumador_n_bits
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/01_sumador_n_bits
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/01_sumador_n_bits
```

Esta practica instancia `nbit_adder`.

Entradas de demostracion:

- `key_reset_n`: bit `a[0]`
- `key_enable_n`: bit `b[0]`

Salida:

- `led_n`: resultado `sum[0]`, activo bajo
