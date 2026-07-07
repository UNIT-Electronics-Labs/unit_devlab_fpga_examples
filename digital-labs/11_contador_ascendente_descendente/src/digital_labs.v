`timescale 1ns/1ps

module nbit_adder #(
    parameter integer N = 4
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);
    assign {cout, sum} = a + b + cin;
endmodule

module nbit_subtractor #(
    parameter integer N = 4
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         bin,
    output wire [N-1:0] diff,
    output wire         bout
);
    wire [N:0] result = {1'b0, a} - {1'b0, b} - bin;

    assign diff = result[N-1:0];
    assign bout = result[N];
endmodule

module nbit_comparator #(
    parameter integer N = 4
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire         eq,
    output wire         ne,
    output wire         lt,
    output wire         le,
    output wire         gt,
    output wire         ge
);
    assign eq = (a == b);
    assign ne = (a != b);
    assign lt = (a < b);
    assign le = (a <= b);
    assign gt = (a > b);
    assign ge = (a >= b);
endmodule

module seven_segment_decoder #(
    parameter ACTIVE_LOW = 1
) (
    input  wire [3:0] hex,
    output wire [6:0] seg
);
    reg [6:0] raw;

    always @* begin
        case (hex)
            4'h0: raw = 7'b1111110;
            4'h1: raw = 7'b0110000;
            4'h2: raw = 7'b1101101;
            4'h3: raw = 7'b1111001;
            4'h4: raw = 7'b0110011;
            4'h5: raw = 7'b1011011;
            4'h6: raw = 7'b1011111;
            4'h7: raw = 7'b1110000;
            4'h8: raw = 7'b1111111;
            4'h9: raw = 7'b1111011;
            4'hA: raw = 7'b1110111;
            4'hB: raw = 7'b0011111;
            4'hC: raw = 7'b1001110;
            4'hD: raw = 7'b0111101;
            4'hE: raw = 7'b1001111;
            4'hF: raw = 7'b1000111;
            default: raw = 7'b0000000;
        endcase
    end

    assign seg = ACTIVE_LOW ? ~raw : raw;
endmodule

module sixteen_segment_decoder #(
    parameter ACTIVE_LOW = 1
) (
    input  wire [3:0] hex,
    output wire [15:0] seg
);
    reg [15:0] raw;

    always @* begin
        case (hex)
            4'h0: raw = 16'b1111110000001100;
            4'h1: raw = 16'b0110000000000000;
            4'h2: raw = 16'b1101101100000000;
            4'h3: raw = 16'b1111001100000000;
            4'h4: raw = 16'b0110011100000000;
            4'h5: raw = 16'b1011011100000000;
            4'h6: raw = 16'b1011111100000000;
            4'h7: raw = 16'b1110000000000000;
            4'h8: raw = 16'b1111111100000000;
            4'h9: raw = 16'b1111011100000000;
            4'hA: raw = 16'b1110111100000000;
            4'hB: raw = 16'b1111000010010010;
            4'hC: raw = 16'b1001110000000000;
            4'hD: raw = 16'b1111000010010010;
            4'hE: raw = 16'b1001111100000000;
            4'hF: raw = 16'b1000111100000000;
            default: raw = 16'b0000000000000000;
        endcase
    end

    assign seg = ACTIVE_LOW ? ~raw : raw;
endmodule

module subtract_to_7seg #(
    parameter integer N = 4,
    parameter ACTIVE_LOW = 1
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] diff,
    output wire         borrow,
    output wire [6:0]   seg
);
    nbit_subtractor #(.N(N)) subtractor (
        .a(a),
        .b(b),
        .bin(1'b0),
        .diff(diff),
        .bout(borrow)
    );

    seven_segment_decoder #(.ACTIVE_LOW(ACTIVE_LOW)) display (
        .hex(diff[3:0]),
        .seg(seg)
    );
endmodule

module nbit_alu #(
    parameter integer N = 4
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire [3:0]   op,
    output reg  [N-1:0] y,
    output reg          carry,
    output reg          borrow,
    output wire         zero,
    output wire         equal,
    output wire         less
);
    reg [N:0] ext;

    always @* begin
        y = {N{1'b0}};
        carry = 1'b0;
        borrow = 1'b0;
        ext = {N+1{1'b0}};

        case (op)
            4'h0: begin
                ext = {1'b0, a} + {1'b0, b};
                y = ext[N-1:0];
                carry = ext[N];
            end
            4'h1: begin
                ext = {1'b0, a} - {1'b0, b};
                y = ext[N-1:0];
                borrow = ext[N];
            end
            4'h2: y = a & b;
            4'h3: y = a | b;
            4'h4: y = a ^ b;
            4'h5: y = ~a;
            4'h6: begin
                y = a << 1;
                carry = a[N-1];
            end
            4'h7: begin
                y = a >> 1;
                carry = a[0];
            end
            4'h8: begin
                ext = {1'b0, a} + 1'b1;
                y = ext[N-1:0];
                carry = ext[N];
            end
            4'h9: begin
                ext = {1'b0, a} - 1'b1;
                y = ext[N-1:0];
                borrow = ext[N];
            end
            default: y = {N{1'b0}};
        endcase
    end

    assign zero = (y == {N{1'b0}});
    assign equal = (a == b);
    assign less = (a < b);
endmodule

module clock_divider #(
    parameter integer DIV_BITS = 24
) (
    input  wire clk,
    input  wire reset,
    output wire tick,
    output wire slow_clk
);
    reg [DIV_BITS-1:0] count = 0;

    always @(posedge clk) begin
        if (reset)
            count <= 0;
        else
            count <= count + 1'b1;
    end

    assign tick = (count == {DIV_BITS{1'b0}});
    assign slow_clk = count[DIV_BITS-1];
endmodule

module counter_up #(
    parameter integer N = 4
) (
    input  wire clk,
    input  wire reset,
    output reg  [N-1:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 0;
        else
            q <= q + 1'b1;
    end
endmodule

module counter_down #(
    parameter integer N = 4
) (
    input  wire clk,
    input  wire reset,
    output reg  [N-1:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 0;
        else
            q <= q - 1'b1;
    end
endmodule

module counter_updown #(
    parameter integer N = 4
) (
    input  wire clk,
    input  wire reset,
    input  wire up,
    output reg  [N-1:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 0;
        else if (up)
            q <= q + 1'b1;
        else
            q <= q - 1'b1;
    end
endmodule

module counter_start_stop_reset #(
    parameter integer N = 4
) (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire up,
    output reg  [N-1:0] q
);
    always @(posedge clk) begin
        if (reset)
            q <= 0;
        else if (enable)
            q <= up ? q + 1'b1 : q - 1'b1;
    end
endmodule

module moore_101_detector (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire found
);
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S10 = 2'd2;
    localparam S101 = 2'd3;

    reg [1:0] state = S0;
    reg [1:0] next_state;

    always @* begin
        case (state)
            S0:   next_state = din ? S1 : S0;
            S1:   next_state = din ? S1 : S10;
            S10:  next_state = din ? S101 : S0;
            S101: next_state = din ? S1 : S10;
            default: next_state = S0;
        endcase
    end

    always @(posedge clk) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    assign found = (state == S101);
endmodule

module mealy_101_detector (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output wire found
);
    localparam S0 = 2'd0;
    localparam S1 = 2'd1;
    localparam S10 = 2'd2;

    reg [1:0] state = S0;
    reg [1:0] next_state;

    always @* begin
        case (state)
            S0:  next_state = din ? S1 : S0;
            S1:  next_state = din ? S1 : S10;
            S10: next_state = din ? S1 : S0;
            default: next_state = S0;
        endcase
    end

    always @(posedge clk) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    assign found = (state == S10) && din;
endmodule
