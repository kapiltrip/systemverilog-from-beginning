# Part 07 — Current and Sampled Values

[← Part 06](../06-overlapped-and-nonoverlapped-implication/README.md) · [SV Assertions index](../README.md) · [Part 08 →](../08-reusable-sequences-and-properties/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 07 - Current and Sampled Values` |
| Stable playground | [JGnz](https://edaplayground.com/x/JGnz) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 errors; output repeatedly shows current `a=0` and sampled `a=1` |
| EPWave | Disabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
// system task 
// $info reactive region 
// $sample preoponed value 
// $rose positive edge 2 clock tick available then it will tell 1 otherwise 0 
// in case of 1 clock tick , default values are considered default i.e x to 1 or 0 to 1 in reg or z to 1 or 0 to 1 in wire 
module tb;
  reg a =1; 
  reg clk = 0 ; 
  always #5 clk = ~ clk ; 
  always #5 a = ~a ; 
  always @(posedge clk) begin
    $info("Value of a is %0b in reactive region and $sampled(a) in preponed region is " , a, $sampled(a));  // monitor strobe  from a reactive region 
    
  end                                                                 ///sampled will tell preopned region value
  assert property (@(posedge clk) (a == $sampled(a))) $info("Sampled time is %0t with a value preopned region val  %0b" , $time , $sampled(a)); 
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      //repeat (20) @(posedge clk) ; 
      #50;
      $finish();
    end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). No substantive design-pane code was present.

## “Current” value versus assertion sample

There can be several values associated with one signal during one simulation time slot:

- the value that existed when the time slot began;
- the value sampled for a concurrent assertion in Preponed;
- a value written later by Active-region blocking code;
- a still later value committed by an NBA;
- the stable value visible after all regions finish.

`$sampled(a)` retrieves the value sampled for the assertion clocking event. The call is not itself an executable action in Preponed; rather, it returns the sample that was taken there. This distinction matters because the same sampled value can later be referenced while a property or its action block is being processed.

## Important correction to the source comments

The statement below is inside an ordinary procedural `always` block:

~~~systemverilog
always @(posedge clk)
  $info(...);
~~~

It executes in the **Active region**, not the Reactive region. A system task does not choose its region merely by being `$info`. It executes in the region of the process that called it. By contrast, the pass/fail action block belonging to a concurrent assertion is scheduled in the Reactive region.

The standard region map is therefore:

~~~text
Preponed : concurrent assertion samples a and clk
Active   : ordinary always blocks run; blocking assignments can update a
Observed : concurrent property is evaluated from sampled values
Reactive : concurrent assertion pass/fail action block runs
Postponed: $strobe and $monitor-style final-value reporting
~~~

## Why the live output differs

Both of these processes wake every 5 ns:

~~~systemverilog
always #5 clk = ~clk;
always #5 a   = ~a;
~~~

At times 5, 15, 25, 35, and 45 ns, `clk` rises and `a` toggles in the same time slot. The assertion sample was already taken before Active-region updates. The ordinary `always @(posedge clk)` then observes the Active-region current value. In the verified run it printed current `a=0`, while `$sampled(a)` returned `1`.

This demonstration depends on same-time scheduling and is race-prone as a stimulus style. It is useful for exposing regions, but a production testbench should normally drive `a` away from the sampling edge.

## What the concurrent assertion really compares

~~~systemverilog
assert property (@(posedge clk) (a == $sampled(a)))
~~~

Inside a concurrent property, a plain reference to an ordinary design signal such as `a` is already evaluated from its sampled value. Therefore this property effectively compares the sample with itself. It is expected to pass; it does not compare a Reactive-region live value with a Preponed value.

To inspect the current procedural value for teaching purposes, do so outside the property, as the `always` block does. To make a real verification rule, compare distinct sampled quantities or a current sample with history:

~~~systemverilog
assert property (@(posedge clk) a == $past(a)); // sampled stability
~~~

## `$rose` and the first sampled tick

`$rose(expr)` is true when the least-significant bit changed from `0`, `X`, or `Z` in the preceding sample to `1` in the current sample. It returns that Boolean transition result; it does not return the current Preponed sample itself. `$sampled(expr)` is the function that retrieves the current sampled value. At the first relevant clock, the language supplies the sampled-value function's defined default history rather than an actual earlier design clock. Consequently, first-tick results must not be casually interpreted as an observed hardware transition.

For a vector, `$rose(bus)` only examines the least-significant bit. Use an explicit vector comparison when the requirement concerns the complete bus.

## A race-free teaching version

~~~systemverilog
always #5 clk = ~clk;

initial forever begin
  @(negedge clk);
  a = ~a;
end

show_history: assert property (@(posedge clk) 1)
  $info("sample=%0b previous=%0b rose=%0b",
        $sampled(a), $past(a), $rose(a));
~~~

Now `a` changes half a cycle before it is sampled, so the trace represents intentional stimulus rather than same-slot process ordering.

## Revision checks

1. Does `$sampled(a)` execute an assignment in Preponed?
2. Why does `$info` in the ordinary `always` block execute in Active?
3. Why is `a == $sampled(a)` nearly tautological inside this concurrent property?
4. Which bit does `$rose` examine when passed a vector?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 4.4 and 16.9.3
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
- [Foundation 00 — all scheduling regions](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
