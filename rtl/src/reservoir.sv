`timescale 1ns / 1ps
module reservoir
# (
NUM_VIRTUAL_NODES = 10,
DATA_WIDTH = 32
)
(
    input clk,
    input rst,
    input en,
    input [DATA_WIDTH - 1 : 0] din,
    output [DATA_WIDTH - 1 : 0] dout,
    output reg reservoir_valid = 0,
    output [11:0] asic_function_out
);

wire [DATA_WIDTH - 1 : 0] node_outputs [NUM_VIRTUAL_NODES : 0];

wire [DATA_WIDTH - 1 : 0] dout_i = {17'h0,node_outputs[NUM_VIRTUAL_NODES][11:0],3'h0};


wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

reg node_en = 0;

reg [1:0] mem_cntr = 0;
reg mem_cntr_en = 0;
reg mem_cntr_rst = 0;

reg [1:0] current_state = 0, next_state = 0;

localparam RESERVOIR_UPDATE = 0, MG_FUNCTION_WAIT = 1, MG_FUNCTION_READY = 2;

assign dout = dout_i;


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
    en,
    mem_cntr
) 
begin
    
    node_en = 0;
    reservoir_valid = 0;

    mem_cntr_en = 0;
    mem_cntr_rst = 0;

    next_state = current_state;

    case(current_state)
        RESERVOIR_UPDATE:
        begin
            
            if (en) begin
                reservoir_valid = 0;
                mem_cntr_rst = 1;

                next_state = MG_FUNCTION_WAIT;
            end
            else
                reservoir_valid = 1;
        end
        MG_FUNCTION_WAIT:
        begin
            mem_cntr_en = 1;
            if (mem_cntr == 2)
                next_state = MG_FUNCTION_READY;
        end
        MG_FUNCTION_READY:
        begin
            node_en = 1;
            next_state = RESERVOIR_UPDATE;
        end
        default:
            next_state = RESERVOIR_UPDATE;
    endcase
    
end

// Counter to Wait for Memory Data Availability

always @(posedge clk) begin
    if (mem_cntr_rst)
        mem_cntr = 0;
    else if (mem_cntr_en)
        mem_cntr = mem_cntr + 1;
end

genvar i;
generate
    for (i = 0; i < NUM_VIRTUAL_NODES; i = i + 1) begin : virtual_node_inst
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

// mackey_glass_block_16bit mackey_glass_block
// (
//     .din(sum_i),
//     .dout(node_outputs[0])
// );

asic_activation_function_ram asic_activation_function_rom
(
    .addra(sum_i[15:0]),
    .clka(clk),
    .douta(node_outputs[0][11:0])
);

assign node_outputs[0][31:12] = 0;
assign asic_function_out = node_outputs[0][11:0];

endmodule