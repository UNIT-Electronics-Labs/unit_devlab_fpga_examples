module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire [3:0] y;

    nbit_alu #(.N(4)) dut (
        .a(a),
        .b(b),
        .op(4'h0),
        .y(y),
        .carry(),
        .borrow(),
        .zero(),
        .equal(),
        .less()
    );

    assign led_n = ~y[0];
endmodule
