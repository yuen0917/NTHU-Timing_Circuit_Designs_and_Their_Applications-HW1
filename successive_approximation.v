// ============================================================
// Successive-Approximation Controller for y = 1000 - 30*x
// - x is 4-bit: 0..15
// - y is 10-bit: 550..1000
// - Given target[9:0], find x via direct thresholding per bit:
//   For each bit from MSB->LSB, try setting it to form trial x.
//   If y(trial) > clipped_target t (t = clip(target, 550..1000)), keep the bit; else clear it.
// - 1 cycle per bit (total 4 cycles after start); simple FSM
// ============================================================
module successive_approximation (
    input            clk,
    input            rst_n,
    input            start,
    input      [9:0] target,
    output reg       done,
    output reg [3:0] x,
    output reg [9:0] y
);

    reg [1:0] counter;
    reg       state;
    reg       next_state;
    reg [9:0] t_reg;       // latched clipped target

    // Combinational pre-calculation regs
    reg [3:0]  trial_c;
    reg [9:0]  y_trial_c;

    // Pure combinational block to derive trial/y_trial/keep from current x, counter, and t_reg
    always @(*) begin
        trial_c        = x | (4'b0001 << counter);
        y_trial_c      = 10'd1000 - ((trial_c << 5) - (trial_c << 1));
    end

    localparam IDLE    = 1'b0;
    localparam COMPARE = 1'b1;

    always @(*) begin
        case (state)
            IDLE:    next_state = start ? COMPARE : IDLE;
            COMPARE: next_state = (counter == 2'd0) ? IDLE : COMPARE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x       <=  4'd0;
            y       <= 10'd1000;
            counter <=  2'd3;
            done    <=  1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if(start) begin
                        x       <=  4'd0;
                        y       <= 10'd1000;
                        counter <=  2'd3;
                        done    <=  1'b0;
                        // latch clipped target: t = clip(target, 550..1000)
                        t_reg   <= (target < 10'd550) ? 10'd550 : ((target > 10'd1000) ? 10'd1000 : target);
                    end
                end
                COMPARE: begin
                    x[counter] <= y_trial_c > t_reg;
                    y          <= y_trial_c > t_reg ? y_trial_c : y;
                    counter    <= (counter == 2'd0) ? 2'd0 : (counter - 2'd1);
                    done       <= (counter == 2'd0) ? 1'b1 : 1'b0;
                end
                default: begin
                    x       <=  4'd0;
                    y       <= 10'd1000;
                    counter <=  2'd3;
                    done    <=  1'b0;
                end
            endcase
        end
    end

endmodule

// module successive_approximation_comb (
//   input  [9:0] target,
//   output [3:0] x,
//   output [9:0] y
// );
//   // calculate the closest x
//   // 30x ≈ 1000 - target => x ≈ (1000 - target)/30
//   wire [10:0] diff = 11'd1000 - target;
//   wire [6:0]  div30 = diff / 11'd30;  // synthesizer will expand into constant division circuit
//   assign x = (div30 > 15) ? 4'd15 : div30[3:0];
//   assign y = 10'd1000 - (x * 10'd30);
// endmodule