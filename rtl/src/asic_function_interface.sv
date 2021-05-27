`timescale 1ns / 1ps
module asic_function_interface
#(
    parameter DELAY = 16
)
(
    input wire clk,
    input wire rst,
    input wire start,
    input wire [15:0] data_in,
    input wire vp_in,
    input wire vn_in,
    output reg xadc_data_valid,
    output reg [15:0] xadc_data_out,
    output reg dac_cs_n,
    output reg dac_ldac_n,
    output reg dac_din,
    output reg dac_sclk,

    // output reg [15:0] asic_outputs [2 ** 15 - 1: 0]
    // Debug
    output wire [2:0] current_state_out,
    output wire [8:0] avg_cntr_out,
    output wire [1:0] dbg
);


localparam  IDLE = 0, 
            DAC_PHASE = 1, 
            SETTLING_PHASE = 2, 
            XADC_CONVERT_PHASE_START = 3, 
            XADC_CONVERT_PHASE_WAIT = 4, 
            XADC_CONVERT_PHASE_DONE = 5, 
            XADC_READY_PHASE = 6,
            XADC_READ_REQ_PHASE = 7, 
            XADC_READ_WAIT_PHASE = 8,
            XADC_READ_DONE_PHASE = 9;

reg [3:0] current_state;
reg [3:0] next_state;

// ASIC Delay Counter
wire delay_cntr_rst;
wire delay_cntr_en;
wire [15:0] delay_cntr;
wire delay_cntr_done = delay_cntr >= DELAY;


// PMOD DAC Signals
reg pmod_dac_start = 0;
wire pmod_dac_busy;

// XADC Signals
reg [6:0] daddr_in = 0;
reg den_in = 0;
reg [15:0] di_in = 0;
reg convst_in = 0;
reg dwe_in = 0;

wire [15:0] do_out;
wire drdy_out;
wire channel_out;
wire eoc_out;
wire eos_out;
wire alarm_out;
wire busy_out;

wire [8:0] avg_cntr;
reg avg_cntr_rst = 0;
reg avg_cntr_en = 0;
wire avg_cntr_done = (avg_cntr == 9'h100) ? 1'b1 : 1'b0;

reg eoc_out_reg = 0;
reg eoc_out_rst = 0;
reg eos_out_reg = 0;
reg eos_out_rst = 0;

assign current_state_out = current_state;
assign avg_cntr_out = avg_cntr;
assign dbg = {eoc_out_reg,eos_out_reg};


counter #(9) xadc_avg_and_settling_counter
(
    .clk(clk),
    .en(avg_cntr_en),
    .rst(avg_cntr_rst),
    .dout(avg_cntr)
);

always @(posedge clk, posedge rst) begin
    if (rst)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always @(
    current_state,
    start,
    pmod_dac_busy,
    eoc_out_reg,
    eos_out_reg,
    eoc_out,
    eos_out,
    drdy_out,
    busy_out,
    avg_cntr_done
) begin
    pmod_dac_start = 0;

    daddr_in = 0;
    den_in = 0;
    di_in = 0;
    convst_in = 0;

    avg_cntr_en = 0;
    avg_cntr_rst = 0;

    xadc_data_valid = 0;

    eos_out_rst = 0;
    eoc_out_rst = 0;

    next_state = current_state;

    case (current_state)
    IDLE:
    begin
        xadc_data_valid = 1;
        if (start) begin
            pmod_dac_start = 1;
            next_state = DAC_PHASE;
        end
    end
    DAC_PHASE:
    begin
        if (~pmod_dac_busy && ~busy_out) begin
            next_state = SETTLING_PHASE;
        end
    end
    SETTLING_PHASE:
    begin
        if (avg_cntr_done) begin
            avg_cntr_rst = 1;
            next_state = XADC_CONVERT_PHASE_START;
        end
        else begin
            avg_cntr_en = 1;
            next_state = SETTLING_PHASE;
        end
    end
    XADC_CONVERT_PHASE_START:
    begin
        // convst_in = 1;
        // avg_cntr_en = 1;
        if (eoc_out || eos_out) begin
            next_state = XADC_CONVERT_PHASE_WAIT;
        end
    end
    XADC_CONVERT_PHASE_WAIT:
    begin
        // Wait for XADC to go busy
        if (eoc_out || eos_out) begin
            pmod_dac_start = 1;
            next_state = XADC_CONVERT_PHASE_DONE;
        end
    end
    XADC_CONVERT_PHASE_DONE:
    begin
        if (avg_cntr_done) begin
            avg_cntr_rst = 1;
            next_state = XADC_READY_PHASE;
        end
        else begin
            avg_cntr_en = 1;
            next_state = XADC_CONVERT_PHASE_DONE;
        end
    end
    XADC_READY_PHASE:
    begin
        if (eoc_out || eos_out) begin
            pmod_dac_start = 1;
            next_state = XADC_READ_REQ_PHASE;
        end
    end
    XADC_READ_REQ_PHASE:
    begin
        if (eoc_out || eos_out) begin
            pmod_dac_start = 1;
            next_state = XADC_READ_WAIT_PHASE;
        end
    end
    XADC_READ_WAIT_PHASE:
    begin
        daddr_in = 7'h03;
        den_in = 1;
        next_state = XADC_READ_DONE_PHASE;
    end
    XADC_READ_DONE_PHASE:
    begin
        if (drdy_out) begin
            next_state = IDLE;
        end
    end
    default:
    begin
        next_state = IDLE;
    end
    endcase
end

always @(posedge clk) begin
    if (eos_out_rst) begin
        eos_out_reg = 0;
    end
    else if (eos_out) begin
        eos_out_reg = 1;
    end
end

always @(posedge clk) begin
    if (eoc_out_rst) begin
        eoc_out_reg = 0;
    end
    else if (eoc_out) begin
        eoc_out_reg = 1;
    end
end

counter #(16) delay_counter
(
    .clk(clk),
    .en(delay_cntr_en),
    .rst(delay_cntr_rst),
    .dout(delay_cntr)
);

register #(16) xadc_output_reg
(
    .clk(clk),
    .rst(rst),
    .en(drdy_out),
    .din(do_out),
    .dout(xadc_data_out)
);

pmod_dac_block #(16) pmod_dac_block
(
    // SoC Inputs
    .clk(clk),
    .rst(rst),
    .din(data_in),
    .start(pmod_dac_start),
    // SoC Outputs
    .dout(),
    .busy(pmod_dac_busy),
    // PMOD DAC Outputs
    .dac_cs_n(dac_cs_n),
    .dac_ldac_n(dac_ldac_n),
    .dac_din(dac_din),
    .dac_sclk(dac_sclk)
);



xadc_wiz_0 xadc_inst (// Connect up instance IO. See UG480 for port descriptions
    .daddr_in  (daddr_in),
    .dclk_in   (clk),
    .den_in    (den_in),
    .di_in     (di_in),
    .dwe_in    (dwe_in),
    .reset_in  (rst),
    // .convst_in(convst_in),
    .busy_out   (busy_out),
    .do_out     (do_out),
    .drdy_out   (drdy_out),
    .eos_out    (eos_out),
    .vn_in     (vn_in),
    .vp_in     (vp_in),
    .alarm_out(),
    .channel_out(),
    .eoc_out(eoc_out)
);

endmodule