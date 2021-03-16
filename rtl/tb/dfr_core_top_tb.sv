`timescale 1ns / 1ps
module dfr_core_top_tb;

localparam CTRL_REG = 16'h0000;
localparam DEBUG_REG = 16'h0004;
localparam NUM_INIT_SAMPLES_REG = 16'h0008;
localparam NUM_TRAIN_SAMPLES_REG = 16'h000C;
localparam NUM_TEST_SAMPLES_REG = 16'h0010;
localparam NUM_STEPS_PER_SAMPLE_REG = 16'h0014;
localparam NUM_INIT_STEPS_REG = 16'h0018;
localparam NUM_TRAIN_STEPS_REG = 16'h001C;
localparam NUM_TEST_STEPS_REG = 16'h0020;

localparam C_S_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 16;
localparam VIRTUAL_NODES = 10;
localparam RESERVOIR_DATA_WIDTH = 32;
localparam RESERVOIR_HISTORY_ADDR_WIDTH = 16;

localparam NUM_TEST_SAMPLES = 5;
localparam NUM_STEPS_PER_SAMPLE = 10;

// Inputs
reg S_AXI_ACLK = 0;
reg S_AXI_ARESETN = 0;
reg [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR = 0;
reg S_AXI_AWVALID = 0;
reg [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR = 0;
reg S_AXI_ARVALID = 0;
reg [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA = 0;
reg [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB = 0;
reg S_AXI_WVALID = 0;
reg S_AXI_RREADY = 0;
reg S_AXI_BREADY = 0;

reg busy = 0;

wire S_AXI_AWREADY; 
wire S_AXI_ARREADY; 
wire S_AXI_WREADY;  
wire [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;  
wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID;  

integer i = 0;
integer j = 0;

reg [31:0] addr = 0;
reg [31:0] read_data = 0;
reg [31:0] write_data = 0;



dfr_core_top
#(
    .C_S_AXI_ACLK_FREQ_HZ(C_S_AXI_ACLK_FREQ_HZ),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .VIRTUAL_NODES(VIRTUAL_NODES),
    .RESERVOIR_DATA_WIDTH(RESERVOIR_DATA_WIDTH),
    .RESERVOIR_HISTORY_ADDR_WIDTH(RESERVOIR_HISTORY_ADDR_WIDTH)
)
uut
(
    // axi_cfg_regs
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
    .busy(busy)
);

initial begin
S_AXI_ACLK = 0;
forever #10 S_AXI_ACLK = ~S_AXI_ACLK;
end 


task AXI_WRITE( input [31:0] WRITE_ADDR, input [31:0] WRITE_DATA );
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_AWADDR = WRITE_ADDR;
        S_AXI_AWVALID = 1'b1;
        S_AXI_WVALID = 1;
        S_AXI_WDATA = WRITE_DATA;
        S_AXI_BREADY = 1'b1;
        @(posedge S_AXI_WREADY);
        @(posedge S_AXI_ACLK);
        S_AXI_WVALID = 0;
        S_AXI_AWVALID = 0;
        S_AXI_BREADY = 1'b0;
        @(posedge S_AXI_ACLK);
        S_AXI_AWADDR = 32'h0;
        S_AXI_WDATA = 32'h0;
        $display("%t: Wrote Data: %h",$time,WRITE_DATA);
    end
endtask

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA = 32'h0, input [31:0] MASK_DATA = 32'h0, input COMPARE=0);
    begin
        @(posedge S_AXI_ACLK);
        S_AXI_ARADDR = READ_ADDR;
        S_AXI_ARVALID = 1'b1;
        @(posedge S_AXI_RVALID);
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1'b1;
        if (((EXPECT_DATA | MASK_DATA) == (S_AXI_RDATA | MASK_DATA)) || ~COMPARE) 
            $display("%t: Read Data: %h",$time,S_AXI_RDATA);
        else 
            $display("%t: ERROR: %h != %h",$time,S_AXI_RDATA,EXPECT_DATA);
        @(posedge S_AXI_ACLK);
        S_AXI_RREADY = 0;
        S_AXI_ARADDR = 32'h0;
    end
endtask

task WAIT( input [31:0] cycles);
    integer i;
    begin
        for (i = 0; i < cycles; i = i + 1)
            @(posedge S_AXI_ACLK);
    end
endtask


initial begin
    WAIT(2);

    S_AXI_ARESETN = 1;

    
    /* Write Reg Tests */
    for (i = 0; i < 4; i = i + 4)
    begin
        AXI_WRITE(i,32'hDEAD_BEEE);
    end

    /* Read Reg Tests */
    for (i = 0; i < 4; i = i + 4)
    begin
        AXI_READ(i,32'hDEAD_BEEE,32'h0000_0003);
    end

    // Test Write to Input Mem

    //Select Input Mem
    AXI_WRITE(CTRL_REG,32'h0000_0000);
    AXI_READ(CTRL_REG,32'h0000_0000);

    // Test Write to Input Mem
    for(i = 0; i < 100; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, i);
        AXI_READ( 32'h01_00 + i, i);
    end

    //Select Reservoir Output Mem
    AXI_WRITE(CTRL_REG,32'h0000_0010);
    AXI_READ(CTRL_REG,32'h0000_0010);

    // Test Write to Reservoir Output Mem
    for(i = 0; i < 2**4; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, i);
        AXI_READ( 32'h01_00 + i, i);
    end

    //Select Weight Mem
    AXI_WRITE(CTRL_REG,32'h0000_0020);
    AXI_READ(CTRL_REG,32'h0000_0020);

    // Test Write to Weight Mem
    for(i = 0; i < 2**4; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, i);
        AXI_READ( 32'h01_00 + i, i);
    end

    //Select DFR Output Mem
    AXI_WRITE(CTRL_REG,32'h0000_0030);
    AXI_READ(CTRL_REG,32'h0000_0030);

    // Test Write to DFR Output Mem
    for(i = 0; i < 2**4; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, i);
        AXI_READ( 32'h01_00 + i, i);
    end

    // for(i = 0; i < 100; i = i + 1) begin
    //     @(posedge S_AXI_ACLK);
    //     // reservoir_data_in = reservoir_data_in + 32'h028F_5C29;
    // end

    ////// ========= Test DFR ============= /////////

    // Configure Widths
    AXI_WRITE(NUM_INIT_SAMPLES_REG,0);
    AXI_WRITE(NUM_TRAIN_SAMPLES_REG,0);
    AXI_WRITE(NUM_TEST_SAMPLES_REG,NUM_TEST_SAMPLES);
    AXI_WRITE(NUM_INIT_STEPS_REG,0);
    AXI_WRITE(NUM_TRAIN_STEPS_REG,0);
    AXI_WRITE(NUM_TEST_STEPS_REG,NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE);
    AXI_WRITE(NUM_STEPS_PER_SAMPLE_REG,NUM_STEPS_PER_SAMPLE);

    // Configure Input Samples
    //Select Input Mem
    AXI_WRITE(CTRL_REG,32'h0000_0000);

    // Test Write to Input Mem
    for(i = 0; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, i*335544);
        AXI_READ( 32'h01_00 + i, i*335544);
    end
    // Clear Empty Spaces
    for(i = NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE + NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i,0);
        AXI_READ( 32'h01_00 + i,0);
    end

    // Configure Weights
    //Select Weight Mem
    AXI_WRITE(CTRL_REG,32'h0000_0020);

    // Test Write to Weight Mem
    for(i = 0; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        AXI_WRITE(32'h01_00 + i, 1);
        AXI_READ( 32'h01_00 + i, 1);
    end

    // Launch DFR
    AXI_WRITE(CTRL_REG,32'h0000_0001);
    // Wait until finished
    // while (busy) begin
    //    WAIT(1);
    // end
    @(negedge busy);

    //Select DFR Output Mem
    AXI_WRITE(CTRL_REG,32'h0000_0030);

    // Read DFR Output Mem
    for(i = 0; i < NUM_TEST_SAMPLES; i = i + 1) begin
        AXI_READ( 32'h01_00 + i, i);
    end

    /*
    // DEBUG: Read Reservoir Output
    $display("Reading reservoir output data");
    //Select Reservoir Output Mem
    AXI_WRITE(CTRL_REG,32'h0000_0010);

    // Test Write to Reservoir Output Mem
    for(i = 0; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        $display("Sample: %d");
        AXI_READ( 32'h01_00 + i);
    end
    */

    $finish;

end



endmodule