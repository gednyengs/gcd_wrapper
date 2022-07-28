module AxiUnpacker (
    // Clock and Reset

    input   wire            CLK,
    input   wire            RESETn,

    // AXI Interface
    input   wire [3:0]      AWID,
    input   wire [31:0]     AWADDR,
    input   wire [7:0]      AWLEN,
    input   wire [2:0]      AWSIZE,
    input   wire [1:0]      AWBURST,
    input   wire            AWLOCK,
    input   wire [3:0]      AWCACHE,
    input   wire [2:0]      AWPROT,
    input   wire            AWVALID,
    output  wire            AWREADY,

    input   wire [63:0]     WDATA,
    input   wire [7:0]      WSTRB,
    input   wire            WLAST,
    input   wire            WVALID,
    output  wire            WREADY,

    output  wire [3:0]      BID,
    output  wire [1:0]      BRESP,
    output  wire            BVALID,
    input   wire            BREADY,

    input   wire [3:0]      ARID,
    input   wire [31:0]     ARADDR,
    input   wire [7:0]      ARLEN,
    input   wire [2:0]      ARSIZE,
    input   wire [1:0]      ARBURST,
    input   wire            ARLOCK,
    input   wire [3:0]      ARCACHE,
    input   wire [2:0]      ARPROT,
    input   wire            ARVALID,
    output  wire            ARREADY,

    output  wire [3:0]      RID,
    output  wire [63:0]     RDATA,
    output  wire [1:0]      RRESP,
    output  wire            RLAST,
    output  wire            RVALID,
    input   wire            RREADY,

    // GCD Interface Signals

    input   wire            DONE,
    output  wire [1278:0]   ARG_A,
    output  wire [1278:0]   ARG_B,
    input   wire [1283:0]   RESULT_A,
    input   wire [1283:0]   RESULT_B
);

endmodule
