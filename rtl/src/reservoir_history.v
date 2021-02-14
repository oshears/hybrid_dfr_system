`timescale 1ns / 1ps

module reservoir_history
# (
MEM_SIZE = 2**20, //1048576
ADDR_WIDTH = 20,
DATA_WIDTH = 32
)
(
    input clk,
    input wen,
    input [ADDR_WIDTH - 1 : 0] addr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

reg [DATA_WIDTH - 1 : 0] mem [MEM_SIZE - 1:0];

always @(posedge clk)
begin
    if (wen)
        mem <= din;

    dout <= mem[addr];
end

endmodule;