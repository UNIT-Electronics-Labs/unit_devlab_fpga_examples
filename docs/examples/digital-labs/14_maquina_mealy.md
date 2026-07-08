# 14 Máquina Mealy

Práctica de máquina de estados tipo Mealy para detectar la secuencia `101`.

## Objetivo

Implementar una FSM donde la salida depende del estado actual y de la entrada.

## Verilog

```bash
cd digital-labs/14_maquina_mealy
devlab build
devlab flash
```

## VHDL

```bash
cd digital-labs/14_maquina_mealy
devlab build -c devlab-vhdl.toml
devlab flash
```

## Conceptos

- Estados codificados.
- Transiciones por entrada.
- Salida combinacional dependiente de estado y entrada.

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

    mealy_101_detector dut (
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
    type state_t is (s0, s1, s10);
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
    found <= '1' when state = s10 and din = '1' else '0';

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
                            state <= s1;
                        else
                            state <= s0;
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

Una maquina Mealy calcula la salida usando el estado actual y la entrada actual. Para detectar `101`, no necesita un estado final separado: cuando el estado indica que ya se recibio `10` y la entrada actual es `1`, `found` se activa inmediatamente.

## Estados

- `S0`: no hay coincidencia parcial.
- `S1`: se detecto un `1`.
- `S10`: se detecto `10`.

## Procedimiento

1. Compila y carga la version Verilog.
2. Genera la secuencia `1`, `0`, `1` con el boton de entrada.
3. Observa que la salida depende del estado `S10` y del valor actual de entrada.
4. Repite con VHDL.

## Actividades

- Dibuja el diagrama de estados.
- Explica por que Mealy usa menos estados que Moore en este ejemplo.
- Identifica una ventaja y una precaucion de tener salida combinacional.

## Entregable

Diagrama de estados y comparacion directa contra la practica 13.
