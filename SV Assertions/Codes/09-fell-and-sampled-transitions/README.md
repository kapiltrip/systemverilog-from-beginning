# Part 09 — `$fell` and Sampled Transitions

[← Part 08](../08-reusable-sequences-and-properties/README.md) · [SV Assertions index](../README.md) · [Part 10 →](../10-gated-past-sampled-values/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 09 - Fell and Sampled Transitions` |
| Stable playground | [gnQU](https://edaplayground.com/x/gnQU) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 errors; `$fell(a)` is 1 only on sampled `1→0` transitions |
| EPWave | Enabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  //reg [3:0] a ; 
  reg a ; 
  reg clk =0 ; 
  always #5 clk = ~clk ; 
  initial begin
    for(int i =0; i<10;i++)begin
      a = $urandom_range(0,1);
      #10;
    end
  end
  always @(posedge clk)begin
    $info("value of a is %0b and $fell(a) is " , a, $fell(a));
    //$info("Value of a is %0b preponed region and a's value in reactive region is %0b  rose a is : %0b " , $sampled(a) ,a , $rose(a)); // 
  end
  
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); // to filter vacuous success
      //repeat (20) @(posedge clk) ; 
      #120;
      $finish();
    end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). No substantive design source was present.

## The exact definition of `$fell`

At a given assertion clock, `$fell(expr)` compares two samples of the least-significant bit of `expr`: the current sampled value and the previous sampled value for that clocking context. It returns true when that bit changes from `1`, `X`, or `Z` in the preceding sample to `0` in the current sample. For ordinary binary stimulus, the memorable case is `1 → 0`. Like `$rose`, it returns a Boolean transition result rather than either sampled value.

It does not mean “the signal changed at any moment since the last display.” It means the transition is visible between consecutive assertion samples.

~~~text
sample N-1  sample N  $fell(a)
    0           0          0
    0           1          0
    1           1          0
    1           0          1
~~~

## Why the result appears only on some positive edges

The random loop changes `a` every 10 ns, while positive clock edges also occur every 10 ns. `$fell(a)` is evaluated in the context of `always @(posedge clk)`, using the inferred clock event. In the captured run, sampled falling transitions occurred at specific edges such as 15 and 85 ns, so those lines displayed `1`; edges without a sampled `1→0` transition displayed `0`.

Because stimulus assignments and clock transitions can share a time slot, this is not ideal deterministic testbench timing. Random values also differ across tools or seeds. The conceptual rule is stable even when the exact transition times change.

## Important region correction

The ordinary `always @(posedge clk)` process executes in Active. A plain `a` read in its `$info` call is therefore a current procedural read. `$fell(a)` is a sampled-value function tied to the inferred positive-edge clock. The commented phrase “a's value in reactive region” is not accurate for this `always` block.

For a concurrent assertion, by comparison:

~~~systemverilog
fell_must_be_known: assert property (
  @(posedge clk) $fell(a) |-> !$isunknown(a)
);
~~~

the signal sampling is in Preponed, property evaluation is in Observed, and its action block is in Reactive.

## The first-clock rule

At the first clocking event, there is no real earlier sampled edge from this simulation history. Sampled-value functions use their language-defined default sampled history. Therefore the first result should not be described as proof of a physical transition that the testbench observed. If first-cycle behavior matters, gate the property until reset/history is valid.

~~~systemverilog
logic history_valid = 0;
always_ff @(posedge clk) history_valid <= 1;

check_fall: assert property (
  @(posedge clk) disable iff (!history_valid)
  $fell(a) |-> !a
);
~~~

## Scalar versus vector behavior

The browser source correctly changes `a` from a commented four-bit declaration to a scalar declaration. `$rose`, `$fell`, `$stable`, and `$changed` accept expressions, but `$rose` and `$fell` detect the transition of the expression's least-significant bit. Thus this vector expression does **not** mean “any bit fell”:

~~~systemverilog
$fell(bus)
~~~

To detect any bit changing from `1` to `0`, compare the full sampled vectors:

~~~systemverilog
logic [3:0] falling_mask;
assign falling_mask = $past(bus) & ~bus;

any_bit_fell: assert property (@(posedge clk) |($past(bus) & ~bus));
~~~

The reduction OR is true if at least one previously-high bit is now low.

## Formatting issue in the live line

~~~systemverilog
$info("value of a is %0b and $fell(a) is " , a, $fell(a));
~~~

The format string contains one conversion but two arguments. Questa appends or otherwise reports the extra argument according to its formatting behavior, which is why a value is still visible. The portable, clear form is:

~~~systemverilog
$info("value of a is %0b and $fell(a) is %0b", a, $fell(a));
~~~

The repository retains the exact browser source and records the correction here instead of silently rewriting the evidence.

## Revision checks

1. Does `$fell(a)` react immediately when `a` changes between clock edges?
2. Which bit is examined if `a` is a vector?
3. Why should first-clock history be treated carefully?
4. How would you detect any falling bit in a bus?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16.9.3
- [Foundation 00 — assertion sampling](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
