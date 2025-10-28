// ============================================================
// Testbench for Successive Approximation Controller
// Tests various target values including edge cases
// ============================================================
`timescale 1ns/1ps

module successive_approximation_tb_syn;

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

    parameter PERIOD = 10;
    // Clock generation
    initial begin
        clk = 0;
        forever #(PERIOD/2) clk = ~clk; 
    end

    // Test stimulus
    initial begin
        $sdf_annotate("./successive_approximation_syn.sdf", dut);
        $fsdbDumpfile("../4.Simulation_Result/successive_approximation_syn.fsdb");
        $fsdbDumpvars;
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

        // // Test case 3: Edge case - minimum (550)
        // test_case(10'd550);

        // // Test case 4: Edge case - maximum (1000)
        // test_case(10'd1000);

        // // Test case 5: Below minimum (should clip to 550)
        // test_case(10'd400);

        // // Test case 6: Above maximum (should clip to 1000)
        // test_case(10'd1000); // Use 1000 instead of 1200 to avoid truncation

        // // Test case 7: Mid-range value
        // test_case(10'd700);

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
                $display("  Cycle %d: counter=%d, x=%d (binary %b), y=%d, state=%s",
                         $time/10, dut.counter, x, x, y, (dut.state) ? "COMPARE" : "IDLE");
            end
            $display("  Done! Final: x=%d (binary %b), y=%d", x, x, y);
        end
    endtask

    // Monitor for debugging
    initial begin
        $monitor("Time=%0t: start=%b, target=%d, done=%b, x=%d, y=%d, counter=%d, state=%s",
                 $time, start, target, done, x, y, dut.counter, (dut.state) ? "COMPARE" : "IDLE");
    end

endmodule
