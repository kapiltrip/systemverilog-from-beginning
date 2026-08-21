# Part 22 — `nexttime` and `s_nexttime`

[← Part 21](../21-eventually-and-always-property-operators/README.md) · [SV Assertions index](../README.md) · [Part 23 →](../23-followed-by-property-operators/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [VsLs](https://edaplayground.com/x/VsLs) |
| EDA code ID | `7375435` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | Weak and strong checks pass when five future clocks exist; 10 pending strong attempts fail at the 100 ns simulation horizon |
| Open EPWave after run | Disabled |

The design pane is placeholder-only. The exact source is retained, including indentation that can obscure which assertion is controlled by `initial`.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
// next time certain behaviour to hold 
// reset should be high after 5 clk tick 
module tb;
  
    
  reg clk = 0, rst = 0;
  always #5 clk = ~clk;
  
  
   initial begin
     repeat(5) @(posedge clk);
     rst = 1;
  end
  
  
  initial a1: assert property (@(posedge clk ) nexttime[5] rst ) $info("reset is high at posedge  after 5 clock tick at time %0t" ,$time ) ; 
    a2: assert property (@(negedge  clk ) nexttime[5] rst ) $info("reset is high at negedge after 5 clock tick at time %0t" ,$time ) ; 
    a3: assert property (@(posedge clk ) s_nexttime[5] rst ) $info("reset is high after 5 clock tick at time %0t" ,$time ) ; 
    a4: assert property (@(negedge  clk ) s_nexttime[5] rst ) $info("reset is high after 5 clock tick at time %0t" ,$time ) ; 
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
    $assertvacuousoff(0);
    #100;
    $finish();
  end 

  
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## The two operators

| Form | When the operand is checked | What happens if the simulation ends too early |
|---|---|---|
| `nexttime[5] rst` | On the fifth future occurrence of its clocking event | Weak: an attempt without enough future clocks does not fail |
| `s_nexttime[5] rst` | On the same fifth future occurrence | Strong: an attempt without enough future clocks fails |

The count is in occurrences of the property's clocking event, not in nanoseconds. The positive-edge and negative-edge properties therefore have separate sampling streams.

### Q: Why do the first positive-edge checks pass at 55 ns?

The one-shot `a1` attempt begins at the first positive edge, 5 ns. Its five future positive edges are 15, 25, 35, 45, and 55 ns. The stimulus assigns `rst = 1` in the Active region of the 45 ns positive edge, after concurrent assertions have already sampled that edge. The new value is first sampled at 55 ns, exactly where `nexttime[5]` checks it.

The first negative-edge attempt begins at 10 ns and checks the fifth future negative edge at 60 ns, so the log reports the corresponding `a2` and `a4` successes at 60 ns.

### Q: Why does only `a1` run once?

Only this statement is part of the labeled `initial` statement:

~~~systemverilog
initial a1: assert property (...);
~~~

The semicolon ends that procedural statement. Labels `a2`, `a3`, and `a4` begin module-level concurrent assertion directives, so they start a new attempt on every event of their respective clocks. Visual indentation does not extend the scope of `initial`.

### Q: Where do the 10 errors at 100 ns come from?

The early `s_nexttime` attempts have five future clocks and pass. Later attempts start too close to `$finish` to reach their fifth future sampling edge:

- five positive-edge `a3` attempts remain incomplete;
- five negative-edge `a4` attempts remain incomplete.

Because the operator is strong, Questa converts those incomplete obligations into failures at the 100 ns horizon. Equivalent late `nexttime` attempts remain weakly incomplete and do not add errors.

## Testing value failure separately from horizon failure

This stimulus makes `rst` high permanently after 45 ns, so completed checks succeed. To test an ordinary value failure, keep the simulation long enough to supply five future clocks but drive `rst` low at the target edge. To test only the strength distinction, keep the operand true and end before the fifth future edge, as this playground already does for its late attempts.

This separation matters: “operand was false at the target” and “the target clock never arrived” are different failure mechanisms.

## Revision checks

1. Which five future positive edges are counted from a 5 ns start?
2. Why is the 45 ns assignment not sampled until 55 ns?
3. Which source semicolon ends the `initial` statement?
4. Why do only the strong late attempts fail at `$finish`?
5. How would you create a completed `nexttime[5]` value failure?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

