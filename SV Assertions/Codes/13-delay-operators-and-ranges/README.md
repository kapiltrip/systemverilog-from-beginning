# Part 13 — Delay Operators and Delay Ranges

[← Part 12](../12-clocking-events-and-disable-iff/README.md) · [SV Assertions index](../README.md) · [Part 14 →](../14-strong-unbounded-eventuality/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 13 - Delay Operators and Delay Ranges` |
| Stable playground | [LSZN](https://edaplayground.com/x/LSZN) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 compile errors; 6 assertion failures (`A1` at 35/65/95 ns and `A2` at 55/85/115 ns) |
| EPWave | Enabled by the source's VCD dump |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
//delay operators 
//constant delay we know when to evaluate 
// variable delay , we have an idea that censequent must become true in the range ##(min, max )delay 
// unbounded delay : if req becomes high ack must also become high somewhere during the simulation 
// ##[: $]
// cause overlapping and non overlapping alone wont allow to evaluate after 1 clock tick
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 
 always #5 clk = ~clk;
 
 initial begin
   repeat(3) begin
     #1;
     req = 1;
     #5;
     req = 0;
     repeat(3) @(negedge clk);
   end
 end
 
  initial begin
    for(int i =0 ; i<15;i++)begin
      repeat(3) @(posedge clk);
      ack = $urandom_range(0,1); 
      @(posedge clk); 
      ack=0; 
      
    end
  end
 
  A1: assert property (@(posedge clk) $rose(req) |=> ##2 $rose(ack)) $info("Success at %0t",$time);
    A2: assert property (@(posedge clk) $rose(req) |-> ##[2:5] $rose(ack) ) $info("Success with min 2 and max 5 delay at %0t" , $time); 
      
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #200;
 $finish();
 end
 
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane is placeholder-only.

## What `##` means

`##` is a **cycle delay inside a sequence**. A cycle means one assertion sampling event to the next, not a number of nanoseconds. Because this property is clocked by `@(posedge clk)`, one assertion cycle is one rising-clock edge.

| Form | Meaning from the current sequence endpoint |
|---|---|
| `##2 expr` | `expr` must match exactly two sampling ticks later |
| `##[2:5] expr` | `expr` may match 2, 3, 4, or 5 ticks later |
| `##[1:$] expr` | `expr` may match any finite tick from 1 onward |

Two source comments need correction:

- A delay range uses square brackets, `##[min:max]`, not `##(min,max)`.
- `##[:$]` is incomplete. Give the lower bound, for example `##[1:$]`.

The word “variable” in the comment means that the **matching time can vary within a fixed range**. It does not mean that ordinary runtime variables may be used freely as SVA delay bounds; standard sequence delay bounds are constant expressions (with `$` allowed as an unbounded upper endpoint).

## The crucial `|->` versus `|=>` calculation

Let the antecedent `$rose(req)` match at sample `T0`.

~~~text
A2: req |-> ##[2:5] ack
         consequent begins at T0
         ack may match at T2, T3, T4, or T5

A1: req |=> ##2 ack
         |=> contributes a one-tick nonoverlapped shift
         ##2 contributes two more ticks
         ack must match at T3
~~~

An easy rule is:

~~~systemverilog
a |=> consequent
// timing-equivalent idea:
a |-> ##1 consequent
~~~

Therefore `|=> ##2` is not “two clocks after `req`”; it is three assertion sampling ticks after the antecedent endpoint. If the intended deadline is exactly two ticks after `req`, use `|-> ##2` or `|=> ##1`.

## Why the random `ack` can be surprising

The generator changes `ack` with blocking assignments immediately after `@(posedge clk)`. Concurrent assertions sample `ack` in the Preponed region, before that Active-region assignment. Consequently, an assignment that visually occurs “at this posedge” cannot be seen by the assertion until the next clock sample.

That creates this ordering:

~~~text
posedge N, Preponed: assertion samples the old ack
posedge N, Active:   generator assigns the new ack
posedge N+1:         assertion can observe that assigned value
~~~

The random value also makes the pass/fail trace seed-dependent. For a deterministic lesson, drive a known `ack` schedule on a clocking block or on the opposite edge.

The verified Questa 2025.2 run produced no compiler errors. With that run's random values, every triggered attempt failed: `A1` at 35, 65, and 95 ns, and `A2` at 55, 85, and 115 ns. These are property failures caused by the generated stimulus, not language or compilation failures.

## Vacuity and termination

Each implication attempt is nonvacuous only when `$rose(req)` is true. At clock samples where it is false, the implication passes vacuously. `$assertvacuousoff(0)` suppresses vacuous-success action execution; it does not disable genuine successes or failures.

`A2` has a finite upper bound, so every triggered attempt must either find an `ack` rise within five ticks or fail. Unbounded behavior is treated separately in Part 14.

## Revision checks

1. Why does `|=> ##2` check one tick later than `|-> ##2`?
2. Which four endpoints are legal for `##[2:5]`?
3. Why can a blocking assignment to `ack` at a posedge miss that edge's assertion sample?
4. Does `$` mean “pass eventually,” or merely “no finite upper bound”?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) — concurrent assertions and sequence operators are standardized in Clause 16
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.7, 16.9, and 16.12
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
