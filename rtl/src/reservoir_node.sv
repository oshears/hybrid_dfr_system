`timescale 1ns / 1ps

module reservoir_node
# (
DATA_WIDTH = 32
)
(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire load_node,
    input  wire [DATA_WIDTH-1:0] load_node_din,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout
);

always @(posedge clk)
begin
    if (rst)
        dout <= 0;
    else if(en)
        dout <= din;
    else if(load_node)
        dout <= load_node_din;
end

endmodule