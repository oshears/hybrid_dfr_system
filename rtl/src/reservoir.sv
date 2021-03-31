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
    output [DATA_WIDTH - 1 : 0] dout,
    output reg reservoir_valid = 0
);

wire [DATA_WIDTH - 1 : 0] node_outputs [VIRTUAL_NODES : 0];

wire [DATA_WIDTH - 1 : 0] dout_i;
assign dout_i[DATA_WIDTH - 1 : DATA_WIDTH - 1 - 11] = node_outputs[VIRTUAL_NODES][11:0];
assign dout_i[(DATA_WIDTH - 1) - 11 - 1 : 0] = 0;

assign dout = dout_i;

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

reg node_en = 0;

localparam RESERVOIR_UPDATE = 0, MG_FUNCTION = 1;
reg [1:0] current_state = 0, next_state = 0;


always @(posedge clk, posedge rst) begin
    if (rst) begin
        current_state <= RESERVOIR_UPDATE;
    end
    else begin
        current_state <= next_state;
    end
end

always @(
    current_state,
    en
) 
begin
    
    node_en = 0;
    reservoir_valid = 0;
    next_state = current_state;

    case(current_state)
        RESERVOIR_UPDATE:
        begin
            
            if (en) begin
                reservoir_valid = 0;
                next_state = MG_FUNCTION;
            end
            else
                reservoir_valid = 1;
        end
        MG_FUNCTION:
        begin
            node_en = 1;
            next_state = RESERVOIR_UPDATE;
        end
        default:
            next_state = RESERVOIR_UPDATE;
    endcase
    
end

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
        .en(node_en),
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