# OR

Ejemplo de compuerta OR con dos entradas y un LED.

## Qué Aprendes

- Describir una operación OR en HDL.
- Separar señales físicas activas en bajo de señales lógicas internas.
- Usar el mismo ejemplo en Verilog y VHDL.

## Archivos

- `or/devlab.toml`: build Verilog.
- `or/devlab-vhdl.toml`: build VHDL.
- `or/src/top.v`: implementación Verilog.
- `or/src/top.vhd`: implementación VHDL.
- `or/pins.cst`: pines de la placa.

## Lógica

El LED se activa cuando al menos una de las dos entradas lógicas vale `1`.

![top entity](img/top_entity.png)

## Pinout

| Señal | Función | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- |
| `gpio3_n` | Entrada activa en bajo | 3 | `LVCMOS18`, pull-up |
| `gpio4_n` | Entrada activa en bajo | 4 | `LVCMOS18`, pull-up |
| `led_n` | LED activo en bajo | 16 | `LVCMOS33` |

```text [pins.cst]
IO_LOC "gpio3_n" 3;
IO_PORT "gpio3_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "gpio4_n" 4;
IO_PORT "gpio4_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "led_n" 16;
IO_PORT "led_n" IO_TYPE=LVCMOS33;
```

## Código Fuente

::: code-group

```verilog [Verilog]
module top (
    input wire gpio3_n,
    input wire gpio4_n,
    output wire led_n
);
    wire a = ~gpio3_n;
    wire b = ~gpio4_n;

    assign led_n = ~(a | b);
endmodule
```

```vhdl [VHDL]
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        gpio3_n : in std_logic;
        gpio4_n : in std_logic;
        led_n : out std_logic
    );
end entity top;

architecture rtl of top is
    signal a : std_logic;
    signal b : std_logic;
begin
    a <= not gpio3_n;
    b <= not gpio4_n;

    led_n <= not (a or b);
end architecture rtl;
```

:::

## Compilar

```bash
cd or
devlab build
devlab flash
```

## VHDL

```bash
cd or
devlab build -c devlab-vhdl.toml
devlab flash
```
