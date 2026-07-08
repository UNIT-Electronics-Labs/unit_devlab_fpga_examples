# Guía Rápida para Linux 

Esta guía proporciona pasos específicos para configurar DevLab en Linux desde la distribución de Ubuntu.

## Instalación Rápida

### 1. Instalar Requisitos

```bash
# Verificar que Python 3.11+ esté instalado
python3 --version
```

### 2. Instalar DevLab

```bash
# Actualizar pip
python3 -m pip install --upgrade pip

# Instalar DevLab
python3 -m pip install devlab-fpga

# Verificar instalación
python3 -m devlab --version
python3 -m devlab doctor
python3 -m devlab install
```
## Inicializar un proyecto


```bash
# Crear proyecto
devlab new blink --hdl vhdl

# Entrar a la carpeta del proyecto
cd blink

# Abrir el proyecto en Visual Studio Code
code . 
```

## Permisos de escritura

Para que se carguen los archivos a la **Tang Nano 9k**, se deben otorgar permisos de escritura. Deberás conectar tu dispositivo a la computadora para continuar.

```bash
# Listar todos los dispositivos conectados
lsusb
```
El siguiente comando es para crear una regla `udev`

```bash
sudo nano /etc/udev/rules.d/99-ft2232.rules
```
Agrega la siguiente regla:

```bash
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", MODE="0666"
```
Guarda con: 

`Ctrl + O`

`Enter`

`Ctrl + X`

Esta regla permite acceso de lectura/escritura al dispositivo USB para todos los usuarios.

## Recargar reglas `udev`
Después de guardar el archivo, ejecuta:

```bash
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Desconecta y vuelve a conectar el dispositivo.

## Uso Diario

### Compilar un Proyecto

```bash
# Compilar con Verilog
python3 -m devlab build

# Compilar con VHDL
python3 -m devlab build -c devlab-vhdl.toml

# Cargar en la FPGA
python3 -m devlab flash
```

![Salida de devlab flash](./img/flash-linux.png)
*Resultado exitoso de `devlab flash` cargando el bitstream en la FPGA*

### Comandos Útiles

```bash
# Ver información del sistema
python3 -m devlab doctor
```

![Salida de devlab doctor](./img/doctor-linux.png)
*Comando `devlab doctor` mostrando las herramientas instaladas*

```bash
# Ver ayuda
python3 -m devlab --help
```

## Notas

Considera usar un entorno virtual si no quieres instalar de forma global el paquete **DevLab**

```bash
# Crear entorno virtual de nombre devlab
python3 -m venv devlab

# Activar el entorno virtual
source devlab/bin/activate

# Desactivar el entorno virtual
deactivate

```

## Recursos Adicionales

- [Guía General de DevLab](./devlab.md)
- [Archivos CST](./cst.md)
- [Introducción a Verilog](./verilog.md)
- [Introducción a VHDL](./vhdl.md)