`timescale 1ns / 1ps
module axi_cfg_regs
#(
// parameter C_S_AXI_ACLK_FREQ_HZ = 100000000,
parameter C_S_AXI_DATA_WIDTH = 32,
parameter C_S_AXI_ADDR_WIDTH = 30 
)
(
    input busy,

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

    output [29:0] mem_addr, // Valid Addr Range: 0x4000_0000 - 0x7FFF_FFFF
    output mem_wen,
    output [C_S_AXI_DATA_WIDTH - 1:0] mem_data_in,
    input [C_S_AXI_DATA_WIDTH - 1:0] mem_data_out,

    output reg S_AXI_AWREADY, 
    output reg S_AXI_ARREADY, 
    output reg S_AXI_WREADY,  
    output reg [C_S_AXI_DATA_WIDTH - 1:0] S_AXI_RDATA,
    output reg [1:0] S_AXI_RRESP,
    output reg S_AXI_RVALID,  
    output reg [1:0] S_AXI_BRESP,
    output reg S_AXI_BVALID,  

    input [31:0] debug_in,

    output [31:0] debug,
    output [31:0] ctrl,
    output [31:0] num_init_samples,
    output [31:0] num_init_steps,
    output [31:0] num_train_samples,
    output [31:0] num_train_steps,
    output [31:0] num_test_samples,
    output [31:0] num_test_steps,
    output [31:0] num_steps_per_sample
);

reg num_train_samples_reg_valid = 0;
reg [31:0] num_train_samples_reg = 0;

reg num_test_samples_reg_valid = 0;
reg [31:0] num_test_samples_reg = 0;

reg num_init_samples_reg_valid = 0;
reg [31:0] num_init_samples_reg = 0;

reg num_init_steps_reg_valid = 0;
reg [31:0] num_init_steps_reg = 0;

reg num_train_steps_reg_valid = 0;
reg [31:0] num_train_steps_reg = 0;

reg num_test_steps_reg_valid = 0;
reg [31:0] num_test_steps_reg = 0;

reg num_steps_per_sample_reg_valid = 0;
reg [31:0] num_steps_per_sample_reg = 0;

reg [31:0] debug_reg = 0;
reg  debug_reg_addr_valid = 0;

reg [31:0] ctrl_reg;
reg ctrl_reg_addr_valid = 0;

reg mem_reg_addr_valid = 0;

reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

reg [29:0] local_address = 0;
reg local_address_valid = 1;

wire [1:0] combined_S_AXI_AWVALID_S_AXI_ARVALID;

reg write_enable_registers = 0;
reg send_read_data_to_AXI = 0;

wire Local_Reset;


localparam reset = 0, idle = 1, read_transaction_in_progress = 2, write_transaction_in_progress = 3, mem_read_transaction_done_stage = 4, complete = 5;

assign Local_Reset = ~S_AXI_ARESETN;
assign combined_S_AXI_AWVALID_S_AXI_ARVALID = {S_AXI_AWVALID, S_AXI_ARVALID};
assign debug = debug_reg;
assign ctrl = ctrl_reg;

always @ (posedge S_AXI_ACLK) begin
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
            next_state = mem_read_transaction_done_stage;
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
        mem_read_transaction_done_stage:
        begin
            next_state = mem_read_transaction_done_stage;
            S_AXI_ARREADY = S_AXI_ARVALID;
            S_AXI_RVALID = 1;
            S_AXI_RRESP = 2'b00;
            send_read_data_to_AXI = 1;
            if (S_AXI_RREADY == 1) 
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
        debug_reg, 
        ctrl_reg, 
        mem_data_out,
        num_train_samples_reg,
        num_test_samples_reg,
        num_init_samples_reg,
        num_steps_per_sample_reg,
        num_train_steps_reg,
        num_test_steps_reg,
        num_init_steps_reg
        )
begin
    S_AXI_RDATA = 32'b0;

    if (local_address_valid == 1 && send_read_data_to_AXI == 1)
    begin
        case(local_address)
            16'h0000:
                S_AXI_RDATA = ctrl_reg;
            16'h0004:
                S_AXI_RDATA = debug_reg;
            16'h0008:
                S_AXI_RDATA = num_init_samples_reg;
            16'h000C:
                S_AXI_RDATA = num_train_samples_reg;
            16'h0010:
                S_AXI_RDATA = num_test_samples_reg;
            16'h0014:
                S_AXI_RDATA = num_steps_per_sample_reg;
            16'h0018:
                S_AXI_RDATA = num_init_steps_reg;
            16'h001C:
                S_AXI_RDATA = num_train_steps_reg;
            16'h0020:
                S_AXI_RDATA = num_test_steps_reg;
            default:
                S_AXI_RDATA = mem_data_out;
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
                    local_address = S_AXI_AWADDR[29:0];
                2'b01:     
                    local_address = S_AXI_ARADDR[29:0];
            endcase
        end
    end
end

// write data address analysis
always @(local_address,write_enable_registers)
begin
    
    ctrl_reg_addr_valid = 0;
    debug_reg_addr_valid = 0;
    num_init_samples_reg_valid = 0;
    num_train_samples_reg_valid = 0;
    num_test_samples_reg_valid = 0;
    num_steps_per_sample_reg_valid = 0;
    num_init_steps_reg_valid = 0;
    num_train_steps_reg_valid = 0;
    num_test_steps_reg_valid = 0;


    local_address_valid = 1;

    if (write_enable_registers)
    begin
        case (local_address)
            30'h0000_0000:
                ctrl_reg_addr_valid = 1;
            30'h0000_0004:
                debug_reg_addr_valid = 1;
            30'h0000_0008:
                num_init_samples_reg_valid = 1;
            30'h0000_000C:
                num_train_samples_reg_valid = 1;
            30'h0000_0010:
                num_test_samples_reg_valid = 1;
            30'h0000_0014:
                num_steps_per_sample_reg_valid = 1;
            30'h0000_0018:
                num_init_steps_reg_valid = 1;
            30'h0000_001C:
                num_train_steps_reg_valid = 1;
            30'h0000_0020:
                num_test_steps_reg_valid = 1;
            default:
            begin
                //mem_reg_addr_valid = 1;
                local_address_valid = 1;
            end
        endcase
    end
end

// ctrl_reg
always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        ctrl_reg = 0;
    else
    begin
        // BIT 0: Start Bit
        // BIT 1: Busy Bit
        // BIT [7:4]: MEM_SEL Bits
        // BIT [15:8]: Upper 8 MEM BITS
        if(ctrl_reg_addr_valid)
            ctrl_reg = {S_AXI_WDATA[31:2],busy,S_AXI_WDATA[0]};
        else begin
            ctrl_reg[1] = busy;
            ctrl_reg[0] = 0;
        end
    end
end

// debug_reg
always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        debug_reg = 0;
    else
    begin
        // LED Controls
        // BIT 0: IF ACTIVE, then display char information on LEDs, ELSE display network output on LEDS
        // BIT 1: IF ACTIVE, then display direct_ctrl_reg values on LEDS, ELSE display char_pwm_gen outputs on LEDS 
        // Output Controls
        // BIT 2: Use direct_ctrl_reg value as digit outputs ELSE use char_pwm_gen
        // BIT 3: Use slow 1HZ Clock
        // BIT 4: Use 1-Hot Encoding for XADC Multiplexer
        // BIT 5: debug_reg[5] output on XADC header GPIO3
        //if(debug_reg_addr_valid)
        //    debug_reg = S_AXI_WDATA;
        debug_reg = debug_in;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_init_samples_reg = 0;
    else
    begin
        if(num_init_samples_reg_valid)
            num_init_samples_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_train_samples_reg = 0;
    else
    begin
        if(num_train_samples_reg_valid)
            num_train_samples_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_test_samples_reg = 0;
    else
    begin
        if(num_test_samples_reg_valid)
            num_test_samples_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_steps_per_sample_reg = 0;
    else
    begin
        if(num_steps_per_sample_reg_valid)
            num_steps_per_sample_reg = S_AXI_WDATA;
    end
end


always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_init_steps_reg = 0;
    else
    begin
        if(num_init_steps_reg_valid)
            num_init_steps_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_train_steps_reg = 0;
    else
    begin
        if(num_train_steps_reg_valid)
            num_train_steps_reg = S_AXI_WDATA;
    end
end

always @(posedge S_AXI_ACLK)
begin
    if (Local_Reset)
        num_test_steps_reg = 0;
    else
    begin
        if(num_test_steps_reg_valid)
            num_test_steps_reg = S_AXI_WDATA;
    end
end

// TODO: Attempt to insert a write buffer

// mem access
assign mem_wen = write_enable_registers && (local_address[29:24] > 0);
assign mem_data_in = S_AXI_WDATA;
// assign mem_addr[15:8] = ctrl_reg[15:8];
// assign mem_addr[7:0] = (combined_S_AXI_AWVALID_S_AXI_ARVALID[1]) ? S_AXI_AWADDR[7:0] : ( (combined_S_AXI_AWVALID_S_AXI_ARVALID[0]) ? S_AXI_ARADDR[7:0] : 8'h00);
assign mem_addr[29:0] = (combined_S_AXI_AWVALID_S_AXI_ARVALID[1]) ? {2'h0,S_AXI_AWADDR[29:2]} : ( (combined_S_AXI_AWVALID_S_AXI_ARVALID[0]) ? {2'h0,S_AXI_ARADDR[29:2]} : 30'h00);

assign num_init_samples = num_init_samples_reg;
assign num_train_samples = num_train_samples_reg;
assign num_test_samples = num_test_samples_reg;
assign num_steps_per_sample = num_steps_per_sample_reg;
assign num_init_steps = num_init_steps_reg;
assign num_train_steps = num_train_steps_reg;
assign num_test_steps = num_test_steps_reg;

endmodule