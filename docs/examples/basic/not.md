# NOT

Ejemplo de inversor lógico.

## Qué Aprendes

- Usar una entrada como señal booleana.
- Aplicar negación lógica.
- Enviar el resultado al LED activo en bajo.

## Archivos

- `not/devlab.toml`: build Verilog.
- `not/devlab-vhdl.toml`: build VHDL.
- `not/src/top.v`: implementación Verilog.
- `not/src/top.vhd`: implementación VHDL.
- `not/pins.cst`: pines de la placa.

## Lógica

La salida cambia al valor contrario de la entrada lógica. Como el LED es activo en bajo, el `top` también considera la polaridad física del LED.

![top entity](img/top_entity.png)

## Pinout

| Señal | Función | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- |
| `gpio3_n` | Entrada activa en bajo | 3 | `LVCMOS18`, pull-up |
| `gpio4_n` | Entrada disponible | 4 | `LVCMOS18`, pull-up |
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

    assign led_n = ~(~a);
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
begin
    a <= not gpio3_n;

    led_n <= not (not a);
end architecture rtl;
```

:::

## Compilar

```bash
cd not
devlab build
devlab flash
```

## VHDL

```bash
cd not
devlab build -c devlab-vhdl.toml
devlab flash
```
