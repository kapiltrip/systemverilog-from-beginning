# Part 24 — Strong Until

[← Part 23](../23-followed-by-property-operators/README.md) · [SV Assertions index](../README.md) · [Part 25 →](../25-property-local-variables/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [J3Hp](https://edaplayground.com/x/J3Hp) |
| EDA code ID | `7375513` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile errors; the one `rst s_until ce` attempt fails at 55 ns after starting at 5 ns |
| Open EPWave after run | Disabled |

The design pane is placeholder-only. The source's opening comments are retained as the questions this lesson answers.

## Exact browser source

~~~systemverilog
/*
until non overlapping 
until with overlapping should have a common behaviour 
*/
/*
signal 1 should remain high  true until we have sig 2 becoming true 
rst goes dowm 
ce goes high 
$fell(sig1) |-> $rose(sig2) vs sig1 until sig2
in this implication will give us truw and until will give us false 
idk the use of until how tis different its just seem like implication with delay can mimic until 
signal 1 remains high till signal 2 becomes high 
and if they are common for 1 clock tick we can call it overlapping 
signal 1 remains high until signal 2 reaches to its specified value 
  what is theuse of until im wondering 
  */
module tb;
  
  reg clk = 0, rst = 0, ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    rst = 1;
    #30;
    rst = 1;
    #10;
    ce = 0;
    rst = 1;
    #10;
    rst = 0;
    #50;
    ce = 0;
  end
  
  
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #100;
    $finish();
  end
  
  initial A1: assert property (@(posedge clk) rst s_until ce) $info("Success at %0t",$time);

endmodule
    

~~~

Local source: [testbench.sv](testbench.sv).

## Reading `rst s_until ce`

The property begins at the first positive edge because the assertion is inside `initial`. Strong until requires:

1. `rst` to remain true on every required sample before the terminating condition;
2. `ce` eventually to become true.

The clock samples `rst=1` at 5, 15, 25, 35, and 45 ns. The stimulus drives `rst=0` at 50 ns and never drives `ce=1). At the 55 ns sample, the terminating condition is still false and the sustaining condition has become false, so the property can no longer match. Questa reports the failure immediately at 55 ns rather than waiting for `$finish`.

### Q: What does the `s_` change?

`until` is the weak form: if the left condition remains true forever and the right condition never arrives, the property can remain weakly satisfied. `s_until` is strong: the right condition must occur in finite time.

In this exact run, both weak and strong forms would still fail at 55 ns because `rst` drops before `ce`. To isolate the strength distinction, hold `rst` high through the end and keep `ce` low. The weak property can then survive the unfinished horizon, while the strong one must fail for lack of a terminating `ce`.

### Q: What is overlapping until?

SystemVerilog also provides `until_with` and `s_until_with`. The `_with` forms require the left operand to remain true on the same sample that satisfies the right operand. The plain `until` family does not require that overlap at the terminating sample.

For “reset stays asserted before enable, but may drop when enable arrives,” plain `s_until` can fit. For “reset is still asserted on the enable sample,” use `s_until_with`.

### Q: Why not write an implication with a delay?

A bounded implication such as `rst |-> ##[1:5] ce` checks for `ce` in a selected window, but it does not by itself require `rst` on every intermediate sample. Adding that level-hold condition recreates an until-like obligation. `s_until` directly expresses “maintain P until Q definitely occurs,” especially when the wait length is not predetermined.

## A stimulus that demonstrates success

A successful plain strong-until experiment would raise `ce` before dropping `rst`:

~~~systemverilog
initial begin
  rst = 1;
  ce  = 0;
  repeat (4) @(posedge clk);
  ce = 1;
  @(posedge clk);
  rst = 0;
end
~~~

Remember that assignments made on a clock edge occur after the concurrent assertion's Preponed sample. Driving between edges makes the intended sampled values clearer.

## Revision checks

1. Which sampled edge first observes `rst=0`?
2. Why can this property fail before the simulation ends?
3. How would keeping `rst=1` expose weak versus strong completion?
4. What same-sample requirement does `s_until_with` add?
5. Why is a delayed implication not automatically equivalent to until?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

