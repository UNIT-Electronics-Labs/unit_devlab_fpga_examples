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
