`timescale 1ns / 1ps
module dfr_core
#(
parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_S_AXI_DATA_WIDTH = 32,
parameter C_S_AXI_ADDR_WIDTH = 9,
parameter VIRTUAL_NODES = 10,
parameter DATA_WIDTH = 32
)
(
    // char_pwm_gen
    pwm_clk, // 100MHz pwm clock input 
    digit,

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

    // asic_output_analyzer

    //XADC
    VN,
    VP,

    //Analog Signal Control
    XADC_MUXADDR,

    // led outputs
    leds
);

wire rst;
assign rst = ~S_AXI_ARESETN;

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

wire [31:0] reservoir_history_addr;
wire [31:0] reservoir_data_out;

reservoir 
#(
    .VIRTUAL_NODES(10),
    .DATA_WIDTH(32)
)
reservoir
(
    .clk(S_AXI_ACLK),
    .rst(rst),
    .din(din),
    .dout(reservoir_data_out)
);

counter
#(
    .DATA_WIDTH(20)
)
sample_counter
(
    .clk(S_AXI_ACLK),
    .en(1'b1),
    .rst(rst),
    .dout(reservoir_history_addr)
);

reservoir_history
# (
    .MEM_SIZE(2**20), //1048576
    .ADDR_WIDTH(20),
    .DATA_WIDTH(32)
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