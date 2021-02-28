`timescale 1ns / 1ps
module dfr_core_top
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 9,
    parameter VIRTUAL_NODES = 10,
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
    output S_AXI_BVALID  
);




wire rst;


assign rst = ~S_AXI_ARESETN;

wire [31:0] debug;
wire [31:0] ctrl;
wire [3:0] mem_sel;

wire  [15:0] mem_addr;
wire  mem_wen;
wire  [C_S_AXI_DATA_WIDTH - 1:0] mem_data_in;
wire  [C_S_AXI_DATA_WIDTH - 1:0] mem_data_out;
wire [RESERVOIR_DATA_WIDTH - 1:0] mem_data_out; 

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] input_mem_addr;
wire [RESERVOIR_DATA_WIDTH - 1:0] input_mem_din;
wire [RESERVOIR_DATA_WIDTH - 1:0] input_mem_dout;
wire input_mem_wen;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_output_mem_addr;

wire RESERVOIR_DATA_WIDTH - 1:0] reservoir_output_mem_data_in;

wire busy;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_history_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_data_out;
wire reservoir_history_en;

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_output_mem_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_output_mem_data_in;
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

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] dfr_output_cntr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] dfr_output_data;
wire dfr_output_wen;

assign mem_sel = ctrl[7:4];

assign input_mem_addr = (mem_sel == 4'h0 && ~busy) ? mem_addr[13:0] : 14'h0;
assign input_mem_din =  (mem_sel == 4'h0 && ~busy) ? mem_data_in : 32'h0;
assign input_mem_wen =  (mem_sel == 4'h0 && ~busy) ? mem_wen : 1'h0;

assign reservoir_output_mem_addr =    (mem_sel == 4'h1 && ~busy) ? mem_addr[13:0] : reservoir_history_addr;
assign reservoir_output_mem_data_in = (mem_sel == 4'h1 && ~busy) ? mem_data_in : reservoir_data_out;
assign reservoir_output_mem_wen =     (mem_sel == 4'h1 && ~busy) ? mem_wen : reservoir_history_en;

assign output_weight_mem_addr =    (mem_sel == 4'h2 && ~busy) ? mem_addr[13:0] : 14'h0;
assign output_weight_mem_data_in = (mem_sel == 4'h2 && ~busy) ? mem_data_in : 32'h0;
assign output_weight_mem_wen =     (mem_sel == 4'h2 && ~busy) ? mem_wen : 1'h0;

assign output_weight_mem_addr =    (mem_sel == 4'h2 && ~busy) ? mem_addr[13:0] : 14'h0;
assign output_weight_mem_data_in = (mem_sel == 4'h2 && ~busy) ? mem_data_in : 32'h0;
assign output_weight_mem_wen =     (mem_sel == 4'h2 && ~busy) ? mem_wen : 1'h0;

assign dfr_output_mem_addr =        (mem_sel == 4'h3 && ~busy) ? mem_addr[13:0] : dfr_output_cntr;
assign dfr_output_mem_data_in =  (mem_sel == 4'h3 && ~busy) ? mem_data_in : dfr_output_data;
assign dfr_output_mem_wen =      (mem_sel == 4'h3 && ~busy) ? mem_wen : dfr_output_wen;

assign mem_data_out =   (mem_sel == 4'h0) ? input_mem_dout : (
                        (mem_sel == 4'h1) ? reservoir_output_mem_data_out : (
                        (mem_sel == 4'h2) ? output_weight_mem_data_out : (
                        (mem_sel == 4'h3) ? dfr_output_mem_data_out : 32'h0)
                        )));

/*
XADC #(// Initializing the XADC Control Registers
    .INIT_40(16'hB903), // Multiplexer Input on VP/VN Channel, 256 sample averaging and settling (acquisition) time 
    .INIT_41(16'h20F0),// Continuous Seq Mode, Calibrate ADC and Supply Sensor
    .INIT_42(16'h3F00),// Set DCLK divides
    .INIT_49(16'h000F),// CHSEL2 - enable aux analog channels 0 - 3
    .INIT_4B(16'h000F), // enable averaging
    .INIT_4F(16'h000F), // enable settling time
    .SIM_MONITOR_FILE("design.txt"),// Analog Stimulus file for simulation
    .SIM_DEVICE("ZYNQ")
)
XADC_INST (// Connect up instance IO. See UG480 for port descriptions
    .CONVST (1'b0),// not used
    .CONVSTCLK  (1'b0), // not used
    .DADDR  (DADDR),
    .DCLK   (S_AXI_ACLK),
    .DEN    (DEN),
    .DI     (DI),
    .DWE    (DWE),
    .RESET  (RESET),
    .BUSY   (BUSY),
    .DO     (DO),
    .DRDY   (DRDY),
    .EOS    (EOS),
    .VP     (VP),
    .VN     (VN),
    .VAUXP(16'b0),
    .VAUXN(16'b0),
    .ALM(),
    .CHANNEL(),
    .EOC(),
    .JTAGBUSY(),
    .JTAGLOCKED(),
    .JTAGMODIFIED(),
    .MUXADDR(XADC_MUXADDR_local),
    .OT()
);
*/


axi_cfg_regs 
#(
    C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH
)
axi_cfg_regs
(
    // System Signals
    .clk(S_AXI_ACLK),
    .rst(RESET),
    // Debug Register Output
    .debug(debug),
    // Control Register
    .ctrl(ctrl),
    // Mem Registers
    .mem_addr(mem_addr),
    .mem_wen(mem_wen),
    .mem_data_in(mem_data_in),
    .mem_data_out(mem_data_out),
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


assign reservoir_busy = (reservoir_history_addr < 100);

reservoir 
#(
    .VIRTUAL_NODES(VIRTUAL_NODES),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
reservoir
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .din(reservoir_data_in),
    .dout(reservoir_data_out),
    .en(reservoir_en)
);

counter
#(
    .DATA_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH)
)
sample_counter
(
    .clk(S_AXI_ACLK),
    .en(1'b1),
    .rst(rst),
    .dout(reservoir_history_addr)
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
    .clk(clk),
    .rst(rst),
    .start(ctrl[0]),
    .busy(busy),
    .reservoir_busy(reservoir_busy),
    .reservoir_history_en(reservoir_history_en),
    .matrix_multiply_busy(matrix_multiply_busy),
    .matrix_multiply_start(matrix_multiply_start),
    .reservoir_en(reservoir_en), 
    .dfr_done(dfr_done)
);

matrix_multiply_top
# (
    .ADDR_WIDTH(14),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH),
    .X_ROWS(100),
    .Y_COLS(100),
    .X_COLS_Y_ROWS(100)
)
matrix_multiply_top
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .start(start),
    .ram_addr(ram_addr),
    .ram_wen(ram_wen),
    .ram_sel(ram_sel),
    .ram_data_in(ram_data_in),
    .busy(matrix_multiply_busy),
    .ram_data_out(ram_data_out)
);

ram
# (
    .ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH),
    .DATA_WIDTH(RESERVOIR_DATA_WIDTH)
)
output_weight_mem
(
    .clk(S_AXI_ACLK),
    .wen(output_weight_mem_wen),
    .addr(output_weight_mem_addr),
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

endmodule