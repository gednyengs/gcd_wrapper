module AxiUnpackerCore (
    // Clock and Reset

    input   wire            CLK,
    input   wire            RESETn,

    // SRAM Interface
    input   wire            SRAM_CEn,
    input   wire [31:0]     SRAM_ADDR,
    input   wire [63:0]     SRAM_WDATA,
    input   wire            SRAM_WEn,
    input   wire [7:0]      SRAM_WBEn,
    output  wire [63:0]     SRAM_RDATA,

    // GCD Interface Signals
    output  wire [1278:0]   ARG_A,
    output  wire [1278:0]   ARG_B,

    input   wire            DONE,
    input   wire [1283:0]   BEZOUT_A,
    input   wire [1283:0]   BEZOUT_B,
    input   wire [1283:0]   DEBUG_A,
    input   wire [1283:0]   DEBUG_B,
    input   wire [1283:0]   DEBUG_U,
    input   wire [1283:0]   DEBUG_Y,
    input   wire [1283:0]   DEBUG_L,
    input   wire [1283:0]   DEBUG_N
);

    // =========================================================================
    // Address Space
    // -------------------------------------------------------------------------
    // Offset   | Memory Allocation (2560 bytes total)
    // -------------------------------------------------------------------------
    // 0x000    | ARG_A     (256 bytes : 2048 bits) : R/W
    // 0x0A8    | ARG_B     (256 bytes : 2048 bits) : R/W
    // 0x150    | BEZOUT_A  (256 bytes : 2048 bits) : RO
    // 0x1F8    | BEZOUT_B  (256 bytes : 2048 bits) : RO
    // 0x2A0    | DEBUG_A   (256 bytes : 2048 bits) : RO
    // 0x348    | DEBUG_B   (256 bytes : 2048 bits) : RO
    // 0x3F0    | DEBUG_U   (256 bytes : 2048 bits) : RO
    // 0x498    | DEBUG_Y   (256 bytes : 2048 bits) : RO
    // 0x540    | DEBUG_L   (256 bytes : 2048 bits) : RO
    // 0x5E8    | DEBUG_N   (256 bytes : 2048 bits) : RO

    // Currently Unused Signals
    wire unused         = DONE;

    // Internal Logic

    integer             i, j;

    reg [2047:0]        arg_a_mem;
    reg [2047:0]        arg_b_mem;
    reg [2047:0]        flat;

    reg [63:0]          packer [31:0];
    reg [63:0]          rd_output;

    wire [4:0]          word_addr;
    assign word_addr    = SRAM_ADDR[7:3];

    //
    // Argument Write Logic
    //
    always @(posedge CLK)
        if (!SRAM_CEn && !SRAM_WEn)
            for (i = 0; i < 32; i=i+1)
                for (j = 0; j < 8; j=j+1)
                    if (!SRAM_WBEn[j] && (i == SRAM_ADDR[7:3]))
                        case (SRAM_ADDR[11:8])
                            4'd0 : arg_a_mem[64*i+8*j +: 8] <= SRAM_WDATA[8*j +: 8];
                            4'd1 : arg_b_mem[64*i+8*j +: 8] <= SRAM_WDATA[8*j +: 8];
                        endcase

    //
    // Read Logic
    //

    always @(*)
    begin
        case (SRAM_ADDR[11:8])
            4'd0    : flat  = arg_a_mem;
            4'd1    : flat  = arg_b_mem;
            4'd2    : flat  = {764'd0, BEZOUT_A};
            4'd3    : flat  = {764'd0, BEZOUT_B};
            4'd4    : flat  = {764'd0, DEBUG_A};
            4'd5    : flat  = {764'd0, DEBUG_B};
            4'd6    : flat  = {764'd0, DEBUG_U};
            4'd7    : flat  = {764'd0, DEBUG_Y};
            4'd8    : flat  = {764'd0, DEBUG_L};
            4'd9    : flat  = {764'd0, DEBUG_N};
            default : flat  = 2048'd0;
        endcase
    end

    always @(*)
    begin
        for (i = 0; i < 32; i=i+1)
        begin
            packer[i] = flat[64*i +: 64];
        end
    end

    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            rd_output   <= 64'd0;
        else if (!SRAM_CEn && SRAM_WEn)
            rd_output   <= packer[word_addr];


    assign SRAM_RDATA   = rd_output;
    assign ARG_A        = arg_a_mem[1278:0];
    assign ARG_B        = arg_b_mem[1278:0];

endmodule
