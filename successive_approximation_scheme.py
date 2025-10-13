# Successive Approximation Register (SAR) search for:
#   y = 1000 - 30*x , where x is a 4-bit code (0..15), y in [550, 1000].
# The algorithm sets bits from MSB->LSB and decides to keep a bit if the
# tentative y is still >= target (since y decreases with larger x).
# After SAR, we also check the neighbor (x+1) to minimize absolute error.

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
    # Try bits from MSB (bit3) to LSB (bit0)
    for bit in range(3, -1, -1):
        trial = x | (1 << bit)
        y_trial = y_from_x(trial)
        keep = y_trial >= t  # keep if we haven't gone below target
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
        for bit, trial_x, trial_y, keep in res.steps:
            print(f"    bit{bit}: trial_x={trial_x:2d} (b{trial_x:04b}), y_trial={trial_y:4d}, keep={keep}")
        print()

if __name__ == "__main__":
    main()
