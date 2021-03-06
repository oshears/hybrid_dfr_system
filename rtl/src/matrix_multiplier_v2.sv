`timescale 1ns / 1ps

module matrix_multiplier_v2
# (
    ADDR_WIDTH = 32,
    DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input start,
    // RAM Inputs
    input [DATA_WIDTH - 1 : 0] x_data,
    input [DATA_WIDTH - 1 : 0] y_data,
    // CONFIG
    input [ADDR_WIDTH - 1 : 0] x_rows,
    input [ADDR_WIDTH - 1 : 0] y_cols,
    input [ADDR_WIDTH - 1 : 0] x_cols_y_rows,
    // RAM Outputs
    output reg [ADDR_WIDTH - 1 : 0] x_addr  = 0,
    output reg [ADDR_WIDTH - 1 : 0] y_addr  = 0,
    output reg [ADDR_WIDTH - 1 : 0] z_addr  = 0,
    output reg [DATA_WIDTH - 1 : 0] z_data  = 0,
    output reg z_wen = 0,
    output reg busy = 0
);

// explicit regs
// reg [DATA_WIDTH - 1 : 0] z_sum = 0;
reg [DATA_WIDTH - 1 : 0] multi_iter = 0;

// explicit counters
reg [DATA_WIDTH - 1 : 0] x_row = 0;
reg [DATA_WIDTH - 1 : 0] y_col = 0;
reg [DATA_WIDTH - 1 : 0] x_col_y_row = 0;

// implicit regs
reg [1:0] x_addr_cnt_en = 0;
reg x_addr_cnt_rst = 0;
reg [1:0] y_addr_cnt_en = 0;
reg y_addr_cnt_rst = 0;
reg z_addr_cnt_en = 0;
reg z_addr_cnt_rst = 0;
reg z_sum_reg_en = 0;
reg z_sum_reg_rst = 0;

reg multi_iter_en = 0;
reg multi_iter_rst = 0;
reg x_row_en = 0;
reg x_row_rst = 0;
reg y_col_en = 0;
reg y_col_rst = 0;
reg x_col_y_row_en = 0;
reg x_col_y_row_rst = 0;

wire [63:0] x_mul_y;


reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

localparam done = 0, x_row_loop = 1, y_col_loop = 2, x_addr_loop = 3, x_col_y_row_loop = 4, y_addr_loop = 5, z_sum_loop = 6, z_sum_store = 7;

always @ (posedge clk) begin
    if (rst)
        current_state <= done;
    else
        current_state <= next_state;
end

always @(
    current_state,
    start,
    z_data,
    multi_iter,
    x_row,
    y_col,
    x_col_y_row,
    x_data,
    x_rows,
    y_cols,
    x_cols_y_rows
     ) begin

    busy = 0;
    z_wen = 0;
    x_addr_cnt_en = 0;
    x_addr_cnt_rst = 0;
    y_addr_cnt_en = 0;
    y_addr_cnt_rst = 0;
    z_addr_cnt_en = 0;
    z_addr_cnt_rst = 0;
    z_sum_reg_en = 0;
    z_sum_reg_rst = 0;
    multi_iter_en = 0;
    multi_iter_rst = 0;
    x_row_en = 0;
    x_row_rst = 0;
    y_col_en = 0;
    y_col_rst = 0;
    x_col_y_row_en = 0;
    x_col_y_row_rst = 0;

    next_state = current_state;

    case (current_state)
        done:
        begin
            if (start) begin
                busy = 1;
                x_addr_cnt_rst = 1;
                y_addr_cnt_rst = 1;
                z_addr_cnt_rst = 1;
                z_sum_reg_rst = 1;
                multi_iter_rst = 1;
                x_row_rst = 1;
                y_col_rst = 1;
                x_col_y_row_rst = 1;

                next_state = x_row_loop;
            end
        end
        x_row_loop:
        begin
            busy = 1;
            if (x_row == x_rows) begin
                next_state = done;
            end
            else begin
                y_col_rst = 1;
                next_state = y_col_loop;
            end
        end
        y_col_loop:
        begin
            busy = 1;
            if (y_col == y_cols) begin
                x_row_en = 1;
                next_state = x_row_loop;
            end
            else begin
                z_sum_reg_rst = 1;
                x_addr_cnt_rst = 1;
                multi_iter_rst = 1;
                x_col_y_row_rst = 1;
                next_state = x_addr_loop;
            end
        end
        x_addr_loop:
        begin
            busy = 1;
            if (multi_iter == x_row) begin
                next_state = x_col_y_row_loop; 
            end
            else begin
                x_addr_cnt_en = 2'b01;
                multi_iter_en = 1;
            end
        end
        x_col_y_row_loop:
        begin
            busy = 1;
            if (x_col_y_row == x_cols_y_rows) begin
                z_wen = 1;
                z_addr_cnt_en = 1;
                y_col_en = 1;
                next_state = y_col_loop;
            end
            else begin
                y_addr_cnt_rst = 1;
                multi_iter_rst = 1;
                next_state = y_addr_loop;
            end
        end
        y_addr_loop:
        begin
            busy = 1;
            if (multi_iter == x_col_y_row) begin
                multi_iter_en = 1;
                y_addr_cnt_en = 2'b10;
            end
            // Need One Delay for RAM Data to Arrive
            else if(multi_iter == x_col_y_row + 1) begin
                multi_iter_rst = 1;
                next_state = z_sum_loop;
            end
            else begin
                multi_iter_en = 1;
                y_addr_cnt_en = 2'b01;
            end
        end
        z_sum_loop:
        begin
            busy = 1;
            multi_iter_en = 1;
            if (multi_iter == 6)
                next_state = z_sum_store;
        end
        z_sum_store:
        begin
            busy = 1;
            z_sum_reg_en = 1;
            x_addr_cnt_en = 2'b10;
            x_col_y_row_en = 1;
            next_state = x_col_y_row_loop;
        end
        default:
        begin
            busy = 0;
            z_wen = 0;
            x_addr_cnt_en = 0;
            x_addr_cnt_rst = 0;
            y_addr_cnt_en = 0;
            y_addr_cnt_rst = 0;
            z_addr_cnt_en = 0;
            z_addr_cnt_rst = 0;
            z_sum_reg_en = 0;
            z_sum_reg_rst = 0;
            multi_iter_en = 0;
            multi_iter_rst = 0;
            x_row_en = 0;
            x_row_rst = 0;
            y_col_en = 0;
            y_col_rst = 0;
            x_col_y_row_en = 0;
            x_col_y_row_rst = 0;
        end
    endcase
end

always @(posedge clk) begin
    if (x_addr_cnt_rst)
        x_addr <= 0;
    else if(x_addr_cnt_en == 2'b01) 
        x_addr <= x_addr + x_cols_y_rows;
    else if (x_addr_cnt_en == 2'b10)
        x_addr <= x_addr + 1;
end

always @(posedge clk) begin
    if (y_addr_cnt_rst)
        y_addr <= 0;
    else if(y_addr_cnt_en == 2'b01)
        y_addr <= y_addr + y_cols;
    else if(y_addr_cnt_en == 2'b10) 
        y_addr <= y_addr + y_col;
end

always @(posedge clk) begin
    if (z_addr_cnt_rst)
        z_addr <= 0;
    else if(z_addr_cnt_en) 
        z_addr <= z_addr + 1;
end

always @(posedge clk) begin
    if (multi_iter_rst)
        multi_iter <= 0;
    else if(multi_iter_en) 
        multi_iter <= multi_iter + 1;
end

always @(posedge clk) begin
    if (x_row_rst)
        x_row <= 0;
    else if(x_row_en) 
        x_row <= x_row + 1;
end

always @(posedge clk) begin
    if (y_col_rst)
        y_col <= 0;
    else if(y_col_en) 
        y_col <= y_col + 1;
end

always @(posedge clk) begin
    if (x_col_y_row_rst)
        x_col_y_row <= 0;
    else if(x_col_y_row_en) 
        x_col_y_row <= x_col_y_row + 1;
end

always @(posedge clk) begin
    if (z_sum_reg_rst)
        z_data <= 0;
    else if(z_sum_reg_en) 
        z_data <= x_mul_y[31:0] + z_data;
end

multiplier multiplier
(
    .CLK(clk),
    .A(x_data),
    .B(y_data),
    .P(x_mul_y)
);

endmodule