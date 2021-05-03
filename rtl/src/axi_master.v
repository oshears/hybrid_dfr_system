`timescale 1ns / 1ps
module axi_master
#(
parameter C_M_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_M_AXI_DATA_WIDTH = 32,
parameter C_M_AXI_ADDR_WIDTH = 32
)
(

    input [31:0] addr,
    input [31:0] write_data,
    input start_read,
    input start_write,


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

    output reg done,
    output reg [31:0] read_data = 0
);

reg [2:0] current_state = 0, next_state = 0;

wire Local_Reset = ~M_AXI_ARESETN;

localparam READY_STATE = 0, WRITE_REQ_STATE = 1, WRITE_PENDING_STATE = 2, WRITE_VALID_STATE = 3, READ_REQ_STATE = 4, READ_PENDING_STATE = 5, READ_VALID_STATE = 6;

always @(posedge M_AXI_ACLK, posedge Local_Reset) begin
    if (Local_Reset) begin
        current_state = READY_STATE;
    end
    else begin
        current_state = next_state;
    end
end

always @(posedge M_AXI_ACLK) begin
    if (start_write) begin
        M_AXI_AWADDR = addr;
        M_AXI_WDATA = write_data;
    end
    if (start_read) begin
        M_AXI_ARADDR = addr;
    end
end

always @(
    current_state,
    M_AXI_AWREADY, 
    M_AXI_ARREADY, 
    M_AXI_WREADY,  
    M_AXI_RDATA,
    M_AXI_RRESP,
    M_AXI_RVALID,  
    M_AXI_BRESP,
    M_AXI_BVALID,  
    start_read,
    start_write
) begin

    M_AXI_AWVALID = 0;
    M_AXI_ARVALID = 0;
    M_AXI_WSTRB   = 0;  
    M_AXI_WVALID  = 0; 
    M_AXI_RREADY  = 0; 
    M_AXI_BREADY  = 0; 

    done = 0;
    // read_data = 0;

    next_state = current_state;

    case (current_state)
        READY_STATE:
        begin
            if (start_write) begin
                done = 0;
                next_state = WRITE_REQ_STATE;
            end
            else if (start_read) begin
                done = 0;
                next_state = READ_REQ_STATE;
            end
            else
                done = 1;
        end
        WRITE_REQ_STATE:
        begin
            M_AXI_AWVALID = 1;
            M_AXI_WVALID = 1;
            M_AXI_BREADY = 1;
            if (M_AXI_WREADY) begin
                next_state = WRITE_PENDING_STATE;
            end
        end
        WRITE_PENDING_STATE:
        begin
            M_AXI_AWVALID = 1;
            M_AXI_WVALID = 1;
            M_AXI_BREADY = 1;
            next_state = WRITE_VALID_STATE;
        end
        WRITE_VALID_STATE:
        begin
            next_state = READY_STATE;
        end
        READ_REQ_STATE:
        begin
            M_AXI_ARVALID = 1;
            if (M_AXI_RVALID) begin
                next_state = READ_PENDING_STATE;
            end
        end
        READ_PENDING_STATE:
        begin
            M_AXI_ARVALID = 1;
            next_state = READ_VALID_STATE;
        end
        READ_VALID_STATE:
        begin
            M_AXI_RREADY = 1;
            next_state = READY_STATE;
            read_data = M_AXI_RDATA;
        end
        default:
        begin
            next_state = READY_STATE;
        end
    endcase
    
end

endmodule