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

    wire                    constant_time;
    wire                    debug_mode;
    wire                    start_pulse;
    wire [2:0]              opcode;
    wire [11:0]             cycle_count;
    wire [1278:0]           arg_a;
    wire [1278:0]           arg_b;

    wire [1283:0]           bezout_a;
    wire [1283:0]           bezout_b;
    wire [1283:0]           debug_a;
    wire [1283:0]           debug_b;
    wire [1283:0]           debug_u;
    wire [1283:0]           debug_y;
    wire [1283:0]           debug_l;
    wire [1283:0]           debug_n;
    wire [15:0]             debug_lower_a;
    wire [15:0]             debug_lower_b;
    wire [15:0]             debug_lower_u;
    wire [15:0]             debug_lower_y;
    wire [15:0]             debug_lower_l;
    wire [15:0]             debug_lower_n;
    wire [3:0]              debug_case_a_b;
    wire [4:0]              debug_case_u;
    wire [4:0]              debug_case_y;
    wire [4:0]              debug_case_l;
    wire [4:0]              debug_case_n;

    wire                    done;
    wire                    done_pulse;
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

        .CONSTANT_TIME      (constant_time),
        .DEBUG_MODE         (debug_mode),
        .OPCODE             (opcode),
        .START_PULSE        (start_pulse),

        .DONE_PULSE         (done_pulse),
        .CYCLE_COUNT        (cycle_count),
        .DEBUG_LOWER_A      (debug_lower_a),
        .DEBUG_LOWER_B      (debug_lower_b),
        .DEBUG_LOWER_U      (debug_lower_u),
        .DEBUG_LOWER_Y      (debug_lower_y),
        .DEBUG_LOWER_L      (debug_lower_l),
        .DEBUG_LOWER_N      (debug_lower_n),
        .DEBUG_CASE_A_B     (debug_case_a_b),
        .DEBUG_CASE_U       (debug_case_u),
        .DEBUG_CASE_Y       (debug_case_y),
        .DEBUG_CASE_L       (debug_case_l),
        .DEBUG_CASE_N       (debug_case_n),

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

        .ARG_A              (arg_a),
        .ARG_B              (arg_b),
        .DONE               (done_pulse),
        .BEZOUT_A           (bezout_a),
        .BEZOUT_B           (bezout_b),
        .DEBUG_A            (debug_a),
        .DEBUG_B            (debug_b),
        .DEBUG_U            (debug_u),
        .DEBUG_Y            (debug_y),
        .DEBUG_L            (debug_l),
        .DEBUG_N            (debug_n)
    );

    //
    // Internal Logic
    //

    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            done_r  <= 1'b0;
        else if (CLKEN)
            done_r  <= done;

    assign done_pulse = do & ~done_r;

    //
    // GCD Module
    //

    GCDStub gcd_inst (
        .clk                (CLK),
        .clk_en             (CLKEN),
        .rst_n              (RESETn),

        .constant_time      (constant_time),
        .debug_mode         (debug_mode),
        .start              (start_pulse),
        .op_code            (opcode),
        .A                  (arg_a),
        .B                  (arg_b),

        .done               (done),
        .cycle_count        (cycle_count),
        .bezout_a           (bezout_a),
        .bezout_b           (bezout_b),
        .debug_a            (debug_a),
        .debug_b            (debug_b),
        .debug_u            (debug_u),
        .debug_y            (debug_y),
        .debug_l            (debug_l),
        .debug_n            (debug_n),
        .debug_lower_a      (debug_lower_a),
        .debug_lower_b      (debug_lower_b),
        .debug_lower_u      (debug_lower_u),
        .debug_lower_y      (debug_lower_y),
        .debug_lower_l      (debug_lower_l),
        .debug_lower_n      (debug_lower_n),
        .debug_case_a_b     (debug_case_a_b),
        .debug_case_u       (debug_case_u),
        .debug_case_y       (debug_case_y),
        .debug_case_l       (debug_case_l),
        .debug_case_n       (debug_case_n)
    );

endmodule
