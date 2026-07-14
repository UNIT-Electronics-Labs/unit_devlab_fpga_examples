module top (
    input  wire       clk,
    input  wire       key_reset_n,
    input  wire       key_enable_n,
    output wire [7:0] dac
);
    dac_r2r_wavegen #(
        .CLK_HZ(27000000),
        .WAVE_HZ(1000)
    ) wavegen (
        .clk(clk),
        .reset_n(key_reset_n),
        .mode_next_n(key_enable_n),
        .dac(dac)
    );
endmodule
