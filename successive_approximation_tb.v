// ============================================================
// Testbench for Successive Approximation Controller
// Tests various target values including edge cases
// ============================================================
`timescale 1ns/1ps

module successive_approximation_tb;

    // Clock and reset
    reg        clk;
    reg        rst_n;
    reg        start;
    reg  [9:0] target;
    wire       done;
    wire [3:0] x;
    wire [9:0] y;

    // Instantiate DUT (requires successive_approximation.v to be compiled together)
    successive_approximation dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .target(target),
        .done(done),
        .x(x),
        .y(y)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period = 100MHz
    end

    // Test stimulus
    initial begin
        $fsdbDumpfile("../4.Simulation_Result/successive_approximation_RTL.fsdb");
        $fsdbDumpvars;
        $dumpfile("../4.Simulation_Result/successive_approximation_RTL.vcd");
        $dumpvars;
        // Initialize signals
        rst_n = 0;
        start = 0;
        target = 0;

        // Reset sequence
        #20 rst_n = 1;
        #10;

        $display("==========================================");
        $display("Successive Approximation Testbench");
        $display("==========================================");

        // Test case 1: Target = 630
        test_case(10'd630);

        // Test case 2: Target = 780
        test_case(10'd780);

        $display("==========================================");
        $display("All tests completed!");
        $display("==========================================");

        #100 $finish;
    end

    // Test case task
    task test_case(input [9:0] test_target);
        begin
            $display("\n--- Testing target = %d ---", test_target);

            // Apply target and start
            target = test_target;
            $display("target = %d", target);
            #10;
            start = 1;
            #20 start = 0;  // Keep start high for 2 clock cycles

            // Wait for completion (4 cycles + 1 for done assertion)
            wait_for_done();

            // Display results
            $display("Final result: x = %d (binary %b), y = %d", x, x, y);
            $display("Expected y = 1000 - 30*x = %d", 1000 - 30*x);
            $display("Absolute error = |%d - %d| = %d", y, test_target, (y > test_target) ? (y - test_target) : (test_target - y));
        end
    endtask

    // Wait for done signal
    task wait_for_done;
        begin
            @(posedge clk);
            while (!done) begin
                @(posedge clk);
            end
            $display("  Done! Final: x=%d (binary %b), y=%d", x, x, y);
        end
    endtask

endmodule
