module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire [3:0] diff;
    wire borrow;
    wire [6:0] seg;

    subtract_to_7seg #(.N(4), .ACTIVE_LOW(1)) dut (
        .a(a),
        .b(b),
        .diff(diff),
        .borrow(borrow),
        .seg(seg)
    );

    assign led_n = seg[6];
endmodule
