// ============================================================
// Successive-Approximation Controller for y = 1000 - 30*x
// - x is 4-bit: 0..15
// - y is 10-bit: 550..1000
// - Given target[9:0], find x that minimizes |y - target|
// - 1 cycle per bit (total 4 cycles after in_valid); simple FSM
// ============================================================
module successive_approximation (
    input            clk,
    input            rst,
    input            start,
    input      [9:0] target,
    output reg       down,
    output reg [3:0] x,
    output reg [9:0] y
);

    reg [1:0] counter;
    reg       state;
    reg       next_state;
    reg [9:0] mid;

    localparam IDLE    = 1'b0;
    localparam COMPARE = 1'b1;

    always @(*) begin
        case (state)
            IDLE:    next_state = start ? COMPARE : IDLE;
            COMPARE: next_state = (counter == 2'd0) ? IDLE : COMPARE;
            default: next_state = IDLE;
        endcase
    end
    
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            x       <=  4'd0;
            y       <= 10'd1000;
            counter <=  2'd3;
            down    <=  1'b0;
        end else begin
            case(state)
                IDLE: begin
                    if(start) begin
                        x       <=  4'd0;
                        y       <= 10'd1000;
                        counter <=  2'd3;
                        down    <=  1'b0;
                    end
                end
                COMPARE: begin
                    // midpoint m = (y + (y - 30*2^bit)) / 2 = y - 15*2^bit
                    mid        <= y - (10'd15 << counter);
                    x[counter] <= (target <= mid) ? 1'b1 : 1'b0;

                    // 30x = 32x -2x = (1 << 5)x - (1 << 1)x = (1 << 5)(1 << counter) - (1 << 1)(1 << counter)
                    y          <= (target <= mid) ? y - ((1 << (counter + 5)) - (1 << (counter + 1))): y; 
                    counter    <= (counter == 2'd0) ? 2'd0 : (counter - 2'd1);
                    down       <= (counter == 2'd0) ? 1'b1 : 1'b0;
                end
                default: begin
                    x       <=  4'd0;
                    y       <= 10'd1000;
                    counter <=  2'd3;
                    down    <=  1'b0;
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