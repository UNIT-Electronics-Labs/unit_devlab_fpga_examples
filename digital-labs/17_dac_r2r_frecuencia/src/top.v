module top (
    input  wire       clk,
    input  wire       key_down_n,
    input  wire       key_up_n,
    output wire [7:0] dac,
    output wire [7:0] seg,
    output wire [1:0] digit_en
);
    dac_sine_frequency_controller #(
        .CLK_HZ(27000000),
        .REFRESH_HZ(1000),
        .DEBOUNCE_MS(10)
    ) controller (
        .clk(clk),
        .key_down_n(key_down_n),
        .key_up_n(key_up_n),
        .dac(dac),
        .seg(seg),
        .digit_en(digit_en)
    );
endmodule
