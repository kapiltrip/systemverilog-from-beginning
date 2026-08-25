# Part 22 — Automatic Covergroup Event Sampling

[← Part 21](../21-reusable-covergroup-memory-range-use-case/README.md) · [Functional Coverage index](../README.md) · [Part 23 →](../23-manual-prebuilt-sample-method/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 7, V093 — Method 1: Sampling Event with Covergroup |
| Source playground | [`twJN`](https://edaplayground.com/x/twJN) |
| EDA code ID / saved Name | `7382349` / **FC S07 V093 - Sampling Event** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 4/4 bins, 100%; 12 automatic samples; 0 source errors or warnings |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 093: the covergroup samples automatically on its declared event.
module tb;
  logic clk = 0;
  logic [1:0] a = 0;

  covergroup clocked_cg @(posedge clk); // sampling event
    option.per_instance = 1;
    cp_a: coverpoint a;
  endgroup

  clocked_cg cg;

  initial repeat (24) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();

    // Drive on the opposite edge so a is stable at the sampling edge.
    repeat (8) begin
      @(negedge clk);
      a = $urandom;
    end
    // TODO: change the event and observe exactly when automatic sampling moves.
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

The saved page completed normally and reported:

| Automatic bin | Hits | Status |
|---|---:|---|
| `auto[0]` | 1 | Covered |
| `auto[1]` | 5 | Covered |
| `auto[2]` | 5 | Covered |
| `auto[3]` | 1 | Covered |
| Total | 12 samples, 4/4 bins | **100%** |

`qrun`, `vlog`, and `vsim` each reported zero errors. The single summary
warning is Questa's generic `+acc` optimization notice, not a source warning.

## What “sampling event” means

The comment `// sampling event` was the one useful note retained from the
omitted V092 overview. It belongs here because `@(posedge clk)` is part of the
covergroup type declaration. After `cg = new()`, every rising edge calls the
covergroup's sampling operation automatically; the testbench never calls
`cg.sample()` explicitly.

The finite clock makes 24 half-period transitions. Starting from zero, the odd
transitions are rising edges, so the covergroup receives exactly 12 samples at
5, 15, ..., 115 ns. The eight stimulus assignments happen at falling edges
from 10 through 80 ns. Consequently:

- the first rising edge samples the initialized value `a = 0`;
- each later assignment is stable for five nanoseconds before sampling;
- after the eighth assignment, the last value remains unchanged and is sampled
  on the four remaining rising edges.

That final repetition explains why the hit total is 12 rather than eight.
Coverage records every declared event, not only cycles on which the producer
changed the value.

## Why drive on the opposite edge?

Driving `a` at `negedge clk` and sampling at `posedge clk` gives a half-cycle
of separation. If both actions used the same edge, the covergroup and the
procedural assignment could execute in the same simulation time slot and the
observed value could depend on scheduling order. The opposite-edge pattern
makes the intended transaction boundary explicit and avoids that race.

Changing the covergroup event to `@(negedge clk)` would move automatic samples
onto the same edges as the blocking assignments. To experiment safely, move
the driver to the opposite edge as well or use a clocking block with defined
input/output skews.

## What 100% proves—and does not prove

All four values of the two-bit variable were observed, so this specific value
coverage model is closed. It does not prove that a DUT produced the right
value, that the value was valid on every sampled edge, or that a protocol
transaction occurred. A real monitor normally gates the event with a valid
condition, uses `iff`, or samples at a transaction callback so idle cycles do
not inflate hit counts.

## Revision checks

1. Where is the sampling operation triggered when no `sample()` call appears?
2. Why do 24 half-cycles produce 12 samples rather than 24?
3. Why is the first sampled value the initialization value?
4. What scheduling risk appears if the driver and covergroup use the same edge?
5. Why can a coverpoint reach 100% even when no DUT is checked?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
