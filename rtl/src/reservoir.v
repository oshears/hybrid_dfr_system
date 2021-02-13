`timescale 1ns / 1ps
module reservoir
# (
VIRTUAL_NODES = 10,
DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input [DATA_WIDTH - 1 : 0] din,
    output [DATA_WIDTH - 1 : 0] dout
);

wire [(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 : 0] node_outputs;

assign node_outputs[DATA_WIDTH - 1 : 0] = din;
assign dout = node_outputs[(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 : (VIRTUAL_NODES) * (DATA_WIDTH)];

genvar i;
generate
    for (i=0; i<VIRTUAL_NODES; i=i+1) begin : virtual_node_inst
    register 
    #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    reservoir_node 
    (
        .clk(clk),
        .rst(rst),
        .din(node_outputs[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH]),
        .dout(node_outputs[(i + 2) * DATA_WIDTH - 1 : (i + 1) * DATA_WIDTH])
    );
end 
endgenerate

endmodule;