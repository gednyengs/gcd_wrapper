module AxiUnpackerCore (
    // Clock and Reset

    input   wire            CLK,
    input   wire            RESETn,

    // SRAM Interface
    input   wire            SRAM_CEn,
    input   wire [31:0]     SRAM_ADDR,
    input   wire [63:0]     SRAM_WDATA,
    input   wire            SRAM_WEn,
    input   wire [7:0]      SRAM_WBEn,
    output  wire [63:0]     SRAM_RDATA,

    // GCD Interface Signals

    input   wire            DONE,
    output  wire [1278:0]   ARG_A,
    output  wire [1278:0]   ARG_B,
    input   wire [1283:0]   RESULT_A,
    input   wire [1283:0]   RESULT_B
);




endmodule
