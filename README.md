# Timing Circuit Designs and Their Applications - HW1
This is the first homework of the course "Timing Circuit Designs and Their Applications".

## Overview
Following the assignment instructions, the project delivers:

1. Software program (Python) using successive approximation (midpoint decision) to solve for x that minimizes |y - target|. Verified with targets 630 and 780 and reports x[3:0].
2. Synthesizable RTL (Verilog) implementing the same algorithm. A testbench verifies RTL results are consistent with the software.
3. Synthesis of the RTL to a gate-level netlist. Run gate-level simulation to confirm behavior matches RTL.
4. Report: final gate count, maximum operating frequency (MHz), and estimated power (mW) from Design Compiler.
5. Physical design: generate a layout using an APR tool (e.g., Encounter). Provide post-layout timing and power. Compare max frequency and power to pre-layout results.

## Successive Approximation(midpoint decision)
If we want to find the closest x to the target, we can use the midpoint decision to decide whether to keep the bit.

$$
|y_{\text{try}} - target| < |y_{\text{cur}} - target| \Rightarrow \text{keep the bit}
$$

We can get the following inequality:

$$
target \lt \frac{y_{\text{cur}} + y_{\text{try}}}{2}
$$

Midpoint of $y_{\text{cur}}$ and $y_{\text{try}}$ is:

$$
\frac{y_{\text{cur}} + y_{\text{try}}}{2}
$$

So we can use the midpoint decision to decide whether to keep the bit.

$$
target \lt \frac{y_{\text{cur}} + y_{\text{try}}}{2}
$$

So we can use the midpoint decision to decide whether to keep the bit.

$$
y_{\text{try}} = y_{\text{cur}} - 15 \times 2^k
$$
