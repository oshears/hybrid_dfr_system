`timescale 1ns / 1ps
module dfr_core_top
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 30,
    parameter NUM_VIRTUAL_NODES = 10,
    parameter RESERVOIR_DATA_WIDTH = 32,
    parameter RESERVOIR_HISTORY_ADDR_WIDTH = 14
)
(
    input S_AXI_ACLK,   
    input S_AXI_ARESETN,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR, 
    input S_AXI_AWVALID,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR,
    input S_AXI_ARVALID,
    input [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA,  
    input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,  
    input S_AXI_WVALID, 
    input S_AXI_RREADY, 
    input S_AXI_BREADY, 

    output S_AXI_AWREADY, 
    output S_AXI_ARREADY, 
    output S_AXI_WREADY,  
    output [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA,
    output [1:0] S_AXI_RRESP,
    output S_AXI_RVALID,  
    output [1:0] S_AXI_BRESP,
    output S_AXI_BVALID,

    output busy
);




wire rst;


assign rst = ~S_AXI_ARESETN;

wire [31:0] debug;
wire [31:0] debug_in;
wire [31:0] ctrl;

wire  [29:0] mem_addr_i;
wire  mem_wen;
wire  [C_S_AXI_DATA_WIDTH - 1:0] mem_data_in;
wire  [C_S_AXI_DATA_WIDTH - 1:0] mem_data_out;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] input_mem_addr;
wire [RESERVOIR_DATA_WIDTH - 1:0] input_mem_din;
wire [RESERVOIR_DATA_WIDTH - 1:0] input_mem_dout;
wire input_mem_wen;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_output_mem_addr;

wire [RESERVOIR_DATA_WIDTH - 1:0] reservoir_output_mem_data_in;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_history_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_data_out;
wire reservoir_history_en;

wire [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_output_mem_data_out;
wire reservoir_output_mem_wen;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] output_weight_mem_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] output_weight_mem_data_in;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] output_weight_mem_data_out;
wire output_weight_mem_wen;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] dfr_output_mem_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] dfr_output_mem_data_in;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] dfr_output_mem_data_out;
wire dfr_output_mem_wen;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] matrix_multiply_output_weight_addr;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] dfr_output_cntr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] dfr_output_data;
wire dfr_output_wen;

wire reservoir_rst;
wire reservoir_rst_i;

wire matrix_multiply_busy;
wire matrix_multiply_start;
wire matrix_multiply_rst;
wire matrix_multiply_rst_i;

wire reservoir_init_busy;
wire reservoir_busy;
wire sample_cntr_rst;


wire [31:0] num_init_samples;
wire [31:0] num_train_samples;
wire [31:0] num_test_samples;
wire [31:0] num_steps_per_sample;

wire [31:0] num_init_steps;
wire [31:0] num_train_steps;
wire [31:0] num_test_steps;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] matrix_multiply_reservoir_history_addr;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] sample_cntr;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_init_cntr;
wire reservoir_filled;

wire dfr_done;
wire reservoir_en;

wire reservoir_valid;

wire sample_cntr_en;

wire init_sample_cntr_rst;
wire init_sample_cntr_en;

wire reservoir_history_rst;

wire [7:0] mem_sel = (busy) ? 8'h0 : mem_addr_i[29:22];

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] mem_addr = mem_addr_i[RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0];

wire [2:0] current_state_out;

assign input_mem_addr = (mem_sel == 8'h1) ? mem_addr : sample_cntr;
assign input_mem_din =  (mem_sel == 8'h1) ? mem_data_in : 32'h0;
assign input_mem_wen =  (mem_sel == 8'h1) ? mem_wen : 1'h0;

assign reservoir_output_mem_addr =    (mem_sel == 8'h2) ? mem_addr : ( (reservoir_history_en) ? reservoir_history_addr : matrix_multiply_reservoir_history_addr);
assign reservoir_output_mem_data_in = (mem_sel == 8'h2) ? mem_data_in : reservoir_data_out;
assign reservoir_output_mem_wen =     (mem_sel == 8'h2) ? mem_wen : reservoir_history_en;

assign output_weight_mem_addr =    (mem_sel == 8'h3) ? mem_addr : matrix_multiply_output_weight_addr;
assign output_weight_mem_data_in = (mem_sel == 8'h3) ? mem_data_in : 32'h0;
assign output_weight_mem_wen =     (mem_sel == 8'h3) ? mem_wen : 1'h0;

assign dfr_output_mem_addr =        (mem_sel == 8'h4) ? mem_addr : dfr_output_cntr;
assign dfr_output_mem_data_in =     (mem_sel == 8'h4) ? mem_data_in : dfr_output_data;
assign dfr_output_mem_wen =         (mem_sel == 8'h4) ? mem_wen : dfr_output_wen;

assign mem_data_out =   (mem_sel == 8'h1) ? input_mem_dout : (
                        (mem_sel == 8'h2) ? reservoir_output_mem_data_out : (
                        (mem_sel == 8'h3) ? output_weight_mem_data_out : (
                        (mem_sel == 8'h4) ? dfr_output_mem_data_out : 32'h0
                        )));


assign debug_in[0] = busy; // DFR Core Controller
assign debug_in[1] = matrix_multiply_busy;
assign debug_in[2] = dfr_done;
assign debug_in[3] = reservoir_busy;
assign debug_in[4] = reservoir_init_busy;
assign debug_in[5] = reservoir_filled;
assign debug_in[6] = reservoir_en;
assign debug_in[7] = 1'b0;
assign debug_in[15:8] = mem_sel;
assign debug_in[18:16] = current_state_out;
assign debug_in[31:19] = reservoir_history_addr[13:0];

axi_cfg_regs 
#(
    C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH
)
axi_cfg_regs
(
    // Debug Register Output
    .debug(debug),
    .debug_in(debug_in),
    // Control Register
    .ctrl(ctrl),
    .busy(busy),
    // Mem Registers
    .mem_addr(mem_addr_i),
    .mem_wen(mem_wen),
    .mem_data_in(mem_data_in),
    .mem_data_out(mem_data_out),
    // Sample Data
    .num_init_samples(num_init_samples),
    .num_train_samples(num_train_samples),
    .num_test_samples(num_test_samples),
    .num_steps_per_sample(num_steps_per_sample),
    .num_init_steps(num_init_steps),
    .num_train_steps(num_train_steps),
    .num_test_steps(num_test_steps),
    //AXI Signals
    .S_AXI_ACLK(S_AXI_ACLK),     
    .S_AXI_ARESETN(S_AXI_ARESETN),  
    .S_AXI_AWADDR(S_AXI_AWADDR),   
    .S_AXI_AWVALID(S_AXI_AWVALID),  
    .S_AXI_AWREADY(S_AXI_AWREADY),  
    .S_AXI_ARADDR(S_AXI_ARADDR),   
    .S_AXI_ARVALID(S_AXI_ARVALID),  
    .S_AXI_ARREADY(S_AXI_ARREADY),  
    .S_AXI_WDATA(S_AXI_WDATA),    
    .S_AXI_WSTRB(S_AXI_WSTRB),    
    .S_AXI_WVALID(S_AXI_WVALID),   
    .S_AXI_WREADY(S_AXI_WREADY),   
    .S_AXI_RDATA(S_AXI_RDATA),    
    .S_AXI_RRESP(S_AXI_RRESP),    
    .S_AXI_RVALID(S_AXI_RVALID),   
    .S_AXI_RREADY(S_AXI_RREADY),   
    .S_AXI_BRESP(S_AXI_BRESP),    
    .S_AXI_BVALID(S_AXI_BVALID),   
    .S_AXI_BREADY(S_AXI_BREADY)   
);




dfr_core_controller
# (
    .ADDR_WIDTH(14),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH),
    .X_ROWS(100), // Num Training Samples?
    .Y_COLS(100), // Num Weights?
    .X_COLS_Y_ROWS(100) // Num Time Steps (Virtual Nodes) per Sample?
)
dfr_core_controller
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .start(ctrl[0]),
    .busy(busy),
    .reservoir_busy(reservoir_busy),
    .reservoir_init_busy(reservoir_init_busy),
    .reservoir_filled(reservoir_filled),
    .reservoir_history_en(reservoir_history_en),
    .matrix_multiply_busy(matrix_multiply_busy),
    .matrix_multiply_start(matrix_multiply_start),
    .reservoir_en(reservoir_en), 
    .dfr_done(dfr_done),
    .reservoir_rst(reservoir_rst_i),
    .matrix_multiply_rst(matrix_multiply_rst_i),
    .sample_cntr_rst(sample_cntr_rst),
    .sample_cntr_en(sample_cntr_en),
    .init_sample_cntr_rst(init_sample_cntr_rst),
    .init_sample_cntr_en(init_sample_cntr_en),
    .reservoir_history_rst(reservoir_history_rst),
    .reservoir_valid(reservoir_valid),
    .current_state_out(current_state_out)
);

assign reservoir_init_busy = (reservoir_init_cntr < num_init_steps) ? 1'b1 : 1'b0;
assign reservoir_busy = (reservoir_history_addr < num_test_steps) ? 1'b1 : 1'b0;


assign reservoir_filled = (sample_cntr > num_init_steps + num_steps_per_sample - 1) ? 1'b1 : 1'b0;

reservoir 
#(
    .NUM_VIRTUAL_NODES(NUM_VIRTUAL_NODES),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
reservoir
(
    .clk(S_AXI_ACLK),
    .rst(reservoir_rst),
    .din(input_mem_dout),
    .dout(reservoir_data_out),
    .reservoir_valid(reservoir_valid),
    .en(reservoir_en)
);

assign reservoir_rst = rst || reservoir_rst_i;

counter
#(
    .DATA_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH)
)
sample_counter
(
    .clk(S_AXI_ACLK),
    .en(sample_cntr_en),
    .rst(sample_cntr_rst),
    .dout(sample_cntr)
);

counter
#(
    .DATA_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH)
)
reservoir_history_counter
(
    .clk(S_AXI_ACLK),
    .en(reservoir_history_en),
    .rst(reservoir_history_rst),
    .dout(reservoir_history_addr)
);

counter
#(
    .DATA_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH)
)
init_sample_counter
(
    .clk(S_AXI_ACLK),
    .en(init_sample_cntr_en),
    .rst(init_sample_cntr_rst),
    .dout(reservoir_init_cntr)
);

ram
# (
    .ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
input_mem
(
    .clk(S_AXI_ACLK),
    .wen(input_mem_wen),
    .addr(input_mem_addr),
    .din(input_mem_din),
    .dout(input_mem_dout)
);

ram
# (
    .ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
reservoir_output_mem
(
    .clk(S_AXI_ACLK),
    .wen(reservoir_output_mem_wen),
    .addr(reservoir_output_mem_addr),
    .din(reservoir_output_mem_data_in),
    .dout(reservoir_output_mem_data_out)
);

ram
# (
    .ADDR_WIDTH(8),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
output_weight_mem
(
    .clk(S_AXI_ACLK),
    .wen(output_weight_mem_wen),
    .addr(output_weight_mem_addr[7:0]),
    .din(output_weight_mem_data_in),
    .dout(output_weight_mem_data_out)
);


ram
# (
    .ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
dfr_output_mem
(
    .clk(S_AXI_ACLK),
    .wen(dfr_output_mem_wen),
    .addr(dfr_output_mem_addr),
    .din(dfr_output_mem_data_in),
    .dout(dfr_output_mem_data_out)
);


assign matrix_multiply_rst = rst || matrix_multiply_rst_i;

matrix_multiplier_v2
# (
    .ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
matrix_multiplier_v2
(
    .clk(S_AXI_ACLK),
    .rst(matrix_multiply_rst),
    .start(matrix_multiply_start),
    .busy(matrix_multiply_busy),
    .x_data(reservoir_output_mem_data_out),
    .y_data(output_weight_mem_data_out),
    .x_addr(matrix_multiply_reservoir_history_addr),
    .y_addr(matrix_multiply_output_weight_addr),
    .z_addr(dfr_output_cntr),
    .z_data(dfr_output_data),
    .z_wen(dfr_output_wen),
    .x_rows(num_test_samples[RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0]),
    .y_cols({{(RESERVOIR_HISTORY_ADDR_WIDTH - 1){1'b0}},1'b1}),
    .x_cols_y_rows(NUM_VIRTUAL_NODES[RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0])
);


endmodule