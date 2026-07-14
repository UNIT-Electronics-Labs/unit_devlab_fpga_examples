# 16 DAC R-2R con contador de modo

Practica para generar cuatro formas de onda en un DAC R-2R mientras el display de dos digitos indica el modo activo.

## Objetivo

Combinar salida analogica y visualizacion:

- `01`: rampa triangular.
- `02`: diente de sierra.
- `03`: cuadrada.
- `04`: sinusoidal.
- `key_enable_n`: avanza al siguiente modo.
- `key_reset_n`: regresa al modo `01`.

## Archivos

- `digital-labs/16_dac_r2r_contador/devlab.toml`: build Verilog.
- `digital-labs/16_dac_r2r_contador/devlab-vhdl.toml`: build VHDL.
- `digital-labs/16_dac_r2r_contador/pins.cst`: pines de reloj, botones, display y DAC.
- `digital-labs/16_dac_r2r_contador/src/top.v`: top-level Verilog.
- `digital-labs/16_dac_r2r_contador/src/digital_labs.v`: controlador de modos, DAC y display.
- `digital-labs/16_dac_r2r_contador/src/top.vhd`: versión VHDL autocontenida.

## Demostracion en Placa

```bash
cd digital-labs/16_dac_r2r_contador
devlab build
devlab flash
```

Mide la salida del R-2R con osciloscopio y observa el display. Cada pulsacion de `key_enable_n` debe cambiar al siguiente numero y a la forma de onda correspondiente.

## VHDL

```bash
cd digital-labs/16_dac_r2r_contador
devlab build -c devlab-vhdl.toml
```

## Pinout

El display conserva el pinout de la practica 04. El DAC conserva el orden MSB a LSB de la practica 15, pero `dac[2]` se mueve a GPIO30 para no compartir GPIO39 con `seg[1]`.

| Senal | Funcion | Pin FPGA | IO_TYPE |
| --- | --- | --- | --- |
| `clk` | Reloj de sistema | 52 | `LVCMOS33`, pull-up |
| `key_reset_n` | Reset activo en bajo | 3 | `LVCMOS18`, pull-up |
| `key_enable_n` | Cambio de modo activo en bajo | 4 | `LVCMOS18`, pull-up |
| `dac[7]` | MSB | 51 | `LVCMOS33` |
| `dac[6]` | bit 6 | 42 | `LVCMOS33` |
| `dac[5]` | bit 5 | 41 | `LVCMOS33` |
| `dac[4]` | bit 4 | 35 | `LVCMOS33` |
| `dac[3]` | bit 3 | 40 | `LVCMOS33` |
| `dac[2]` | bit 2 | 30 | `LVCMOS33` |
| `dac[1]` | bit 1 | 34 | `LVCMOS33` |
| `dac[0]` | LSB | 33 | `LVCMOS33` |
| `seg[7:0]` | segmentos | 37, 25, 26, 28, 27, 36, 39, 38 | `LVCMOS33` |
| `digit_en[0]` | decenas | 31 | `LVCMOS33` |
| `digit_en[1]` | unidades | 32 | `LVCMOS33` |

```text [pins.cst]
IO_LOC "clk" 52;
IO_PORT "clk" IO_TYPE=LVCMOS33 PULL_MODE=UP;

IO_LOC "key_reset_n" 3;
IO_PORT "key_reset_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "key_enable_n" 4;
IO_PORT "key_enable_n" IO_TYPE=LVCMOS18 PULL_MODE=UP;

IO_LOC "seg[7]" 37;
IO_PORT "seg[7]" IO_TYPE=LVCMOS33;

IO_LOC "seg[6]" 25;
IO_PORT "seg[6]" IO_TYPE=LVCMOS33;

IO_LOC "seg[5]" 26;
IO_PORT "seg[5]" IO_TYPE=LVCMOS33;

IO_LOC "seg[4]" 28;
IO_PORT "seg[4]" IO_TYPE=LVCMOS33;

IO_LOC "seg[3]" 27;
IO_PORT "seg[3]" IO_TYPE=LVCMOS33;

IO_LOC "seg[2]" 36;
IO_PORT "seg[2]" IO_TYPE=LVCMOS33;

IO_LOC "seg[1]" 39;
IO_PORT "seg[1]" IO_TYPE=LVCMOS33;

IO_LOC "seg[0]" 38;
IO_PORT "seg[0]" IO_TYPE=LVCMOS33;

IO_LOC "digit_en[0]" 31;
IO_PORT "digit_en[0]" IO_TYPE=LVCMOS33;

IO_LOC "digit_en[1]" 32;
IO_PORT "digit_en[1]" IO_TYPE=LVCMOS33;

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

IO_LOC "dac[2]" 30;
IO_PORT "dac[2]" IO_TYPE=LVCMOS33;

IO_LOC "dac[1]" 34;
IO_PORT "dac[1]" IO_TYPE=LVCMOS33;

IO_LOC "dac[0]" 33;
IO_PORT "dac[0]" IO_TYPE=LVCMOS33;
```

## Codigo Fuente

::: code-group

```verilog [src/top.v]
module top (
    input  wire       clk,
    input  wire       key_reset_n,
    input  wire       key_enable_n,
    output wire [7:0] dac,
    output wire [7:0] seg,
    output wire [1:0] digit_en
);
    dac_mode_controller #(
        .CLK_HZ(27000000),
        .WAVE_HZ(1000),
        .REFRESH_HZ(1000),
        .ACTIVE_LOW_SEG(1),
        .ACTIVE_LOW_DIGIT(1)
    ) controller (
        .clk(clk),
        .reset_n(key_reset_n),
        .mode_next_n(key_enable_n),
        .dac(dac),
        .seg(seg),
        .digit_en(digit_en)
    );
endmodule
```

```verilog [src/digital_labs.v]
`timescale 1ns/1ps

module seven_segment_decoder #(
    parameter ACTIVE_LOW = 1
) (
    input  wire [3:0] value,
    output wire [6:0] seg
);
    reg [6:0] raw;

    always @* begin
        case (value)
            4'd0: raw = 7'b1111110;
            4'd1: raw = 7'b0110000;
            4'd2: raw = 7'b1101101;
            4'd3: raw = 7'b1111001;
            4'd4: raw = 7'b0110011;
            4'd5: raw = 7'b1011011;
            4'd6: raw = 7'b1011111;
            4'd7: raw = 7'b1110000;
            4'd8: raw = 7'b1111111;
            4'd9: raw = 7'b1111011;
            default: raw = 7'b0000000;
        endcase
    end

    assign seg = ACTIVE_LOW ? ~raw : raw;
endmodule

module dac_mode_controller #(
    parameter integer CLK_HZ = 27000000,
    parameter integer WAVE_HZ = 1000,
    parameter integer REFRESH_HZ = 1000,
    parameter ACTIVE_LOW_SEG = 1,
    parameter ACTIVE_LOW_DIGIT = 1
) (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       mode_next_n,
    output reg  [7:0] dac,
    output wire [7:0] seg,
    output wire [1:0] digit_en
);
    localparam integer TRIANGLE_STEP_MAX = CLK_HZ / (WAVE_HZ * 512);
    localparam integer SAW_STEP_MAX = CLK_HZ / (WAVE_HZ * 256);
    localparam integer WAVE_STEP_MAX = CLK_HZ / (WAVE_HZ * 32);
    localparam integer DEBOUNCE_MAX = CLK_HZ / 100;
    localparam integer REFRESH_MAX = CLK_HZ / (REFRESH_HZ * 2);

    localparam [1:0] MODE_TRIANGLE = 2'd0;
    localparam [1:0] MODE_SAW      = 2'd1;
    localparam [1:0] MODE_SQUARE   = 2'd2;
    localparam [1:0] MODE_SINE     = 2'd3;

    reg [9:0] sample_div = 0;
    reg [18:0] debounce_count = 0;
    reg [14:0] refresh_div = 0;
    reg [8:0] triangle_phase = 0;
    reg [7:0] saw_value = 0;
    reg [4:0] phase = 0;
    reg [1:0] mode = MODE_TRIANGLE;
    reg mode_meta = 1'b1;
    reg mode_sync = 1'b1;
    reg mode_stable = 1'b1;
    reg selected_digit = 1'b0;
    reg [3:0] selected_bcd;
    reg [7:0] raw_seg;
    reg [1:0] raw_digit_en;

    wire [6:0] seg7;
    wire [3:0] mode_number = {2'b00, mode} + 4'd1;
    wire sample_tick =
        ((mode == MODE_TRIANGLE) && (sample_div == TRIANGLE_STEP_MAX - 1)) ||
        ((mode == MODE_SAW) && (sample_div == SAW_STEP_MAX - 1)) ||
        (((mode == MODE_SQUARE) || (mode == MODE_SINE)) && (sample_div == WAVE_STEP_MAX - 1));

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
            triangle_phase <= 0;
            saw_value <= 0;
            phase <= 0;
            mode <= MODE_TRIANGLE;
            mode_stable <= 1'b1;
            dac <= 8'd0;
        end else begin
            if (mode_sync == mode_stable) begin
                debounce_count <= 0;
            end else if (debounce_count == DEBOUNCE_MAX - 1) begin
                debounce_count <= 0;
                mode_stable <= mode_sync;

                if (!mode_sync) begin
                    mode <= mode + 2'd1;
                    triangle_phase <= 0;
                    saw_value <= 0;
                    phase <= 0;
                    dac <= 8'd0;
                end
            end else begin
                debounce_count <= debounce_count + 1'b1;
            end

            if (sample_tick) begin
                sample_div <= 0;

                case (mode)
                    MODE_SAW: begin
                        dac <= saw_value;
                        saw_value <= saw_value + 1'b1;
                    end

                    MODE_SQUARE: begin
                        dac <= phase[4] ? 8'hff : 8'h00;
                        phase <= phase + 1'b1;
                    end

                    MODE_SINE: begin
                        dac <= sine_lut(phase);
                        phase <= phase + 1'b1;
                    end

                    default: begin
                        dac <= triangle_phase[8] ? ~triangle_phase[7:0] : triangle_phase[7:0];
                        triangle_phase <= triangle_phase + 1'b1;
                    end
                endcase
            end else begin
                sample_div <= sample_div + 1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if (!reset_n) begin
            refresh_div <= 0;
            selected_digit <= 1'b0;
        end else if (refresh_div == REFRESH_MAX - 1) begin
            refresh_div <= 0;
            selected_digit <= ~selected_digit;
        end else begin
            refresh_div <= refresh_div + 1'b1;
        end
    end

    always @* begin
        selected_bcd = selected_digit ? 4'd0 : mode_number;
        raw_seg = {seg7, 1'b0};
        raw_digit_en = selected_digit ? 2'b01 : 2'b10;
    end

    seven_segment_decoder #(.ACTIVE_LOW(0)) decoder (
        .value(selected_bcd),
        .seg(seg7)
    );

    assign seg = ACTIVE_LOW_SEG ? ~raw_seg : raw_seg;
    assign digit_en = ACTIVE_LOW_DIGIT ? ~raw_digit_en : raw_digit_en;
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
        dac : out std_logic_vector(7 downto 0);
        seg : out std_logic_vector(7 downto 0);
        digit_en : out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of top is
    constant CLK_HZ : natural := 27000000;
    constant WAVE_HZ : natural := 1000;
    constant REFRESH_HZ : natural := 1000;
    constant TRIANGLE_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 512);
    constant SAW_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 256);
    constant WAVE_STEP_MAX : natural := CLK_HZ / (WAVE_HZ * 32);
    constant DEBOUNCE_MAX : natural := CLK_HZ / 100;
    constant REFRESH_MAX : natural := CLK_HZ / (REFRESH_HZ * 2);

    constant MODE_TRIANGLE : natural := 0;
    constant MODE_SAW : natural := 1;
    constant MODE_SQUARE : natural := 2;
    constant MODE_SINE : natural := 3;

    signal sample_div : natural range 0 to WAVE_STEP_MAX - 1 := 0;
    signal debounce_count : natural range 0 to DEBOUNCE_MAX - 1 := 0;
    signal refresh_div : natural range 0 to REFRESH_MAX - 1 := 0;
    signal triangle_phase : unsigned(8 downto 0) := (others => '0');
    signal saw_value : unsigned(7 downto 0) := (others => '0');
    signal phase : unsigned(4 downto 0) := (others => '0');
    signal mode : natural range 0 to 3 := MODE_TRIANGLE;
    signal mode_meta : std_logic := '1';
    signal mode_sync : std_logic := '1';
    signal mode_stable : std_logic := '1';
    signal selected_digit : std_logic := '0';
    signal dac_reg : unsigned(7 downto 0) := (others => '0');

    function seven_seg(value : natural) return std_logic_vector is
    begin
        case value is
            when 0 => return "1111110";
            when 1 => return "0110000";
            when 2 => return "1101101";
            when 3 => return "1111001";
            when 4 => return "0110011";
            when 5 => return "1011011";
            when 6 => return "1011111";
            when 7 => return "1110000";
            when 8 => return "1111111";
            when 9 => return "1111011";
            when others => return "0000000";
        end case;
    end function;

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
                triangle_phase <= (others => '0');
                saw_value <= (others => '0');
                phase <= (others => '0');
                mode <= MODE_TRIANGLE;
                mode_stable <= '1';
                dac_reg <= (others => '0');
            else
                if mode_sync = mode_stable then
                    debounce_count <= 0;
                elsif debounce_count = DEBOUNCE_MAX - 1 then
                    debounce_count <= 0;
                    mode_stable <= mode_sync;

                    if mode_sync = '0' then
                        if mode = MODE_SINE then
                            mode <= MODE_TRIANGLE;
                        else
                            mode <= mode + 1;
                        end if;

                        triangle_phase <= (others => '0');
                        saw_value <= (others => '0');
                        phase <= (others => '0');
                        dac_reg <= (others => '0');
                    end if;
                else
                    debounce_count <= debounce_count + 1;
                end if;

                if ((mode = MODE_TRIANGLE) and (sample_div = TRIANGLE_STEP_MAX - 1)) or
                   ((mode = MODE_SAW) and (sample_div = SAW_STEP_MAX - 1)) or
                   (((mode = MODE_SQUARE) or (mode = MODE_SINE)) and (sample_div = WAVE_STEP_MAX - 1)) then
                    sample_div <= 0;

                    case mode is
                        when MODE_SAW =>
                            dac_reg <= saw_value;
                            saw_value <= saw_value + 1;

                        when MODE_SQUARE =>
                            if phase(4) = '1' then
                                dac_reg <= (others => '1');
                            else
                                dac_reg <= (others => '0');
                            end if;
                            phase <= phase + 1;

                        when MODE_SINE =>
                            dac_reg <= sine_lut(phase);
                            phase <= phase + 1;

                        when others =>
                            if triangle_phase(8) = '1' then
                                dac_reg <= not triangle_phase(7 downto 0);
                            else
                                dac_reg <= triangle_phase(7 downto 0);
                            end if;
                            triangle_phase <= triangle_phase + 1;
                    end case;
                else
                    sample_div <= sample_div + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if key_reset_n = '0' then
                refresh_div <= 0;
                selected_digit <= '0';
            elsif refresh_div = REFRESH_MAX - 1 then
                refresh_div <= 0;
                selected_digit <= not selected_digit;
            else
                refresh_div <= refresh_div + 1;
            end if;
        end if;
    end process;

    process(mode, selected_digit)
        variable raw_seg : std_logic_vector(7 downto 0);
        variable raw_digit_en : std_logic_vector(1 downto 0);
        variable selected_bcd : natural range 0 to 9;
    begin
        if selected_digit = '1' then
            selected_bcd := 0;
            raw_digit_en := "01";
        else
            selected_bcd := mode + 1;
            raw_digit_en := "10";
        end if;

        raw_seg := seven_seg(selected_bcd) & '0';
        seg <= not raw_seg;
        digit_en <= not raw_digit_en;
    end process;

    dac <= std_logic_vector(dac_reg);
end architecture;
```

:::

## Teoria Minima

La practica usa un contador de modo debounced por boton. Ese modo alimenta dos bloques al mismo tiempo: el generador DAC y el multiplexado del display. Asi el numero mostrado y la forma generada cambian juntos.

La salida del DAC mantiene el orden MSB a LSB de la práctica 15, excepto `dac[2]`, que se mueve a `GPIO30` porque `GPIO39` queda reservado para el segmento `g` del display.

## Prueba Esperada

| Display | Forma de onda | Acción |
| --- | --- | --- |
| `01` | Rampa triangular | Estado inicial o reset |
| `02` | Diente de sierra | Una pulsación de `key_enable_n` |
| `03` | Cuadrada | Dos pulsaciones de `key_enable_n` |
| `04` | Sinusoidal | Tres pulsaciones de `key_enable_n` |
| `01` | Rampa triangular | Cuatro pulsaciones o `key_reset_n` |

## Actividades

- Mide las cuatro formas de onda con osciloscopio.
- Verifica que el display cambie `01`, `02`, `03`, `04`.
- Confirma que `key_reset_n` regresa a `01`.
