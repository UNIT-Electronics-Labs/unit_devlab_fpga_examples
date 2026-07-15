`timescale 1ns/1ps

module debounce_press #(
    parameter integer CYCLES = 270000
) (
    input  wire clk,
    input  wire key_n,
    output reg  pressed = 1'b0
);
    reg key_meta = 1'b1;
    reg key_sync = 1'b1;
    reg key_stable = 1'b1;
    reg [18:0] count = 0;

    always @(posedge clk) begin
        key_meta <= key_n;
        key_sync <= key_meta;
        pressed <= 1'b0;

        if (key_sync == key_stable) begin
            count <= 0;
        end else if (count == CYCLES - 1) begin
            count <= 0;
            key_stable <= key_sync;
            if (!key_sync)
                pressed <= 1'b1;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule

module seven_segment_decoder (
    input  wire [3:0] value,
    output reg  [6:0] seg
);
    always @* begin
        case (value)
            4'd0: seg = 7'b1111110;
            4'd1: seg = 7'b0110000;
            4'd2: seg = 7'b1101101;
            4'd3: seg = 7'b1111001;
            4'd4: seg = 7'b0110011;
            4'd5: seg = 7'b1011011;
            4'd6: seg = 7'b1011111;
            4'd7: seg = 7'b1110000;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1111011;
            default: seg = 7'b0000000;
        endcase
    end
endmodule

module dac_sine_frequency_controller #(
    parameter integer CLK_HZ = 27000000,
    parameter integer REFRESH_HZ = 1000,
    parameter integer DEBOUNCE_MS = 10
) (
    input  wire       clk,
    input  wire       key_down_n,
    input  wire       key_up_n,
    output reg  [7:0] dac = 8'd128,
    output wire [7:0] seg,
    output wire [1:0] digit_en
);
    localparam integer DEBOUNCE_CYCLES = (CLK_HZ / 1000) * DEBOUNCE_MS;
    localparam integer REFRESH_CYCLES = CLK_HZ / (REFRESH_HZ * 2);

    reg [3:0] frequency_index = 4'd1;
    reg [31:0] phase = 0;
    reg [14:0] refresh_count = 0;
    reg selected_digit = 1'b0;

    wire down_pressed;
    wire up_pressed;
    wire [3:0] display_number = frequency_index + 4'd1;
    wire [3:0] display_value = selected_digit ? 4'd0 : display_number;
    wire [6:0] raw_seg;
    wire [1:0] raw_digit_en = selected_digit ? 2'b01 : 2'b10;

    function [31:0] phase_increment;
        input [3:0] index;
        begin
            case (index)
                4'd0: phase_increment = 32'd79536;    // 500 Hz
                4'd1: phase_increment = 32'd159073;   // 1 kHz
                4'd2: phase_increment = 32'd238609;   // 1.5 kHz
                4'd3: phase_increment = 32'd318146;   // 2 kHz
                4'd4: phase_increment = 32'd477219;   // 3 kHz
                default: phase_increment = 32'd636291; // 4 kHz
            endcase
        end
    endfunction

    function [7:0] sine_lut;
        input [4:0] addr;
        begin
            case (addr)
                5'd0: sine_lut=8'd128; 5'd1: sine_lut=8'd153;
                5'd2: sine_lut=8'd177; 5'd3: sine_lut=8'd199;
                5'd4: sine_lut=8'd218; 5'd5: sine_lut=8'd234;
                5'd6: sine_lut=8'd245; 5'd7: sine_lut=8'd253;
                5'd8: sine_lut=8'd255; 5'd9: sine_lut=8'd253;
                5'd10: sine_lut=8'd245; 5'd11: sine_lut=8'd234;
                5'd12: sine_lut=8'd218; 5'd13: sine_lut=8'd199;
                5'd14: sine_lut=8'd177; 5'd15: sine_lut=8'd153;
                5'd16: sine_lut=8'd128; 5'd17: sine_lut=8'd103;
                5'd18: sine_lut=8'd79; 5'd19: sine_lut=8'd57;
                5'd20: sine_lut=8'd38; 5'd21: sine_lut=8'd22;
                5'd22: sine_lut=8'd11; 5'd23: sine_lut=8'd3;
                5'd24: sine_lut=8'd0; 5'd25: sine_lut=8'd3;
                5'd26: sine_lut=8'd11; 5'd27: sine_lut=8'd22;
                5'd28: sine_lut=8'd38; 5'd29: sine_lut=8'd57;
                5'd30: sine_lut=8'd79; default: sine_lut=8'd103;
            endcase
        end
    endfunction

    debounce_press #(.CYCLES(DEBOUNCE_CYCLES)) down_button (
        .clk(clk), .key_n(key_down_n), .pressed(down_pressed)
    );

    debounce_press #(.CYCLES(DEBOUNCE_CYCLES)) up_button (
        .clk(clk), .key_n(key_up_n), .pressed(up_pressed)
    );

    seven_segment_decoder decoder (.value(display_value), .seg(raw_seg));

    always @(posedge clk) begin
        if (up_pressed && !down_pressed && frequency_index < 4'd5)
            frequency_index <= frequency_index + 1'b1;
        else if (down_pressed && !up_pressed && frequency_index > 0)
            frequency_index <= frequency_index - 1'b1;

        phase <= phase + phase_increment(frequency_index);
        dac <= sine_lut(phase[31:27]);

        if (refresh_count == REFRESH_CYCLES - 1) begin
            refresh_count <= 0;
            selected_digit <= ~selected_digit;
        end else begin
            refresh_count <= refresh_count + 1'b1;
        end
    end

    assign seg = ~{raw_seg, 1'b0};
    assign digit_en = ~raw_digit_en;
endmodule
