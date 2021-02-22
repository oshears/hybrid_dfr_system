`timescale 1ns / 1ps

module mac_tb;

localparam DATA_WIDTH = 32;

reg clk = 0;
reg rst = 0;
reg [DATA_WIDTH - 1 : 0] a = 0;
reg [DATA_WIDTH - 1 : 0] b = 0;
wire [DATA_WIDTH - 1 : 0] dout;
wire busy;

mac 
#(
    .DATA_WIDTH(DATA_WIDTH)
)
uut
(
    .clk(clk),
    .rst(rst),
    .a(a),
    .b(b),
    .start(start),
    .dout(dout),
    .busy(busy)
);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end 

initial begin
    rst = 1;
    #10;
    rst = 0;
    #100;
    
    a = 5;
    b = 3;
    start = 1;
    #1;
    @(negedge busy);

    $finish;
end

endmodule