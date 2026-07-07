module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire eq;

    nbit_comparator #(.N(4)) dut (
        .a(a),
        .b(b),
        .eq(eq),
        .ne(),
        .lt(),
        .le(),
        .gt(),
        .ge()
    );

    assign led_n = ~eq;
endmodule
