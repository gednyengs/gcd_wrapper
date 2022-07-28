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

    //
    // Internal Signals
    //

    wire                    constant_time_w;
    wire                    start_pulse_w;
    wire [2:0]              opcode_w;
    wire [11:0]             cycle_count_w;

    wire [1278:0]           arg_a_w;
    wire [1278:0]           arg_b_w;
    wire [1283:0]           result_a_w;
    wire [1283:0]           result_b_w;

    wire                    done_w;
    wire                    done_pulse_w;
    reg                     done_r;

    //
    // Control Register File
    //

    RegFile reg_file_inst (
        .CLK                (CLK),
        .RESETn             (RESETn),

        .PADDR              (S_APB_PADDR),
        .PSEL               (S_APB_PSEL),
        .PENABLE            (S_APB_PENABLE),
        .PWRITE             (S_APB_PWRITE),
        .PWDATA             (S_APB_PWDATA),
        .PRDATA             (S_APB_PRDATA),
        .PREADY             (S_APB_PREADY),
        .PSLVERR            (S_APB_PSLVERR),

        .CONSTANT_TIME      (constant_time_w),
        .START_PULSE        (start_pulse_w),
        .OPCODE             (opcode_w),
        .CYCLE_COUNT        (cycle_count_w),
        .DONE_PULSE         (done_pulse_w),

        .IRQ                (IRQ)
    );

    //
    // AXI Unpacker
    //

    AxiUnpacker axi_unpacker_inst (
        .CLK                (CLK),
        .RESETn             (RESETn),

        .AWID               (S_AXI_AWID),
        .AWADDR             (S_AXI_AWADDR),
        .AWLEN              (S_AXI_AWLEN),
        .AWSIZE             (S_AXI_AWSIZE),
        .AWBURST            (S_AXI_AWBURST),
        .AWLOCK             (S_AXI_AWLOCK),
        .AWCACHE            (S_AXI_AWCACHE),
        .AWPROT             (S_AXI_AWPROT),
        .AWVALID            (S_AXI_AWVALID),
        .AWREADY            (S_AXI_AWREADY),
        .WDATA              (S_AXI_WDATA),
        .WSTRB              (S_AXI_WSTRB),
        .WLAST              (S_AXI_WLAST),
        .WVALID             (S_AXI_WVALID),
        .WREADY             (S_AXI_WREADY),
        .BID                (S_AXI_BID),
        .BRESP              (S_AXI_BRESP),
        .BVALID             (S_AXI_BVALID),
        .BREADY             (S_AXI_BREADY),
        .ARID               (S_AXI_ARID),
        .ARADDR             (S_AXI_ARADDR),
        .ARLEN              (S_AXI_ARLEN),
        .ARSIZE             (S_AXI_ARSIZE),
        .ARBURST            (S_AXI_ARBURST),
        .ARLOCK             (S_AXI_ARLOCK),
        .ARCACHE            (S_AXI_ARCACHE),
        .ARPROT             (S_AXI_ARPROT),
        .ARVALID            (S_AXI_ARVALID),
        .ARREADY            (S_AXI_ARREADY),
        .RID                (S_AXI_RID),
        .RDATA              (S_AXI_RDATA),
        .RRESP              (S_AXI_RRESP),
        .RLAST              (S_AXI_RLAST),
        .RVALID             (S_AXI_RVALID),
        .RREADY             (S_AXI_RREADY),

        .DONE               (done_pulse_w),
        .ARG_A              (arg_a_w),
        .ARG_B              (arg_b_w),
        .RESULT_A           (result_a_w),
        .RESULT_B           (result_b_w)
    );

    //
    // Internal Logic
    //

    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            done_r  <= 1'b0;
        else if (CLKEN)
            done_r  <= done_w;

    assign done_pulse_w = done_w & ~done_r;

    //
    // GCD Module
    //

    GCDStub gcd_inst (
        .clk                (CLK),
        .clk_en             (CLKEN),
        .rst_n              (RESETn),

        .constant_time      (constant_time_w),
        .start              (start_pulse_w),
        .op_code            (opcode_w),
        .A                  (arg_a_w),
        .B                  (arg_b_w),

        .done               (done_w),
        .cycle_count        (cycle_count_w),
        .bezout_a           (result_a_w),
        .bezout_b           (result_b_w)
    );

endmodule
