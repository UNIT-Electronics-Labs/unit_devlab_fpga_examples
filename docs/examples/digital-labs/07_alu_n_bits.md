# 07 ALU N bits

Práctica de unidad aritmética y lógica. Instancia `nbit_alu`.

## Objetivo

Combinar varias operaciones aritméticas y lógicas en un solo bloque controlado por `op`.

## Demostración en Placa

El `top` usa operación suma (`op = 0`).

## Verilog

```bash
cd digital-labs/07_alu_n_bits
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/07_alu_n_bits
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `nbit_alu`.
- `src/top.v`: selección de operación y conexión a pines.
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
    wire [3:0] y;

    nbit_alu #(.N(4)) dut (
        .a(a),
        .b(b),
        .op(4'h0),
        .y(y),
        .carry(),
        .borrow(),
        .zero(),
        .equal(),
        .less()
    );

    assign led_n = ~y[0];
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
    signal y : unsigned(3 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);
    y <= a + b;

    led_n <= not y(0);
end architecture;
```

:::

## Teoría Mínima

Una ALU agrupa operaciones aritmeticas y logicas dentro de un solo modulo. La entrada `op` selecciona la operacion y las banderas (`zero`, `equal`, `less`, `carry`, `borrow`) describen condiciones utiles para controladores mas grandes. En el `top` de demostracion `op = 0`, por lo que se observa una suma.

## Procedimiento

1. Revisa el `case` de `nbit_alu`.
2. Compila y prueba la operacion suma.
3. Cambia `op` a otra operacion disponible y recompila.
4. Repite al menos una operacion en VHDL.

## Actividades

- Documenta dos valores de `op` y su salida esperada.
- Cambia el LED para observar la bandera `zero`.
- Explica por que una ALU necesita banderas ademas de la salida `y`.

## Entregable

Tabla con dos operaciones de la ALU, salida esperada y bandera relevante.
