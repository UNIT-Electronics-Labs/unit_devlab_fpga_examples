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
