# 05 Decodificador de 16 Segmentos

Práctica de decodificación para exhibidor de 16 segmentos. Instancia `sixteen_segment_decoder`.

## Objetivo

Extender la idea del decodificador de 7 segmentos a más segmentos para representar símbolos con mayor detalle.

## Demostración en Placa

El `top` actual muestra en `led_n` uno de los segmentos decodificados.

## Verilog

```bash
cd digital-labs/05_decodificador_16_segmentos
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/05_decodificador_16_segmentos
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `sixteen_segment_decoder`.
- `src/top.v`: conexión Verilog.
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
    wire [3:0] hex = {2'b00, ~key_reset_n, ~key_enable_n};
    wire [15:0] seg;

    sixteen_segment_decoder #(.ACTIVE_LOW(1)) dut (
        .hex(hex),
        .seg(seg)
    );

    assign led_n = seg[15];
endmodule
```

```vhdl [src/top.vhd]
library ieee;
use ieee.std_logic_1164.all;

entity top is
    port (
        key_reset_n : in std_logic;
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal hex : std_logic_vector(3 downto 0);
    signal raw : std_logic_vector(15 downto 0);
begin
    hex <= "00" & (not key_reset_n) & (not key_enable_n);

    with hex select raw <=
        "1111110000001100" when "0000",
        "0110000000000000" when "0001",
        "1101101100000000" when "0010",
        "1111001100000000" when "0011",
        "0110011100000000" when "0100",
        "1011011100000000" when "0101",
        "1011111100000000" when "0110",
        "1110000000000000" when "0111",
        "1111111100000000" when "1000",
        "1111011100000000" when "1001",
        "1110111100000000" when "1010",
        "1111000010010010" when "1011",
        "1001110000000000" when "1100",
        "1111000010010010" when "1101",
        "1001111100000000" when "1110",
        "1000111100000000" when others;

    led_n <= not raw(15);
end architecture;
```

:::

## Teoría Mínima

Un exhibidor de 16 segmentos permite representar mas simbolos que uno de 7 segmentos. La idea de diseno es la misma: una entrada hexadecimal selecciona un patron de bits. En esta practica se observa solo un bit del patron para mantener el hardware minimo.

## Procedimiento

1. Revisa la tabla `case` del decodificador.
2. Identifica el segmento conectado a `led_n`.
3. Prueba las cuatro combinaciones disponibles con los botones.
4. Repite la prueba en VHDL.

## Actividades

- Cambia `seg[15]` por otro bit y documenta el cambio observado.
- Agrega en tu reporte la diferencia entre 7 y 16 segmentos.
- Explica por que el modulo usa una entrada de 4 bits aunque solo haya dos botones.

## Entregable

Descripcion del patron observado y tabla parcial para los valores `0` a `3`.
