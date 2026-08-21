# Part 23 — Followed-By Property Operators

[← Part 22](../22-nexttime-and-strong-nexttime/README.md) · [SV Assertions index](../README.md) · [Part 24 →](../24-strong-until/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [CdVx](https://edaplayground.com/x/CdVx) |
| EDA code ID | `7375512` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile errors; `A3` and `A4` fail at 5 ns; 2 assertion errors total |
| Open EPWave after run | Disabled |

The design pane is placeholder-only. The exact source keeps the original comparison among implication and followed-by operators.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
//follow by operator 
//#-# and #=# antecedant true then evaluate to true , also it doesnt give a vacuous success 
module tb;
  
  reg clk = 0, rst = 0, ce = 0;
  always #5 clk = ~clk;
  
  
  initial begin
    rst = 0;
    #20;
    ce = 1;
    rst = 0;
    #20;
    ce = 0;
  end
  
  
  
  
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
   // $assertvacuousoff(0);
    #50;
    $finish();
  end
  
  initial A1 : assert property (@(posedge clk) rst[*2] |-> ##1 ce[*2]) $info("A1 Suc at %0t",$time); 
  
  initial A2 : assert property (@(posedge clk) rst[*2] |=> ce[*2]) $info("A2 Suc at %0t",$time);  
 
    initial A3 : assert property (@(posedge clk) rst[*2] #=# ce[*2])$info("A3 Suc at %0t",$time);  //overlapping operator 
  
  initial A4 : assert property (@(posedge clk) rst[*2] #-# ##1 ce[*2])$info("A4 Suc at %0t",$time); 
    
    
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Four superficially similar properties

| Assertion | Form | If `rst[*2]` does not match |
|---|---|---|
| `A1` | `rst[*2] |-> ##1 ce[*2]` | Implication succeeds vacuously |
| `A2` | `rst[*2] |=> ce[*2]` | Implication succeeds vacuously |
| `A3` | `rst[*2] #=# ce[*2]` | Overlapped followed-by fails |
| `A4` | `rst[*2] #-# ##1 ce[*2]` | Nonoverlapped followed-by fails |

The main lesson is not just an offset difference. Followed-by is nonvacuous: failure of its left sequence is a property failure rather than an automatic vacuous success.

### Q: Why do `A3` and `A4` fail at 5 ns?

Every assertion is inside an `initial` statement and therefore makes one attempt beginning on the first positive edge. `rst` is low in the first sampled state, so `rst[*2]` cannot even complete its first repetition.

That false antecedent makes `A1` and `A2` vacuous. It makes followed-by properties `A3` and `A4` fail immediately. Questa consequently reports both errors at 5 ns and never needs to evaluate their `ce` sequences.

### Q: What is the timing difference between `#=#` and `#-#`?

When the left sequence does match:

- `#=#` is overlapped: the right property begins at the left sequence's endpoint.
- `#-#` is nonoverlapped: the right property begins on the next sampling event.

The source then puts an explicit `##1` at the start of `A4`'s right side. That adds another sequence delay after the nonoverlapped boundary. It is not the same timing as `A2` unless the full endpoint arithmetic is checked carefully.

### Q: How should the stimulus be changed to expose RHS timing?

Drive `rst` high before the first sampled edge and hold it high for two positive edges. Then place `ce` so that it covers two sampled clocks at each candidate RHS start. Run the overlapped and nonoverlapped forms separately and record their start/end timestamps. The current stimulus is useful for vacuity, but it cannot demonstrate successful followed-by offsets because the left sequence never matches.

## Why followed-by exists

Implication is ideal for “whenever trigger A occurs, response B must follow,” because no trigger means no violation. Followed-by is useful when the left sequence itself is mandatory as part of the property. That difference must come from the specification; replacing implication only to suppress vacuous passes changes the requirement.

The source comment correctly points toward “no vacuous success,” but the live result shows the consequence: a missing left sequence is now an actual error.

## Revision checks

1. Why does a low `rst` make `A1` vacuous but `A3` false?
2. When does the RHS of `#=#` begin relative to the LHS endpoint?
3. What extra offset is introduced by `#-# ##1`?
4. Why does this stimulus not test successful `ce[*2]` timing?
5. When is vacuous implication the correct specification behavior?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

