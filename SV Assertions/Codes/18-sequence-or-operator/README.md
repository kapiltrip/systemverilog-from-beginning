# Part 18 — Sequence `or` Operator

[← Part 17](../17-nonconsecutive-and-goto-repetition-ranges/README.md) · [SV Assertions index](../README.md) · [Part 19 →](../19-sequence-and-not-strong/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [aVj3](https://edaplayground.com/x/aVj3) |
| EDA code ID | `7374026` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ps` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile errors; assertion at line 55 fails at 35 ns after starting at 25 ns |
| Open EPWave after run | Disabled |

The design pane contains only EDA Playground's placeholder, so this part stores only `testbench.sv`. The blank browser Name is recorded exactly; the descriptive local title is not presented as a saved EDA name.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
// boolean operator and throughout operator adn within operator 
// 3 boolean operator and or not 
// if both sequence behave same throughout the simulation 
// and or(smallest sequence become true ) not 
// if start asserted then both a and b should remain high for two consecutive clock ticks 
// b becomes high in the next clock tick after a become high 
module tb;
 reg clk = 0,a,b,start,done;
 
 always #5 clk = ~clk;
 
 initial begin
 start = 0;
 #20;
 start = 1;
 #10;
 start = 0;
 end
 
 initial begin
 done = 0;
 #60;
 done = 1;
 #10;
 done = 0;
 end
 
 
 
 
 initial begin
 a = 0;
 #30;
 a = 1;
 #20;
 a = 0;
 end
 
 initial begin
 b = 0;
 #40;
 b = 1;
 #20;
 b = 0;
 end

sequence s1;
  a[*2];
endsequence
  sequence s2;
    ##1 b[*2]; 
  endsequence
  assert property (@(posedge clk) $rose(start) |-> s1 or s2 ) $info("sequence behaves the same at time %0t", $time ) ; 
    
 initial begin
 #100;
 $finish;
 end

 
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## What does the sequence `or` operator mean?

For two sequences that start on the same assertion attempt, `s1 or s2` matches when **at least one** operand matches. It is temporal alternation, not the Boolean expression `s1 || s2` and not a requirement that both operands succeed.

The two branches may have different lengths:

~~~systemverilog
sequence s1;
  a[*2];
endsequence

sequence s2;
  ##1 b[*2];
endsequence
~~~

- `s1` requires `a` on the starting sample and the following sample.
- `s2` waits one clock, then requires `b` on two consecutive samples.
- A quick failure of one branch does not fail the `or` while the other branch still has a possible match.
- A successful branch is enough; the other branch does not also need to complete.

## Why does the verified assertion fail?

The 10 ns clock has positive edges at 5, 15, 25, 35, 45 ns, and so on. `start` is assigned high at 20 ns, so `$rose(start)` is sampled at 25 ns. Because the property uses overlapped implication, both sequence alternatives start at that same 25 ns sample.

| Sample | `a` | `b` | Relevant requirement |
|---:|---:|---:|---|
| 25 ns | 0 | 0 | `s1` immediately fails because its first `a` is false |
| 35 ns | 1 | 0 | `s2` reaches its delayed first `b`, which is false |
| 45 ns | 1 | 1 | Too late to rescue the already-failed `s2` attempt |

Questa therefore reports the assertion error at 35 ns and identifies the attempt as having started at 25 ns. This is timing evidence, not an `or`-operator compiler problem.

To make the original `s1` branch pass, drive `a` high before the 25 ns sampling edge. To make `s2` pass, `b` must already be high at the delayed 35 ns sample and remain high at 45 ns.

## The comment and the property express different requirements

The source says that both `a` and `b` should remain high, but `s1 or s2` intentionally accepts either sequence. If both sequences must match from the same start, use sequence `and`:

~~~systemverilog
$rose(start) |-> s1 and s2
~~~

If the real rule is that `a` and `b` must both be high for the same two consecutive samples, state that directly:

~~~systemverilog
$rose(start) |-> (a && b)[*2]
~~~

These are not interchangeable. `s1 and s2` retains each operand's own timing, including the leading `##1` in `s2`; `(a && b)[*2]` demands simultaneous highs on two adjacent samples.

## Other source observations

- `done` is driven but is not referenced by the assertion, so it does not delimit the property or affect the result.
- No VCD dump is requested, and the live “Open EPWave after run” option is off.
- The pass action text says “sequence behaves the same,” but `or` does not compare sequences for equivalence. It only accepts a match from either alternative.
- The captured source has no explicit failure action, so Questa supplies its normal assertion-error report.

## Revision checks

1. Why does `s1` begin at 25 ns rather than 35 ns?
2. Which samples must satisfy `s2 = ##1 b[*2]` when the sequence starts at 25 ns?
3. Why does one failed branch not immediately fail a sequence `or`?
4. Which operator expresses “both sequences,” and which expression requires simultaneous `a && b` values?
5. Why does the unused `done` signal have no effect on this assertion?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
