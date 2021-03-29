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

    // DAC Interface
    output DAC_CS_N,
    output DAC_LDAC_N,
    output DAC_DIN,
    output DAC_SCLK
);

// wire [(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 : 0] node_outputs;
wire [DATA_WIDTH - 1 : 0] node_outputs [VIRTUAL_NODES : 0];

//wire [DATA_WIDTH - 1 : 0] dout_i = {node_outputs[(VIRTUAL_NODES + 1) * DATA_WIDTH - 1 - (DATA_WIDTH - 12): (VIRTUAL_NODES) * (DATA_WIDTH)],12'h0};
wire [DATA_WIDTH - 1 : 0] dout_i;
// assign dout_i[DATA_WIDTH - 1 : DATA_WIDTH - 1 - 11] = node_outputs[((VIRTUAL_NODES + 1)*DATA_WIDTH - 1) - (DATA_WIDTH - 12): (VIRTUAL_NODES) * (DATA_WIDTH)];
// assign dout_i[(DATA_WIDTH - 1) - 11 - 1 : 0] = 0;
assign dout_i[DATA_WIDTH - 1 : DATA_WIDTH - 1 - 11] = node_outputs[VIRTUAL_NODES][11:0];
assign dout_i[(DATA_WIDTH - 1) - 11 - 1 : 0] = 0;

assign dout = dout_i;

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

// assign node_outputs[DATA_WIDTH - 1 : 0] = din;

reg node_en = 0;

reg clk(),
reg rst(),
reg start(),
reg data_in(),
reg vp_in(),
reg vn_in(),
reg xadc_data_valid(),
reg xadc_data_out(),
reg dac_cs_n(),
reg dac_ldac_n(),
reg dac_din(),
reg dac_sclk()

localparam RESERVOIR_UPDATE = 0, ASIC_FUNCTION = 1;
reg [1:0] current_state = 0, next_state = 0;

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
        // .din(node_outputs[(i + 1) * DATA_WIDTH - 1 : i * DATA_WIDTH]),
        // .dout(node_outputs[(i + 2) * DATA_WIDTH - 1 : (i + 1) * DATA_WIDTH])
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
    xadc_data_valid,
    en
) 
begin

    case(current_state)
        RESERVOIR_UPDATE:
        begin
            if (en) begin
                next_state = 
            end
        end
        ASIC_FUNCTION:
        begin
            
        end
        default:
            next_state = RESERVOIR_UPDATE;
    endcase
    
end

asic_function_interface asic_function_interface 
(
    .clk(),
    .rst(),
    .start(),
    .data_in(),
    .vp_in(),
    .vn_in(),
    .xadc_data_valid(),
    .xadc_data_out(),
    .dac_cs_n(DAC_CS_N),
    .dac_ldac_n(DAC_LDAC_N),
    .dac_din(DAC_DIN),
    .dac_sclk(DAC_SCLK)
);


endmodule