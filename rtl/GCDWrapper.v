module GCDWrapper (
    // Clock and Reset

    input   wire            CLK,
    input   wire            CLKEN,
    input   wire            RESETn,

    // Control Interface

    input   wire [31:0]     S_APB_PADDR,
    input   wire            S_APB_PSEL,
    input   wire            S_APB_PENABLE,
    input   wire            S_APB_PWRITE,
    input   wire [31:0]     S_APB_PWDATA,
    output  wire [31:0]     S_APB_PRDATA,
    output  wire            S_APB_PREADY,
    output  wire            S_APB_PSLVERR,

    // Data Interface

    input   wire [3:0]      S_AXI_AWID,
    input   wire [31:0]     S_AXI_AWADDR,
    input   wire [7:0]      S_AXI_AWLEN,
    input   wire [2:0]      S_AXI_AWSIZE,
    input   wire [1:0]      S_AXI_AWBURST,
    input   wire            S_AXI_AWLOCK,
    input   wire [3:0]      S_AXI_AWCACHE,
    input   wire [2:0]      S_AXI_AWPROT,
    input   wire            S_AXI_AWVALID,
    output  wire            S_AXI_AWREADY,

    input   wire [63:0]     S_AXI_WDATA,
    input   wire [7:0]      S_AXI_WSTRB,
    input   wire            S_AXI_WLAST,
    input   wire            S_AXI_WVALID,
    output  wire            S_AXI_WREADY,

    output  wire [3:0]      S_AXI_BID,
    output  wire [1:0]      S_AXI_BRESP,
    output  wire            S_AXI_BVALID,
    input   wire            S_AXI_BREADY,

    input   wire [3:0]      S_AXI_ARID,
    input   wire [31:0]     S_AXI_ARADDR,
    input   wire [7:0]      S_AXI_ARLEN,
    input   wire [2:0]      S_AXI_ARSIZE,
    input   wire [1:0]      S_AXI_ARBURST,
    input   wire            S_AXI_ARLOCK,
    input   wire [3:0]      S_AXI_ARCACHE,
    input   wire [2:0]      S_AXI_ARPROT,
    input   wire            S_AXI_ARVALID,
    output  wire            S_AXI_ARREADY,

    output  wire [3:0]      S_AXI_RID,
    output  wire [63:0]     S_AXI_RDATA,
    output  wire [1:0]      S_AXI_RRESP,
    output  wire            S_AXI_RLAST,
    output  wire            S_AXI_RVALID,
    input   wire            S_AXI_RREADY,

    // Interrupt

    output  wire            IRQ
);

endmodule
