`timescale 1ns / 1ps
module asic_function_interface_top_tb;

localparam CTRL_REG_ADDR = 16'h0000;
localparam ASIC_DATA_OUT_REG_ADDR = 16'h0004;
localparam ASIC_DATA_IN_REG_ADDR = 16'h0008;

localparam C_S_AXI_DATA_WIDTH = 32;
localparam C_S_AXI_ADDR_WIDTH = 16;

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

wire S_AXI_AWREADY; 
wire S_AXI_ARREADY; 
wire S_AXI_WREADY;  
wire [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA;
wire [1:0] S_AXI_RRESP;
wire S_AXI_RVALID;  
wire [1:0] S_AXI_BRESP;
wire S_AXI_BVALID; 

// DAC Interface
wire DAC_CS_N;
wire DAC_LDAC_N;
wire DAC_DIN;
wire DAC_SCLK;

//XADC Interface
wire VP_IN;
wire VN_IN;


asic_function_interface_top
#(
    .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
)
uut
(
    // AXI Interface
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

    //DAC Interface
    .DAC_CS_N(DAC_CS_N),
    .DAC_LDAC_N(DAC_LDAC_N),
    .DAC_DIN(DAC_DIN),
    .DAC_SCLK(DAC_SCLK),

    //XADC Interface
    .VP_IN(VP_IN),
    .VN_IN(VN_IN)
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

task AXI_READ( input [31:0] READ_ADDR, input [31:0] EXPECT_DATA = 32'h0, input [31:0] MASK_DATA = 32'h0, input COMPARE=0, input DECIMAL=0, input SILENT=0, output [31:0] READ_DATA);
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
        if (~SILENT) begin
            if (((EXPECT_DATA | MASK_DATA) == (S_AXI_RDATA | MASK_DATA)) || ~COMPARE) 
                if (DECIMAL)
                    $display("%t: Read Data: %d",$time,read_data_int);
                else
                    $display("%t: Read Data: %h",$time,read_data_int);
            else 
                $display("%t: ERROR: %h != %h",$time,S_AXI_RDATA,EXPECT_DATA);
        end
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
    integer i;
    integer read_data;

    WAIT(2);

    S_AXI_ARESETN = 1;

    // Wait for XADC to boot
    WAIT(100);

    for (i = 0; i <= 32'hFFFF; i = i + 32'h1000) begin
        AXI_WRITE(ASIC_DATA_OUT_REG_ADDR,i);
        AXI_WRITE(CTRL_REG_ADDR,32'h1);
        AXI_READ( .READ_ADDR(CTRL_REG_ADDR), .READ_DATA(read_data), .SILENT(1));
        while(read_data[1] == 0) begin
            AXI_READ( .READ_ADDR(CTRL_REG_ADDR), .READ_DATA(read_data), .SILENT(1));
        end
        AXI_READ( .READ_ADDR(ASIC_DATA_IN_REG_ADDR), .READ_DATA(read_data));
    end

    $finish;
end

// always @(negedge DAC_CS_N) begin
//     $display("%t: DAC_CS_N Deasserted",$time);
// end

endmodule