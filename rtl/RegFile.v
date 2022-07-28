module RegFile (
    // Clock and Reset

    input   wire            CLK,
    input   wire            RESETn,

    // APB Interface

    input   wire [31:0]     PADDR,
    input   wire            PSEL,
    input   wire            PENABLE,
    input   wire            PWRITE,
    input   wire [31:0]     PWDATA,
    output  wire [31:0]     PRDATA,
    output  wire            PREADY,
    output  wire            PSLVERR,

    // Control Signals

    output  wire            CONSTANT_TIME,
    output  wire            START_PULSE,
    output  wire [2:0]      OPCODE,
    output  wire [11:0]     CYCLE_COUNT,
    input   wire            DONE_PULSE,

    // Interrupt
    output  wire            IRQ
);

endmodule
