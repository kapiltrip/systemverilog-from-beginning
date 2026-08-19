# Part 08 — Reusable Sequences and Properties

[← Part 07](../07-current-and-sampled-values/README.md) · [SV Assertions index](../README.md) · [Part 09 →](../09-fell-and-sampled-transitions/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 08 - Reusable Sequences and Properties` |
| Stable playground | [Mx6p](https://edaplayground.com/x/Mx6p) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 errors; `p1` passes at 35 ns and `p2` passes at 45 ns |
| EPWave | Disabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg ce=0,wr=0,rd=0,clk =0,rst=0;
  always #5 clk = ~ clk ; 
  initial begin
    rst=1; 
    #30; 
    rst=0; 
  end
  initial begin
    ce=0;
    #30;
    ce=1;
    
  end
  initial begin
    #30;
    wr=1;
    #10;
    rd=1;
    #20;
    wr=0;
    rd=0;   
  end
  
  sequence cewr(logic a , logic b);
      a && b; 
  endsequence 
  
  property p1;
    (@(posedge clk) $fell(rst) |-> cewr(ce,wr));   
  endproperty
  
  property p2(logic a , logic b );
    (@(posedge clk) $fell(rst) |=> (a&&b ));   
  endproperty
  
     CHECK_WRP1 : assert property (p1) $info("checked by p1 passes at time %0t" , $time);
       CHECK_WRP2 : assert property (p2(ce,rd)) $info("check passes through p2 at time %0t" , $time);  
     
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      repeat (20) @(posedge clk) ; 
      $finish();
    end
         
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane contains only the default placeholder.

## Why name a sequence?

~~~systemverilog
sequence cewr(logic a, logic b);
  a && b;
endsequence
~~~

A sequence describes a temporal match. This one is only one clock long: both formal arguments must be true at its evaluation tick. Naming it still provides value because the expression can be reused, reviewed, and later expanded without rewriting every property.

The formal names `a` and `b` are local placeholders, not the module signals `a` and `b`. The invocation `cewr(ce,wr)` binds `a` to `ce` and `b` to `wr` for that use.

For readability, semantic names are often better:

~~~systemverilog
sequence both_high(logic enable, logic request);
  enable && request;
endsequence
~~~

## Named properties and formal arguments

`p1` has no formal arguments and directly refers to module signals:

~~~systemverilog
property p1;
  @(posedge clk) $fell(rst) |-> cewr(ce,wr);
endproperty
~~~

`p2` is parameterized:

~~~systemverilog
property p2(logic a, logic b);
  @(posedge clk) $fell(rst) |=> (a && b);
endproperty
~~~

The assertion `p2(ce,rd)` specializes the property for `ce` and `rd`. The same property shape could be reused with another pair of signals. This is textual verification reuse with typed formal arguments; it does not create a procedural call stack like a task or function.

## The live timeline

The clock rises at 5, 15, 25, 35, 45 ns. Reset is assigned low at 30 ns, so the first positive-edge sample that detects its falling transition is at 35 ns.

| Time | Sampled event | Consequence |
|---:|---|---|
| 25 ns | previous reset sample is high | establishes history |
| 30 ns | `rst=0`, `ce=1`, and `wr=1` are driven between assertion edges | values settle before next sample |
| 35 ns | `$fell(rst)` is true; `ce && wr` is true | overlapped `p1` passes now |
| 40 ns | `rd=1` | settles before next edge |
| 45 ns | nonoverlapped consequent of `p2` checks `ce && rd` | `p2` passes now |

This explains the exact verified output: `p1` at 35 ns and `p2` at 45 ns.

## `|->` versus `|=>` in these properties

`p1` uses overlapped implication, so `cewr(ce,wr)` begins on the same sampled tick at which `$fell(rst)` matches. Because the sequence is a one-tick Boolean expression, both `ce` and `wr` must be sampled high at 35 ns.

`p2` uses nonoverlapped implication, so `(ce && rd)` begins at the next positive edge. This is why `rd` may become high at 40 ns and still satisfy the attempt created at 35 ns.

## What `$fell(rst)` means

`$fell(rst)` compares the current sampled least-significant bit with its previous sampled value. It is not triggered directly at the procedural assignment at 30 ns. With the property clocked by `posedge clk`, the transition is recognized at the next assertion sampling event.

This source treats reset as active-high because deassertion is a transition from `1` to `0`. For an active-low reset named `rst_n`, deassertion would normally be `$rose(rst_n)`.

## A more production-like formulation

Reset deassertion and required behavior should be stated from the actual design specification. If the intent is “on the first clock after active-high reset falls, `ce` and `rd` must both be high,” a direct property is:

~~~systemverilog
reset_release_enables_read: assert property (
  @(posedge clk)
  $fell(rst) |=> ce && rd
);
~~~

If reset may be unknown, add a knownness check rather than allowing an unknown antecedent to hide the obligation:

~~~systemverilog
reset_known: assert property (@(posedge clk) !$isunknown(rst));
~~~

## Revision checks

1. When are the actual arguments of `cewr(ce,wr)` evaluated?
2. Why does `$fell(rst)` become true at 35 ns instead of 30 ns?
3. Which exact change makes `p2` finish at 45 ns?
4. When is a named sequence clearer than repeating its Boolean expression?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
