`timescale 1ns / 1ps
module reservoir
# (
VIRTUAL_NODES = 10,
DATA_WIDTH = 32,
)
(
    input clk,
    input rst,
    input din,
    output dout
);

// wire [][] node_outputs;

genvar i;
generate
    for (i=0; i<VIRTUAL_NODES; i=i+1) begin : virtual_node_inst
    register 
    #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    reservoir_node (
        .clk(clk),
        .rst(rst),
        .din(i),
        .dout()
    );
end 
endgenerate
