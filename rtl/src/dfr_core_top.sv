`timescale 1ns / 1ps
module dfr_core_top
#(
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 30,
    parameter NUM_VIRTUAL_NODES = 100,
    parameter RESERVOIR_DATA_WIDTH = 32,
    parameter RESERVOIR_HISTORY_ADDR_WIDTH = 17
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

    output busy,
    
    output [31:0] debug_reg
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

wire [31:0] input_mem_doutb; 

wire [31:0] reservoir_output_mem_doutb;

wire [31:0] output_weight_mem_doutb;

wire [11:0] asic_function_out;


assign input_mem_wen            =     (mem_sel == 8'h1) ? mem_wen : 1'h0;
assign reservoir_output_mem_wen =     (mem_sel == 8'h2) ? mem_wen : 1'h0;
assign output_weight_mem_wen    =     (mem_sel == 8'h3) ? mem_wen : 1'h0;
assign dfr_output_mem_wen       =     (mem_sel == 8'h4) ? mem_wen : dfr_output_wen;

assign mem_data_out =   (mem_sel == 8'h1) ? input_mem_dout : (
                        (mem_sel == 8'h2) ? reservoir_output_mem_data_out : (
                        (mem_sel == 8'h3) ? output_weight_mem_data_out : (
                        (mem_sel == 8'h4) ? dfr_output_mem_data_out : 32'h0
                        )));

// DEBUG_REG BITS
assign debug_in[0] = busy; // DFR Core Controller
assign debug_in[1] = matrix_multiply_busy;
assign debug_in[2] = dfr_done;
assign debug_in[3] = reservoir_busy;
assign debug_in[4] = reservoir_init_busy;
assign debug_in[5] = reservoir_filled;
assign debug_in[6] = reservoir_en;
assign debug_in[7] = 1'b0;
assign debug_in[19:8] = asic_function_out;
assign debug_in[22:20] = axi_current_state_out;
assign debug_in[23] = 1'b0;
assign debug_in[31:24] = input_mem_doutb[7:0];

assign debug_reg = debug_in;

wire [2:0] axi_current_state_out;

axi_cfg_regs 
#(
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
    .S_AXI_BREADY(S_AXI_BREADY),
    .current_state_out(axi_current_state_out)   
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
    .din(input_mem_doutb),
    .dout(reservoir_data_out),
    .reservoir_valid(reservoir_valid),
    .en(reservoir_en),
    .asic_function_out(asic_function_out)
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

bram_16k_dual_port input_sample_mem
(
    .addra(mem_addr[RESERVOIR_HISTORY_ADDR_WIDTH - 1:0]),
    .clka(S_AXI_ACLK),
    .dina(mem_data_in),
    .douta(input_mem_dout),
    .wea(input_mem_wen),
    .addrb(sample_cntr),
    .clkb(S_AXI_ACLK),
    .dinb(32'h0000_0000),
    .doutb(input_mem_doutb),
    .web(1'b0)
);

assign reservoir_output_mem_addr = (reservoir_history_en) ? reservoir_history_addr : matrix_multiply_reservoir_history_addr;

bram_16k_dual_port reservoir_output_mem
(
    .addra(mem_addr[RESERVOIR_HISTORY_ADDR_WIDTH - 1:0]),
    .clka(S_AXI_ACLK),
    .dina(mem_data_in),
    .douta(reservoir_output_mem_data_out),
    .wea(reservoir_output_mem_wen),
    .addrb(reservoir_output_mem_addr),
    .clkb(S_AXI_ACLK),
    .dinb(reservoir_data_out),
    .doutb(reservoir_output_mem_doutb),
    .web(reservoir_history_en)
);

bram_128_dual_port output_weight_mem
(
    .addra(mem_addr[6:0]),
    .clka(S_AXI_ACLK),
    .dina(mem_data_in),
    .douta(output_weight_mem_data_out),
    .wea(output_weight_mem_wen),
    .addrb(matrix_multiply_output_weight_addr[6:0]),
    .clkb(S_AXI_ACLK),
    .dinb(32'h0000_0000),
    .doutb(output_weight_mem_doutb),
    .web(1'b0)
);

wire [31:0] dfr_output_mem_doutb;

bram_16k_dual_port dfr_output_mem
(
    .addra(mem_addr[RESERVOIR_HISTORY_ADDR_WIDTH - 1:0]),
    .clka(S_AXI_ACLK),
    .dina(mem_data_in),
    .douta(dfr_output_mem_data_out),
    .wea(output_weight_mem_wen),
    .addrb(dfr_output_cntr),
    .clkb(S_AXI_ACLK),
    .dinb(dfr_output_data),
    .doutb(dfr_output_mem_doutb),
    .web(dfr_output_wen)
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
    .x_data(reservoir_output_mem_doutb),
    .y_data(output_weight_mem_doutb),
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