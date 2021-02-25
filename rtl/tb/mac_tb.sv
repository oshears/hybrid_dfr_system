`timescale 1ns / 1ps

module mac_tb;

localparam DATA_WIDTH = 32;

reg clk = 0;
reg rst = 0;
reg [DATA_WIDTH - 1 : 0] a = 0;
reg [DATA_WIDTH - 1 : 0] b = 0;
reg start = 0;
wire [DATA_WIDTH - 1 : 0] dout;
wire busy;

integer i = 0;
integer expect_data = 0;

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

    for (i = 0; i < 10; i = i + 1) begin
        @(posedge clk);
        a = i;
        b = i;
        start = 1;
        @(posedge clk);
        start = 0;
        @(negedge busy);

        expect_data = expect_data + (i * i);
        if (dout != expect_data)
            $display("Error: Expected: %h Actual: %h",expect_data,dout);

    end
    

    $finish;
end

endmodule