# 04 Decodificador de 7 Segmentos

Práctica de decodificación para exhibidor de 7 segmentos. Instancia `seven_segment_decoder`.

## Objetivo

Convertir un valor binario en las señales de segmentos `a` a `g`.

## Demostración en Placa

El `top` muestra en `led_n` el segmento `a` del número formado con dos entradas.

## Verilog

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/04_decodificador_7_segmentos
devlab build -c devlab-vhdl.toml
devlab flash
```

## Archivos Clave

- `src/digital_labs.v`: módulo `seven_segment_decoder`.
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
    wire [6:0] seg;

    seven_segment_decoder #(.ACTIVE_LOW(1)) dut (
        .hex(hex),
        .seg(seg)
    );

    assign led_n = seg[6];
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
    signal raw : std_logic_vector(6 downto 0);
begin
    hex <= "00" & (not key_reset_n) & (not key_enable_n);

    with hex select raw <=
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

Un decodificador convierte un valor binario en un patron de segmentos. El modulo genera siete salidas para los segmentos `a` a `g`. En esta placa de demostracion solo se observa un segmento mediante `led_n`, por eso la practica se centra en leer la tabla del decodificador.

## Procedimiento

1. Revisa el `case` del modulo `seven_segment_decoder`.
2. Identifica que bit de `seg` se conecta a `led_n`.
3. Compila, carga y prueba los valores `00`, `01`, `10` y `11`.
4. Repite con VHDL.

## Actividades

- Cambia el LED para observar otro segmento.
- Completa la tabla de segmentos para los valores de 0 a 3.
- Explica que cambia cuando `ACTIVE_LOW` vale `1`.

## Entregable

Tabla de los segmentos observados y explicacion de salidas activas en bajo.
