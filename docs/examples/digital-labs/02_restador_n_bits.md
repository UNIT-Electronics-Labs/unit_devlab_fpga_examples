# 02 Restador N bits

Práctica de resta binaria en paralelo. Instancia `nbit_subtractor`.

## Objetivo

Entender la resta como operación combinacional parametrizable y observar un bit de diferencia en el LED.

## Salida

- `led_n`: `diff[0]`, activo en bajo.

## Verilog

```bash
cd digital-labs/02_restador_n_bits
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/02_restador_n_bits
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `nbit_subtractor`.
- `src/top.v`: conexión Verilog a entradas y LED.
- `src/top.vhd`: versión VHDL autocontenida.

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
    wire [3:0] diff;
    wire bout;

    nbit_subtractor #(.N(4)) dut (
        .a(a),
        .b(b),
        .bin(1'b0),
        .diff(diff),
        .bout(bout)
    );

    assign led_n = ~diff[0];
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
    signal diff : unsigned(3 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);
    diff <= a - b;

    led_n <= not diff(0);
end architecture;
```

:::

## Teoría Mínima

La resta binaria calcula `a - b - bin`. Cuando `a` no alcanza para restar `b`, aparece un prestamo (`bout`). El `top` conecta los botones a `a[0]` y `b[0]`, y muestra solo `diff[0]`.

## Procedimiento

1. Compila y carga la version Verilog.
2. Prueba las cuatro combinaciones de botones.
3. Registra si el LED coincide con `diff[0]`.
4. Repite con la version VHDL.

## Tabla Esperada

| `a[0]` | `b[0]` | `diff[0]` | Prestamo |
| --- | --- | --- | --- |
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 |

## Actividades

- Modifica el `top` para observar `bout` en lugar de `diff[0]`.
- Compara la resta con el sumador de la practica 01.
- Explica por que `0 - 1` produce `diff[0] = 1`.

## Entregable

Tabla de resta, observacion del LED y explicacion del prestamo en resta binaria.
