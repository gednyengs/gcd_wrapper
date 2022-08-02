module GCDStub (
    // Clock and Reset

    input   wire            clk,
    input   wire            clk_en,
    input   wire            rst_n,

    input   wire            constant_time,
    input   wire            debug_mode,
    input   wire            start,
    input   wire [2:0]      op_code,
    input   wire [1278:0]   A,
    input   wire [1278:0]   B,

    output  wire            done,
    output  wire [11:0]     cycle_count,
    output  wire [1283:0]   bezout_a,
    output  wire [1283:0]   bezout_b,
    output  wire [1283:0]   debug_a,
    output  wire [1283:0]   debug_b,
    output  wire [1283:0]   debug_u,
    output  wire [1283:0]   debug_y,
    output  wire [1283:0]   debug_l,
    output  wire [1283:0]   debug_n,
    output  wire [15:0]     debug_lower_a,
    output  wire [15:0]     debug_lower_b,
    output  wire [15:0]     debug_lower_u,
    output  wire [15:0]     debug_lower_y,
    output  wire [15:0]     debug_lower_l,
    output  wire [15:0]     debug_lower_n,
    output  wire [3:0]      debug_case_a_b,
    output  wire [4:0]      debug_case_u,
    output  wire [4:0]      debug_case_y,
    output  wire [4:0]      debug_case_l,
    output  wire [4:0]      debug_case_n
);

endmodule
