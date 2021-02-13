`timescale 1ns / 1ps

module reservoir_tb;

reg clk = 0;
reg rst = 0;
reg din = 0;
wire dout;

reservoir 
#(
    .VIRTUAL_NODES(10),
)
reservoir
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
        din = i;
        #1;
    end

    $finish;
end

endmodule;