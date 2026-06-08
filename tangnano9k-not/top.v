module top (
    input wire gpio3_n,
    input wire gpio4_n,
    output wire led_n
);

wire a = ~gpio3_n;

assign led_n = ~(~a);

endmodule
