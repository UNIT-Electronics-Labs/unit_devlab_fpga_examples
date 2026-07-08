# 10 Contador Descendente

Práctica de contador que decrementa con el reloj.

## Objetivo

Comparar el comportamiento de conteo descendente contra el contador ascendente.

## Verilog

```bash
cd digital-labs/10_contador_descendente
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/10_contador_descendente
devlab build -c devlab-vhdl.toml
devlab flash
```

## Conceptos

- Decremento de registros.
- Lógica secuencial.
- Observación de bits de estado en salida.

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
    input  wire clk,
    input  wire key_reset_n,
    output wire led_n
);
    wire slow_clk;
    wire [7:0] count;

    clock_divider #(.DIV_BITS(24)) clock_signal (
        .clk(clk),
        .reset(~key_reset_n),
        .tick(),
        .slow_clk(slow_clk)
    );

    counter_down #(.N(8)) dut (
        .clk(slow_clk),
        .reset(~key_reset_n),
        .q(count)
    );

    assign led_n = ~count[7];
endmodule
```

```vhdl [src/top.vhd]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port (
        clk : in std_logic;
        key_reset_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    signal divider : unsigned(23 downto 0) := (others => '0');
    signal count : unsigned(7 downto 0) := (others => '0');
    signal slow_clk : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if key_reset_n = '0' then
                divider <= (others => '0');
            else
                divider <= divider + 1;
            end if;
        end if;
    end process;

    slow_clk <= divider(23);

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if key_reset_n = '0' then
                count <= (others => '0');
            else
                count <= count - 1;
            end if;
        end if;
    end process;

    led_n <= not count(7);
end architecture;
```

:::

## Teoría Mínima

El contador descendente resta uno en cada flanco de reloj. En aritmetica binaria de ancho fijo, despues de cero el contador regresa al valor maximo. Esta practica permite observar el mismo circuito secuencial de la practica anterior, pero con actualizacion inversa.

## Procedimiento

1. Compila y carga la version Verilog.
2. Observa el LED y compara con el contador ascendente.
3. Presiona reset para reiniciar el estado.
4. Repite con VHDL.

## Actividades

- Cambia el bit observado y describe la nueva frecuencia visible.
- Explica que valor sigue despues de `00000000` en un contador de 8 bits descendente.
- Compara el codigo de `counter_up` y `counter_down`.

## Entregable

Comparacion breve entre contador ascendente y descendente.
