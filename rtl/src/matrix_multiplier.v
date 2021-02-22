`timescale 1ns / 1ps

module matrix_multiplier
# (
    ADDR_WIDTH = 32,
    DATA_WIDTH = 32,
    X_ROWS = 5,
    Y_COLS = 5,
    X_COLS_Y_ROWS = 5
)
(
    input clk,
    input rst,
    input start,
    // RAM 
    input [DATA_WIDTH - 1 : 0] x_data,
    input [DATA_WIDTH - 1 : 0] y_data,
    output reg [ADDR_WIDTH - 1 : 0] x_addr,
    output reg [ADDR_WIDTH - 1 : 0] y_addr,
    output reg [ADDR_WIDTH - 1 : 0] z_addr,
    output reg [ADDR_WIDTH - 1 : 0] z_data,
    output reg z_wen
    output reg busy,
);

reg [DATA_WIDTH - 1 : 0] z_sum = 0;
reg [DATA_WIDTH - 1 : 0] multi_iter = 0;

endmodule