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

Esta practica muestra un contador decimal de dos digitos.

El `top` multiplexa dos digitos de 7 segmentos con salidas activas en bajo.

- `digit_en[0]` y `digit_en[1]`: habilitan cada digito en nivel bajo.
- `seg[7:0]`: segmentos en orden `a,b,c,d,e,f,g,p`, activos en bajo.
- `key_reset_n`: reinicia a `00` al presionar.
- `key_enable_n`: suma una unidad por pulsacion.

Uso:

1. Compila y carga.
2. Pulsa `key_enable_n` para avanzar el contador.
3. Presiona `key_reset_n` para regresar a `00`.

Mapeo de salida:

| Señal | Funcion | Pin de tarjeta | Voltaje |
| --- | --- | --- | --- |
| `seg[7]` | `a` | GPIO 37 | 3.3 V |
| `seg[6]` | `b` | GPIO 25 | 3.3 V |
| `seg[5]` | `c` | GPIO 26 | 3.3 V |
| `seg[4]` | `d` | GPIO 28 | 3.3 V |
| `seg[3]` | `e` | GPIO 27 | 3.3 V |
| `seg[2]` | `f` | GPIO 36 | 3.3 V |
| `seg[1]` | `g` | GPIO 39 | 3.3 V |
| `seg[0]` | `p` | GPIO 38 | 3.3 V |
| `digit_en[0]` | decenas, activo en 0 | GPIO 31 | 3.3 V |
| `digit_en[1]` | unidades, activo en 0 | GPIO 32 | 3.3 V |
