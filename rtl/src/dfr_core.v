`timescale 1ns / 1ps
module dfr_core
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 9,
    parameter VIRTUAL_NODES = 10,
    parameter RESERVOIR_DATA_WIDTH = 32,
    parameter RESERVOIR_HISTORY_ADDR_WIDTH = 20
)
(
    // axi_cfg_regs
    S_AXI_ACLK,     
    S_AXI_ARESETN,  
    S_AXI_AWADDR,   
    S_AXI_AWVALID,  
    S_AXI_AWREADY,  
    S_AXI_ARADDR,   
    S_AXI_ARVALID,  
    S_AXI_ARREADY,  
    S_AXI_WDATA,    
    S_AXI_WSTRB,    
    S_AXI_WVALID,   
    S_AXI_WREADY,   
    S_AXI_RDATA,    
    S_AXI_RRESP,    
    S_AXI_RVALID,   
    S_AXI_RREADY,   
    S_AXI_BRESP,    
    S_AXI_BVALID,   
    S_AXI_BREADY,   

    reservoir_data_in
);

input S_AXI_ACLK;   
input S_AXI_ARESETN;
input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR; 
input S_AXI_AWVALID;
input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR; 
input S_AXI_ARVALID;
input [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA;  
input [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB;  
input S_AXI_WVALID; 
input S_AXI_RREADY; 
input S_AXI_BREADY; 

input [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_data_in;

output S_AXI_AWREADY; 
output S_AXI_ARREADY; 
output S_AXI_WREADY;  
output [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA;
output [1:0] S_AXI_RRESP;
output S_AXI_RVALID;  
output [1:0] S_AXI_BRESP;
output S_AXI_BVALID;  


wire rst;


assign rst = ~S_AXI_ARESETN;

wire [31:0] debug;


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

wire [RESERVOIR_HISTORY_ADDR_WIDTH - 1 : 0] reservoir_history_addr;
wire [RESERVOIR_DATA_WIDTH - 1 : 0] reservoir_data_out;

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
    .dout(reservoir_data_out)
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
reservoir_history
(
    .clk(S_AXI_ACLK),
    .wen(1'b1),
    .addr(reservoir_history_addr),
    .din(reservoir_data_out),
    .dout()
);



endmodule;