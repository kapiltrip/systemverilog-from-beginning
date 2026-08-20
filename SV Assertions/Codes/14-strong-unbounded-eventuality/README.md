# Part 14 — Strong Unbounded Eventuality

[← Part 13](../13-delay-operators-and-ranges/README.md) · [SV Assertions index](../README.md) · [Part 15 →](../15-consecutive-repetition-ranges/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 14 - Strong Unbounded Eventuality` |
| Stable playground | [ZTL5](https://edaplayground.com/x/ZTL5) |
| Simulator | Siemens Questa 2025.2 |
| Expected result | One nonvacuous strong-property failure because `ack` never rises |
| Verification status | Exact saved source recovered; final live rerun is pending Edge control |
| EPWave | Enabled by the source's VCD dump |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 
 always #5 clk = ~clk;
 
 initial begin
 #2;
 req = 1;
 #5;
 req = 0;
 end
 
 initial begin
 #120;
 ack = 0;
 #10;
 ack = 0;
 
 end
  a1: assert property (@(posedge clk) $rose(req) |-> strong( ##[1:$] $rose(ack))) $info("success at %0t", $time); 
    else $error("cant find any ack in the total time "); 
    //unbounded delay is weak in nature so simulater will not say anything , related to that 
    
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #140;
 $finish();
 end
 
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane is placeholder-only.

## What the property asks

~~~systemverilog
$rose(req) |-> strong(##[1:$] $rose(ack))
~~~

Read it as:

> Whenever a sampled rising edge of `req` occurs, there must be a sampled rising edge of `ack` at some finite future positive edge, at least one clock later.

The range `##[1:$]` has no fixed upper bound. It creates candidate endpoints one tick later, two ticks later, three ticks later, and so on.

## Why `strong(...)` matters

An unbounded sequence can remain unfinished until simulation ends. If the sequence is treated weakly, “there might have been a future match if simulation had continued” is not forced into a failure. `strong(sequence)` changes that: at least one finite match of the sequence must occur.

| Consequent | If simulation ends before `ack` rises |
|---|---|
| `##[1:$] $rose(ack)` with weak sequence semantics | may remain non-failing/inconclusive at termination |
| `strong(##[1:$] $rose(ack))` | fails because no finite match completed |

`strong` does not make the search faster and does not impose a numerical timeout. It only changes the required end-of-simulation outcome. If the protocol has a real deadline, a bounded range such as `##[1:8]` is clearer and fails at the ninth relevant sample rather than waiting for simulation termination.

## Exact stimulus result

`req` becomes `1` at 2 ns and returns to `0` at 7 ns. At the 5 ns positive edge, the assertion samples a rise of `req`, so one nonvacuous attempt starts.

`ack` begins at `0`; later assignments at 120 and 130 ns merely assign `0` again. Therefore `$rose(ack)` never becomes true. The strong consequent has no finite match before `$finish` at 140 ns, so the attempt is expected to execute the failure action:

~~~text
cant find any ack in the total time
~~~

The later clock samples where `$rose(req)` is false create vacuous implication successes, but `$assertvacuousoff(0)` suppresses their pass action.

## Strong is not the same as overlapped or nonoverlapped

These concepts answer different questions:

- `|->` versus `|=>` chooses when the consequent may begin.
- `##[1:$]` chooses the set of legal future match points.
- `strong(...)` requires a finite match before termination.

Changing `|->` to `|=>` would shift the search by one tick; it would not solve the weak-termination problem.

## Practical bounded alternative

If `ack` is required within 16 clocks, state the real contract:

~~~systemverilog
ack_within_16: assert property (@(posedge clk)
  $rose(req) |-> ##[1:16] $rose(ack)
);
~~~

Use the unbounded strong form only when “eventually, with no architectural maximum” is genuinely the requirement.

## Revision checks

1. Why does `$` not automatically make a property strong?
2. What event creates the single nonvacuous attempt in this source?
3. Why do assignments `ack=0` at 120 and 130 ns not satisfy `$rose(ack)`?
4. When is a bounded deadline preferable to `strong(##[1:$] ...)`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.7, 16.12.1, and 16.12.2
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

