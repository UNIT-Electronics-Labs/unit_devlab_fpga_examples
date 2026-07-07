# HDMI con OSS CAD Suite

Este ejemplo queda integrado al flujo comun del repositorio.

Desde la raiz del proyecto:

```sh
make hdmi
```

Desde este directorio:

```sh
make
```

Los archivos compilados quedan en `build/`:

- `build/top.json`
- `build/top_pnr.json`
- `build/top.fs`

Para programar el bitstream:

```sh
make flash
```

Para usar otra ruta de OSS CAD Suite:

```sh
make OSS_CAD_SUITE=/ruta/a/oss-cad-suite
```
