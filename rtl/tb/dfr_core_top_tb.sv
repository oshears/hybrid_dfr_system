`timescale 1ns / 1ps
module dfr_core_top_tb;

localparam CTRL_REG_ADDR = 16'h0000;
localparam DEBUG_REG_ADDR = 16'h0004;
localparam NUM_INIT_SAMPLES_REG_ADDR = 16'h0008;
localparam NUM_TRAIN_SAMPLES_REG_ADDR = 16'h000C;
localparam NUM_TEST_SAMPLES_REG_ADDR = 16'h0010;
localparam NUM_STEPS_PER_SAMPLE_REG_ADDR = 16'h0014;
localparam NUM_INIT_STEPS_REG_ADDR = 16'h0018;
localparam NUM_TRAIN_STEPS_REG_ADDR = 16'h001C;
localparam NUM_TEST_STEPS_REG_ADDR = 16'h0020;

localparam C_S_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 30;
localparam NUM_VIRTUAL_NODES = 100;
localparam RESERVOIR_DATA_WIDTH = 32;
localparam RESERVOIR_HISTORY_ADDR_WIDTH = 16;

localparam NUM_STEPS_PER_SAMPLE = 100;
localparam NUM_INIT_SAMPLES = 0;
localparam NUM_TEST_SAMPLES = 5;

localparam DFR_INPUT_MEM_ADDR_OFFSET     = 32'h0100_0000;
localparam DFR_RESERVOIR_ADDR_MEM_OFFSET = 32'h0200_0000;
localparam DFR_WEIGHT_MEM_ADDR_OFFSET    = 32'h0300_0000;
localparam DFR_OUTPUT_MEM_ADDR_OFFSET    = 32'h0400_0000;

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



reg [31:0] addr = 0;
reg [31:0] read_data = 0;
reg [31:0] write_data = 0;



dfr_core_top
#(
    .C_S_AXI_ACLK_FREQ_HZ(C_S_AXI_ACLK_FREQ_HZ),
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
    .NUM_VIRTUAL_NODES(NUM_VIRTUAL_NODES),
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


task AXI_WRITE( input [31:0] WRITE_ADDR, input [31:0] WRITE_DATA, input DECIMAL=0);
    integer signed write_data_int; 
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
        write_data_int = WRITE_DATA;
        if (DECIMAL)
            $display("%t: Wrote Data: %d",$time,write_data_int);
        else
            $display("%t: Wrote Data: %h",$time,write_data_int);
    end
endtask

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA = 32'h0, input [31:0] MASK_DATA = 32'h0, input COMPARE=0, input DECIMAL=0);
    integer signed read_data_int; 
    begin
        

        @(posedge S_AXI_ACLK);
        S_AXI_ARADDR = READ_ADDR;
        S_AXI_ARVALID = 1'b1;
        @(posedge S_AXI_RVALID);
        @(posedge S_AXI_ACLK);
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 1'b1;
        read_data_int = S_AXI_RDATA;
        if (((EXPECT_DATA | MASK_DATA) == (S_AXI_RDATA | MASK_DATA)) || ~COMPARE) 
            if (DECIMAL)
                $display("%t: Read Data: %d",$time,read_data_int);
            else
                $display("%t: Read Data: %h",$time,read_data_int);
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
    integer i = 0;
    integer j = 0;

    WAIT(2);

    S_AXI_ARESETN = 1;

    
    /* Write Reg Tests */
    for (i = 0; i < 4; i = i + 4)
    begin
        $display("Writing %h",i);
        AXI_WRITE(i,32'hDEAD_BEEE);
    end

    /* Read Reg Tests */
    for (i = 0; i <= 32'h0000_0020; i = i + 4)
    begin
        $display("Reading %h",i);
        AXI_READ(i,32'hDEAD_BEEE,32'h0000_0003);
    end


    // Test Write to Input Mem
    $display("Testing Input Mem");
    for(i = 0; i < 400; i = i + 4) begin
        AXI_WRITE(DFR_INPUT_MEM_ADDR_OFFSET + i, i);
        AXI_READ( DFR_INPUT_MEM_ADDR_OFFSET+ i, i);
    end

    // Test Write to Reservoir Output Mem
    $display("Testing Reservoir Output Mem");
    for(i = 0; i < 400; i = i + 4) begin
        AXI_WRITE(DFR_RESERVOIR_ADDR_MEM_OFFSET + i, i);
        AXI_READ( DFR_RESERVOIR_ADDR_MEM_OFFSET + i, i);
    end

    // Test Write to Weight Mem
    $display("Testing Weight Mem");
    for(i = 0; i < 400; i = i + 4) begin
        AXI_WRITE(DFR_WEIGHT_MEM_ADDR_OFFSET + i, i);
        AXI_READ( DFR_WEIGHT_MEM_ADDR_OFFSET + i, i);
    end

    // Test Write to DFR Output Mem
    $display("Testing DFR Output Mem");
    for(i = 0; i < 400; i = i + 4) begin
        AXI_WRITE(DFR_OUTPUT_MEM_ADDR_OFFSET + i, i);
        AXI_READ( DFR_OUTPUT_MEM_ADDR_OFFSET + i, i);
    end

    ////// ========= Test DFR ============= /////////

    // Configure Widths
    AXI_WRITE(NUM_INIT_SAMPLES_REG_ADDR,0);
    AXI_WRITE(NUM_TRAIN_SAMPLES_REG_ADDR,0);
    AXI_WRITE(NUM_TEST_SAMPLES_REG_ADDR,NUM_TEST_SAMPLES);

    AXI_WRITE(NUM_INIT_STEPS_REG_ADDR,0);
    AXI_WRITE(NUM_TRAIN_STEPS_REG_ADDR,0);
    AXI_WRITE(NUM_TEST_STEPS_REG_ADDR,NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE);

    AXI_WRITE(NUM_STEPS_PER_SAMPLE_REG_ADDR,NUM_STEPS_PER_SAMPLE);

    // Configure Input Samples

    // Test Write to Input Mem
    for(i = 0; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        AXI_WRITE(DFR_INPUT_MEM_ADDR_OFFSET + i*4, i*32,1);
    end
    // Clear Empty Spaces
    for(i = NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE; i < NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE + NUM_STEPS_PER_SAMPLE; i = i + 1) begin
        AXI_WRITE(DFR_INPUT_MEM_ADDR_OFFSET + i*4,0,1);
    end

    // Configure Weights

    // Test Write to Weight Mem
    for(i = 0; i < NUM_VIRTUAL_NODES; i = i + 1) begin
        AXI_WRITE(DFR_WEIGHT_MEM_ADDR_OFFSET + i*4, 1, 1);
    end

    // Launch DFR
    AXI_WRITE(CTRL_REG_ADDR,32'h0000_0001);
    @(negedge busy);

    // Read DFR Output Mem
    for(i = 0; i < NUM_TEST_SAMPLES; i = i + 1) begin
        AXI_READ( .READ_ADDR(DFR_OUTPUT_MEM_ADDR_OFFSET + i*4), .DECIMAL(1));
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

/*
Outputs:
121470000: Wrote Data: 00000001
693310000: Read Data:      149152
693390000: Read Data:      571296
693470000: Read Data:     1239840
693550000: Read Data:     2089096
693630000: Read Data:     1837128
*/



endmodule