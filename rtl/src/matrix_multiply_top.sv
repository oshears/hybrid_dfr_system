module matrix_multiply_top
# (
    ADDR_WIDTH = 32,
    DATA_WIDTH = 32,
    X_ROWS = 5,
    Y_COLS = 5,
    X_COLS_Y_ROWS = 5
)
(
    input clk,
    input rst,
    input start,
    input [ADDR_WIDTH - 1 : 0] ram_addr,
    input ram_wen,
    input [1:0] ram_sel,
    input [DATA_WIDTH - 1 : 0] ram_data_in,
    output busy,
    output [DATA_WIDTH - 1 : 0] ram_data_out
);


wire [ADDR_WIDTH - 1 : 0] x_addr;
wire [ADDR_WIDTH - 1 : 0] y_addr;
wire [ADDR_WIDTH - 1 : 0] z_addr;
wire [DATA_WIDTH - 1 : 0] x_data_in;
wire [DATA_WIDTH - 1 : 0] y_data_in;
wire [DATA_WIDTH - 1 : 0] z_data_in;
wire [DATA_WIDTH - 1 : 0] x_data_out;
wire [DATA_WIDTH - 1 : 0] y_data_out;
wire [DATA_WIDTH - 1 : 0] z_data_out;
wire x_wen;
wire y_wen;
wire z_wen;

wire [ADDR_WIDTH - 1 : 0] x_addr_i;
wire [ADDR_WIDTH - 1 : 0] y_addr_i;
wire [ADDR_WIDTH - 1 : 0] z_addr_i;
wire [DATA_WIDTH - 1 : 0] z_data_i;
wire z_wen_i;

assign x_addr = (~busy && ram_sel == 2'b00) ? ram_addr : x_addr_i; 
assign y_addr = (~busy && ram_sel == 2'b01) ? ram_addr : y_addr_i; 
assign z_addr = (~busy && ram_sel == 2'b10) ? ram_addr : z_addr_i; 

assign x_data_in = (~busy && ram_sel == 2'b00) ? ram_data_in : 32'h0; 
assign y_data_in = (~busy && ram_sel == 2'b01) ? ram_data_in : 32'h0; 
assign z_data_in = (~busy && ram_sel == 2'b10) ? ram_data_in : z_data_i; 

assign x_wen = (~busy && ram_sel == 2'b00) ? ram_wen : 32'h0; 
assign y_wen = (~busy && ram_sel == 2'b01) ? ram_wen : 32'h0; 
assign z_wen = (~busy && ram_sel == 2'b10) ? ram_wen : z_wen_i; 

assign ram_data_out = (ram_sel == 2'b10) ? z_data_out : ( (ram_sel == 2'b01) ? y_data_out : x_data_out );

matrix_multiplier_v2
# (
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
)
matrix_multiplier
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .busy(busy),
    .x_data(x_data_out),
    .y_data(y_data_out),
    .x_addr(x_addr_i),
    .y_addr(y_addr_i),
    .z_addr(z_addr_i),
    .z_data(z_data_i),
    .z_wen(z_wen_i),
    .x_rows(X_ROWS[ADDR_WIDTH - 1:0]),
    .y_cols(Y_COLS[ADDR_WIDTH - 1:0]),
    .x_cols_y_rows(X_COLS_Y_ROWS[ADDR_WIDTH - 1:0])
);

ram 
#(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) 
x_ram
(
    .clk(clk),
    .wen(x_wen),
    .addr(x_addr),
    .din(x_data_in),
    .dout(x_data_out)
);

ram 
#(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) 
y_ram
(
    .clk(clk),
    .wen(y_wen),
    .addr(y_addr),
    .din(y_data_in),
    .dout(y_data_out)
);

ram 
#(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) 
z_ram
(
    .clk(clk),
    .wen(z_wen),
    .addr(z_addr),
    .din(z_data_in),
    .dout(z_data_out)
);

endmodule