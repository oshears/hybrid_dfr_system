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
    input matrix_multiply_busy,

    output reg busy,
    output reg matrix_multiply_start,
    output reg reservoir_en, 
    output reg reservoir_history_en,
    output reg dfr_done
);

localparam done = 0, reservoir_stage = 1, matrix_multiply_stage = 2;

reg [2:0] current_state = 0;
reg [2:0] next_state = 0;

always @ (posedge clk or posedge rst) begin
    if (rst)
        current_state <= done;
    else
        current_state <= next_state;
end

always @(
    current_state,
    start,
    matrix_multiply_busy,
    reservoir_busy
) begin

    matrix_multiply_start = 0;
    reservoir_en = 0;
    dfr_done = 0;
    busy = 0;

    case (current_state)
        done:
        begin
            if (start) begin
                next_state = reservoir_stage;
            end
        end
        reservoir_stage:
        begin
            busy = 1;
            if (~reservoir_busy) begin
                matrix_multiply_start = 1;
                next_state = matrix_multiply_stage;
            end
            else begin
                reservoir_en = 1;
                reservoir_history_en = 1;
            end
        end
        matrix_multiply_stage:
        begin
            busy = 1;
            if (~matrix_multiply_busy) begin
                next_state = done;
            end
        end
        default:
        begin
        end
    endcase
end



endmodule