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
    output  wire [1278:0]   ARG_A,
    output  wire [1278:0]   ARG_B,

    input   wire            DONE,
    input   wire [1283:0]   BEZOUT_A,
    input   wire [1283:0]   BEZOUT_B,

    input   wire [1283:0]   DEBUG_A_CARRY,
    input   wire [1283:0]   DEBUG_A_SUM,
    input   wire [1283:0]   DEBUG_B_CARRY,
    input   wire [1283:0]   DEBUG_B_SUM,

    input   wire [1283:0]   DEBUG_U_CARRY,
    input   wire [1283:0]   DEBUG_U_SUM,
    input   wire [1283:0]   DEBUG_Y_CARRY,
    input   wire [1283:0]   DEBUG_Y_SUM,
    input   wire [1283:0]   DEBUG_L_CARRY,
    input   wire [1283:0]   DEBUG_L_SUM,
    input   wire [1283:0]   DEBUG_N_CARRY,
    input   wire [1283:0]   DEBUG_N_SUM
);

    wire                    sram_ce_n;
    wire [31:0]             sram_addr;
    wire [63:0]             sram_wdata;
    wire                    sram_we_n;
    wire [7:0]              sram_wbe_n;
    wire [63:0]             sram_rdata;

    //
    // AXI to SRAM
    //

    AXItoSRAM axi_to_sram_inst (
        .ACLK               (CLK),
        .ARESETn            (RESETn),

        .S_AXI_AWID         (AWID),
        .S_AXI_AWADDR       (AWADDR),
        .S_AXI_AWLEN        (AWLEN),
        .S_AXI_AWSIZE       (AWSIZE),
        .S_AXI_AWBURST      (AWBURST),
        .S_AXI_AWLOCK       (AWLOCK),
        .S_AXI_AWCACHE      (AWCACHE),
        .S_AXI_AWPROT       (AWPROT),
        .S_AXI_AWVALID      (AWVALID),
        .S_AXI_AWREADY      (AWREADY),
        .S_AXI_WDATA        (WDATA),
        .S_AXI_WSTRB        (WSTRB),
        .S_AXI_WLAST        (WLAST),
        .S_AXI_WVALID       (WVALID),
        .S_AXI_WREADY       (WREADY),
        .S_AXI_BID          (BID),
        .S_AXI_BRESP        (BRESP),
        .S_AXI_BVALID       (BVALID),
        .S_AXI_BREADY       (BREADY),
        .S_AXI_ARID         (ARID),
        .S_AXI_ARADDR       (ARADDR),
        .S_AXI_ARLEN        (ARLEN),
        .S_AXI_ARSIZE       (ARSIZE),
        .S_AXI_ARBURST      (ARBURST),
        .S_AXI_ARLOCK       (ARLOCK),
        .S_AXI_ARCACHE      (ARCACHE),
        .S_AXI_ARPROT       (ARPROT),
        .S_AXI_ARVALID      (ARVALID),
        .S_AXI_ARREADY      (ARREADY),
        .S_AXI_RID          (RID),
        .S_AXI_RDATA        (RDATA),
        .S_AXI_RRESP        (RRESP),
        .S_AXI_RLAST        (RLAST),
        .S_AXI_RVALID       (RVALID),
        .S_AXI_RREADY       (RREADY),

        .SRAM_CEn           (sram_ce_n),
        .SRAM_ADDR          (sram_addr),
        .SRAM_WDATA         (sram_wdata),
        .SRAM_WEn           (sram_we_n),
        .SRAM_WBEn          (sram_wbe_n),
        .SRAM_RDATA         (sram_rdata)
    );

    //
    // AXI Unpacker Core
    //

    AxiUnpackerCore axi_unpacker_core_inst (
        .CLK                (CLK),
        .RESETn             (RESETn),

        .SRAM_CEn           (sram_ce_n),
        .SRAM_ADDR          (sram_addr),
        .SRAM_WDATA         (sram_wdata),
        .SRAM_WEn           (sram_we_n),
        .SRAM_WBEn          (sram_wbe_n),
        .SRAM_RDATA         (sram_rdata),

        .DONE               (DONE),

        .ARG_A              (ARG_A),
        .ARG_B              (ARG_B),

        .BEZOUT_A           (BEZOUT_A),
        .BEZOUT_B           (BEZOUT_B),

        .DEBUG_A_CARRY      (DEBUG_A_CARRY),
        .DEBUG_A_SUM        (DEBUG_A_SUM),
        .DEBUG_B_CARRY      (DEBUG_B_CARRY),
        .DEBUG_B_SUM        (DEBUG_B_SUM),

        .DEBUG_U_CARRY      (DEBUG_U_CARRY),
        .DEBUG_U_SUM        (DEBUG_U_SUM),
        .DEBUG_Y_CARRY      (DEBUG_Y_CARRY),
        .DEBUG_Y_SUM        (DEBUG_Y_SUM),
        .DEBUG_L_CARRY      (DEBUG_L_CARRY),
        .DEBUG_L_SUM        (DEBUG_L_SUM),
        .DEBUG_N_CARRY      (DEBUG_N_CARRY),
        .DEBUG_N_SUM        (DEBUG_N_SUM)
    );

endmodule
