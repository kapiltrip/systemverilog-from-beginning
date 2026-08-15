# Part 01 — Simulation basics

EDA Playground: [https://edaplayground.com/x/Ucnp](https://edaplayground.com/x/Ucnp)

This first example introduces simulation time, initialization, delays, waveform dumping, console monitoring, reset stimulus, and explicit simulation termination.

## Answers and notes

- `` `timescale 1ns/1ps `` means one delay unit is 1 ns and simulation time is rounded to a precision of 1 ps. Therefore, `#10` represents 10 ns.
- Every `initial` block starts concurrently at simulation time 0. Statements inside one block execute sequentially.
- A `reg` that is not initialized starts as `x` in four-state Verilog simulation. Assigning `clk = 1'b0` and `reset = 1'b0` removes that unknown initial state.
- `$dumpfile` selects the VCD output file and `$dumpvars` records signal changes for waveform viewing.
- `$monitor` prints once when it is called and again whenever one of its arguments changes.
- `$finish` ends the simulation. It is necessary here as a safety endpoint and becomes essential when free-running `always` blocks are added later.
- In the `temp` stimulus, two assignments at the same simulation time overwrite one another. A delay is needed between them if both values must be visible in the waveform.

