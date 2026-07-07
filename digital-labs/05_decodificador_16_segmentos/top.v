module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] hex = {2'b00, ~key_reset_n, ~key_enable_n};
    wire [15:0] seg;

    sixteen_segment_decoder #(.ACTIVE_LOW(1)) dut (
        .hex(hex),
        .seg(seg)
    );

    assign led_n = seg[15];
endmodule
