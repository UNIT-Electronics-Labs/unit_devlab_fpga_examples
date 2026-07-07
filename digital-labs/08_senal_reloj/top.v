module top (
    input  wire clk,
    input  wire key_reset_n,
    output wire led_n
);
    wire slow_clk;

    clock_divider #(.DIV_BITS(24)) dut (
        .clk(clk),
        .reset(~key_reset_n),
        .tick(),
        .slow_clk(slow_clk)
    );

    assign led_n = ~slow_clk;
endmodule
