module dfr_core_controller
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
    input reservoir_busy,
    input reservoir_init_busy,
    input matrix_multiply_busy,
    input reservoir_filled,
    input reservoir_valid,

    output reg busy = 0,
    output reg matrix_multiply_start = 0,
    output reg matrix_multiply_rst = 0,
    output reg reservoir_rst = 0,
    output reg reservoir_en = 0, 
    output reg sample_cntr_rst = 0,
    output reg init_sample_cntr_rst = 0,
    output reg init_sample_cntr_en = 0,
    output reg reservoir_history_en = 0,
    output reg reservoir_history_rst = 0,
    output reg dfr_done = 0,
    output reg sample_cntr_en = 0,
    output wire [2:0] current_state_out
);

localparam DONE = 0, RESERVOIR_INIT_STAGE = 1, RESERVOIR_INIT_WAIT_STAGE = 2, RESERVOIR_STAGE = 3, RESERVOIR_WAIT_STAGE = 4, MATRIX_MULTIPLY_STAGE = 5;

reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

assign current_state_out = current_state;

always @ (posedge clk) begin
    if (rst)
        current_state <= DONE;
    else
        current_state <= next_state;
end

always @(
    current_state,
    start,
    matrix_multiply_busy,
    reservoir_busy,
    reservoir_filled,
    reservoir_init_busy,
    reservoir_valid
) begin

    matrix_multiply_start = 0;
    matrix_multiply_rst = 0;
    reservoir_en = 0;
    reservoir_rst = 0;
    dfr_done = 0;
    busy = 0;
    reservoir_history_en = 0;
    sample_cntr_rst = 0;
    sample_cntr_en = 0;
    init_sample_cntr_rst = 0;
    init_sample_cntr_en = 0;
    reservoir_history_rst = 0;

    next_state = current_state;

    case (current_state)
        DONE:
        begin
            if (start) begin
                next_state = RESERVOIR_INIT_STAGE;
                reservoir_rst = 1;
                matrix_multiply_rst = 1;
                init_sample_cntr_rst = 1;
                reservoir_history_rst = 1;
                sample_cntr_rst = 1;
                busy = 1;
            end
            else begin
                dfr_done = 1;
                busy = 0;
            end
        end
        RESERVOIR_INIT_STAGE:
        begin
            busy = 1;
            if (~reservoir_init_busy) begin
                next_state = RESERVOIR_STAGE;
            end
            else begin
                reservoir_en = 1;
                next_state = RESERVOIR_INIT_WAIT_STAGE;
            end
        end
        RESERVOIR_INIT_WAIT_STAGE:
        begin
            busy = 1;
            if (reservoir_valid) begin
                sample_cntr_en = 1;
                init_sample_cntr_en = 1;
                next_state = RESERVOIR_INIT_STAGE;
            end
        end
        RESERVOIR_STAGE:
        begin
            busy = 1;
            if(reservoir_filled)
                reservoir_history_en = 1;

            if (~reservoir_busy) begin
                matrix_multiply_start = 1;
                next_state = MATRIX_MULTIPLY_STAGE;
            end
            else begin
                reservoir_en = 1;
                next_state = RESERVOIR_WAIT_STAGE;
            end
        end
        RESERVOIR_WAIT_STAGE:
        begin
            busy = 1;
            if (reservoir_valid) begin
                sample_cntr_en = 1;
                next_state = RESERVOIR_STAGE;
            end
        end
        MATRIX_MULTIPLY_STAGE:
        begin
            busy = 1;
            if (~matrix_multiply_busy) begin
                next_state = DONE;
            end
        end
        default:
        begin
        end
    endcase
end



endmodule