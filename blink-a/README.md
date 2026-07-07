# Blink - Tang Nano 9K (GW1NR-LV9QN88PC6/I5)

Proyecto minimo de "hola mundo" en FPGA: hace parpadear el LED de la placa
Tang Nano 9K usando la cadena de herramientas open-source (Yosys,
nextpnr-himbaechel y apicula/gowin_pack) gestionada por devlab-fpga y
OSS CAD Suite.

## Estructura

```text
blink-a/
|-- devlab.toml       # Configuracion del proyecto
|-- pins.cst          # Restricciones de pines Gowin CST
|-- src/
|   |-- top.v         # Top-level en Verilog
|   `-- top.vhd       # Version VHDL conservada como referencia
`-- build/            # Salidas del build
    `-- top.fs        # Bitstream generado
```

## Requisitos

- Python 3.11+
- devlab-fpga instalado: `pip install devlab-fpga`
- OSS CAD Suite instalado por devlab con `devlab install`

Las condiciones de toolchain por sistema operativo estan documentadas en
`toolchains.toml`.

## Uso

```bash
devlab build
devlab flash
```

## Notas

### 1. Se usa Verilog, no VHDL

El build de OSS CAD Suite `windows-x64` release `2026-07-06` puede fallar
al cargar el plugin GHDL de Yosys. Por eso `devlab.toml` compila
`src/top.v` por defecto.

`src/top.vhd` se conserva como referencia. Para probar VHDL explicitamente:

```bash
devlab build -c devlab-vhdl.toml
```

Resumen de condiciones:

```toml
[windows]
osscad = "oss-cad-suite-windows-x64-20260706.exe"
ghdl = "ghdl-6.0.0-mcode-windows.zip"
default_hdl = "verilog"

[linux]
osscad = "oss-cad-suite-linux-x64-20260706.tgz"
ghdl = "embedded"
default_hdl = "verilog"

[macos]
osscad = "oss-cad-suite-darwin-{x64,arm64}-20260706.tgz"
ghdl = "embedded"
default_hdl = "verilog"
```

### 2. Parche local a devlab en Windows

Si Yosys falla con `STATUS_DLL_NOT_FOUND` (`0xC0000135`, exit code
`3221225781`), el entorno de devlab necesita incluir tambien las carpetas
`lib` de OSS CAD Suite en `PATH`:

```python
def env_with_toolchain(path: Path | None = None) -> dict[str, str]:
    env = os.environ.copy()
    path = path or install_path()
    extra_dirs = [
        path / "oss-cad-suite" / "bin",
        path / "oss-cad-suite" / "lib",
        path / "bin",
        path / "lib",
    ]
    binary_dirs = os.pathsep.join(str(d) for d in extra_dirs)
    env["PATH"] = binary_dirs + os.pathsep + env.get("PATH", "")
    return env
```

Ese parche se pierde al actualizar devlab-fpga y conviene reportarlo aguas
arriba.

### 3. devlab en Git Bash / MSYS2

Si `devlab.exe` esta en el PATH de PowerShell pero no en Git Bash/MSYS2:

```bash
export PATH="/c/Users/julio/anaconda3/Scripts:$PATH"
```

## Configuracion de pines

Valores actuales para Tang Nano 9K:

| Senal | Pin | I/O type |
|-------|-----|----------|
| clk   | 52  | LVCMOS33 |
| led   | 10  | LVCMOS33 |

## Diseno

`src/top.v` implementa un contador de 24 bits sobre `clk`. El bit mas
significativo (`counter[23]`) alimenta al LED.
