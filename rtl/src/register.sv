`timescale 1ns / 1ps

module register
# (
DATA_WIDTH = 32
)
(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout
);

always @(posedge clk)
begin
    if (rst)
        dout <= 0;
    else if(en)
        dout <= din;
end

endmodule