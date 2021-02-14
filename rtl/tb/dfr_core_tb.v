`timescale 1ns / 1ps
module dfr_core_tb;
// Inputs
reg pwm_clk;
wire [15:0] digit;

reg S_AXI_ACLK;

reg VP, VN;

wire [7:0] leds;
   
reg S_AXI_ARESETN;
reg [8:0] S_AXI_AWADDR; 
reg S_AXI_AWVALID;
reg [8:0] S_AXI_ARADDR; 
reg S_AXI_ARVALID;
reg [31:0] S_AXI_WDATA;  
reg [3:0] S_AXI_WSTRB;  
reg S_AXI_WVALID; 
reg S_AXI_RREADY; 
reg S_AXI_BREADY; 
wire S_AXI_AWREADY; 
wire S_AXI_ARREADY; 
wire S_AXI_WREADY;  
wire [31:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;  
wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;  
wire [3:0] XADC_MUXADDR;

integer i = 0;
integer j = 0;



endmodule;