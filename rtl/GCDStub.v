module GCDStub (
    // Clock and Reset

    input   wire            clk,
    input   wire            clk_en,
    input   wire            rst_n,

    input   wire            constant_time,
    input   wire            start,
    input   wire [2:0]      op_code,
    input   wire [1278:0]   A,
    input   wire [1278:0]   B,

    output  wire            done,
    output  wire [11:0]     cycle_count,
    output  wire [1283:0]   bezout_a,
    output  wire [1283:0]   bezout_b
);

endmodule
