`timescale 1ns / 1ps

module matrix_multiply_top_tb;

localparam ADDR_WIDTH = 4;
localparam DATA_WIDTH = 32;
localparam X_ROWS = 2;
localparam Y_COLS = 2;
localparam X_COLS_Y_ROWS = 2;


integer i = 0;
integer j = 0;
integer expect_data = 0;

reg clk = 0;
reg rst = 0;
reg start = 0;
reg [ADDR_WIDTH - 1 : 0] ram_addr = 0;
reg ram_wen = 0;
reg [1:0] ram_sel = 0;
reg [DATA_WIDTH - 1 : 0] ram_data_in = 0;
wire busy;
wire  [DATA_WIDTH - 1 : 0] ram_data_out;

matrix_multiply_top
# (
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .X_ROWS(X_ROWS),
    .Y_COLS(Y_COLS),
    .X_COLS_Y_ROWS(X_COLS_Y_ROWS)
)
uut
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .ram_addr(ram_addr),
    .ram_wen(ram_wen),
    .ram_sel(ram_sel),
    .ram_data_in(ram_data_in),
    .busy(busy),
    .ram_data_out(ram_data_out)
);

task WAIT( input [31:0] timesteps);
    integer i;
    begin
        for (i = 0; i < timesteps; i = i + 1)
            @(posedge clk);
    end
endtask


initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

initial begin
    // Reset
    rst = 1;
    WAIT(1);
    rst = 0;
    WAIT(1);

    // Initialize Rams

    // X RAM
    for (i = 0; i < X_ROWS * X_COLS_Y_ROWS; i = i + 1) begin
        WAIT(1);
        ram_addr = i;
        ram_data_in = i + 1;
        ram_wen = 1'b1;
        ram_sel = 2'b0;
        WAIT(1);
        ram_addr = 0;
        ram_data_in = 0;
        ram_wen = 1'b0;
    end

    // Y RAM
    for (i = 0; i < X_COLS_Y_ROWS * Y_COLS; i = i + 1) begin
        WAIT(1);
        ram_addr = i;
        ram_data_in = i + 1;
        ram_wen = 1'b1;
        ram_sel = 2'b1;
        WAIT(1);
        ram_addr = 0;
        ram_data_in = 0;
        ram_wen = 1'b0;
    end

    start = 1;
    WAIT(1);
    start = 0;
    @(negedge busy);

    $finish;
end

endmodule