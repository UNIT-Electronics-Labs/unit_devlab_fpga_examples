module top (
    input  wire clk,
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire slow_clk;
    wire [7:0] count;

    clock_divider #(.DIV_BITS(24)) clock_signal (
        .clk(clk),
        .reset(~key_reset_n),
        .tick(),
        .slow_clk(slow_clk)
    );

    counter_start_stop_reset #(.N(8)) dut (
        .clk(slow_clk),
        .reset(~key_reset_n),
        .enable(~key_enable_n),
        .up(1'b1),
        .q(count)
    );

    assign led_n = ~count[7];
endmodule
