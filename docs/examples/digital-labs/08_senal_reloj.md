# 08 Señal de Reloj

Práctica secuencial para dividir el reloj principal y observarlo en el LED.

## Objetivo

Usar un contador como divisor de frecuencia para transformar un reloj rápido en una señal visible.

## Verilog

```bash
cd digital-labs/08_senal_reloj
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/08_senal_reloj
devlab build -c devlab-vhdl.toml
devlab flash
```

## Conceptos

- `clk` como reloj principal.
- Registro que cambia en flanco de subida.
- Selección de un bit del contador como salida lenta.

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

    clock_divider #(.DIV_BITS(24)) dut (
        .clk(clk),
        .reset(~key_reset_n),
        .tick(),
        .slow_clk(slow_clk)
    );

    assign led_n = ~slow_clk;
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
    signal count : unsigned(23 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if key_reset_n = '0' then
                count <= (others => '0');
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    led_n <= not count(23);
end architecture;
```

:::

## Teoría Mínima

El reloj principal de la FPGA es demasiado rapido para observarlo directamente en un LED. Un divisor de frecuencia usa un contador; cada bit alto del contador cambia mas lento que el anterior. Al conectar un bit alto a `led_n`, el parpadeo se vuelve visible.

## Procedimiento

1. Compila y carga la version Verilog.
2. Observa la frecuencia de parpadeo.
3. Cambia `DIV_BITS` a un valor menor y compara.
4. Repite con VHDL.

## Actividades

- Explica que pasa si se reduce `DIV_BITS`.
- Identifica que senal reinicia el contador.
- Calcula de forma aproximada la division de frecuencia para `DIV_BITS = 24`.

## Entregable

Descripcion del parpadeo observado y comparacion entre dos valores de division.
