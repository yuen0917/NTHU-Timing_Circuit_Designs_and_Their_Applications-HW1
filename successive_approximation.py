# Successive Approximation Register (SAR) search for:
#   y = 1000 - 30*x , where x is a 4-bit code (0..15), y in [550, 1000].
# The algorithm sets bits from MSB->LSB by direct thresholding:
#   For bit b, try setting it (trial x). If y(trial) > clipped target t, keep this bit; otherwise clear it.
# After SAR, also check neighbor (x+1) to minimize absolute error to original target.

from dataclasses import dataclass

def y_from_x(x: int) -> int:
    return 1000 - 30 * x

@dataclass
class SARResult:
    target: int
    x: int
    y: int
    abs_error: int
    steps: list  # (bit_index, trial_x, trial_y, keep_bit: bool)

def sar_successive_approx(target: int) -> SARResult:
    # Clip target into reachable range [550, 1000] for meaningful SAR behavior
    t = max(550, min(1000, int(target)))
    x = 0
    steps = []

    # Try bits from MSB (bit3) to LSB (bit0) using direct threshold comparison
    for bit in range(3, -1, -1):
        trial = x | (1 << bit)
        y_trial = y_from_x(trial)
        # Keep this bit if trial output exceeds the clipped target (strictly greater)
        keep = y_trial > t
        if keep:
            x = trial
        steps.append((bit, trial, y_trial, keep))

    # After SAR, choose the closer between x and x+1 (if valid)
    candidates = [x]
    if x < 15:
        candidates.append(x + 1)

    # Pick the one minimizing absolute error to the (unclipped) original target
    best_x = min(candidates, key=lambda c: abs(y_from_x(c) - target))
    best_y = y_from_x(best_x)
    return SARResult(target=target, x=best_x, y=best_y, abs_error=abs(best_y - target), steps=steps)

def main():
    # Demo for targets 630 and 780
    for target in [630, 780]:
        res = sar_successive_approx(target)
        print(f"Target = {res.target}")
        print(f"  -> Best x = {res.x:2d}  (binary {res.x:04b}), y = {res.y}, |y-target| = {res.abs_error}")
        print("  SAR steps (bit, trial_x, trial_y, keep?):")

        # print the steps in order
        for bit, trial_x, trial_y, keep in res.steps:
            print(f"    bit{bit}: trial_x = {trial_x:2d} (b{trial_x:04b}), y_trial = {trial_y:3d}, keep = {keep}")
        print()

if __name__ == "__main__":
    main()
