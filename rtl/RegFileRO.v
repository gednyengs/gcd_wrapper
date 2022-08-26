module RegFileRO (
    // Clock and Reset
    input   logic            CLK,
    input   logic            RESETn,

    // APB Interface
    input   logic [31:0]     PADDR,
    input   logic            PENABLE,
    input   logic            PSEL,
    input   logic            PWRITE,
    input   logic [31:0]     PWDATA,
    output  logic            PREADY,
    output  logic            PSLVERR,
    output  logic [31:0]     PRDATA,

    // Control Signals

    output  logic [14:0]     mux_select,
    output  logic [5:0]      divide_factor
);

    // =========================================================================
    // Address Space
    // -------------------------------------------------------------------------
    // Offset   | Reg Name
    // -------------------------------------------------------------------------
    // 0x00     | ID Register
    // 0x04     | CTRL (divide_factor[20:15], mux_select[14:0])
    // 0x08     | STATUS (RUN_STATUS, IRQ_STATUS)
    // 0x0C     | CYCLE_COUNT
    // 0x10     | DEBUG_0   (DEBUG_LOWER_B, DEBUG_LOWER_A)
    // 0x14     | DEBUG_1   (DEBUG_LOWER_Y, DEBUG_LOWER_U)
    // 0x18     | DEBUG_2   (DEBUG_LOWER_N, DEBUG_LOWER_L)
    // 0x1C     | DEBUG_3   (DEBUG_CASE_N, DEBUG_CASE_L, DEBUG_CASE_Y, DEBUG_CASE_U,
    //                       DEBUG_CASE_A_B)
    //--------------------------------------------------------------------------

    // Internal APB Signals

    reg [31:0]  apb_prdata;
    reg [31:0]  reg_data_out;
    wire        setup_phase;
    wire        wr_en;
    wire        rd_en;

    // Registers
    reg [31:0]  reg_CTRL;
    reg         reg_START_PULSE;
    reg         reg_IE_STAT;
    reg         reg_RUN_STAT;

    // Register Access

    wire [2:0]  addr_oft;
    assign addr_oft = PADDR[4:2];

    // reg_CTRL
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_CTRL        <= 32'd0;
        else if (wr_en && (addr_oft == 3'd1))
            reg_CTRL[31:1]  <= PWDATA[31:1];

    // Read Data
    always @(*)
        case (addr_oft)
            3'd0    : reg_data_out  = 32'h5A5A5A5A;
            3'd1    : reg_data_out  = reg_CTRL;
            default : reg_data_out  = 32'd0;
        endcase

    always @(posedge CLK or negedge RESETn)
            if (!RESETn)
            apb_prdata  <= 32'd0;
        else if (rd_en)
            apb_prdata  <= reg_data_out;

    // Control Output Signal Assignments

    assign mux_select = reg_CTRL[14:0];
    assign divide_factor = reg_CTRL[20:15];

    // APB Signal Assignments

    assign setup_phase = PSEL & ~PENABLE;
    assign wr_en = setup_phase & PWRITE;
    assign rd_en = setup_phase & ~PWRITE;

    assign PRDATA   = apb_prdata;
    assign PREADY   = 1'b1;
    assign PSLVERR  = 1'b0;

endmodule
