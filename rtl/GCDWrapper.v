module GCDWrapper_1279_1279 (
    // Clock and Reset

    input   wire            CLK,
    input   wire            CLK_DIV_8,
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

    output  wire            IRQ,

    output  wire            start_out,
    output  wire            done_out
);

    //
    // Internal Signals
    //

    wire                    constant_time;
    wire                    debug_mode;
    wire                    start_pulse;
    wire                    clk_en;
    wire [11:0]             opcode;
    wire [11:0]             cycle_count;
    wire [1278:0]           arg_a;
    wire [1278:0]           arg_b;

    wire [1283:0]           bezout_a;
    wire [1283:0]           bezout_b;

    wire [1283:0]           debug_a_carry;
    wire [1283:0]           debug_b_carry;
    wire [1283:0]           debug_u_carry;
    wire [1283:0]           debug_y_carry;
    wire [1283:0]           debug_l_carry;
    wire [1283:0]           debug_n_carry;
    wire [1283:0]           debug_a_sum;
    wire [1283:0]           debug_b_sum;
    wire [1283:0]           debug_u_sum;
    wire [1283:0]           debug_y_sum;
    wire [1283:0]           debug_l_sum;
    wire [1283:0]           debug_n_sum;

    wire [3:0]              debug_case_a_out;
    wire [3:0]              debug_case_b_out;

    wire [5:0]              debug_case_u_out;
    wire [2:0]              u_odd_delta_update_add_case_u_out;
    wire [2:0]              u_odd_delta_update_sub_case_u_out;

    wire [5:0]              debug_case_y_out;

    wire [5:0]              debug_case_l_out;
    wire [2:0]              u_odd_delta_update_add_case_l_out;
    wire [2:0]              u_odd_delta_update_sub_case_l_out;

    wire [5:0]              debug_case_n_out;

    wire [4:0]              delta_case;

    wire                    done;
    wire                    done_pulse;
    reg                     done_r;

    assign done_out = done;
    assign start_out = start_out;

    //
    // Control Register File
    //

    RegFile reg_file_inst (
        .CLK                (CLK_DIV_8),
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
        .CLK_EN             (clk_en),

        .DONE_PULSE         (done_pulse),
        .CYCLE_COUNT        (cycle_count),

        .START_OUT          (start_out),

        .DEBUG_CASE_A_OUT   (debug_case_a_out),
        .DEBUG_CASE_B_OUT   (debug_case_b_out),

        .DEBUG_CASE_U_OUT   (debug_case_u_out),
        .U_ODD_DELTA_UPDATE_ADD_CASE_U_OUT  (u_odd_delta_update_add_case_u_out),
        .U_ODD_DELTA_UPDATE_SUB_CASE_U_OUT  (u_odd_delta_update_sub_case_u_out),

        .DEBUG_CASE_Y_OUT   (debug_case_y_out),

        .DEBUG_CASE_L_OUT   (debug_case_l_out),
        .U_ODD_DELTA_UPDATE_ADD_CASE_L_OUT  (u_odd_delta_update_add_case_l_out),
        .U_ODD_DELTA_UPDATE_SUB_CASE_L_OUT  (u_odd_delta_update_sub_case_l_out),

        .DEBUG_CASE_N_OUT   (debug_case_n_out),

        .DELTA_CASE         (delta_case)
    );

    //
    // AXI Unpacker
    //

    AxiUnpacker axi_unpacker_inst (
        .CLK                (CLK_DIV_8),
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
        
        .DEBUG_A_CARRY      (debug_a_carry),
        .DEBUG_A_SUM        (debug_a_sum),
        .DEBUG_B_CARRY      (debug_b_carry),
        .DEBUG_B_SUM        (debug_b_sum),

        .DEBUG_U_CARRY      (debug_u_carry),
        .DEBUG_U_SUM        (debug_u_sum),
        .DEBUG_Y_CARRY      (debug_y_carry),
        .DEBUG_Y_SUM        (debug_y_sum),
        .DEBUG_L_CARRY      (debug_l_carry),
        .DEBUG_L_SUM        (debug_l_sum),
        .DEBUG_N_CARRY      (debug_n_carry),
        .DEBUG_N_SUM        (debug_n_sum)
    );

    //
    // Internal Logic
    //

    always @(posedge CLK_DIV_8 or negedge RESETn)
        if (!RESETn)
            done_r  <= 1'b0;
        else
            done_r  <= done;

    assign done_pulse = done & ~done_r;

    //
    // GCD Module
    //

    XGCDTop_1279 gcd_inst_1279 (
        .clk                (CLK),
        .rst_n              (RESETn),

        .constant_time      (constant_time),
        .debug_mode         (debug_mode),
        .op_code            (opcode),

        .start              (start_pulse),
        .clk_en             (clk_en),
        
        .A                  (arg_a),
        .B                  (arg_b),

        .bezout_a           (bezout_a),
        .bezout_b           (bezout_b),

        .done               (done),
        .total_cycle_count  (cycle_count),

        .start_out          (start_out),
        
        .debug_a_carry      (debug_a_carry),
        .debug_a_sum        (debug_a_sum),
        .debug_b_carry      (debug_b_carry),
        .debug_b_sum        (debug_b_sum),

        .debug_u_carry      (debug_u_carry),
        .debug_u_sum        (debug_u_sum),
        .debug_y_carry      (debug_y_carry),
        .debug_y_sum        (debug_y_sum),
        .debug_l_carry      (debug_l_carry),
        .debug_l_sum        (debug_l_sum),
        .debug_n_carry      (debug_n_carry),
        .debug_n_sum        (debug_n_sum),

        .debug_case_a_out   (debug_case_a_out),
        .debug_case_b_out   (debug_case_b_out),

        .debug_case_u_out   (debug_case_u_out),
        .u_odd_delta_update_add_case_u_out  (u_odd_delta_update_add_case_u_out),
        .u_odd_delta_update_sub_case_u_out  (u_odd_delta_update_sub_case_u_out),

        .debug_case_y_out   (debug_case_y_out),

        .debug_case_l_out   (debug_case_l_out),
        .u_odd_delta_update_add_case_l_out  (u_odd_delta_update_add_case_l_out),
        .u_odd_delta_update_sub_case_l_out  (u_odd_delta_update_sub_case_l_out),

        .debug_case_n_out   (debug_case_n_out),

        .delta_case         (delta_case)
    );

endmodule
