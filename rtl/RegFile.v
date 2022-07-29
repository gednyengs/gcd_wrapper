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
    output  wire            START_PULSE,
    output  wire [2:0]      OPCODE,
    input   wire [11:0]     CYCLE_COUNT,
    input   wire            DONE_PULSE,

    // Interrupt
    output  wire            IRQ
);

    // =========================================================================
    // Address Space
    // -------------------------------------------------------------------------
    // Offset   | Reg Name
    // -------------------------------------------------------------------------
    // 0x00     | ID Register
    // 0x04     | CTRL
    // 0x08     | STATUS

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
    reg [31:0]  reg_DBG0;
    reg [31:0]  reg_DBG1;
    reg [31:0]  reg_DBG2;
    reg [31:0]  reg_DBG3;
    reg [31:0]  reg_DBG4;

    // Register Access

    wire [2:0]  addr_oft;
    assign addr_oft = PADDR[4:2];

    // REG_CTRL
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_CTRL        <= 32'd0;
        else if (wr_en && (addr_oft == 3'd1))
            reg_CTRL        <= PWDATA;

    // REG_STAT
    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            reg_STAT        <= 32'd0;
        else if(Capt)
            reg_STAT[0]     <= 1'b1;
        else if (wr_en && (addr_oft == 3'd2) && (PWDATA[0] == 1'b1))
            reg_STAT[0]     <= 1'b0;


    // Read Data
    always @(*)
        case (addr_oft)
            3'd0    : reg_data_out  = 32'h5A5A5A5A;
            3'd1    : reg_data_out  = REG_CTRL;
            3'd2    : reg_data_out  = REG_STAT;
            3'd3    : reg_data_out  = reg_DBG0;
            3'd4    : reg_data_out  = reg_DBG1;
            3'd5    : reg_data_out  = reg_DBG2;
            3'd6    : reg_data_out  = reg_DBG3;
            3'd7    : reg_data_out  = reg_DBG4;
            default : reg_data_out  = 32'd0;
        endcase

    always @(posedge CLK or negedge RESETn)
            if (!RESETn)
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
