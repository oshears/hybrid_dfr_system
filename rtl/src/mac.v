`timescale 1ns / 1ps

module counter
# (
DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input [DATA_WIDTH - 1 : 0] a,
    input [DATA_WIDTH - 1 : 0] b,
    input start,
    output reg [DATA_WIDTH - 1 : 0] dout,
    output reg busy
);

reg [1:0] current_state = 0;
reg [1:0] next_state = 0;

reg [DATA_WIDTH - 1 : 0] a_i;
reg [DATA_WIDTH - 1 : 0] b_i;
reg [DATA_WIDTH - 1 : 0] product;
reg [DATA_WIDTH - 1 : 0] multi_iter; 
reg [DATA_WIDTH - 1 : 0] multi_iter_rst; 
reg multi_en;

localparam done_state = 0, busy_state = 1;

always @ (posedge clk or posedge rst) begin
    if (rst)
        current_state <= done_state;
    else
        current_state <= next_state;
end

always @ (current_state)
begin
    
    busy = 0;
    multi_en = 0;
    multi_iter_rst = 1;

    case (current_state)
        done_state:
        begin
            if (start) begin
                next_state = busy_state;
                a_i = a;
                b_i = b;
            end
        end
        busy_state:
        begin
            if (multi_iter == b)
                next_state = done_state;
            else
                busy = 1;
                multi_en = 1;
                multi_iter_rst = 0;
                
        end
        default:
        begin
            busy = 0;
            multi_en = 0;
            multi_iter_rst = 1;
        end
    endcase
end

always @(clk,rst) begin
    if (rst)
        dout <= 0;
    else if (multi_en)
        dout <= dout + a_i;
end

always @(clk,multi_iter_rst) begin
    if (multi_iter_rst)
        multi_iter <= 0;
    else
        multi_iter = multi_iter + 1;
end



endmodule