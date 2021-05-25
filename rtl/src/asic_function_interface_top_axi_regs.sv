`timescale 1ns / 1ps
module asic_function_interface_top_axi_regs
#(
parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_S_AXI_DATA_WIDTH = 32,
parameter C_S_AXI_ADDR_WIDTH = 9 
)
(
    input S_AXI_ACLK,
    input S_AXI_ARESETN,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_AWADDR, 
    input S_AXI_AWVALID,
    input [C_S_AXI_ADDR_WIDTH - 1:0] S_AXI_ARADDR, 
    input S_AXI_ARVALID,
    input [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_WDATA,  
    input [(C_S_AXI_DATA_WIDTH/8 - 1):0] S_AXI_WSTRB,  
    input S_AXI_WVALID, 
    input S_AXI_RREADY, 
    input S_AXI_BREADY, 

    output reg S_AXI_AWREADY, 
    output reg S_AXI_ARREADY, 
    output reg S_AXI_WREADY,  
    output reg [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,  
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,  

    input [31:0] asic_data_in,
    input done,
    output [31:0] asic_data_out,
    output [31:0] ctrl,
    input [31:0] debug_in
);

reg [31:0] asic_data_in_reg = 0;
reg  asic_data_in_reg_addr_valid = 0;

reg [31:0] asic_data_out_reg;
reg asic_data_out_reg_addr_valid = 0;

reg [31:0] ctrl_reg;
reg ctrl_reg_addr_valid = 0;

reg [31:0] debug_reg;
reg debug_reg_addr_valid = 0;

reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

reg [15:0] local_address = 0;
reg local_address_valid = 1;

wire [1:0] combined_S_AXI_AWVALID_S_AXI_ARVALID;

reg write_enable_registers = 0;
reg send_read_data_to_AXI = 0;

wire Local_Reset;


localparam reset = 0, idle = 1, read_transaction_in_progress = 2, write_transaction_in_progress = 3, complete = 4;

assign Local_Reset = ~S_AXI_ARESETN;
assign combined_S_AXI_AWVALID_S_AXI_ARVALID = {S_AXI_AWVALID, S_AXI_ARVALID};

always @ (posedge S_AXI_ACLK or posedge Local_Reset) begin
    if (Local_Reset)
        current_state <= reset;
    else
        current_state <= next_state;

end

// main AXI state machine
always @ (current_state, combined_S_AXI_AWVALID_S_AXI_ARVALID, S_AXI_ARVALID, S_AXI_RREADY, S_AXI_AWVALID, S_AXI_WVALID, S_AXI_BREADY, local_address, local_address_valid) begin
    S_AXI_ARREADY = 0;
    S_AXI_RRESP = 2'b00;
    S_AXI_RVALID = 0;
    S_AXI_WREADY = 0;
    S_AXI_BRESP = 2'b00;
    S_AXI_BVALID = 0;
    S_AXI_WREADY = 0;
    S_AXI_AWREADY = 0;
    write_enable_registers = 0;
    send_read_data_to_AXI = 0;
    next_state = current_state;

    case (current_state)
        reset:
            next_state = idle;
        idle:
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID)
                2'b01:
                    next_state = read_transaction_in_progress;
                2'b10:
                    next_state = write_transaction_in_progress;
            endcase
        end
        read_transaction_in_progress:
        begin
            next_state = read_transaction_in_progress;
            S_AXI_ARREADY = S_AXI_ARVALID;
            S_AXI_RVALID = 1;
            S_AXI_RRESP = 2'b00;
            send_read_data_to_AXI = 1;
            if (S_AXI_RREADY == 1) 
                next_state = complete;
        end
        write_transaction_in_progress:
        begin
            next_state = write_transaction_in_progress;
			write_enable_registers = 1;
            S_AXI_AWREADY = S_AXI_AWVALID;
            S_AXI_WREADY = S_AXI_WVALID;
            S_AXI_BRESP = 2'b00;
            S_AXI_BVALID = 1;
			if (S_AXI_BREADY == 1)
			    next_state = complete;
        end
        complete:
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID) 
				2'b00:
                     next_state = idle;
				default:
                    next_state = complete;
			endcase;
        end
    endcase
end

// send data to AXI RDATA
always @(send_read_data_to_AXI, 
        local_address, 
        local_address_valid, 
        asic_data_in_reg, 
        asic_data_out_reg,
        ctrl_reg,
        debug_reg
        )
begin
    S_AXI_RDATA = 32'b0;

    if (local_address_valid == 1 && send_read_data_to_AXI == 1)
    begin
        case(local_address)
            16'h0000:
                S_AXI_RDATA = ctrl_reg;
            16'h0004:
                S_AXI_RDATA = asic_data_out_reg;
            16'h0008:
                S_AXI_RDATA = asic_data_in_reg;
            16'h000C:
                S_AXI_RDATA = debug_reg;
            default:
                S_AXI_RDATA = 32'h0;
        endcase;     
    end
end

// local address capture
always  @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        local_address = 0;
    else
    begin
        if (local_address_valid == 1)
        begin
            case (combined_S_AXI_AWVALID_S_AXI_ARVALID)
                2'b10:
                    local_address = S_AXI_AWADDR[15:0];
                2'b01:     
                    local_address = S_AXI_ARADDR[15:0];
            endcase
        end
    end
end

// write data address analysis
always @(local_address,write_enable_registers)
begin
    
    ctrl_reg_addr_valid = 0;
    asic_data_out_reg_addr_valid = 0;
    asic_data_in_reg_addr_valid = 0;
    debug_reg_addr_valid = 0;

    local_address_valid = 1;

    if (write_enable_registers)
    begin
        case (local_address)
            16'h0000:
                ctrl_reg_addr_valid = 1;
            16'h0004:
                asic_data_out_reg_addr_valid = 1;
            16'h0008:
                asic_data_in_reg_addr_valid = 1;
            16'h000C:
                debug_reg_addr_valid = 1;
            default:
            begin
                local_address_valid = 0;
            end
        endcase
    end
end

// asic_data_out_reg
always @(posedge S_AXI_ACLK, posedge Local_Reset)
begin
    if (Local_Reset) begin
        ctrl_reg[31:2] = 0;
        ctrl_reg[0] = 0;
    end
    else
    begin
        if(ctrl_reg_addr_valid) begin
            ctrl_reg[31:2] = S_AXI_WDATA[31:2];
            ctrl_reg[1] = done;
            ctrl_reg[0] = S_AXI_WDATA[0];
        end
        else begin
            ctrl_reg[1] = done;
            ctrl_reg[0] = 0;
        end
    end
end

// asic_data_out_reg
always @(posedge S_AXI_ACLK, posedge Local_Reset)
begin
    if (Local_Reset)
        asic_data_out_reg = 0;
    else
    begin
        if(asic_data_out_reg_addr_valid)
            asic_data_out_reg = S_AXI_WDATA[31:0];
    end
end

// asic_data_in_reg
always @(posedge S_AXI_ACLK, posedge Local_Reset)
begin
    if (Local_Reset)
        asic_data_in_reg = 0;
    else
    begin
        asic_data_in_reg = asic_data_in;
    end
end

always @(posedge S_AXI_ACLK)
begin
   debug_reg = debug_in; 
end

assign asic_data_out = asic_data_out_reg;
assign ctrl = ctrl_reg;

endmodule