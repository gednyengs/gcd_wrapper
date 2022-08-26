module ROWrapper (
    input   logic [31:0]     S_APB_PADDR,
    input   logic            S_APB_PSEL,
    input   logic            S_APB_PENABLE,
    input   logic            S_APB_PWRITE,
    input   logic [31:0]     S_APB_PWDATA,
    output  logic [31:0]     S_APB_PRDATA,
    output  logic            S_APB_PREADY,
    output  logic            S_APB_PSLVERR,

    input logic              clk_in_extern,
    input logic              clk_in_system,
    input logic [1:0]        clk_select,

    input logic              RESETn,

    output logic             clk_1279,
    output logic             clk_255,

    output logic [5:0]       divide_factor
);

    logic clk_1279_internal;
    logic clk_255_internal;
    logic [14:0] mux_select;

    assign clk_1279 = clk_1279_internal;
    assign clk_255 = clk_255_internal;

    //
    // Control Register File
    //

    RegFileRO reg_file_ro_inst (
        // TODO -- check system clock
        .CLK                (clk_in_system),
        .RESETn             (RESETn),

        .PADDR              (S_APB_PADDR),
        .PSEL               (S_APB_PSEL),
        .PENABLE            (S_APB_PENABLE),
        .PWRITE             (S_APB_PWRITE),
        .PWDATA             (S_APB_PWDATA),
        .PRDATA             (S_APB_PRDATA),
        .PREADY             (S_APB_PREADY),
        .PSLVERR            (S_APB_PSLVERR),

        .mux_select(mux_select),
        .divide_factor(divide_factor)

    );

    RingOscillator ring_oscillator (
        // inputs
        .mux_select(mux_select),
        .clk_select(clk_select),
        .clk_in_extern(clk_in_extern),
        .clk_in_system(clk_in_system),
        // outputs
        .clk_1279(clk_1279_internal),
        .clk_255(clk_255_internal)
    );

endmodule
