# 01 Sumador N bits

Práctica de suma binaria en paralelo. Instancia `nbit_adder` y muestra `sum[0]` en el LED activo en bajo.

## Objetivo

Comprender como se construye un sumador parametrizable con acarreo de entrada y salida.

## Entradas y Salidas

- `key_reset_n`: bit `a[0]`.
- `key_enable_n`: bit `b[0]`.
- `led_n`: resultado `sum[0]`, activo en bajo.

## Verilog

```bash
cd digital-labs/01_sumador_n_bits
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/01_sumador_n_bits
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `nbit_adder`.
- `src/top.v`: conexión Verilog a la placa.
- `src/top.vhd`: versión VHDL autocontenida.

## Restricciones de Pines

El archivo `pins.cst` conecta los puertos del `top` con los pines físicos de la tarjeta. En estas prácticas se conserva el mismo mapeo base para reloj, botones y LED.

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
    wire [3:0] sum;
    wire cout;

    nbit_adder #(.N(4)) dut (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout(cout)
    );

    assign led_n = ~sum[0];
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
    signal sum : unsigned(4 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);
    sum <= ('0' & a) + ('0' & b);

    led_n <= not sum(0);
end architecture;
```

:::

## Teoría Mínima

Un sumador binario combina `a`, `b` y `cin`. El resultado completo necesita `N + 1` bits: `N` bits para `sum` y un bit extra para `cout`. En esta práctica el módulo se parametriza con `N = 4`, aunque la demostración solo cambia el bit menos significativo con los botones.

## Procedimiento

1. Compila y carga la version Verilog.
2. Presiona cada botón por separado y observa el LED.
3. Presiona ambos botones al mismo tiempo.
4. Repite la prueba con `devlab-vhdl.toml`.

## Tabla Esperada

| `a[0]` | `b[0]` | `sum[0]` | LED |
| --- | --- | --- | --- |
| 0 | 0 | 0 | Apagado |
| 0 | 1 | 1 | Encendido |
| 1 | 0 | 1 | Encendido |
| 1 | 1 | 0 | Apagado |

## Actividades

- Cambia `cin` a `1'b1` en Verilog y explica como cambia la tabla.
- Localiza el equivalente en VHDL y aplica el mismo cambio.
- Explica por que `cout` no se ve en el LED actual.

## Entregable

Tabla de verdad completa, comando de compilación exitoso y una explicación corta de la diferencia entre `sum[0]` y `cout`.
