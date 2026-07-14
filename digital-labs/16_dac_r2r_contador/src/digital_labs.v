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
