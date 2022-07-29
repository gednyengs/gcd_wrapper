module RegFile (
    // Clock and Reset
    input   wire            ACLK,
    input   wire            ARESETN,

    // Capture Regs
    input   wire [31:0]     AW,
    input   wire [31:0]     AWInfo,
    input   wire [63:0]     W,
    input   wire [31:0]     WInfo,
    input   wire [31:0]     BInfo,
    input   wire [31:0]     AR,
    input   wire [31:0]     ARInfo,
    input   wire [63:0]     R,
    input   wire [31:0]     RInfo,

    // APB Interface
    input   wire [31:0]     PADDR,
    input   wire            PENABLE,
    input   wire            PSEL,
    input   wire            PWRITE,
    input   wire [31:0]     PWDATA,
    output  wire            PREADY,
    output  wire            PSLVERR,
    output  wire [31:0]     PRDATA,

    // Control Signals
    input   wire            Capt,
    output  wire            Irq
);

    // =========================================================================
    // Address Space
    // -------------------------------------------------------------------------
    // Offset   | Reg Name
    // -------------------------------------------------------------------------
    // 0x00     | ID Register
    // 0x04     | AW Info (AWLEN, AWSIZE, AWBURST, AWID)
    // 0x08     | AW
    // 0x0C     | W Info (WSTRB, WLAST)
    // 0x10     | W_Low (WDATA[31:0])
    // 0x14     | W_High (WDATA[63:32])
    // 0x18     | B Info (BRESP, BID)
    // 0x1C     | AR Info (ARLEN, ARSIZE, ARBURST, ARID)
    // 0x20     | AR
    // 0x24     | R Info (RLAST, RRESP, RID)
    // 0x28     | R_Low (R[31:0])
    // 0x2C     | R_High (R[63:32])
    // 0x30     | CTRL
    // 0x34     | STAT
    //--------------------------------------------------------------------------

    // Internal APB Signals

    reg [31:0]  apb_prdata;
    reg [31:0]  reg_data_out;
    wire        setup_phase;
    wire        wr_en;
    wire        rd_en;

    // Registers
    reg [31:0]  reg_CTRL;
    reg [31:0]  reg_STAT;

    // Register Access

    wire [3:0]  addr_oft;
    assign addr_oft = PADDR[5:2];

    // REG_CTRL
    always @(posedge ACLK or negedge ARESETN)
        if (!ARESETN)
            reg_CTRL        <= 32'd0;
        else if (wr_en && (addr_oft == 4'd12))
            reg_CTRL        <= PWDATA;

    // REG_STAT
    always @(posedge ACLK or negedge ARESETN)
        if (!ARESETN)
            reg_STAT        <= 32'd0;
        else if(Capt)
            reg_STAT[0]     <= 1'b1;
        else if (wr_en && (addr_oft == 4'd13) && (PWDATA[0] == 1'b1))
            reg_STAT[0]     <= 1'b0;


    // Read Data
    always @(*)
        case (addr_oft)
            4'd0    : reg_data_out  = 32'h5A5A5A5A;
            4'd1    : reg_data_out  = AWInfo;
            4'd2    : reg_data_out  = AW;
            4'd3    : reg_data_out  = WInfo;
            4'd4    : reg_data_out  = W[31:0];
            4'd5    : reg_data_out  = W[63:32];
            4'd6    : reg_data_out  = BInfo;
            4'd7    : reg_data_out  = ARInfo;
            4'd8    : reg_data_out  = AR;
            4'd9    : reg_data_out  = RInfo;
            4'd10   : reg_data_out  = R[31:0];
            4'd11   : reg_data_out  = R[63:32];
            4'd12   : reg_data_out  = reg_CTRL;
            4'd13   : reg_data_out  = reg_STAT;
            default : reg_data_out  = 32'd0;
        endcase

    always @(posedge ACLK or negedge ARESETN)
        if (!ARESETN)
            apb_prdata  <= 32'd0;
        else if (rd_en)
            apb_prdata  <= reg_data_out;

    // Control Output Signal Assignments

    assign Irq  = reg_CTRL[0] & reg_STAT[0];

    // APB Signal Assignments

    assign setup_phase = PSEL & ~PENABLE;
    assign wr_en = setup_phase & PWRITE;
    assign rd_en = setup_phase & ~PWRITE;

    assign PRDATA   = apb_prdata;
    assign PREADY   = 1'b1;
    assign PSLVERR  = 1'b0;

endmodule
