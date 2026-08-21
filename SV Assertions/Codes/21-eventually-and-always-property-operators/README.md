# Part 21 — `eventually`, `s_eventually`, and `always`

[← Part 20](../20-throughout-within-and-intersect/README.md) · [SV Assertions index](../README.md) · [Part 22 →](../22-nexttime-and-strong-nexttime/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [v2k2](https://edaplayground.com/x/v2k2) |
| EDA code ID | `7375369` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | Compilation succeeds; undefined `$into` actions cause two execution errors at 65 ns; `a2` reports an assertion error at 120 ns |
| Open EPWave after run | Disabled |

The exact source is intentionally preserved, including the misspelled action task. The design pane contains only the default placeholder.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
//eventually and seventually 
//property occured during simulation 
// seventually ce; somewhere during the simulation we r ecpecting that, ce goes high the we will get the failure 
//eventually ce 
/*
ce asserted eventually 
rst must go down within 3 to 10 clock ticks 
ce assert eventually and then stay high 
rst deasserted eventually and stay low 
eventually we must know a range 
  eventually [min: max]
  seventually with and without a range (must hold within)
  // strong vs weak property 
  if 5 clock ticks 
    eventually [3:10] ce; 
    only once it may trigger so we need initial block  initial seventually and always 
*/
module tb;
  
    
  reg clk = 0, rst = 1,  ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    #20;
    rst = 1;
  #40;
    rst = 0;
    ce = 1;
    #50;
    rst = 0;
    #10;
    ce = 0;
    
    
  end
  // do not have a range use seventually 
  initial a1:  assert property (@(posedge clk ) s_eventually !rst ) $into("success at %0t" , $time); 
  // reset become low eventually and stayed low 
  initial a2:  assert property (@(posedge clk ) s_eventually always  !rst ) $into("success at %0t" , $time); 
  // reset must go down withing 3to 10 clock ticks 
  initial a3:  assert property (@(posedge clk ) eventually [3:10] !rst ) $into("success at %0t" , $time); 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #120;
    $finish();
  end 
 

endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## What the three properties ask

| Assertion | Temporal requirement |
|---|---|
| `s_eventually !rst` | At some finite future sampled clock, reset must be low |
| `s_eventually always !rst` | A finite witness must be found from which reset remains low forever |
| `eventually [3:10] !rst` | Reset must be low on at least one sampled clock 3 through 10 clocks after the attempt begins |

Each assertion is preceded by `initial`, so it creates one property evaluation rather than starting a fresh attempt at every positive edge.

Reset is assigned low at 60 ns. Concurrent assertions sample before Active-region assignments, so the first clock that observes `!rst` is the 65 ns positive edge. That is within the bounded 3–10 clock window and is also a witness for the simple `s_eventually !rst`.

### Q: Why do successful checks produce simulator errors?

The pass action calls `$into`, which is not a standard SystemVerilog system task:

~~~systemverilog
$into("success at %0t", $time)
~~~

Questa accepts the property syntax, warns during loading that `$into` is undefined, and then raises an execution error when the successful `a1` and `a3` actions try to call it at 65 ns. The intended informational action is:

~~~systemverilog
$info("success at %0t", $time)
~~~

This is an action-block typo, not a failure of `s_eventually` or bounded `eventually`.

### Q: Why does `s_eventually always !rst` fail at the end?

The nested `always !rst` describes an unbounded suffix. Even though reset stays low from 60 ns through the end of this stimulus, a finite simulation cannot demonstrate that it will remain low forever. Wrapping that unbounded condition in strong eventuality requires a finite successful witness that never becomes available, so the attempt is unresolved until the simulation horizon and Questa reports the failure at 120 ns.

For a simulation-oriented requirement, give the stability interval a finite endpoint—for example, a fixed repetition count or a protocol completion event.

### Q: Is `eventually [3:10] !rst` legal syntax?

Yes. Questa compiles it without an SVA grammar error. The range belongs to the property operator and selects the allowed future sampling offsets. It is different from writing a separate exact delay followed by a bare bracket range.

## Strong, weak, and finite endpoints

Strong eventuality is useful when “it must happen” is the requirement: reaching the end without a finite match must fail. A bounded range also supplies a definite decision point. An unbounded `always` condition, however, expresses an invariant over the remaining future, so it cannot normally produce an early finite proof in simulation.

A practical pair of checks often separates the obligations:

~~~systemverilog
// Reset must deassert within ten clocks.
eventually [1:10] !rst

// Once low, reset must remain low through a finite transaction.
$rose(transaction_start) |-> !rst throughout transaction_window
~~~

The exact endpoint must come from the protocol, not from an arbitrary number chosen only to make simulation end.

## Revision checks

1. Which sampled edge first observes the reset assignment made at 60 ns?
2. Why are `a1` and `a3` temporal successes even though the log contains execution errors?
3. What spelling change fixes the action block without changing the property?
4. Why can an unbounded `always` suffix not be proven by a finite trace?
5. When should a protocol requirement use a bounded eventuality instead?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

