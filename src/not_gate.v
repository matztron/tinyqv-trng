module not_gate(a, inversedA);

input a;
output inversedA;

`ifdef SIMULATION
    assign #1 inversedA = ~a; // For simulation: 1 time unit delay
`else
    assign inversedA = ~a; // For synthesis: no delay
`endif

endmodule