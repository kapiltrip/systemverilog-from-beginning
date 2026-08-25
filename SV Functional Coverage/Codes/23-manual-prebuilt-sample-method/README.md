# Part 23 — Manual Use of the Prebuilt `sample()` Method

[← Part 22](../22-covergroup-event-sampling/README.md) · [Functional Coverage index](../README.md) · [Part 24 →](../24-user-defined-sample-in-task/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 7, V095 — Method 2: Using Prebuilt `sample()` Method |
| Source playground | [`EfZj`](https://edaplayground.com/x/EfZj) |
| EDA code ID / saved Name | `7382352` / **FC S07 V095 - Prebuilt sample()** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 3/4 bins, 75%; eight explicit samples; 0 source errors or warnings |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 095: manually call the pre-built sample() method after stimulus.
module tb;
  logic clk = 0;
  logic [1:0] a = 0;

  covergroup manual_cg;
    option.per_instance = 1;
    cp_a: coverpoint a;
  endgroup

  manual_cg cg;

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    repeat (8) begin
      @(negedge clk);
      a = $urandom;
      cg.sample();
    end
    // TODO: call sample() only at the transaction boundary you choose.
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Complete saved `run.do`

~~~tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
~~~

Local script: [run.do](run.do).

## Fresh direct Questa result

| Automatic bin | Hits | Status |
|---|---:|---|
| `auto[0]` | 0 | Missing |
| `auto[1]` | 2 | Covered |
| `auto[2]` | 5 | Covered |
| `auto[3]` | 1 | Covered |
| Total | 8 samples, 3/4 bins | **75%** |

The eight hits equal the eight explicit calls. Unlike Part 22, no extra sample
is taken at a clock edge merely because the clock toggled. `qrun`, `vlog`, and
`vsim` reported zero errors; the only summary warning is the saved `+acc`
optimization notice.

## Why this `sample()` method is “prebuilt”

`manual_cg` has no sampling event and does not use `with function sample(...)`.
SystemVerilog therefore provides the normal no-argument method on every
constructed instance. Calling `cg.sample()` snapshots the expressions in that
instance's coverpoints—in this case the current value of module variable `a`.

The call is manual, but the observed expression was fixed when the covergroup
type was declared. The caller chooses *when* to sample; it does not pass a
different value into this method.

## Ordering inside the loop

Each iteration performs three ordered operations in one procedural thread:

1. wait for `negedge clk`;
2. assign a newly truncated random value to `a` with a blocking assignment;
3. call `cg.sample()`.

Because the assignment is blocking, the sample sees the new two-bit value.
Moving `cg.sample()` before the assignment would record the previous iteration's
value. Replacing the assignment with a nonblocking assignment and sampling
immediately would also record the old value because the NBA update occurs
later in the time slot.

## The transaction-boundary TODO

The TODO is the central design choice. A monitor should sample only when it has
assembled a complete, valid transaction. Examples include:

- after a handshake such as `valid && ready`;
- after a packet parser has decoded all fields;
- after a scoreboard input transaction is published;
- after a task has completed a bus transfer.

Sampling every clock is convenient but may count reset, idle, invalid, or
partially updated values. Manual sampling ties coverage to the monitor's
semantic boundary instead of the raw clock.

## Why coverage stopped at 75%

Eight random draws do not guarantee all four values. The recorded seed never
generated `0`, so `auto[0]` remained empty. This is a stimulus-closure issue,
not a sampling-method failure. A deterministic closure loop can drive `0`,
`1`, `2`, and `3` once each and call `sample()` after every assignment.

The VCD file helps inspect signal timing but is independent of functional
coverage. A waveform does not call the covergroup, and a covered bin does not
prove waveform correctness.

## Revision checks

1. Why does `cg.sample()` take no argument here?
2. Which expression does the coverpoint snapshot?
3. What changes if sampling occurs before the blocking assignment?
4. Why do clock edges alone create no coverage hits in this lesson?
5. How would you make closure deterministic without changing the coverage model?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
