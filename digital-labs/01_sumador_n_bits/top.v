module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire [3:0] sum;
    wire cout;

    nbit_adder #(.N(4)) dut (
        .a(a),
        .b(b),
        .cin(1'b0),
        .sum(sum),
        .cout(cout)
    );

    assign led_n = ~sum[0];
endmodule
