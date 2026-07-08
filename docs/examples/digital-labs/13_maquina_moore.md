# 13 Máquina Moore

Práctica de máquina de estados tipo Moore para detectar la secuencia `101`.

## Objetivo

Implementar una FSM donde la salida depende solo del estado actual.

## Verilog

```bash
cd digital-labs/13_maquina_moore
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/13_maquina_moore
devlab build -c devlab-vhdl.toml
devlab flash
```

## Conceptos

- Estados codificados.
- Transiciones por entrada.
- Salida asociada al estado.

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
    input  wire key_enable_n,
    output wire led_n
);
    wire slow_clk;
    wire found;

    clock_divider #(.DIV_BITS(24)) clock_signal (
        .clk(clk),
        .reset(~key_reset_n),
        .tick(),
        .slow_clk(slow_clk)
    );

    moore_101_detector dut (
        .clk(slow_clk),
        .reset(~key_reset_n),
        .din(~key_enable_n),
        .found(found)
    );

    assign led_n = ~found;
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
        key_enable_n : in std_logic;
        led_n : out std_logic
    );
end entity;

architecture rtl of top is
    type state_t is (s0, s1, s10, s101);
    signal divider : unsigned(23 downto 0) := (others => '0');
    signal state : state_t := s0;
    signal slow_clk : std_logic;
    signal din : std_logic;
    signal found : std_logic;
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
    din <= not key_enable_n;
    found <= '1' when state = s101 else '0';

    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            if key_reset_n = '0' then
                state <= s0;
            else
                case state is
                    when s0 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s0;
                        end if;
                    when s1 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s10;
                        end if;
                    when s10 =>
                        if din = '1' then
                            state <= s101;
                        else
                            state <= s0;
                        end if;
                    when s101 =>
                        if din = '1' then
                            state <= s1;
                        else
                            state <= s10;
                        end if;
                end case;
            end if;
        end if;
    end process;

    led_n <= not found;
end architecture;
```

:::

## Teoría Mínima

Una maquina Moore calcula la salida solo a partir del estado actual. Para detectar `101`, el diseno guarda cuanto de la secuencia ya se ha reconocido. La salida `found` se activa cuando el estado representa que la secuencia completa fue detectada.

## Estados

- `S0`: no hay coincidencia parcial.
- `S1`: se detecto un `1`.
- `S10`: se detecto `10`.
- `S101`: se detecto `101`.

## Procedimiento

1. Compila y carga la version Verilog.
2. Usa el boton de entrada para generar la secuencia `1`, `0`, `1` con el reloj dividido.
3. Observa cuando enciende el LED.
4. Repite con VHDL.

## Actividades

- Dibuja el diagrama de estados.
- Explica por que Moore necesita un estado extra para indicar deteccion.
- Compara la salida con la practica Mealy.

## Entregable

Diagrama de estados y tabla de transiciones para la secuencia `101`.
