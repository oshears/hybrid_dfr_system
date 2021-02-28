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

wire [(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 : 0] node_outputs;

//wire [DATA_WIDTH - 1 : 0] dout_i = {node_outputs[(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 - (DATA_WIDTH - 12): (VIRTUAL_NODES) * (DATA_WIDTH)],12'h0};
wire [DATA_WIDTH - 1 : 0] dout_i;
assign dout_i[DATA_WIDTH - 1 : DATA_WIDTH - 1 - 11] = node_outputs[(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 - (DATA_WIDTH - 12): (VIRTUAL_NODES) * (DATA_WIDTH)];
assign dout_i[DATA_WIDTH - 1 - 11 - 1 : 0] = 0;

assign dout = dout_i;

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

// assign node_outputs[DATA_WIDTH - 1 : 0] = din;

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
        .din(node_outputs[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH]),
        .dout(node_outputs[(i + 2) * DATA_WIDTH - 1 : (i + 1) * DATA_WIDTH])
    );
end 
endgenerate

mackey_glass_block mackey_glass_block
(
    .din(sum_i),
    .dout(node_outputs[DATA_WIDTH - 1 : 0])
);


endmodule