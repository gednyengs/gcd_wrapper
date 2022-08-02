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
    // Offset   | Memory Allocation (1680 bytes total)
    // -------------------------------------------------------------------------
    // 0x000    | ARG_A (168 bytes : 1344 bits) : R/W
    // 0x0A8    | ARG_B (168 bytes : 1344 bits) : R/W
    // 0x150    | BEZOUT_A  (168 bytes : 1344 bits) : RO
    // 0x1F8    | BEZOUT_B  (168 bytes : 1344 bits) : RO
    // 0x2A0    | DEBUG_A  (168 bytes : 1344 bits) : RO
    // 0x348    | DEBUG_B  (168 bytes : 1344 bits) : RO
    // 0x3F0    | DEBUG_U  (168 bytes : 1344 bits) : RO
    // 0x498    | DEBUG_Y  (168 bytes : 1344 bits) : RO
    // 0x540    | DEBUG_L  (168 bytes : 1344 bits) : RO
    // 0x5E8    | DEBUG_N  (168 bytes : 1344 bits) : RO

    // Currently Unused Signals
    wire unused = DONE;

    // Internal Signals

    wire [1283:0]   arg_a_w;
    wire [1283:0]   arg_b_w;
    reg [1283:0]    rd_sel_signal;
    reg [63:0]      rd_sel_dword;
    reg [63:0]      rd_output;

    reg [7:0]       arg_a_mem[4:0][2:0];
    reg [2047:0]    arg_a_flat;
    reg [7:0]       arg_b_mem[4:0][2:0];
    reg [2047:0]    arg_b_flat;

    //
    // Write Logic
    //
    integer i;
    integer j;
    always @(posedge CLK)
        if (~SRAM_CEn & ~SRAM_WEn) begin
            case (SRAM_ADDR[11:8])
                4'd0    :   begin
                    for (i = 0; i < 8; i=i+1)
                        if (~SRAM_WBEn[i])
                            arg_a_mem[SRAM_ADDR[7:3]][i] <= SRAM_WDATA[8*i+7:8*i];
                end
                4'd1    :   begin
                    for (i = 0; i < 8; i=i+1)
                        if (~SRAM_WBEn[i])
                            arg_b_mem[SRAM_ADDR[7:3]][i] <= SRAM_WDATA[8*i+7:8*i];
                end
            endcase
        end

    always @(*)
        for (i = 0; i < 32; i=i+1)
            for (j = 0; j < 8; j=j+1) begin
                arg_a_flat[(i*64 + j*8 + 7):(i*64 + j*8)] = arg_a_mem[i][j];
                arg_b_flat[(i*64 + j*8 + 7):(i*64 + j*8)] = arg_b_mem[i][j];
            end


    //
    // Read Logic
    //
    always @(*)
        case (SRAM_ADDR[11:8])
            4'd0    : rd_sel_signal = arg_a_w;
            4'd1    : rd_sel_signal = arg_b_w;
            4'd2    : rd_sel_signal = BEZOUT_A;
            4'd3    : rd_sel_signal = BEZOUT_B;
            4'd4    : rd_sel_signal = DEBUG_A;
            4'd5    : rd_sel_signal = DEBUG_B;
            4'd6    : rd_sel_signal = DEBUG_U;
            4'd7    : rd_sel_signal = DEBUG_Y;
            4'd8    : rd_sel_signal = DEBUG_L;
            4'd9    : rd_sel_signal = DEBUG_N;
            default : rd_sel_signal = 1284'd0;
        endcase

    always @(*)
        case (SRAM_ADDR[7:3])
            5'd0    : rd_sel_dword  =  rd_sel_signal[63:0];
            5'd1    : rd_sel_dword  =  rd_sel_signal[127:64];
            5'd2    : rd_sel_dword  =  rd_sel_signal[191:128];
            5'd3    : rd_sel_dword  =  rd_sel_signal[255:192];
            5'd4    : rd_sel_dword  =  rd_sel_signal[319:256];
            5'd5    : rd_sel_dword  =  rd_sel_signal[383:320];
            5'd6    : rd_sel_dword  =  rd_sel_signal[447:384];
            5'd7    : rd_sel_dword  =  rd_sel_signal[511:448];
            5'd8    : rd_sel_dword  =  rd_sel_signal[575:512];
            5'd9    : rd_sel_dword  =  rd_sel_signal[639:576];
            5'd10   : rd_sel_dword  =  rd_sel_signal[703:640];
            5'd11   : rd_sel_dword  =  rd_sel_signal[767:704];
            5'd12   : rd_sel_dword  =  rd_sel_signal[831:768];
            5'd13   : rd_sel_dword  =  rd_sel_signal[895:832];
            5'd14   : rd_sel_dword  =  rd_sel_signal[959:896];
            5'd15   : rd_sel_dword  =  rd_sel_signal[1023:960];
            5'd16   : rd_sel_dword  =  rd_sel_signal[1087:1024];
            5'd17   : rd_sel_dword  =  rd_sel_signal[1151:1088];
            5'd18   : rd_sel_dword  =  rd_sel_signal[1215:1152];
            5'd19   : rd_sel_dword  =  rd_sel_signal[1279:1216];
            5'd20   : rd_sel_dword  =  {60'd0, rd_sel_signal[1283:1280]};
            default : rd_sel_dword  =  64'd0;
        endcase

    always @(posedge CLK or negedge RESETn)
        if (!RESETn)
            rd_output   <= 64'd0;
        else if (~SRAM_CEn & SRAM_WEn)
            rd_output   <= rd_sel_dword;


    //
    // Output Assignments
    //

    assign SRAM_RDATA   = rd_output;

endmodule
