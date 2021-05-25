`timescale 1ns / 1ps
module asic_function_interface_top
#(
    parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
    parameter C_S_AXI_DATA_WIDTH = 32,
    parameter C_S_AXI_ADDR_WIDTH = 16
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

    // DAC Interface
    output DAC_CS_N,
    output DAC_LDAC_N,
    output DAC_DIN,
    output DAC_SCLK,

    //XADC Interface
    input VP_IN,
    input VN_IN
);

wire [31:0] asic_data_in;
wire [31:0] asic_data_out;
wire [31:0] ctrl;

wire done;

wire rst = ~S_AXI_ARESETN;

assign asic_data_in[31:16] = 16'h0000;

asic_function_interface_top_axi_regs 
#(
    C_S_AXI_ACLK_FREQ_HZ,
    C_S_AXI_DATA_WIDTH,
    C_S_AXI_ADDR_WIDTH
)
asic_function_interface_top_axi_regs
(
    // System Signals
    .asic_data_in(asic_data_in),
    .asic_data_out(asic_data_out),
    .ctrl(ctrl),
    .done(done),
    
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

asic_function_interface asic_function_interface 
(
    // SoC Control Signals
    .clk(S_AXI_ACLK),
    .rst(rst),
    .start(ctrl[0]),
    .data_in(asic_data_out[15:0]),
    
    // XADC Output
    .xadc_data_valid(done),
    .xadc_data_out(asic_data_in[15:0]),
    
    // XADC Interface
    .vp_in(VP_IN),
    .vn_in(VN_IN),
    
    // DAC Interface
    .dac_cs_n(DAC_CS_N),
    .dac_ldac_n(DAC_LDAC_N),
    .dac_din(DAC_DIN),
    .dac_sclk(DAC_SCLK)
);



endmodule