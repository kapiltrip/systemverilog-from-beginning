# Part 02 — Clock generation

EDA Playground: [https://edaplayground.com/x/gi86](https://edaplayground.com/x/gi86)

This part continues Part 01 by generating several clocks with procedural delays and observing frequency, period, duty cycle, and simulator termination.

## Question: Why can a testbench `always` block omit a sensitivity list?

A testbench clock generator is an intentional procedural loop. A delay inside the block advances simulation time, and after the last statement the `always` block starts again. It does not wait for an input signal to change.

Design logic normally reacts to events:

- Combinational logic uses `always_comb` (preferred SystemVerilog) or `always @*` so it is reevaluated when a read input changes.
- Sequential logic uses an explicit event such as `always_ff @(posedge clk)`.
- A delay-free `always begin ... end` is unsafe because it loops forever at the same simulation time.

## Clock calculations

- `always #5 clk = ~clk` gives a 10 ns period, or 100 MHz.
- `always #31.25 clk16Mhz = ~clk16Mhz` gives a 62.5 ns period, or 16 MHz.
- `always #62.5 clk8Mhz = ~clk8Mhz` gives a 125 ns period, or 8 MHz.
- The active `clk50MHZ` block produces a 20 ns period, or 50 MHz.
- The active `clk25Mhz` block has a 30 ns period and is therefore about 33.33 MHz, not 25 MHz. A symmetric 25 MHz clock can use `always #20 clk25Mhz = ~clk25Mhz`.
- `$finish` is required because clock-generating `always` blocks otherwise run forever.

