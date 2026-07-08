# 06 Restador a 7 Segmentos

Práctica que combina una resta binaria con decodificación a 7 segmentos. Instancia `subtract_to_7seg`.

## Objetivo

Encadenar bloques combinacionales: primero calcular una resta y después traducir el resultado a segmentos.

## Verilog

```bash
cd digital-labs/06_restador_a_7_segmentos
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/06_restador_a_7_segmentos
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulos de resta y decodificación.
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
    wire [3:0] diff;
    wire borrow;
    wire [6:0] seg;

    subtract_to_7seg #(.N(4), .ACTIVE_LOW(1)) dut (
        .a(a),
        .b(b),
        .diff(diff),
        .borrow(borrow),
        .seg(seg)
    );

    assign led_n = seg[6];
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
    signal raw : std_logic_vector(6 downto 0);
begin
    a <= "000" & (not key_reset_n);
    b <= "000" & (not key_enable_n);
    diff <= a - b;

    with std_logic_vector(diff) select raw <=
        "1111110" when "0000",
        "0110000" when "0001",
        "1101101" when "0010",
        "1111001" when "0011",
        "0110011" when "0100",
        "1011011" when "0101",
        "1011111" when "0110",
        "1110000" when "0111",
        "1111111" when "1000",
        "1111011" when "1001",
        "1110111" when "1010",
        "0011111" when "1011",
        "1001110" when "1100",
        "0111101" when "1101",
        "1001111" when "1110",
        "1000111" when others;

    led_n <= not raw(6);
end architecture;
```

:::

## Teoría Mínima

Esta practica encadena dos bloques combinacionales. Primero se calcula una resta con `nbit_subtractor`; despues el resultado pasa a un decodificador de 7 segmentos. Esta composicion muestra como construir sistemas mayores a partir de modulos pequenos.

## Procedimiento

1. Revisa la conexion interna de `subtract_to_7seg`.
2. Compila y carga la version Verilog.
3. Prueba las combinaciones de botones y registra el segmento observado.
4. Repite con VHDL.

## Actividades

- Conecta `borrow` al LED para observar el prestamo.
- Cambia el segmento observado por otro bit de `seg`.
- Dibuja el diagrama de bloques: entradas, restador, decodificador y LED.

## Entregable

Diagrama de bloques y explicacion de como se propaga el resultado de la resta hacia el decodificador.
