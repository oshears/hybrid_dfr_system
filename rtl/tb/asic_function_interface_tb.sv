`timescale 1ns / 1ps

module asic_function_interface_tb;

localparam DATA_WIDTH = 32;

reg clk = 0;
reg rst = 0;
reg start = 0;
reg [15:0] data_in = 0;
wire vp_in;
wire vn_in;
wire xadc_data_valid;
wire [15:0] xadc_data_out;
wire dac_cs_n;
wire dac_ldac_n;
wire dac_din;
wire dac_sclk;

integer i = 0;
integer expect_data = 0;

asic_function_interface asic_function_interface 
(
    // SoC Ports
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .start(start),
    .xadc_data_valid(xadc_data_valid),
    .xadc_data_out(xadc_data_out),
    // XADC Pins
    .vp_in(vp_in),
    .vn_in(vn_in),
    // DAC Pins
    .dac_cs_n(dac_cs_n),
    .dac_ldac_n(dac_ldac_n),
    .dac_din(dac_din),
    .dac_sclk(dac_sclk)
);

// 10MHz Clock
initial begin
    clk = 0;
    forever #50 clk = ~clk;
end 

initial begin
    rst = 1;
    #10;
    rst = 0;

    #7000;

    @(posedge clk);

    for (i = 0; i < 15; i = i + 1) begin
        
        start = 1;
        data_in = (16'h0001 << i);
        @(posedge clk);
        start = 0;
        @(posedge xadc_data_valid);

    end
    

    $finish;
end

endmodule