# AND

Ejemplo de compuerta AND usando las entradas GPIO 3 y GPIO 4 con pull-up.

- `gpio3_n`: pin 3, entrada con pull-up.
- `gpio4_n`: pin 4, entrada con pull-up.
- `led_n`: pin 16, LED activo en bajo.

Las entradas se invierten dentro del HDL para que `a` y `b` valgan `1` cuando la entrada esta en bajo. El LED se enciende cuando `a AND b` vale `1`.

```sh
make
make flash
```

Los archivos generados quedan en `build/`, incluyendo `build/top.fs`.

Por defecto el entorno comun `../mk/common.mk` busca oss-cad-suite en `~/oss-cad-suite`. Si esta en otra ruta:

```sh
make OSS_CAD_SUITE=/ruta/a/oss-cad-suite
```

Tambien puedes compilar la version Verilog:

```sh
make HDL=verilog
```
