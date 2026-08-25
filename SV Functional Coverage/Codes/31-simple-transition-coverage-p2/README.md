# Part 31 — Simple FSM Transition Coverage, Part 2

[← Part 30](../30-simple-transition-coverage-p1/README.md) · [Functional Coverage index](../README.md) · [Part 32 →](../32-consecutive-repetition-transition/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 9, V122 — Simple Transition Coverage P2 |
| Source playground | [`gsCG`](https://edaplayground.com/x/gsCG) |
| EDA code ID / saved Name | `7382370` / **FC S09 V122 - Simple Transitions P2** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | `cp_d` 100%, `cp_state` 50%, displayed total 75%; zero compile/simulation errors |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 122: legal holds and illegal state changes while d is low.
module tb;
  logic clk = 0, reset = 1, d = 0;
  logic d_out;

  two_state_fsm dut(.*);

  covergroup transition_low_cg @(posedge clk);
    option.per_instance = 1;
    cp_d: coverpoint d { bins low = {0}; }
    cp_state: coverpoint dut.state iff (!reset && !d) {
      bins hold_s0 = (0 => 0);
      bins hold_s1 = (1 => 1);
      illegal_bins changed_state = (0 => 1), (1 => 0);
    }
  endgroup

  transition_low_cg cg;

  initial repeat (34) #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    repeat (2) @(negedge clk);
    reset = 0;
    @(negedge clk); d = 0;
    repeat (8) @(negedge clk);
    // TODO: deliberately pulse d high, then observe the illegal transition
    // diagnostic when sampling resumes with d low.
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Complete saved design

~~~systemverilog
module two_state_fsm(
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic d_out
);
  localparam logic S0 = 1'b0;
  localparam logic S1 = 1'b1;
  logic state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= S0;
    else       state <= next_state;
  end

  always_comb begin
    next_state = state;
    d_out = 1'b0;
    case (state)
      S0: if (d) next_state = S1;
      S1: if (d) begin next_state = S0; d_out = 1'b1; end
      default: next_state = S0;
    endcase
  end
endmodule
~~~

Local RTL: [design.sv](design.sv).

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

| Coverage item | Hit evidence | Metric |
|---|---|---:|
| `cp_d.low` | 17 hits | 100.00% |
| `cp_state.hold_s0` | 14 hits | Covered |
| `cp_state.hold_s1` | 0 hits | Missing |
| `cp_state.changed_state` | 0 illegal hits | No forbidden transition observed |
| `cp_state` | 1/2 scored bins | 50.00% |
| Whole covergroup | Equal average of 100% and 50% | **75.00%** |

The raw score is two covered bins out of three, or 66.66%; the displayed 75%
is the equal-weight average of the two coverpoint metrics. Questa reported zero
compile and simulation errors. Its only total warning was the standard
`vopt-10587` notice caused by `+acc`.

## Why only the `S0` hold is covered

The FSM changes state only when `d` is one. This test leaves `d` at zero for the
entire run, so reset brings the state to `S0` and it never reaches `S1`.
Consequently, `0→0` is repeatedly observed, `1→1` is unreachable under this
stimulus, and no changed-state illegal transition can occur.

The 34 half-cycle toggles create 17 positive-edge samples. `cp_d` has no reset
guard, so all 17 edges hit `low`. Reset is released at 20 ns; the guarded state
coverpoint then sees 15 accepted `S0` samples from 25 through 165 ns. Fifteen
values contain fourteen adjacent `0→0` transitions, matching the report.

## What the TODO would need to do

The saved TODO says to pulse `d` high and then resume sampling with `d` low.
A single high interval can move the FSM from `S0` to `S1`; holding `d` low after
that would close `hold_s1`. It should not create an illegal bin if the FSM is
correct, because the state must remain stable whenever the guard is true.

To test the illegal diagnostic deliberately, the testbench must inject a fault
or force the state to change while `!reset && !d` is sampled. Merely pulsing
`d` high creates a legal transition outside the coverpoint's guard. That
distinction is important: a coverage hole is not proof that the illegal
behavior cannot happen.

## Why this page is useful beside Part 30

Part 30 contains both high-`d` toggle coverage and a second low-`d` model. This
page isolates the low-`d` requirement with descriptive labels, reset gating,
and opposite-edge stimulus. It is therefore the cleaner explanation of legal
holds, even though the saved TODO was not completed and the result remains 75%.

The opposite-edge stimulus is also safer than Part 30's same-edge blocking
writes: reset and `d` are stable for half a cycle before each positive-edge
sample, so the coverage interpretation does not depend on process ordering.

## Coverage versus checking

`illegal_bins` records a runtime diagnostic when a forbidden sampled sequence
occurs, but the FSM rule is temporal behavior and is better enforced by an
assertion such as “if `d` is low and reset is inactive, state remains stable on
the next clock.” Coverage then answers whether both legal hold states were
actually exercised; the assertion answers whether every observed hold cycle
obeyed the rule.

## Revision checks

1. Why does `cp_d.low` have 17 hits while `cp_state` has only 15 samples?
2. Why do 15 accepted `S0` values create 14 transition-bin hits?
3. Why is `hold_s1` unreachable with the saved stimulus?
4. Why would a legal high-`d` pulse not hit `changed_state`?
5. Why is the displayed 75% different from the raw 2/3 bin ratio?
6. What assertion complements this transition-coverage model?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification — transition bins and `iff`](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator and custom `run.do` settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
