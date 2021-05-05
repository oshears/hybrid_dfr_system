`timescale 1ns / 1ps
module axi_master_top #(
parameter C_M_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_M_AXI_DATA_WIDTH = 32,
parameter C_M_AXI_ADDR_WIDTH = 32
)
(
    input BTN,

    input M_AXI_ACLK,
    input M_AXI_ARESETN,
    input M_AXI_AWREADY, 
    input M_AXI_ARREADY, 
    input M_AXI_WREADY,  
    input [C_M_AXI_DATA_WIDTH - 1:0] M_AXI_RDATA,
    input [1:0] M_AXI_RRESP,
    input M_AXI_RVALID,  
    input [1:0] M_AXI_BRESP,
    input M_AXI_BVALID,  

    output reg [C_M_AXI_ADDR_WIDTH - 1:0] M_AXI_AWADDR, 
    output reg M_AXI_AWVALID,
    output reg [C_M_AXI_ADDR_WIDTH - 1:0] M_AXI_ARADDR, 
    output reg M_AXI_ARVALID,
    output reg [C_M_AXI_DATA_WIDTH - 1:0] M_AXI_WDATA,  
    output reg [(C_M_AXI_DATA_WIDTH/8 - 1):0] M_AXI_WSTRB,  
    output reg M_AXI_WVALID, 
    output reg M_AXI_RREADY, 
    output reg M_AXI_BREADY, 

    output reg [7:0] LEDS
);


axi_master #(C_M_AXI_ACLK_FREQ_HZ,C_M_AXI_DATA_WIDTH,C_M_AXI_ADDR_WIDTH) axi_master
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

localparam IDLE_STATE = 0, WRITE_STATE = 1, READ_STATE = 2;

reg [2:0] current_state = 0, next_state = 0;

reg [31:0] addr = 0, write_data = 0, read_data = 0;
reg start_write = 0, start_read = 0;
wire done;

reg [7:0] counter = 0;

wire Local_Reset = ~M_AXI_ARESETN;


always @(posedge M_AXI_ACLK, posedge Local_Reset) begin
    if (Local_Reset) begin
        current_state = IDLE_STATE;
    end
    else begin
        current_state = next_state;
    end
end

always @(
    current_state,
    BTN,
    done
) begin

    // addr = 0;
    // write_data = 0;
    start_write = 0;
    start_read = 0;

    next_state = current_state;

    case(current_state)
        IDLE: begin
            if (BTN) begin
                addr = 0;
                write_data = counter;
                start_write = 1;
                next_state = WRITE_STATE;
            end
        end
        WRITE_STATE: begin
            if (done) begin
                addr = 0;
                start_read = 1;
                next_state = READ_STATE;
            end
        end
        READ_STATE: begin
            if (done) begin
                counter = counter + 1;
                LEDS = read_data;
                next_state = IDLE;
            end
        end
        default:
            next_state = IDLE;    
    endcase

end


endmodule