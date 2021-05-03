`timescale 1ns / 1ps
module dfr_core_top_tb;

localparam C_M_AXI_ACLK_FREQ_HZ = 100000000;
localparam C_M_AXI_DATA_WIDTH = 32;
localparam C_M_AXI_ADDR_WIDTH = 9;

reg [31:0] addr = 0;
reg [31:0] write_data  = 0;
reg start_read  = 0;
reg start_write  = 0;

reg M_AXI_ACLK  = 0;
reg M_AXI_ARESETN = 0;

wire M_AXI_AWREADY;
wire M_AXI_ARREADY;
wire M_AXI_WREADY;  
wire [C_M_AXI_DATA_WIDTH - 1:0] M_AXI_RDATA;
wire [1:0] M_AXI_RRESP;
wire M_AXI_RVALID;  
wire [1:0] M_AXI_BRESP;
wire M_AXI_BVALID;  

wire [C_M_AXI_ADDR_WIDTH - 1:0] M_AXI_AWADDR; 
wire M_AXI_AWVALID;
wire [C_M_AXI_ADDR_WIDTH - 1:0] M_AXI_ARADDR;
wire M_AXI_ARVALID;
wire [C_M_AXI_DATA_WIDTH - 1:0] M_AXI_WDATA;  
wire [(C_M_AXI_DATA_WIDTH/8 - 1):0] M_AXI_WSTRB;  
wire M_AXI_WVALID;
wire M_AXI_RREADY; 
wire M_AXI_BREADY; 

wire done;
wire [31:0] read_data;

axi_master axi_master
(

    .addr(addr),
    .write_data(write_data),
    .start_read(start_read),
    .start_write(start_write),

    .M_AXI_ACLK(M_AXI_ACLK),
    .M_AXI_ARESETN(M_AXI_ARESETN),

    .M_AXI_AWREADY(M_AXI_AWREADY), 
    .M_AXI_ARREADY(M_AXI_ARREADY), 
    .M_AXI_WREADY(M_AXI_WREADY),  
    .M_AXI_RDATA(M_AXI_RDATA),
    .M_AXI_RRESP(M_AXI_RRESP),
    .M_AXI_RVALID(M_AXI_RVALID),  
    .M_AXI_BRESP(M_AXI_BRESP),
    .M_AXI_BVALID(M_AXI_BVALID),  
    
    .M_AXI_AWADDR(M_AXI_AWADDR), 
    .M_AXI_AWVALID(M_AXI_AWVALID),
    .M_AXI_ARADDR(M_AXI_ARADDR), 
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_WDATA(M_AXI_WDATA),  
    .M_AXI_WSTRB(M_AXI_WSTRB),  
    .M_AXI_WVALID(M_AXI_WVALID), 
    .M_AXI_RREADY(M_AXI_RREADY), 
    .M_AXI_BREADY(M_AXI_BREADY), 

    .done(done),
    .read_data(read_data)
);

axi_cfg_regs axi_cfg_regs
(
    .busy(),
    
    .S_AXI_ACLK(M_AXI_ACLK),
    .S_AXI_ARESETN(M_AXI_ARESETN),

    .S_AXI_AWADDR(M_AXI_AWADDR), 
    .S_AXI_AWVALID(M_AXI_AWVALID),
    .S_AXI_ARADDR(M_AXI_ARADDR), 
    .S_AXI_ARVALID(M_AXI_ARVALID),
    .S_AXI_WDATA(M_AXI_WDATA),  
    .S_AXI_WSTRB(M_AXI_WSTRB),  
    .S_AXI_WVALID(M_AXI_WVALID), 
    .S_AXI_RREADY(M_AXI_RREADY), 
    .S_AXI_BREADY(M_AXI_BREADY), 

    .mem_addr(),
    .mem_wen(),
    .mem_data_in(),
    .mem_data_out(),

    .S_AXI_AWREADY(M_AXI_AWREADY), 
    .S_AXI_ARREADY(M_AXI_ARREADY), 
    .S_AXI_WREADY(M_AXI_WREADY),  
    .S_AXI_RDATA(M_AXI_RDATA),
    .S_AXI_RRESP(M_AXI_RRESP),
    .S_AXI_RVALID(M_AXI_RVALID),  
    .S_AXI_BRESP(M_AXI_BRESP),
    .S_AXI_BVALID(M_AXI_BVALID),  

    .debug(),
    .ctrl(),
    .num_init_samples(),
    .num_init_steps(),
    .num_train_samples(),
    .num_train_steps(),
    .num_test_samples(),
    .num_test_steps(),
    .num_steps_per_sample()
);




initial begin
M_AXI_ACLK = 0;
forever #10 M_AXI_ACLK = ~M_AXI_ACLK;
end 

task WAIT( input [31:0] cycles);
    integer i;
    begin
        for (i = 0; i < cycles; i = i + 1)
            @(posedge M_AXI_ACLK);
    end
endtask


initial begin
    WAIT(2);

    M_AXI_ARESETN = 1;

    @(posedge M_AXI_ACLK);

    addr = 32'h0000_0000;
    write_data = 32'hDEAD_BEEF;
    start_write = 1;
    @(posedge M_AXI_ACLK);
    start_write = 0;

    @(posedge M_AXI_ACLK);
    @(posedge done);

    addr = 32'h0000_0004;
    write_data = 32'hABCD_0123;
    start_write = 1;
    @(posedge M_AXI_ACLK);
    start_write = 0;

    @(posedge M_AXI_ACLK);
    @(posedge done);

    addr = 32'h0000_0000;
    start_read = 1;
    @(posedge M_AXI_ACLK);
    start_read = 0;

    @(posedge M_AXI_ACLK);
    @(posedge done);

    addr = 32'h0000_0004;
    start_read = 1;
    @(posedge M_AXI_ACLK);
    start_read = 0;

    @(posedge M_AXI_ACLK);
    @(posedge done);

    $finish;

end



endmodule