module top (
    input  wire key_reset_n,
    input  wire key_enable_n,
    output wire led_n
);
    wire [3:0] a = {3'b000, ~key_reset_n};
    wire [3:0] b = {3'b000, ~key_enable_n};
    wire [3:0] diff;
    wire bout;

    nbit_subtractor #(.N(4)) dut (
        .a(a),
        .b(b),
        .bin(1'b0),
        .diff(diff),
        .bout(bout)
    );

    assign led_n = ~diff[0];
endmodule
