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
    output reg xadc_data_valid = 0,
    output reg [15:0] xadc_data_out = 0,
    output reg dac_cs_n = 0,
    output reg dac_ldac_n = 0,
    output reg dac_din = 0,
    output reg dac_sclk = 0

    // output reg [15:0] asic_outputs [2 ** 15 - 1: 0]
);


localparam IDLE = 0, DAC_PHASE = 1, XADC_CONVERT_PHASE = 2, XADC_READ_REQ_PHASE = 3, XADC_READ_WAIT_PHASE = 4;

reg [2:0] current_state;
reg [2:0] next_state;

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
    eoc_out,
    drdy_out
) begin
    pmod_dac_start = 0;

    daddr_in = 0;
    den_in = 0;
    di_in = 0;
    convst_in = 0;

    xadc_data_valid = 0;

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
        if (~pmod_dac_busy) begin
            convst_in = 1;
            next_state = XADC_CONVERT_PHASE;
        end
    end
    XADC_CONVERT_PHASE:
    begin
        if (eoc_out) begin
            next_state = XADC_READ_REQ_PHASE;
        end
    end
    XADC_READ_REQ_PHASE:
    begin
        daddr_in = 7'h03;
        den_in = 1;
        next_state = XADC_READ_WAIT_PHASE;
    end
    XADC_READ_WAIT_PHASE:
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
    .convst_in(convst_in),
    .busy_out   (busy_out),
    .do_out     (do_out),
    .drdy_out   (drdy_out),
    .eos_out    (),
    .vn_in     (vn_in),
    .vp_in     (vp_in),
    .alarm_out(),
    .channel_out(),
    .eoc_out(eoc_out)
);

endmodule