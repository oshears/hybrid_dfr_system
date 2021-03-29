`timescale 1ns / 1ps
module reservoir
# (
VIRTUAL_NODES = 10,
DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input en,
    input [DATA_WIDTH - 1 : 0] din,
    output [DATA_WIDTH - 1 : 0] dout
);

wire [DATA_WIDTH - 1 : 0] node_outputs [VIRTUAL_NODES : 0];

wire [DATA_WIDTH - 1 : 0] dout_i;
assign dout_i[DATA_WIDTH - 1 : DATA_WIDTH - 1 - 11] = node_outputs[VIRTUAL_NODES][11:0];
assign dout_i[(DATA_WIDTH - 1) - 11 - 1 : 0] = 0;

assign dout = dout_i;

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

genvar i;
generate
    for (i = 0; i < VIRTUAL_NODES; i = i + 1) begin : virtual_node_inst
    register 
    #(
        .DATA_WIDTH(DATA_WIDTH)
    )
    reservoir_node 
    (
        .clk(clk),
        .rst(rst),
        .en(en),
        .din(node_outputs[i]),
        .dout(node_outputs[i+1])
    );
end 
endgenerate

mackey_glass_block mackey_glass_block
(
    .din(sum_i),
    .dout(node_outputs[0])
);


endmodule