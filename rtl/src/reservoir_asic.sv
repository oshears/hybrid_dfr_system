`timescale 1ns / 1ps
module reservoir_asic
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

    // DAC Interface
    output DAC_CS_N,
    output DAC_LDAC_N,
    output DAC_DIN,
    output DAC_SCLK,

    //XADC Interface
    input VP_IN,
    input VN_IN
);

wire [DATA_WIDTH - 1 : 0] node_outputs [NUM_VIRTUAL_NODES : 0];

wire [DATA_WIDTH - 1 : 0] dout_i = {17'h0,node_outputs[NUM_VIRTUAL_NODES][11:0],3'h0};

assign dout = dout_i;

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i;

reg node_en = 0;
reg asic_function_start = 0;
wire xadc_data_valid;
wire [15:0] xadc_data_out;

wire [15:0] asic_function_output;
assign node_outputs[0] = {4'b0000,asic_function_output[15:4]};

localparam RESERVOIR_UPDATE = 0, ASIC_FUNCTION = 1;
reg [1:0] current_state = 0, next_state = 0;

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
    
    node_en = 0;
    asic_function_start = 0;
    reservoir_valid = 0;
    next_state = current_state;

    case(current_state)
        RESERVOIR_UPDATE:
        begin
            
            if (en) begin
                next_state = ASIC_FUNCTION;
                asic_function_start = 1;
            end
            else
                reservoir_valid = 1;
        end
        ASIC_FUNCTION:
        begin
            if (xadc_data_valid) begin
                next_state = RESERVOIR_UPDATE;
                node_en = 1;
            end
        end
        default:
            next_state = RESERVOIR_UPDATE;
    endcase
    
end

asic_function_interface asic_function_interface 
(
    .clk(clk),
    .rst(rst),
    .start(asic_function_start),
    .data_in(sum_i),
    .vp_in(VP_IN),
    .vn_in(VN_IN),
    .xadc_data_valid(xadc_data_valid),
    .xadc_data_out(asic_function_output),
    .dac_cs_n(DAC_CS_N),
    .dac_ldac_n(DAC_LDAC_N),
    .dac_din(DAC_DIN),
    .dac_sclk(DAC_SCLK)
);


endmodule