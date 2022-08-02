module RegFile (
    // Clock and Reset
    input   wire            CLK,
    input   wire            RESETn,

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
    output  wire            CONSTANT_TIME,
    output  wire            DEBUG_MODE,
    output  wire [2:0]      OPCODE,
    output  wire            START_PULSE,

    input   wire            DONE_PULSE,
    input   wire [11:0]     CYCLE_COUNT,
    input   wire [15:0]     DEBUG_LOWER_A,
    input   wire [15:0]     DEBUG_LOWER_B,
    input   wire [15:0]     DEBUG_LOWER_U,
    input   wire [15:0]     DEBUG_LOWER_Y,
    input   wire [15:0]     DEBUG_LOWER_L,
    input   wire [15:0]     DEBUG_LOWER_N,
    input   wire [3:0]      DEBUG_CASE_A_B,
    input   wire [4:0]      DEBUG_CASE_U,
    input   wire [4:0]      DEBUG_CASE_Y,
    input   wire [4:0]      DEBUG_CASE_L,
    input   wire [4:0]      DEBUG_CASE_N,

    // Interrupt
    output  wire            IRQ
);

    // =========================================================================
    // Address Space
    // -------------------------------------------------------------------------
    // Offset   | Reg Name
    // -------------------------------------------------------------------------
    // 0x00     | ID Register
    // 0x04     | CTRL (IE [6:6], CONSTANT_TIME[5:5], DEBUG_MODE[4:4], OPCODE[3:1],
    //                  START_PULSE[0:0])
    // 0x08     | STATUS (IRQ_STATUS)
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
    reg         reg_STAT;

    // Register Access

    wire [2:0]  addr_oft;
    assign addr_oft = PADDR[4:2];

    // reg_CTRL
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_CTRL        <= 32'd0;
        else if (wr_en && (addr_oft == 3'd1))
            reg_CTRL[31:1]  <= PWDATA[31:1];

    // reg_START_PULSE
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_START_PULSE <= 1'b0;
        else if (wr_en && (addr_oft == 3'd1))
            reg_START_PULSE <= PWDATA[0];
        else
            reg_START_PULSE <= 1'b0;

    // reg_STAT
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_STAT        <= 1'b0;
        else if(DONE_PULSE)
            reg_STAT        <= 1'b1;
        else if (wr_en && (addr_oft == 3'd2) && (PWDATA[0] == 1'b1))
            reg_STAT        <= 1'b0;


    // Read Data
    always @(*)
        case (addr_oft)
            3'd0    : reg_data_out  = 32'h5A5A5A5A;
            3'd1    : reg_data_out  = REG_CTRL;
            3'd2    : reg_data_out  = {31'd0, reg_STAT};
            3'd3    : reg_data_out  = {20'd0, CYCLE_COUNT};
            3'd4    : reg_data_out  = {DEBUG_LOWER_B, DEBUG_LOWER_A};
            3'd5    : reg_data_out  = {DEBUG_LOWER_Y, DEBUG_LOWER_U};
            3'd6    : reg_data_out  = {DEBUG_LOWER_N, DEBUG_LOWER_L};
            3'd7    : reg_data_out  = {8'd0, DEBUG_CASE_N, DEBUG_CASE_L,
                                       DEBUG_CASE_Y, DEBUG_CASE_U, DEBUG_CASE_A_B};
            default : reg_data_out  = 32'd0;
        endcase

    always @(posedge CLK or negedge RESETn)
            if (!RESETn)
            apb_prdata  <= 32'd0;
        else if (rd_en)
            apb_prdata  <= reg_data_out;

    // Control Output Signal Assignments

    assign CONSTANT_TIME    = reg_CTRL[5:5];
    assign DEBUG_MODE       = reg_CTRL[4:4];
    assign OPCODE           = reg_CTRL[3:1];
    assign START_PULSE      = reg_START_PULSE;
    assign IRQ              = reg_CTRL[6] & reg_STAT;

    // APB Signal Assignments

    assign setup_phase = PSEL & ~PENABLE;
    assign wr_en = setup_phase & PWRITE;
    assign rd_en = setup_phase & ~PWRITE;

    assign PRDATA   = apb_prdata;
    assign PREADY   = 1'b1;
    assign PSLVERR  = 1'b0;

endmodule
