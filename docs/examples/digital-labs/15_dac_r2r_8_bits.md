# 15 DAC R-2R de 8 bits

Práctica para generar rampa, seno y cuadrada en una salida DAC R-2R conectada a GPIO.

## Objetivo

Generar tres formas de onda para comprobar que los 8 bits cambian y que la red R-2R produce una salida analógica:

- Modo 0: rampa de `0x00` a `0xFF`.
- Modo 1: seno con tabla de 32 muestras.
- Modo 2: cuadrada entre `0x00` y `0xFF`.
- `key_enable_n`: cambia de modo en cada pulsación.
- `key_reset_n`: regresa a rampa y reinicia la fase.
- Las tres formas apuntan a `1 kHz`.
- Por el divisor entero del reloj, la rampa queda cerca de `1004 Hz` y seno/cuadrada cerca de `1001 Hz`.

## Archivos

- `digital-labs/15_dac_r2r_8_bits/devlab.toml`: build Verilog.
- `digital-labs/15_dac_r2r_8_bits/devlab-vhdl.toml`: build VHDL.
- `digital-labs/15_dac_r2r_8_bits/pins.cst`: pines de reloj, botones y DAC.
- `digital-labs/15_dac_r2r_8_bits/src/top.v`: top-level Verilog.
- `digital-labs/15_dac_r2r_8_bits/src/digital_labs.v`: generador de señales.
- `digital-labs/15_dac_r2r_8_bits/src/top.vhd`: versión VHDL autocontenida.

## Demostración en Placa

```bash
cd digital-labs/15_dac_r2r_8_bits
devlab build
devlab flash
```

Al cargar la práctica inicia en rampa. Cada pulsación de `key_enable_n` cambia a seno, cuadrada y de vuelta a rampa. Mide la salida analógica del R-2R con osciloscopio para verificar la forma seleccionada.

## VHDL

```bash
cd digital-labs/15_dac_r2r_8_bits
devlab build -c devlab-vhdl.toml
devlab flash
```

## Pinout

La salida `dac[7:0]` está ordenada de MSB a LSB para conectar la red R-2R. El reloj usa `GPIO52` y los botones usan entradas activas en bajo con pull-up.

| Señal | Función | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- |
| `clk` | Reloj de sistema | 52 | `LVCMOS33`, pull-up |
| `key_reset_n` | Reset activo en bajo | 3 | `LVCMOS18`, pull-up |
| `key_enable_n` | Cambio de modo activo en bajo | 4 | `LVCMOS18`, pull-up |
| `dac[7]` | MSB | 51 | `LVCMOS33` |
| `dac[6]` | bit 6 | 42 | `LVCMOS33` |
| `dac[5]` | bit 5 | 41 | `LVCMOS33` |
| `dac[4]` | bit 4 | 35 | `LVCMOS33` |
| `dac[3]` | bit 3 | 40 | `LVCMOS33` |
| `dac[2]` | bit 2 | 39 | `LVCMOS33` |
| `dac[1]` | bit 1 | 34 | `LVCMOS33` |
| `dac[0]` | LSB | 33 | `LVCMOS33` |

```text [pins.cst]
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;

IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "dac[7]" 51;
IO_PORT "dac[7]" IO_TYPE=LVCMOS33;

IO_LOC "dac[6]" 42;
IO_PORT "dac[6]" IO_TYPE=LVCMOS33;

IO_LOC "dac[5]" 41;
IO_PORT "dac[5]" IO_TYPE=LVCMOS33;

IO_LOC "dac[4]" 35;
IO_PORT "dac[4]" IO_TYPE=LVCMOS33;

IO_LOC "dac[3]" 40;
IO_PORT "dac[3]" IO_TYPE=LVCMOS33;

IO_LOC "dac[2]" 39;
IO_PORT "dac[2]" IO_TYPE=LVCMOS33;

IO_LOC "dac[1]" 34;
IO_PORT "dac[1]" IO_TYPE=LVCMOS33;

IO_LOC "dac[0]" 33;
IO_PORT "dac[0]" IO_TYPE=LVCMOS33;
```

## Código Fuente

::: code-group

```verilog [src/top.v]
module top (
    input  wire       clk,
    input  wire       key_reset_n,
    input  wire       key_enable_n,
    output wire [7:0] dac
);
    dac_r2r_wavegen #(
        .CLK_HZ(27000000),
        .WAVE_HZ(1000)
    ) wavegen (
        .clk(clk),
        .reset_n(key_reset_n),
        .mode_next_n(key_enable_n),
        .dac(dac)
    );
endmodule
```

```verilog [src/digital_labs.v]
`timescale 1ns/1ps

module dac_r2r_wavegen #(
    parameter integer CLK_HZ = 27000000,
    parameter integer WAVE_HZ = 1000
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       mode_next_n,
    output reg  [7:0] dac
);
    localparam integer RAMP_STEP_MAX = CLK_HZ / (WAVE_HZ * 256);
    localparam integer WAVE_STEP_MAX = CLK_HZ / (WAVE_HZ * 32);
    localparam integer DEBOUNCE_MAX = CLK_HZ / 100;

    localparam [1:0] MODE_RAMP   = 2'd0;
    localparam [1:0] MODE_SINE   = 2'd1;
    localparam [1:0] MODE_SQUARE = 2'd2;

    reg [9:0] sample_div = 0;
    reg [18:0] debounce_count = 0;
    reg [7:0] ramp_value = 0;
    reg [4:0] phase = 0;
    reg [1:0] mode = MODE_RAMP;
    reg mode_meta = 1'b1;
    reg mode_sync = 1'b1;
    reg mode_stable = 1'b1;

    function [7:0] sine_lut;
        input [4:0] addr;
        begin
            case (addr)
                5'd0:  sine_lut = 8'd128;
                5'd1:  sine_lut = 8'd153;
                5'd2:  sine_lut = 8'd177;
                5'd3:  sine_lut = 8'd199;
                5'd4:  sine_lut = 8'd218;
                5'd5:  sine_lut = 8'd234;
                5'd6:  sine_lut = 8'd245;
                5'd7:  sine_lut = 8'd253;
                5'd8:  sine_lut = 8'd255;
                5'd9:  sine_lut = 8'd253;
                5'd10: sine_lut = 8'd245;
                5'd11: sine_lut = 8'd234;
                5'd12: sine_lut = 8'd218;
                5'd13: sine_lut = 8'd199;
                5'd14: sine_lut = 8'd177;
                5'd15: sine_lut = 8'd153;
                5'd16: sine_lut = 8'd128;
                5'd17: sine_lut = 8'd103;
                5'd18: sine_lut = 8'd79;
                5'd19: sine_lut = 8'd57;
                5'd20: sine_lut = 8'd38;
                5'd21: sine_lut = 8'd22;
                5'd22: sine_lut = 8'd11;
                5'd23: sine_lut = 8'd3;
                5'd24: sine_lut = 8'd0;
                5'd25: sine_lut = 8'd3;
                5'd26: sine_lut = 8'd11;
                5'd27: sine_lut = 8'd22;
                5'd28: sine_lut = 8'd38;
                5'd29: sine_lut = 8'd57;
                5'd30: sine_lut = 8'd79;
                5'd31: sine_lut = 8'd103;
                default: sine_lut = 8'd128;
            endcase
        end
    endfunction

    always @(posedge clk) begin
        mode_meta <= mode_next_n;
        mode_sync <= mode_meta;

        if (!reset_n) begin
            sample_div <= 0;
            debounce_count <= 0;
            ramp_value <= 0;
            phase <= 0;
            mode <= MODE_RAMP;
            mode_stable <= 1'b1;
            dac <= 8'd0;
        end else begin
            if (mode_sync == mode_stable) begin
                debounce_count <= 0;
            end else if (debounce_count == DEBOUNCE_MAX - 1) begin
                debounce_count <= 0;
                mode_stable <= mode_sync;

                if (!mode_sync) begin
                    mode <= (mode == MODE_SQUARE) ? MODE_RAMP : mode + 2'd1;
                    ramp_value <= 0;
                    phase <= 0;
                    dac <= 8'd0;
                end
            end else begin
                debounce_count <= debounce_count + 1'b1;
            end

            if (((mode == MODE_RAMP) && (sample_div == RAMP_STEP_MAX - 1)) ||
                ((mode != MODE_RAMP) && (sample_div == WAVE_STEP_MAX - 1))) begin
                sample_div <= 0;

                case (mode)
                    MODE_SINE: begin
                        dac <= sine_lut(phase);
                        phase <= phase + 1'b1;
                    end

                    MODE_SQUARE: begin
                        dac <= phase[4] ? 8'hff : 8'h00;
                        phase <= phase + 1'b1;
                    end

                    default: begin
                        dac <= ramp_value;
                        ramp_value <= ramp_value + 1'b1;
                    end
                endcase
            end else begin
                sample_div <= sample_div + 1'b1;
            end
        end
    end
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
        dac : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of top is
    constant CLK_HZ : natural := 27000000;
    constant WAVE_HZ : natural := 1000;
    constant RAMP_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 256);
    constant WAVE_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 32);
    constant SAMPLE_DIV_MAX : natural := WAVE_STEP_MAX;
    constant DEBOUNCE_MAX : natural := CLK_HZ / 100;

    constant MODE_RAMP : natural := 0;
    constant MODE_SINE : natural := 1;
    constant MODE_SQUARE : natural := 2;

    signal sample_div : natural range 0 to SAMPLE_DIV_MAX - 1 := 0;
    signal debounce_count : natural range 0 to DEBOUNCE_MAX - 1 := 0;
    signal ramp_value : unsigned(7 downto 0) := (others => '0');
    signal phase : unsigned(4 downto 0) := (others => '0');
    signal mode : natural range 0 to 2 := MODE_RAMP;
    signal mode_meta : std_logic := '1';
    signal mode_sync : std_logic := '1';
    signal mode_stable : std_logic := '1';
    signal dac_reg : unsigned(7 downto 0) := (others => '0');

    function sine_lut(addr : unsigned(4 downto 0)) return unsigned is
    begin
        case to_integer(addr) is
            when 0  => return to_unsigned(128, 8);
            when 1  => return to_unsigned(153, 8);
            when 2  => return to_unsigned(177, 8);
            when 3  => return to_unsigned(199, 8);
            when 4  => return to_unsigned(218, 8);
            when 5  => return to_unsigned(234, 8);
            when 6  => return to_unsigned(245, 8);
            when 7  => return to_unsigned(253, 8);
            when 8  => return to_unsigned(255, 8);
            when 9  => return to_unsigned(253, 8);
            when 10 => return to_unsigned(245, 8);
            when 11 => return to_unsigned(234, 8);
            when 12 => return to_unsigned(218, 8);
            when 13 => return to_unsigned(199, 8);
            when 14 => return to_unsigned(177, 8);
            when 15 => return to_unsigned(153, 8);
            when 16 => return to_unsigned(128, 8);
            when 17 => return to_unsigned(103, 8);
            when 18 => return to_unsigned(79, 8);
            when 19 => return to_unsigned(57, 8);
            when 20 => return to_unsigned(38, 8);
            when 21 => return to_unsigned(22, 8);
            when 22 => return to_unsigned(11, 8);
            when 23 => return to_unsigned(3, 8);
            when 24 => return to_unsigned(0, 8);
            when 25 => return to_unsigned(3, 8);
            when 26 => return to_unsigned(11, 8);
            when 27 => return to_unsigned(22, 8);
            when 28 => return to_unsigned(38, 8);
            when 29 => return to_unsigned(57, 8);
            when 30 => return to_unsigned(79, 8);
            when 31 => return to_unsigned(103, 8);
            when others => return to_unsigned(128, 8);
        end case;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            mode_meta <= key_enable_n;
            mode_sync <= mode_meta;

            if key_reset_n = '0' then
                sample_div <= 0;
                debounce_count <= 0;
                ramp_value <= (others => '0');
                phase <= (others => '0');
                mode <= MODE_RAMP;
                mode_stable <= '1';
                dac_reg <= (others => '0');
            else
                if mode_sync = mode_stable then
                    debounce_count <= 0;
                elsif debounce_count = DEBOUNCE_MAX - 1 then
                    debounce_count <= 0;
                    mode_stable <= mode_sync;

                    if mode_sync = '0' then
                        if mode = MODE_SQUARE then
                            mode <= MODE_RAMP;
                        else
                            mode <= mode + 1;
                        end if;

                        ramp_value <= (others => '0');
                        phase <= (others => '0');
                        dac_reg <= (others => '0');
                    end if;
                else
                    debounce_count <= debounce_count + 1;
                end if;

                if ((mode = MODE_RAMP) and (sample_div = RAMP_STEP_MAX - 1)) or
                   ((mode /= MODE_RAMP) and (sample_div = WAVE_STEP_MAX - 1)) then
                    sample_div <= 0;

                    case mode is
                        when MODE_SINE =>
                            dac_reg <= sine_lut(phase);
                            phase <= phase + 1;

                        when MODE_SQUARE =>
                            if phase(4) = '1' then
                                dac_reg <= (others => '1');
                            else
                                dac_reg <= (others => '0');
                            end if;
                            phase <= phase + 1;

                        when others =>
                            dac_reg <= ramp_value;
                            ramp_value <= ramp_value + 1;
                    end case;
                else
                    sample_div <= sample_div + 1;
                end if;
            end if;
        end if;
    end process;

    dac <= std_logic_vector(dac_reg);
end architecture;
```

:::

## Teoría Mínima

Una red R-2R suma corrientes ponderadas por bit. El MSB aporta la mitad del rango, el siguiente bit aporta un cuarto, y así sucesivamente. Con 8 bits se obtienen 256 niveles teóricos.

La rampa usa 256 pasos por ciclo. El seno y la cuadrada usan 32 muestras por ciclo. Con reloj de `27 MHz`, los divisores enteros usados dejan las tres formas alrededor de `1 kHz`.

## Prueba Esperada

| Modo | `key_enable_n` | Forma esperada |
| --- | --- | --- |
| 0 | Estado inicial o reset | Rampa ascendente |
| 1 | Una pulsación | Seno aproximado de 32 muestras |
| 2 | Dos pulsaciones | Cuadrada `0x00` / `0xFF` |
| 0 | Tres pulsaciones | Regresa a rampa |

## Actividades

- Mide la salida analógica del R-2R con osciloscopio en los tres modos.
- Confirma que el MSB y LSB están conectados en el orden esperado.
- Usa `key_reset_n` para regresar a rampa si pierdes el modo actual.

## Nota de Pines

La lista original tenía 9 valores y pines repetidos. Para compilar esta práctica se usaron 8 pines únicos para el DAC: `51, 42, 41, 35, 40, 39, 34, 33`.
