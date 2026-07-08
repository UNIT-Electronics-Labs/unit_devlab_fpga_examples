# Archivos CST

Un archivo `.cst` define la distribución física de entradas y salidas de la FPGA Gowin. En otras palabras: conecta los nombres que usas en Verilog o VHDL con pines reales del target.

DevLab usa este archivo desde `devlab.toml`:

```toml
[build]
top = "top"
sources = ["src/top.v"]
constraints = "pins.cst"
build_dir = "build"
```

## Relación Entre HDL, Chip y Target

Hay tres niveles distintos:

- HDL: define puertos logicos como `clk`, `led_n` o `key_reset_n`.
- Chip Gowin: define familia, dispositivo y bancos de I/O, por ejemplo `GW1N-9C` y `GW1NR-LV9QN88PC6/I5`.
- Target: define la tarjeta concreta, sus conectores, botones, LEDs, reloj y programador.

El `.cst` vive entre el HDL y el target: traduce puertos logicos a pines fisicos. Por eso no conviene escribir la documentacion como si el SDK perteneciera a una sola tarjeta. La tarjeta de referencia puede cambiar; el concepto de distribucion de pines se mantiene.

Para la tarjeta de referencia, consulta tambien el [esquematico Tang Nano 9K](./esquematico.md). El esquematico es la fuente para confirmar conexiones fisicas, bancos de voltaje y polaridad de señales antes de cambiar un `IO_LOC` o `IO_TYPE`.

## Relación Entre HDL y CST

Si tu `top.v` declara estos puertos:

```verilog
module top (
    input  wire clk,
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
endmodule
```

Entonces el `pins.cst` debe usar exactamente esos mismos nombres:

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;

IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "led_n" 16;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

Si el nombre no coincide, el toolchain no puede asignar ese puerto a un pin fisico.

## Líneas Principales

Cada señal normalmente usa dos líneas:

```text
IO_LOC "nombre_señal" número_pin;
IO_PORT "nombre_señal" IO_TYPE=LVCMOS33;
```

- `IO_LOC`: asigna una señal a un pin físico.
- `IO_PORT`: configura características eléctricas del pin.
- `IO_TYPE`: define el voltaje/interfaz eléctrica.
- `PULL_MODE=UP`: habilita resistencia pull-up interna, útil para botones o entradas abiertas.

## Tipos de IO_TYPE

La FPGA soporta diferentes estándares eléctricos según el banco de pines. Debes usar el `IO_TYPE` correcto según el voltaje del banco:

| IO_TYPE   | Voltaje | Uso Común                                      |
|-----------|---------|------------------------------------------------|
| LVCMOS33  | 3.3V    | LEDs, reloj, pines de propósito general        |
| LVCMOS18  | 1.8V    | Botones internos, algunos bancos específicos   |
| LVCMOS25  | 2.5V    | Interfaces especiales, menos común             |

**¿Cómo saber cuál usar?**

1. Consulta el datasheet de tu FPGA para ver el voltaje de cada banco de pines
2. Para la Tang Nano 9K:
   - Pin 52 (reloj): usa LVCMOS33
   - Pines 10-16 (LEDs): usa LVCMOS33
   - Pines 3-4 (botones internos): usa LVCMOS18
3. Si conectas hardware externo, el `IO_TYPE` debe coincidir con el voltaje de ese hardware

**Regla práctica**: Si no estás seguro y usas pines de propósito general, LVCMOS33 es el más común.

## Cómo Funcionan las Señales Activas en Bajo con Pull-Up

Las señales activas en bajo (`_n`) con `PULL_MODE=UP` pueden parecer confusas al principio. Aquí está la explicación:

### Circuito Físico

```
       VCC (3.3V)
          |
      [Pull-Up]  (resistencia interna de la FPGA)
          |
          ├─────> Pin de la FPGA (lee este valor)
          |
      [Botón] 
          |
         GND
```

### Comportamiento

| Estado del Botón | Conexión Física      | Valor Leído | Valor Lógico |
|------------------|---------------------|-------------|--------------|
| No presionado    | Pin flotante → VCC  | `1`         | `0` (inactivo) |
| Presionado       | Pin conectado a GND | `0`         | `1` (activo)   |

**Por qué vale 0 cuando se presiona:**
- Cuando NO presionas el botón: la resistencia pull-up jala el pin hacia VCC (3.3V), así que la FPGA lee `1`
- Cuando presionas el botón: conectas el pin directamente a tierra (GND), así que la FPGA lee `0`
- Por eso se llama "activo en bajo" (`_n`) - se activa con `0`

**En el código HDL:**

```verilog
input wire btn_n;        // Señal física (activo en bajo)
wire btn = ~btn_n;       // Señal lógica (activo en alto)
```

Ahora:
- `btn_n = 1` (botón no presionado) → `btn = 0` (lógicamente inactivo)
- `btn_n = 0` (botón presionado) → `btn = 1` (lógicamente activo)

**Ventajas del Pull-Up:**
- El pin no queda flotante (valor indefinido) cuando el botón no está presionado
- Es un diseño robusto contra ruido eléctrico
- Permite usar botones simples de 2 pines sin resistencias externas

## Entradas

Para entradas con boton o GPIO con pull-up:

```text
IO_LOC "gpio3_n" 3;
IO_PORT "gpio3_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;
```

En el HDL se declara como entrada:

```verilog
input wire gpio3_n
```

El sufijo `_n` indica que la señal es activa en bajo. Con pull-up, la entrada normalmente vale `1`; cuando presionas el botón o conectas a tierra, vale `0`.

Para convertirla a lógica positiva:

```verilog
wire gpio3 = ~gpio3_n;
```

## Salidas

Para una salida de LED:

```text
IO_LOC "led_n" 16;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

En el HDL:

```verilog
output wire led_n
```

Si el LED es activo en bajo, se enciende con `0` y se apaga con `1`:

```verilog
assign led_n = ~resultado;
```

## Reloj

El reloj principal de estas prácticas usa el pin 52:

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;
```

En Verilog:

```verilog
input wire clk
```

En VHDL:

```vhdl
clk : in std_logic
```

Usa `clk` solo para lógica secuencial: contadores, registros y máquinas de estado.

## Ejemplo Completo

Este ejemplo define dos entradas y una salida:

```text
IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "led_n" 16;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

Top equivalente en Verilog:

```verilog
module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire a = ~key_reset_n;
    wire b = ~key_enable_n;

    assign led_n = ~(a & b);
endmodule
```

Top equivalente en VHDL:

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        key_reset_n  : in std_logic;
        key_enable_n : in std_logic;
        led_n        : out std_logic
    );
end entity;

architecture rtl of top is
    signal a : std_logic;
    signal b : std_logic;
begin
    a <= not key_reset_n;
    b <= not key_enable_n;
    led_n <= not (a and b);
end architecture;
```

## Checklist Para Crear un CST

1. Escribe primero los puertos de tu `top`.
2. Usa esos mismos nombres en `IO_LOC` e `IO_PORT`.
3. Consulta el pin físico correcto del target.
4. Usa `IO_TYPE` compatible con el banco de voltaje del pin.
5. Agrega `PULL_MODE=UP` en entradas que deben quedar en `1` cuando están libres.
6. Marca señales activas en bajo con sufijo `_n`.
7. Declara el archivo en `devlab.toml` con `constraints = "pins.cst"`.

## Plantillas Reutilizables

### Plantilla Básica con Reloj y LED

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;

IO_LOC "led" 16;
IO_PORT "led" IO_TYPE=LVCMOS33;
```

**Uso**: Copia esta plantilla para proyectos simples como blink. Cambia `"led"` por el nombre de tu señal.

### Plantilla con Botones y LED

```text
IO_LOC "gpio3_n" 3;
IO_PORT "gpio3_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "gpio4_n" 4;
IO_PORT "gpio4_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "led_n" 10;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

**Uso**: Para compuertas lógicas (AND, OR, NOT). Los botones son activos en bajo (`_n`).

### Plantilla con Múltiples LEDs

```text
IO_LOC "led[0]" 10;
IO_PORT "led[0]" IO_TYPE=LVCMOS33;

IO_LOC "led[1]" 11;
IO_PORT "led[1]" IO_TYPE=LVCMOS33;

IO_LOC "led[2]" 13;
IO_PORT "led[2]" IO_TYPE=LVCMOS33;

IO_LOC "led[3]" 14;
IO_PORT "led[3]" IO_TYPE=LVCMOS33;

IO_LOC "led[4]" 15;
IO_PORT "led[4]" IO_TYPE=LVCMOS33;

IO_LOC "led[5]" 16;
IO_PORT "led[5]" IO_TYPE=LVCMOS33;
```

**Uso**: Para displays, contadores o salidas paralelas. Usa notación de arreglo `led[n]` tanto en CST como en HDL.

### Plantilla con Display de 7 Segmentos

```text
IO_LOC "seg[0]" 25;
IO_PORT "seg[0]" IO_TYPE=LVCMOS33;

IO_LOC "seg[1]" 26;
IO_PORT "seg[1]" IO_TYPE=LVCMOS33;

IO_LOC "seg[2]" 27;
IO_PORT "seg[2]" IO_TYPE=LVCMOS33;

IO_LOC "seg[3]" 28;
IO_PORT "seg[3]" IO_TYPE=LVCMOS33;

IO_LOC "seg[4]" 29;
IO_PORT "seg[4]" IO_TYPE=LVCMOS33;

IO_LOC "seg[5]" 30;
IO_PORT "seg[5]" IO_TYPE=LVCMOS33;

IO_LOC "seg[6]" 31;
IO_PORT "seg[6]" IO_TYPE=LVCMOS33;
```

**Uso**: Conecta pines según el diagrama de tu módulo de 7 segmentos. Ajusta los números de pin según tu tarjeta.

## Tabla de Referencia: Tang Nano 9K

Esta tabla muestra los pines más comunes para la Tang Nano 9K:

| Señal         | Pin | IO_TYPE   | PULL_MODE | Descripción           |
|---------------|-----|-----------|-----------|----------------------|
| `clk`         | 52  | LVCMOS33  | -         | Reloj del sistema 27MHz |
| `led[0]`      | 10  | LVCMOS33  | -         | LED 0 (activo bajo)  |
| `led[1]`      | 11  | LVCMOS33  | -         | LED 1 (activo bajo)  |
| `led[2]`      | 13  | LVCMOS33  | -         | LED 2 (activo bajo)  |
| `led[3]`      | 14  | LVCMOS33  | -         | LED 3 (activo bajo)  |
| `led[4]`      | 15  | LVCMOS33  | -         | LED 4 (activo bajo)  |
| `led[5]`      | 16  | LVCMOS33  | -         | LED 5 (activo bajo)  |
| `btn[0]`      | 3   | LVCMOS18  | UP        | Botón S1 (activo bajo) |
| `btn[1]`      | 4   | LVCMOS18  | UP        | Botón S2 (activo bajo) |

**Nota**: Verifica siempre el pinout de tu tarjeta específica. Estos valores son para referencia.
Si hay duda, valida el pin contra el [esquematico de la tarjeta](./esquematico.md) antes de cargar el bitstream.

## Cómo Reutilizar un CST Existente

1. **Copia el archivo**: Toma un `pins.cst` de un ejemplo similar.
2. **Identifica tus puertos**: Revisa tu módulo `top` y anota los nombres de los puertos.
3. **Renombra señales**: Cambia los nombres en `IO_LOC` e `IO_PORT` para que coincidan exactamente con tu HDL.
4. **Ajusta pines si es necesario**: Si cambias de tarjeta, actualiza los números de pin.
5. **Verifica IO_TYPE**: Asegúrate que coincida con el voltaje del banco de tu pin.
6. **Guarda como `pins.cst`**: Coloca el archivo en la raíz de tu proyecto.

## Ejemplo Paso a Paso

Supón que tienes este módulo:

```verilog
module top (
    input wire clk,
    input wire reset_n,
    output wire [3:0] counter_out
);
```

### Paso 1: Crea `pins.cst` con plantilla base

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;
```

### Paso 2: Agrega reset_n con PULL_MODE

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;

IO_LOC "reset_n" 3;
IO_PORT "reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;
```

### Paso 3: Agrega salidas del contador

```text
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33;

IO_LOC "reset_n" 3;
IO_PORT "reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "counter_out[0]" 10;
IO_PORT "counter_out[0]" IO_TYPE=LVCMOS33;

IO_LOC "counter_out[1]" 11;
IO_PORT "counter_out[1]" IO_TYPE=LVCMOS33;

IO_LOC "counter_out[2]" 13;
IO_PORT "counter_out[2]" IO_TYPE=LVCMOS33;

IO_LOC "counter_out[3]" 14;
IO_PORT "counter_out[3]" IO_TYPE=LVCMOS33;
```

### Paso 4: Verifica en devlab.toml

```toml
[build]
top = "top"
sources = ["src/top.v"]
constraints = "pins.cst"
```

### Paso 5: Compila

```bash
devlab build
devlab flash
```

## Errores Comunes

### Error: "Port 'xxx' not found"

**Causa**: El nombre en CST no coincide con el nombre en HDL.

**Solución**: Verifica que los nombres sean exactamente iguales, incluyendo mayúsculas/minúsculas.

```text
❌ IO_LOC "LED" 16;      // HDL usa "led"
✅ IO_LOC "led" 16;
```

### Error: "Pin 'XX' already assigned"

**Causa**: Asignaste el mismo pin físico a dos señales diferentes.

**Solución**: Usa un pin diferente para cada señal.

### Error: Síntesis exitosa pero hardware no funciona

**Causa**: Probablemente `IO_TYPE` incorrecto o falta `PULL_MODE`.

**Solución**: Verifica el voltaje del banco y agrega `PULL_MODE=UP` a entradas no conectadas.

## Errores Comunes

- El puerto existe en HDL pero no en `pins.cst`.
- El nombre en `pins.cst` no coincide exactamente con el puerto.
- Se usa un pin equivocado o reservado.
- Se olvida la polaridad activa en bajo del LED o boton.
- Se usa `LVCMOS33` en una entrada que en el target esta conectada a banco de `1.8 V`.

Para las practicas de este repositorio, toma como referencia los `pins.cst` ya incluidos en cada ejemplo.
