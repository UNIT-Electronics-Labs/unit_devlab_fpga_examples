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
