`timescale 1ns / 1ps

module reservoir_tb;

localparam VIRTUAL_NODES = 10;
localparam DATA_WIDTH = 32;

reg clk = 0;
reg rst = 0;
reg [DATA_WIDTH - 1 : 0] din = 0;
wire [DATA_WIDTH - 1 : 0] dout;

integer i = 0;

reservoir 
#(
    .VIRTUAL_NODES(VIRTUAL_NODES),
    .DATA_WIDTH(DATA_WIDTH)
)
uut
(
    .clk(clk),
    .rst(rst),
    .din(din),
    .dout(dout)
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
    
    for(i = 0; i < 100; i = i + 1) begin
        din = din + 32'h028F_5C29;
        #2;
    end

    $finish;
end

endmodule;