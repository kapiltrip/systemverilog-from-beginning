# Part 30 — Simple FSM Transition Coverage, Part 1

[← Part 29](../29-binsof-intersect-cross-filtering/README.md) · [Functional Coverage index](../README.md) · [Part 31 →](../31-simple-transition-coverage-p2/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 9, V121 — Simple Transition Coverage P1 |
| Source playground | [`v_s9`](https://edaplayground.com/x/v_s9) |
| EDA code ID / saved Name | `7382369` / **FC S09 V121 - Simple Transitions P1** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | `c1` 100%, `c2` 80%, total 90%; zero compile/simulation errors |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 121: legal toggles and illegal same-state behavior while d is high.
module tb;
  reg clk =0 ;
  reg reset = 0 ;
  reg d =0 ;
  wire d_out;


  two_state_fsm dut (clk , reset , d , d_out );

  initial  repeat (50) #5 clk = ~ clk ;
  initial begin
    repeat (4) @(posedge clk ) {reset  , d }= 2'b10 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b01 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b10 ;
    repeat (1) @(posedge clk ) {reset , d }= 2'b10 ;
    repeat (4) @(posedge clk ) {reset , d }= 2'b00 ;

  end
  covergroup c1 @(posedge clk ) ;
    option.per_instance = 1;

    coverpoint reset {
      bins reset_high = {1};
      bins reset_low = {0};
    }
    coverpoint d{
      bins d_high = {1};
    }
    coverpoint d_out {
      bins d_out_high = {1};
      bins d_out_low = {0};

    }
    coverpoint dut.state iff(d == 1'b1){
      bins transition_s0_s1 = (dut.s0 => dut.s1) ;
      bins transition_s1_s0 = (dut.s1 => dut.s0) ;
      illegal_bins same_state = (dut.s0 => dut.s0 , dut.s1 => dut.s1 );

    }
    cross reset , d, dut.state {
      ignore_bins reset_is_high = binsof(reset) intersect {1} ;
    }
  endgroup

    covergroup c2 @(posedge clk ) ;
      option.per_instance = 1;


    coverpoint d{
      bins d_low  = {0};
    }

     coverpoint dut.state iff(d == 1'b0){
       bins transition_s0_s0 = (dut.s0 => dut.s0) ;
       bins transition_s1_s1 = (dut.s1 => dut.s1) ;
       illegal_bins same_state = (dut.s0 => dut.s1 , dut.s1 => dut.s0 );

    }
    cross reset , d, dut.state {
      ignore_bins reset_is_high = binsof(reset) intersect {1} ;
    }
  endgroup
  c1 ci;
  c2 ci2 ;
  initial begin
    ci = new();
    ci2 = new();

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
  localparam logic s0 = 1'b0;
  localparam logic s1 = 1'b1;
  logic state, next_state;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) state <= s0;
    else       state <= next_state;
  end

  always_comb begin
    next_state = state;
    d_out = 1'b0;
    case (state)
      s0: if (d) next_state = s1;
      s1: if (d) begin
        next_state = s0;
        d_out = 1'b1;
      end
      default: next_state = s0;
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

| Coverage item | Important bin hits | Metric |
|---|---|---:|
| `c1`: `d == 1` transitions | `s0→s1 = 2`, `s1→s0 = 1`, same-state illegal bin `0` | 100.00% |
| `c1`: output values | `d_out_low = 23`, `d_out_high = 2` | 100.00% |
| `c1`: filtered cross | 2/2 scored tuples | 100.00% |
| `c2`: `d == 0` transitions | `s0→s0 = 19`, `s1→s1 = 0`, changed-state illegal bin `0` | 50.00% transition coverpoint |
| `c2`: filtered cross | 1/2 scored tuples; reset-high ignore bin occurred 9 times | 50.00% cross |
| Whole run | Equal average of `c1` 100% and `c2` 80% | **90.00%** |

Questa completed `qrun`, compilation, and simulation with zero errors. The only
total warning was `vopt-10587`, produced by the saved `+acc` visibility option;
it is not a source or coverage-model failure.

## What the two transition models mean

When `d` is high, the RTL toggles its one-bit state. `c1` therefore calls
`s0→s1` and `s1→s0` legal and treats `s0→s0` or `s1→s1` as illegal. The four
accepted high-`d` samples form the state trace `s0, s1, s0, s1`, so the two
forward transitions and one reverse transition exactly explain the 2/1 counts.

When `d` is low, the state should hold. `c2` reverses the expectation: its legal
bins are `s0→s0` and `s1→s1`, while state changes are illegal. The source reuses
the name `same_state` for that illegal bin, but the listed transitions are
changes. A clearer name would be `changed_state`; the archived source keeps the
browser spelling and records the correction here.

## Why `c2` is 80%, not 77.77%

The detailed report shows seven covered raw bins out of nine, or 77.77% if all
bins are counted together. Questa's displayed covergroup metric instead gives
equal weight to its five coverage items:

```text
d value 100 + state transition 50 + implicit reset 100
            + implicit state 100 + cross 50
------------------------------------------------------- = 80%
                           5
```

The missing goals are `s1→s1` and the cross tuple containing state `s1`.
Independent value coverage for state `s1` does not create the missing low-`d`
hold transition.

## `iff`, the cross, and the reset ignore bin

`iff(d == 1'b1)` or `iff(d == 1'b0)` disables that transition coverpoint on an
unwanted sample. It does not automatically gate every other coverage item.
Questa's report shows that each cross creates a separate implicit value
coverpoint for hierarchical `dut.state`; the explicit transition coverpoint and
its `iff` remain a different item.

The explicit `d` coverpoint in `c1` defines only `d_high`, so a low value maps
to no cross bin. The corresponding `c2` coverpoint defines only `d_low`. This is
what restricts the two crosses to their intended operation modes. The
`ignore_bins` declaration then removes reset-high tuples from the scored
denominator. Its nine occurrences in `c2` are expected observations, not
illegal-bin failures; `c1` sees none because reset-high stimulus uses low `d`,
which does not belong to its cross domain.

## Same-edge driving is the fragile part

The stimulus writes `{reset,d}` with blocking assignments immediately after
`@(posedge clk)`, while the DUT and both covergroups also react to that edge.
The recorded Questa result samples the pre-write control values and the
pre-NBA FSM state. That one-sample shift explains all 25 rising-edge samples:
four see `d == 1`, 21 see `d == 0`, and the reset-high/low-`d` combination is
observed nine times.

This is simulator-scheduler-sensitive testbench style. Driving controls at
`negedge clk` and sampling at `posedge clk` makes the intended value stable for
half a cycle and removes the race without changing the coverage requirements.

## What this coverage does not prove

The report proves that named state movements and combinations were observed.
It does not check that `d_out` asserted on the correct cycle, that the next-state
logic is functionally correct, or that every illegal transition would fail a
regression in a portable way. Assertions should check the temporal FSM rules,
and a scoreboard should check output behavior.

## Revision checks

1. Why are `s0→s1` and `s1→s0` legal only while `d` is high?
2. Why does four sampled high-`d` states produce only three transition hits?
3. Which two goals keep `c2` below 100%?
4. Why does Questa display 80% for `c2` although seven of nine raw bins hit?
5. Why can an ignore bin report nine occurrences without being an error?
6. What race is removed by driving `{reset,d}` on the negative edge?
7. What verification evidence is still missing even though `c1` is 100%?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification — transition bins and `iff`](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator and custom `run.do` settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
