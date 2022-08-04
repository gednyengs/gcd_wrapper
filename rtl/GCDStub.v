module GCDStub (
    // Clock and Reset

    input   wire            clk,
    input   wire            clk_en,
    input   wire            rst_n,

    input   wire            constant_time,
    input   wire            debug_mode,
    input   wire            start,
    input   wire [11:0]     op_code,
    input   wire [1278:0]   A,
    input   wire [1278:0]   B,

    output  wire            done,
    output  wire [11:0]     cycle_count,
    output  wire [1283:0]   bezout_a,
    output  wire [1283:0]   bezout_b,
    output  wire [1283:0]   debug_a,
    output  wire [1283:0]   debug_b,
    output  wire [1283:0]   debug_u,
    output  wire [1283:0]   debug_y,
    output  wire [1283:0]   debug_l,
    output  wire [1283:0]   debug_n,
    output  wire [15:0]     debug_lower_a,
    output  wire [15:0]     debug_lower_b,
    output  wire [15:0]     debug_lower_u,
    output  wire [15:0]     debug_lower_y,
    output  wire [15:0]     debug_lower_l,
    output  wire [15:0]     debug_lower_n,
    output  wire [3:0]      debug_case_a_b,
    output  wire [4:0]      debug_case_u,
    output  wire [4:0]      debug_case_y,
    output  wire [4:0]      debug_case_l,
    output  wire [4:0]      debug_case_n
);

    reg [11:0]      counter;
    reg             counter_en;

    reg             done_r;
    reg [11:0]      cycle_count_r;
    reg [1283:0]    bezout_a_r;
    reg [1283:0]    bezout_b_r;
    reg [1283:0]    debug_a_r;
    reg [1283:0]    debug_b_r;
    reg [1283:0]    debug_u_r;
    reg [1283:0]    debug_y_r;
    reg [1283:0]    debug_l_r;
    reg [1283:0]    debug_n_r;
    reg [15:0]      debug_lower_a_r;
    reg [15:0]      debug_lower_b_r;
    reg [15:0]      debug_lower_u_r;
    reg [15:0]      debug_lower_y_r;
    reg [15:0]      debug_lower_l_r;
    reg [15:0]      debug_lower_n_r;
    reg [3:0]       debug_case_a_b_r;
    reg [4:0]       debug_case_u_r;
    reg [4:0]       debug_case_y_r;
    reg [4:0]       debug_case_l_r;
    reg [4:0]       debug_case_n_r;

    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            counter     <= 12'd0;
        else if (counter_en)
            counter     <= counter + 1'b1;
        else
            counter     <= 12'd0;

    always @(posedge clk or negedge rst_n)
        if (!rst_n)
            counter_en  <= 1'b0;
        else if (start & ~counter_en)
            counter_en  <= 1'b1;
        else if (counter == 12'hFFF)
            counter_en  <= 1'b0;


    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            done_r              <= 0;
            cycle_count_r       <= 0;
            bezout_a_r          <= 0;
            bezout_b_r          <= 0;
            debug_a_r           <= 0;
            debug_b_r           <= 0;
            debug_u_r           <= 0;
            debug_y_r           <= 0;
            debug_l_r           <= 0;
            debug_n_r           <= 0;
            debug_lower_a_r     <= 0;
            debug_lower_b_r     <= 0;
            debug_lower_u_r     <= 0;
            debug_lower_y_r     <= 0;
            debug_lower_l_r     <= 0;
            debug_lower_n_r     <= 0;
            debug_case_a_b_r    <= 0;
            debug_case_u_r      <= 0;
            debug_case_y_r      <= 0;
            debug_case_l_r      <= 0;
            debug_case_n_r      <= 0;
        end
        else if (start) begin
            done_r              <= 0;
            cycle_count_r       <= 0;
            bezout_a_r          <= 0;
            bezout_b_r          <= 0;
            debug_a_r           <= 0;
            debug_b_r           <= 0;
            debug_u_r           <= 0;
            debug_y_r           <= 0;
            debug_l_r           <= 0;
            debug_n_r           <= 0;
            debug_lower_a_r     <= 0;
            debug_lower_b_r     <= 0;
            debug_lower_u_r     <= 0;
            debug_lower_y_r     <= 0;
            debug_lower_l_r     <= 0;
            debug_lower_n_r     <= 0;
            debug_case_a_b_r    <= 0;
            debug_case_u_r      <= 0;
            debug_case_y_r      <= 0;
            debug_case_l_r      <= 0;
            debug_case_n_r      <= 0;
        end
        else if (counter == 12'hFFF) begin
            done_r              <= 1'b1;
            cycle_count_r       <= 12'hFFF;
            bezout_a_r          <= {5'd0, (A+B)};
            bezout_b_r          <= {5'd0, (A-B)};
            debug_a_r           <= {5'd0, (A+B)};
            debug_b_r           <= {5'd0, (A-B)};
            debug_u_r           <= {5'd0, (A+B)};
            debug_y_r           <= {5'd0, (A-B)};
            debug_l_r           <= {5'd0, (A+B)};
            debug_n_r           <= {5'd0, (A-B)};
            debug_lower_a_r     <= A[15:0];
            debug_lower_b_r     <= B[15:0];
            debug_lower_u_r     <= A[15:0];
            debug_lower_y_r     <= B[15:0];
            debug_lower_l_r     <= A[15:0];
            debug_lower_n_r     <= B[15:0];
            debug_case_a_b_r    <= A[3:0];
            debug_case_u_r      <= A[4:0];
            debug_case_y_r      <= A[4:0];
            debug_case_l_r      <= B[4:0];
            debug_case_n_r      <= B[4:0];
        end


        assign done             = done_r;
        assign cycle_count      = cycle_count_r;
        assign bezout_a         = bezout_a_r;
        assign bezout_b         = bezout_b_r;
        assign debug_a          = debug_a_r;
        assign debug_b          = debug_b_r;
        assign debug_u          = debug_u_r;
        assign debug_y          = debug_y_r;
        assign debug_l          = debug_l_r;
        assign debug_n          = debug_n_r;
        assign debug_lower_a    = debug_lower_a_r;
        assign debug_lower_b    = debug_lower_b_r;
        assign debug_lower_u    = debug_lower_u_r;
        assign debug_lower_y    = debug_lower_y_r;
        assign debug_lower_l    = debug_lower_l_r;
        assign debug_lower_n    = debug_lower_n_r;
        assign debug_case_a_b   = debug_case_a_b_r;
        assign debug_case_u     = debug_case_u_r;
        assign debug_case_y     = debug_case_y_r;
        assign debug_case_l     = debug_case_l_r;
        assign debug_case_n     = debug_case_n_r;
endmodule
