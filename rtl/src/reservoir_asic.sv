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
    input  load_node,
    input  [NODE_DATA_WIDTH - 1 : 0] load_node_din,
    input  [$clog2(NUM_VIRTUAL_NODES) - 1 : 0] node_sel,
    output [NODE_DATA_WIDTH - 1 : 0] node_dout,
    input  [DATA_WIDTH - 1 : 0] din,
    output [DATA_WIDTH - 1 : 0] dout,
    output reg reservoir_valid = 0,
    output [NODE_DATA_WIDTH - 1:0] asic_function_out

    // DAC Interface
    output DAC_CS_N,
    output DAC_LDAC_N,
    output DAC_DIN,
    output DAC_SCLK,

    //XADC Interface
    input VP_IN,
    input VN_IN
);

wire [NODE_DATA_WIDTH - 1 : 0] node_outputs [NUM_VIRTUAL_NODES : 0];

wire [DATA_WIDTH - 1 : 0] dout_i = {16'h0,node_outputs[NUM_VIRTUAL_NODES],4'h0};

wire [DATA_WIDTH - 1 : 0] sum_i = din + dout_i[15:2];

reg node_en = 0;

reg [1:0] mem_cntr = 0;
reg mem_cntr_en = 0;
reg mem_cntr_rst = 0;

reg [1:0] current_state = 0, next_state = 0;

localparam RESERVOIR_UPDATE = 0, MG_FUNCTION_WAIT = 1, MG_FUNCTION_READY = 2;

assign dout = dout_i;

assign node_dout = node_outputs[node_sel + 1];

reg asic_function_start = 0;
wire xadc_data_valid;
wire [15:0] xadc_data_out;
wire [15:0] asic_function_output;
assign node_outputs[0] = {4'b0000,asic_function_output[15:4]};




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
    mem_cntr,
    xadc_data_valid
) 
begin
    
    node_en = 0;
    reservoir_valid = 0;

    mem_cntr_en = 0;
    mem_cntr_rst = 0;

    next_state = current_state;

    asic_function_start = 0;

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
            if (mem_cntr == 2) begin
                asic_function_start = 1;
                next_state = MG_FUNCTION_READY;
            end
        end
        MG_FUNCTION_READY:
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
        wire load_node_i = (node_sel == i) ? load_node : 1'b0;

        reservoir_node 
        #(
            .DATA_WIDTH(NODE_DATA_WIDTH)
        )
        reservoir_node 
        (
            .clk(clk),
            .rst(rst),
            .en(node_en),
            .din(node_outputs[i]),
            .dout(node_outputs[i+1]),
            .load_node(load_node_i),
            .load_node_din(load_node_din)
        );
    end 
endgenerate

asic_function_interface asic_function_interface 
(
    .clk(clk),
    .rst(rst),
    .start(asic_function_start),
    .data_in(sum_i[15:0]),
    .vp_in(VP_IN),
    .vn_in(VN_IN),
    .xadc_data_valid(xadc_data_valid),
    .xadc_data_out(asic_function_output),
    .dac_cs_n(DAC_CS_N),
    .dac_ldac_n(DAC_LDAC_N),
    .dac_din(DAC_DIN),
    .dac_sclk(DAC_SCLK)
);

assign asic_function_out = node_outputs[0];

endmodule