// The Ring - 8bit TRNG
// Done in association with FPGA Ignite 2024
// 09.08.2024

// _Disclaimer_:
// Depending on the SIZE parameters the RO might result in exessive dynamic power!
// Monitor current and chip temperature to be extra safe
// A small setting of SIZE = 8 was demonstrated in FPGA to be not noticeable

// _Ports_:
// - clk: Clock that samples the RO values (probably 50ishMHz IO clk)
// - en: Turn on RO. You might want to turn off RO when not using as to safe power and maybe stop chip from aging too much ;)
// - d_out: 8-bit random values sampled form RO

module trng_top #(parameter SIZE = 8) (
    input clk,
    input en,
    output [SIZE-1:0] d_out
);

    reg[SIZE-1:0] d_out_internal;
    wire[2*SIZE-1:0] ro_out;
    wire[SIZE-1:0] xor_out;

    // Generate ring oscillators
    genvar i;
    generate
        for (i = 0; i < SIZE; i=i+1) begin
            generic_ro #(.SIZE(1)) ro_1 (.en(en), .ro_out(ro_out[2*i]));   // 3-inv elements
            generic_ro #(.SIZE(2)) ro_2 (.en(en), .ro_out(ro_out[2*i+1])); // 5-inv elements
            assign xor_out[i] = ro_out[2*i] ^ ro_out[2*i+1];
        end
    endgenerate

    // FF that sample the XOR output
    always @(posedge clk) begin
        d_out_internal <= xor_out;
    end

    // Assign to output
    assign d_out = d_out_internal;

endmodule