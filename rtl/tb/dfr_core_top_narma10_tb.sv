`timescale 1ns / 1ps
module dfr_core_top_narma10_tb;

localparam CTRL_REG_ADDR = 16'h0000;
localparam DEBUG_REG_ADDR = 16'h0004;
localparam NUM_INIT_SAMPLES_REG_ADDR = 16'h0008;
localparam NUM_TRAIN_SAMPLES_REG_ADDR = 16'h000C;
localparam NUM_TEST_SAMPLES_REG_ADDR = 16'h0010;
localparam NUM_STEPS_PER_SAMPLE_REG_ADDR = 16'h0014;
localparam NUM_INIT_STEPS_REG_ADDR = 16'h0018;
localparam NUM_TRAIN_STEPS_REG_ADDR = 16'h001C;
localparam NUM_TEST_STEPS_REG_ADDR = 16'h0020;

localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 30;
localparam NUM_VIRTUAL_NODES = 100;
localparam RESERVOIR_DATA_WIDTH = 32;
localparam RESERVOIR_HISTORY_ADDR_WIDTH = 17;

localparam NUM_STEPS_PER_SAMPLE = NUM_VIRTUAL_NODES;

localparam MAX_INPUT_SAMPLES_STEPS = 2 ** RESERVOIR_HISTORY_ADDR_WIDTH;
localparam MAX_INPUT_SAMPLES = MAX_INPUT_SAMPLES_STEPS / NUM_STEPS_PER_SAMPLE;

// NUM_INIT_SAMPLES + NUM_TEST_SAMPLES must be less than MAX_INPUT_SAMPLES - 1 to prevent internal sample_cntr from overflowing  
localparam NUM_INIT_SAMPLES = 1;
localparam NUM_TEST_SAMPLES = MAX_INPUT_SAMPLES - NUM_INIT_SAMPLES - 1;

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
        @(posedge S_AXI_ACLK);
        S_AXI_BREADY = 1'b1;
        while(S_AXI_WREADY != 1) begin
            @(posedge S_AXI_ACLK);
        end
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

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA = 32'h0, input [31:0] MASK_DATA = 32'h0, input COMPARE=0, input DECIMAL=0, output [31:0] READ_DATA);
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
        READ_DATA = read_data_int;
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
    integer input_samples_file;
    integer weights_file;
    integer expected_output_file;
    integer i = 0;
    integer j = 0;
    integer mem_cntr = 0;
    string line;
    integer readInt;
    reg [31:0] write_addr = 0;
    integer read_data = 0;

    input_samples_file = $fopen("/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/python/data/narma10/dfr_sw_int_narma10_inputs.txt","r");
    weights_file = $fopen("/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/python/data/narma10/dfr_sw_int_narma10_weights.txt","r");
    expected_output_file = $fopen("/home/oshears/Documents/vt/research/code/verilog/hybrid_dfr_system/python/data/narma10/dfr_sw_int_narma10_dfr_outputs.txt","r");


    WAIT(2);

    S_AXI_ARESETN = 1;


    ////// ========= Test DFR ============= /////////

    // Configure Widths
    AXI_WRITE(NUM_INIT_SAMPLES_REG_ADDR,NUM_INIT_SAMPLES);
    AXI_WRITE(NUM_TRAIN_SAMPLES_REG_ADDR,0);
    AXI_WRITE(NUM_TEST_SAMPLES_REG_ADDR,NUM_TEST_SAMPLES);

    AXI_WRITE(NUM_INIT_STEPS_REG_ADDR,NUM_INIT_SAMPLES * NUM_STEPS_PER_SAMPLE);
    AXI_WRITE(NUM_TRAIN_STEPS_REG_ADDR,0);
    AXI_WRITE(NUM_TEST_STEPS_REG_ADDR,NUM_TEST_SAMPLES * NUM_STEPS_PER_SAMPLE);
    
    AXI_WRITE(NUM_STEPS_PER_SAMPLE_REG_ADDR,NUM_STEPS_PER_SAMPLE);


    AXI_WRITE(CTRL_REG_ADDR,32'h0000_0000);

    // Configure Input Samples
    
    i = 0;
    mem_cntr = 0;
    while(!$feof(input_samples_file) && i < NUM_STEPS_PER_SAMPLE * (NUM_TEST_SAMPLES + NUM_INIT_SAMPLES) && mem_cntr < MAX_INPUT_SAMPLES_STEPS) begin
        $fgets(line,input_samples_file);
        readInt = line.atoi();
        AXI_WRITE(DFR_INPUT_MEM_ADDR_OFFSET + (i * 4), readInt, 1);
        i++;
        mem_cntr++;
    end

    // Configure Weights

    i = NUM_VIRTUAL_NODES - 1;
    while(!$feof(weights_file)) begin
        $fgets(line,weights_file);
        readInt = line.atoi();
        AXI_WRITE(DFR_WEIGHT_MEM_ADDR_OFFSET + (i * 4), readInt,1);
        i--;
    end

    // Launch DFR
    AXI_WRITE(CTRL_REG_ADDR,32'h0000_0001);
    @(negedge busy);


    // Read DFR Output Mem
    mem_cntr = 0;
    for(i = 0; i < NUM_TEST_SAMPLES &&  mem_cntr < MAX_INPUT_SAMPLES; i = i + 1) begin
        AXI_READ( .READ_ADDR(DFR_OUTPUT_MEM_ADDR_OFFSET + (i * 4) ), .DECIMAL(1), .READ_DATA(read_data));
        mem_cntr++;
    end

    $fclose(input_samples_file);
    $fclose(weights_file);
    $fclose(expected_output_file);


    $finish;

end


endmodule