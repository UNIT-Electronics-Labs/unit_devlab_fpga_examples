# Preparar el entorno

Esta guía prepara la computadora para descargar y abrir los ejemplos del repositorio:

[UNIT-Electronics-Labs/unit_devlab_fpga_examples](https://github.com/UNIT-Electronics-Labs/unit_devlab_fpga_examples)

## Requisitos

Instala las siguientes herramientas antes de continuar:

- [Visual Studio Code](https://code.visualstudio.com/download), para editar y usar la terminal integrada.
- [Python 3.11 o posterior](https://www.python.org/downloads/), requerido por DevLab.
- [Git](https://git-scm.com/downloads), recomendado para descargar y actualizar los ejemplos.

En Windows, activa la opción **Add Python to PATH** durante la instalación de Python. VS Code incluye integración con Git, pero Git debe instalarse por separado.

### Requisito adicional para Windows: Zadig

Para que DevLab pueda cargar el diseño en la FPGA desde Windows, también necesitas [Zadig](https://zadig.akeo.ie/). Conecta la tarjeta, abre Zadig, activa **Options → List All Devices**, selecciona **JTAG Debugger** o **USB-JTAG** e instala el controlador **WinUSB** o **libusbK**.

::: warning Importante
Sin este controlador, `devlab flash` no podrá comunicarse con la FPGA. Consulta la [configuración detallada de Zadig](./windows.md#_2-configurar-driver-usb-con-zadig), que incluye capturas y todos los pasos.
:::

## Verificar la instalación

Cierra y vuelve a abrir la terminal después de instalar las herramientas. En Windows ejecuta:

```powershell
git --version
python --version
code --version
```

En Linux ejecuta:

```bash
git --version
python3 --version
code --version
```

Cada comando debe mostrar un número de versión. Si `code` no se reconoce, abre la carpeta desde **Archivo → Abrir carpeta** en VS Code.

## Descargar los ejemplos

El repositorio es público. Para descargarlo por HTTPS o como ZIP no necesitas una cuenta de GitHub ni credenciales.

| Método | ¿Requiere credenciales? | ¿Permite actualizar con Git? | Recomendado para |
| --- | --- | --- | --- |
| HTTPS | No, para descargar este repositorio público | Sí | La mayoría de los estudiantes |
| SSH | Sí, requiere una llave SSH registrada en GitHub | Sí | Quien ya usa GitHub por SSH |
| ZIP | No | No | Obtener una copia sin instalar o usar Git |

### Opción 1: clonar con HTTPS (recomendada)

Abre PowerShell, Git Bash o una terminal y ejecuta:

```bash
git clone https://github.com/UNIT-Electronics-Labs/unit_devlab_fpga_examples.git
cd unit_devlab_fpga_examples
code .
```

Más adelante puedes descargar cambios del repositorio con:

```bash
git pull
```

GitHub solo solicitará autenticación si intentas enviar cambios o acceder a recursos privados.

### Opción 2: clonar con SSH

Usa esta opción solamente si ya [generaste una llave SSH y la agregaste a tu cuenta de GitHub](https://docs.github.com/es/authentication/connecting-to-github-with-ssh).

```bash
git clone git@github.com:UNIT-Electronics-Labs/unit_devlab_fpga_examples.git
cd unit_devlab_fpga_examples
code .
```

No es necesario crear una llave SSH para seguir el curso; HTTPS es suficiente.

### Opción 3: descargar un archivo ZIP

1. Abre el [repositorio en GitHub](https://github.com/UNIT-Electronics-Labs/unit_devlab_fpga_examples).
2. Selecciona **Code → Download ZIP**.
3. Extrae el archivo en una carpeta de trabajo.
4. En VS Code selecciona **Archivo → Abrir carpeta** y abre `unit_devlab_fpga_examples-main`.

Una copia ZIP no conserva el historial de Git y no se puede actualizar con `git pull`. Para recibir cambios tendrás que descargar un ZIP nuevo.

## Preparar VS Code

Abre **Extensiones** con `Ctrl + Shift + X` e instala la extensión oficial **Python**, publicada por Microsoft. De manera opcional, instala una extensión de sintaxis para Verilog y VHDL.

Después abre la terminal integrada con **Terminal → Nueva terminal**. Los comandos de compilación y carga se ejecutarán desde esta terminal.

## Siguiente paso

Con el repositorio abierto, continúa con la instalación correspondiente a tu sistema operativo:

- [Configurar Windows](./windows.md)
- [Configurar Linux](./linux.md)

Después consulta [Usar DevLab](./devlab.md) para compilar y cargar un ejemplo en la FPGA.
