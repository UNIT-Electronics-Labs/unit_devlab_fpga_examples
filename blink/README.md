

wget https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-06-07/oss-cad-suite-linux-x64-20260607.tgz

or


wget -O oss-cad-suite.tgz https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-06-07/oss-cad-suite-linux-x64-20260607.tgz

yosys -V
nextpnr-himbaechel --version
gowin_pack --help
openFPGALoader --version



echo 'source ~/oss-cad-suite/environment' >> ~/.bashrc
source ~/.bashrc


make

Los archivos generados quedan en `build/`, incluyendo `build/top.fs`.

Por defecto el entorno comun `../mk/common.mk` busca oss-cad-suite en `~/oss-cad-suite`. Si esta en otra ruta:

```sh
make OSS_CAD_SUITE=/ruta/a/oss-cad-suite
```

Tambien puedes compilar la version Verilog:

```sh
make HDL=verilog
```
