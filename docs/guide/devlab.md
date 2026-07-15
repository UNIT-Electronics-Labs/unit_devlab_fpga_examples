# Usar DevLab

DevLab es el flujo principal de este repositorio para compilar y cargar los
ejemplos FPGA sin depender de `make`. Cada ejemplo compatible contiene un
archivo `devlab.toml` para Verilog y, cuando aplica, un
`devlab-vhdl.toml` para VHDL.

## Requisitos

- Python 3.11 o posterior.
- DevLab y OSS CAD Suite instalados.
- GHDL si se van a compilar fuentes VHDL.
- Una tarjeta Gowin compatible conectada por USB para cargar el bitstream.

Antes de continuar, sigue la instalación correspondiente a tu sistema:

- [Windows](./windows.md), incluida la configuración del controlador USB y
  el soporte GHDL independiente.
- [Linux](./linux.md), incluidos el entorno virtual y los permisos `udev`.

## Verificar el entorno

Ejecuta el diagnóstico antes del primer build:

```bash
devlab --version
devlab doctor
```

Si Windows no encuentra el ejecutable `devlab`, antepone `python -m` a los
mismos comandos:

```powershell
python -m devlab --version
python -m devlab doctor
```

Si `python` selecciona una instalación distinta de aquella donde está DevLab,
usa el lanzador de Windows para elegir la versión correcta. Por ejemplo:

```powershell
py --list
py -3.14 -m devlab --version
py -3.14 -m devlab doctor
py -3.14 -m devlab build
```

El valor `3.14` es un ejemplo: sustitúyelo por la versión que contiene DevLab
y utiliza la misma selección para los demás comandos.

`doctor` comprueba las herramientas de OSS CAD Suite. GHDL solamente es
necesario para compilar configuraciones VHDL.

## Compilar Verilog

Entra al directorio de un ejemplo y ejecuta el build predeterminado:

```bash
cd digital-labs/01_sumador_n_bits
devlab build
```

El archivo `devlab.toml` selecciona las fuentes Verilog:

```toml
[build]
top = "top"
sources = ["src/digital_labs.v", "src/top.v"]
constraints = "pins.cst"
build_dir = "build"
```

## Compilar VHDL

Selecciona explícitamente la configuración VHDL:

```bash
devlab build -c devlab-vhdl.toml
```

El archivo alternativo usa la fuente VHDL autocontenida:

```toml
[build]
top = "top"
sources = ["src/top.vhd"]
constraints = "pins.cst"
build_dir = "build"
```

En Windows, DevLab no depende del plugin `yosys-ghdl`. Convierte primero VHDL
a Verilog con GHDL y entrega el archivo generado a Yosys:

```text
VHDL -> GHDL --synth --out=verilog -> Yosys -> nextpnr -> gowin_pack
```

Consulta [Soporte VHDL/GHDL en Windows](./windows.md#soporte-vhdl-ghdl-en-windows)
para instalar GHDL y verificar esta etapa con `devlab build --dry-run`.

## Cargar en SRAM

Después de un build correcto, carga el bitstream:

```bash
devlab flash
```

La configuración de los ejemplos usa la Tang Nano 9K y carga en SRAM:

```toml
[flash]
board = "tangnano9k"
mode = "sram"
verify = false
```

Si se utiliza otra tarjeta, hay que ajustar `board`, el dispositivo FPGA y
`pins.cst`. El archivo CST conecta los puertos del diseño con los pines físicos;
no se genera automáticamente para una tarjeta diferente.

## Flujo de trabajo recomendado

```bash
devlab doctor
devlab build
devlab flash
```

Para revisar los comandos sin ejecutar la síntesis:

```bash
devlab build --dry-run
```

En Windows también se puede usar `python -m devlab` en cada línea.

## Estructura de un ejemplo

```text
ejemplo/
|-- devlab.toml
|-- devlab-vhdl.toml
|-- pins.cst
|-- src/
|   |-- top.v
|   |-- top.vhd
|   `-- digital_labs.v
`-- README.md
```

Los ejemplos básicos no siempre necesitan `digital_labs.v`; los laboratorios
digitales lo usan para separar módulos reutilizables del `top`.

## Problemas frecuentes

- Si `devlab` no está en `PATH`, usa `python -m devlab`. En Windows, si ese
  comando elige otra instalación, usa `py -<versión> -m devlab`; por ejemplo,
  `py -3.14 -m devlab build`.
- Si falla la asignación de pines con `ERROR: Unconstrained IO`, revisa
  [`pins.cst`](./cst.md); GHDL y Yosys ya terminaron su etapa.
- Si Windows bloquea la instalación o algún ejecutable de síntesis, consulta
  [Solución de problemas en Windows](./windows.md#solucion-de-problemas).
- Si `flash` no encuentra la tarjeta, revisa Zadig en Windows o las reglas
  `udev` en Linux.

## Siguiente paso

Revisa [Archivos CST](./cst.md) para aprender a conectar las entradas y salidas
del HDL con los pines físicos de la tarjeta.
