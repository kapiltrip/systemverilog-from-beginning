# Project 02 — Counter Assertions with a Bound Checker

[← Project 01](../01-fsm-verification-with-sva/README.md) · [Projects index](../README.md) · Latest captured project

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [C7eC](https://edaplayground.com/x/C7eC) |
| EDA code ID | `7378502` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | Compilation stops at `testbench.sv:63`: unexpected `else` in `property p1`; 1 `vlog` error, so simulation does not start |
| Open EPWave after run | Disabled |

This project combines a four-bit synchronous up/down counter with a separately declared assertion module attached through `bind`. Both browser panes are preserved exactly. Corrections below are explanatory; they do not silently replace the captured learning evidence.

The fresh run found a compile barrier before any assertion could execute. Static review also found that `clk` is never initialized, so after the syntax error is fixed, `always #5 clk = ~clk` would continue assigning `X` to `clk` and still create no positive edges. Both issues must be understood before interpreting any assertion pass/fail behavior.

## Exact browser design

~~~systemverilog
// Code your design here
module counter(
  input wire clk , rst, up,
  output reg [3:0] dout 
);

  always @(posedge clk )begin
    if(rst)begin
      dout<= 4'b0000;
      
    end else begin
      if(up)
        dout <= dout + 4'd1; 
      else 
        dout <= dout - 4'd1; 
      
    end 
  end
endmodule
~~~

Local source: [design.sv](design.sv).

## Exact browser testbench and checker

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg clk , rst , up ; 
  wire [3:0] dout;

  // what is a temp 
  counter dut (clk , rst , up , dout);
  bind counter counter_assert dut2 (clk , rst, up , dout );
  always #5 clk = ~clk ; 
  initial begin
    rst=1; 
    #30; 
    rst=0;
    up=1;
    #200; 
    up=0;
    rst=1; 
    #25; 
    rst =0; 
    
  end
    initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    $assertvacuousoff(0);
    #360;
    $finish;
  end
endmodule
module counter_assert (
  input clk , rst , up, 
  input [3:0] dout
);
// reset is asserted , behaviour of dout 
  dout_rst_asserted : assert property (@(posedge clk) $rose(rst) |-> (dout == 4'b0000)) $info("dout must be 0 for reset asserted ");
  dout_rst_asserted_2 : assert property (@(posedge clk) rst |-> (dout == 4'b0000)) $info("dout must be 0 for reset asserted ");
  dout_beh_3 : assert property (@(posedge clk) $rose(rst) |=>rst  throughout ((dout==4'b0000)[*1:36])) ;  
      
      
  // dout must be valid after rst deassert 
    doutValid : assert property (@(posedge clk) $fell(rst) |-> !$isunknown(dout)); 
      always @(posedge clk ) begin
        doutValid2: assert (!$isunknown(dout));
      end
      // to verify how the up counter behaviour 
      upBeh: assert property (@(posedge clk) disable iff(rst) up|-> (dout == $past(dout) + 4'd1) || (dout ==0));
      // next value must be greater than zero when up =1 and rst =0 
        upHighRst: assert property (@(posedge clk) $fell(rst) |=> (dout != 0 )) ;
          upHighRst2: assert property (@(posedge clk ) $fell(rst) |-> up[->1] |=> !$stable(dout)); // i greater than the prev value hence unstable 
      // i think i can use in upHighRst assertion the non overlapping and the delay operator interchangibly 
            // also i wanna know the use of [-> 1 ] goto operator ? do i used it cause i am expecting up to be high in any interval and also its stronger version i should there ig.
       // curr value of dout must be one less than previous value when up ==0  
       
            upZero : assert property (@(posedge clk) disable iff (rst) !up|-> (dout  == $past(dout)-1  ) || dout==0 || ($past(dout ==0 ))) ; 
        // to comment on the correctness of upZero 
            upZero2: assert property (@(posedge clk) (!up && !rst ) |=> !$stable(dout)); 
              
              
              property p1;
                if(up) 
                  (dout == $past(dout) +1 );
                  else 
                    (dout == $past(dout) -1 );
              endproperty          
              both_property: assert property (@(posedge clk) !rst |-> p1 ); 
                both_prop2: assert property (@(posedge clk) $fell(rst) |=> (dout !=0 )) ; 
  endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Counter behavior

`rst` is an active-high **synchronous** reset because the RTL reads it only at `posedge clk`. The nonblocking assignment updates `dout` after the clocked process has evaluated.

| Sampled condition | Scheduled register update |
|---|---|
| `rst == 1` | `dout <= 4'd0` |
| `rst == 0 && up == 1` | `dout <= dout + 4'd1` |
| `rst == 0 && up == 0` | `dout <= dout - 4'd1` |

The register is four bits, so arithmetic is modulo 16:

- up-counting wraps from 15 to 0;
- down-counting wraps from 0 to 15.

Those wrap transitions are valid changes, not exceptions that need broad `|| dout == 0` escape clauses.

## Verified compile result

The live browser run compiled `counter`, `tb`, and began compiling `counter_assert`, then stopped with:

~~~text
** Error: (vlog-13069) testbench.sv(63):
near "else": syntax error, unexpected else,
expecting "SystemVerilog keyword 'endproperty'".
~~~

Questa reported one `vlog` error and did not elaborate or simulate the design. Therefore, none of the assertion messages in this exact version are verified runtime passes or failures. The remaining observations below are source analysis and corrected teaching forms.

## Two blockers before assertion behavior can be tested

### 1. `property p1` has an extra semicolon before `else`

The semicolon after the true branch terminates the property expression, so the parser sees an orphan `else`:

~~~systemverilog
if (up)
  (dout == $past(dout) + 1);  // terminates the expression too early
else
  ...
~~~

A syntax-only correction is:

~~~systemverilog
property p1;
  if (up)
    (dout == $past(dout) + 4'd1)
  else
    (dout == $past(dout) - 4'd1);
endproperty
~~~

That form compiles, but its sampling alignment still needs correction; current `up` did not produce current sampled `dout`. The timing issue is explained below.

### 2. `clk` starts as `X`

The declaration has no initializer:

~~~systemverilog
reg clk, rst, up;
always #5 clk = ~clk;
~~~

At time zero `clk == X`, and `~X` is still `X`. Repeating that assignment never creates a `0→1` transition, so no `@(posedge clk)` RTL or assertion process runs.

The minimum correction is:

~~~systemverilog
reg clk = 0;
reg rst = 1;
reg up  = 0;
~~~

There is also a stimulus race at 255 ns after clock initialization: the blocking assignment `rst = 0` occurs at the same time as a positive edge. Drive inputs on a negative edge or through a clocking block to make their sampled values deterministic.

## Answers to the questions in the code

### Q: “What is a temp?”

There is no identifier named `temp` in the captured source. If this comment refers to the nearby names:

- `dut` is the instance name of the `counter` design in `tb`;
- `dut2` is the instance name of the bound `counter_assert` checker;
- neither is a temporary variable.

This line:

~~~systemverilog
bind counter counter_assert dut2 (clk, rst, up, dout);
~~~

means: for every instance of module type `counter`, insert an instance of `counter_assert` named `dut2` and connect it to signals resolved in that counter instance's scope. This testbench has one `counter` instance, so it receives one bound checker.

If “temp” means a temporary assertion variable, it is an intermediate snapshot such as:

~~~systemverilog
property example;
  logic [3:0] temp;
  (1, temp = dout) |=> dout == temp + 4'd1;
endproperty
~~~

A property-local `temp` belongs separately to each concurrent assertion attempt. That prevents overlapping attempts from overwriting one shared snapshot.

### Q: Can nonoverlapped implication and a delay operator be used interchangeably?

Only for a specific timing equivalence. With this one-clock antecedent:

~~~systemverilog
A |=> B
~~~

the consequence is checked one property clock later, which has the same check timing as:

~~~systemverilog
A |-> ##1 B
~~~

They are not generally interchangeable concepts:

- `|->` and `|=>` are property implication operators and allow vacuous success when the antecedent does not match;
- `##1` is a sequence concatenation delay;
- `A ##1 B` used as a complete asserted sequence fails when `A` does not match, rather than succeeding vacuously;
- `|=> ##1 B` adds another delay and checks two clocks after a one-cycle antecedent.

So `$fell(rst) |=> P` may be rewritten as `$fell(rst) |-> ##1 P` here, but not as an arbitrary replacement of implication by delay.

### Q: What does `up[->1]` mean, and is it used because `up` may arrive in any interval?

Yes, it can wait through zero or more clock samples where `up` does not match, then ends on the first sampled occurrence of `up == 1`. `[->1]` is **goto repetition of one Boolean match**.

It does not require `up` to remain high, and it is not itself a “stronger” form. It only chooses the first occurrence endpoint. Because the wait can be unbounded, a finite simulation can end while the attempt is still waiting.

If `up` is required to arrive eventually, make completion strong:

~~~systemverilog
$fell(rst) |-> strong(up[->1])
~~~

If the first `up` must also cause a counter change visible at the next sample:

~~~systemverilog
first_up_changes_count: assert property (@(posedge clk)
  disable iff (rst)
  $fell(rst) |-> strong(up[->1] ##1 !$stable(dout))
);
~~~

In the captured stimulus, `up` remains low after the second reset deassertion. A strong eventual-up requirement would therefore expose that missing event at the simulation horizon; a weak unbounded wait may remain incomplete and silent.

### Q: Is `upZero` correct?

Not as an exact down-counter check:

~~~systemverilog
!up |-> (dout == $past(dout)-1)
        || dout==0
        || $past(dout==0)
~~~

There are three problems.

1. **Timing:** `|->` checks in the same sampled cycle. The current sampled `dout` was produced by the previous clock edge, whereas current `up` controls the NBA update that will become visible at the next sampled edge.
2. **Overly broad exceptions:** `dout == 0` passes regardless of whether the transition was correct.
3. **Past Boolean, not past value:** `$past(dout == 0)` returns a one-bit answer to “was `dout` zero previously?” If true, the whole assertion passes regardless of current `dout`. It masks the required wrap from 0 to 15.

The direct modulo-16 check is:

~~~systemverilog
count_down: assert property (@(posedge clk)
  disable iff (rst)
  !up |=> dout == ($past(dout) - 4'd1)
);
~~~

Four-bit arithmetic already makes `0 - 1 == 15`, and `1 - 1 == 0`. No extra zero clauses are needed.

### Q: Is `upZero2` better?

It has better next-cycle timing:

~~~systemverilog
(!up && !rst) |=> !$stable(dout)
~~~

For this modulo counter, decrementing always changes the four-bit value, so it can detect a stuck output. But it only checks “changed,” not “decreased by exactly one modulo 16.” A jump from 7 to 3 would pass. The arithmetic equality above is the stronger functional check.

Also prefer `disable iff (rst)` so a reset asserted while an obligation is pending aborts the count check.

## Review of every captured assertion

### `dout_rst_asserted`

~~~systemverilog
$rose(rst) |-> dout == 0
~~~

This same-sample check is misaligned with a synchronous reset. At the reset edge, the assertion samples old `dout` and the RTL only schedules `dout <= 0` for the NBA region. Use:

~~~systemverilog
$rose(rst) |=> dout == 0
~~~

### `dout_rst_asserted_2`

~~~systemverilog
rst |-> dout == 0
~~~

This may pass on later reset-high edges after `dout` is already zero, but can fail on the first reset edge for the same NBA reason. `rst |=> dout == 0` checks the value produced by every sampled reset-high edge.

### `dout_beh_3`

~~~systemverilog
$rose(rst) |=> rst throughout ((dout == 0)[*1:36])
~~~

The repetition may choose a match only one clock long. A pass does not prove that `dout` stayed zero throughout the complete reset pulse or for 36 clocks. The direct repeated invariant `rst |=> dout == 0` is clearer and stronger for this synchronous design.

### `doutValid`

~~~systemverilog
$fell(rst) |-> !$isunknown(dout)
~~~

This is reasonable if reset has already been sampled high on at least one clock, because `dout` should already contain zero at deassertion. A broader active-mode invariant is:

~~~systemverilog
disable iff (rst) !$isunknown(dout)
~~~

### `doutValid2`

This is an immediate assertion executed in an `always @(posedge clk)` process. It runs in the procedural scheduling flow before the current edge's NBA assignment updates `dout`. At the first reset edge it can therefore see the startup unknown value. It also checks reset and non-reset edges indiscriminately.

Use a clocked concurrent property aligned to the next sampled result, or deliberately check at a later stable phase. Do not treat the immediate assertion as observing the just-scheduled nonblocking update.

### `upBeh`

~~~systemverilog
up |-> (dout == $past(dout) + 1) || dout == 0
~~~

It has the same causal timing mismatch as `upZero`. The `dout == 0` clause can hide an incorrect transition, and modulo addition already models the legal 15→0 wrap. Use:

~~~systemverilog
up |=> dout == ($past(dout) + 4'd1)
~~~

### `upHighRst` and `both_prop2`

These two properties are duplicates:

~~~systemverilog
$fell(rst) |=> dout != 0
~~~

They do not test `up` even though the comment says “when `up=1`,” and any wrong nonzero value passes. A precise first active up-count check is:

~~~systemverilog
($fell(rst) && up) |=> dout == ($past(dout) + 4'd1)
~~~

### `upHighRst2`

The intent—wait for the first future high `up` and then check that `dout` changes—is reasonable. Writing the full expected sequence under one implication is clearer than chaining implication operators:

~~~systemverilog
$fell(rst) |-> strong(up[->1] ##1 !$stable(dout))
~~~

Use `strong` only if the specification truly requires a future `up` event. Otherwise, it is legal for no such event to occur and the property should not demand it.

### `p1` and `both_property`

After the semicolon syntax fix, `p1` still chooses the arithmetic relation using current sampled `up` while comparing current and past sampled `dout`. Current `dout` reflects the prior edge's control, so a change in `up` can make the branch selection wrong.

Two explicit nonoverlapped properties are easier to read and diagnose than one conditional property:

~~~systemverilog
count_up: assert property (@(posedge clk)
  disable iff (rst)
  up |=> dout == ($past(dout) + 4'd1)
);

count_down: assert property (@(posedge clk)
  disable iff (rst)
  !up |=> dout == ($past(dout) - 4'd1)
);
~~~

## A cohesive corrected checker

This is a teaching rewrite, not a replacement for the exact saved file:

~~~systemverilog
module counter_assert (
  input logic       clk,
  input logic       rst,
  input logic       up,
  input logic [3:0] dout
);
  default clocking cb @(posedge clk);
  endclocking

  reset_rise: assert property (
    $rose(rst) |=> dout == 4'd0
  );

  reset_effect: assert property (
    rst |=> dout == 4'd0
  );

  known_when_active: assert property (
    disable iff (rst)
    !$isunknown(dout)
  );

  count_up: assert property (
    disable iff (rst)
    up |=> dout == ($past(dout) + 4'd1)
  );

  count_down: assert property (
    disable iff (rst)
    !up |=> dout == ($past(dout) - 4'd1)
  );
endmodule
~~~

This split gives each failure one meaning: reset timing, knownness, increment, or decrement.

## Revision checks

1. Why does `clk = ~clk` fail to oscillate when `clk` starts at `X`?
2. Why does a synchronous-reset consequence usually need next-sample timing?
3. What exact syntax error makes the parser reject `else` in `p1`?
4. When is `A |=> B` timing-equivalent to `A |-> ##1 B`?
5. What endpoint does `up[->1]` select?
6. Why is goto repetition not automatically strong?
7. Why does `$past(dout == 0)` weaken `upZero`?
8. Why does modulo arithmetic make special wrap escape clauses unnecessary?
9. What does `bind counter counter_assert dut2 (...)` instantiate?
10. Why is exact arithmetic stronger than only checking `!$stable(dout)`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 10 (Assignments), 16 (Assertions), and 23.11 (`bind`)
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
