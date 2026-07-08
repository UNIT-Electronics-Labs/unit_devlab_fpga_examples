# 03 Comparador N bits

Práctica de comparación binaria. Instancia `nbit_comparator`.

## Objetivo

Comparar dos vectores y generar banderas como igualdad, mayor que o menor que.

## Salida

- `led_n`: encendido cuando `a == b`.

## Verilog

```bash
cd digital-labs/03_comparador_n_bits
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/03_comparador_n_bits
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `nbit_comparator`.
- `src/top.v`: top-level Verilog.
- `src/top.vhd`: versión VHDL.

## Restricciones de Pines

El archivo `pins.cst` conecta los puertos del `top` con los pines fisicos de la tarjeta. En estas practicas se conserva el mismo mapeo base para reloj, botones y LED.

```text [pins.cst]
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;

IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "led_n" 16;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

## Código Fuente

::: code-group

```verilog [src/top.v]
module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire eq;

    nbit_comparator #(.N(4)) dut (
        .a(a),
        .b(b),
        .eq(eq),
        .ne(),
        .lt(),
        .le(),
        .gt(),
        .ge()
    );

    assign led_n = ~eq;
endmodule
```

```vhdl [src/top.vhd]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal a : unsigned(3 downto 0);
    signal b : unsigned(3 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);

    led_n <= '0' when a = b else '1';
end architecture;
```

:::

## Teoría Mínima

Un comparador genera banderas relacionales. Este modulo produce `eq`, `ne`, `lt`, `le`, `gt` y `ge`; el `top` solo muestra `eq`. Como los vectores usados en placa tienen tres bits altos en cero, los botones comparan valores de 0 o 1.

## Procedimiento

1. Compila y carga la version Verilog.
2. Prueba las combinaciones de `a[0]` y `b[0]`.
3. Confirma que el LED enciende cuando ambos valores son iguales.
4. Repite con la version VHDL.

## Tabla Esperada

| `a[0]` | `b[0]` | `eq` | LED |
| --- | --- | --- | --- |
| 0 | 0 | 1 | Encendido |
| 0 | 1 | 0 | Apagado |
| 1 | 0 | 0 | Apagado |
| 1 | 1 | 1 | Encendido |

## Actividades

- Cambia el LED para mostrar `gt`.
- Cambia el LED para mostrar `lt`.
- Explica cual bandera conviene usar para detectar valores distintos.

## Entregable

Tabla de comparacion y descripcion de al menos dos banderas relacionales.
