# Practica 07: Unidad aritmetica y logica de N bits

Compilar con DevLab:

```bash
cd digital-labs/07_alu_n_bits
devlab build
devlab flash
```

Para probar VHDL explicitamente:

```bash
cd digital-labs/07_alu_n_bits
devlab build -c devlab-vhdl.toml
```

El `Makefile` queda como compatibilidad para Linux:

```bash
make -C digital-labs/07_alu_n_bits
```

Esta practica instancia `nbit_alu`.

El `top` usa operacion suma (`op = 0`).
