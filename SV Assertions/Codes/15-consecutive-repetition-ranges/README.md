# Part 15 — Consecutive Repetition Ranges

[← Part 14](../14-strong-unbounded-eventuality/README.md) · [SV Assertions index](../README.md) · [Part 16 →](../16-consecutive-and-nonconsecutive-repetition/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 15 - Consecutive Repetition Ranges` |
| Stable playground | [EZ5Z](https://edaplayground.com/x/EZ5Z) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 compile errors; 8 assertion passes and 0 simulation errors |
| EPWave | Enabled by the source's VCD dump |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
//repetition operator 
// consecutive and non consecutive 
//we know the exact count for which we know to keepa signal high
/*
a1: assert property (@(posedge clk) $rose(rd) |-> rd[*3] ) $info("consecutive repeat success for repetition operator "); 
// read should be high for 3 clock ticks 
  a2: assert property(@(posedge clk) $rose(a) |-> b[*2:4] ) $info("success at %0t" , $time ); 
    // if repetition of more then the upper bound range wont cause an error 
    */
module tb;
 
 reg clk = 0;
 
 reg req1 = 0;
 reg req2 = 0;
 int delay1 = 0, delay2 = 0;

 
 
 always #5 clk = ~clk;
 
 initial begin
 for(int i = 0; i < 4; i++)
 begin
   delay1 = $urandom_range(4,8); // to get random delay 
 #delay1;
 req1 = 1;
 #20;
 req1 = 0;
 #30;
 end
 end
 
 initial begin
 for(int i = 0; i < 4; i++)
 begin
 delay2 = $urandom_range(3,5);
 #delay2;
 req2 = 1;
 repeat(delay2) #10;
 req2 = 0;
 #20;
 end
 end
 
 /////if req1 asserts, then it should remain stable for 2 clock ticks
  a1 : assert property (@(posedge clk) $rose(req1) |->  req1[*2] ) $info("success at time %0t", $time); 
 ////////if req2 asserts, then it should remain stable for 3 to 5 clock ticks 
 
 a2 : assert property (@(posedge clk) $rose(req2) |-> req2 [*3:5] ) $info("success at time %0t" , $time); 
      
 initial begin 
 #250;
 $finish();
 end
 
 
   initial begin
     $dumpfile("dump.vcd"); 
     $dumpvars ; 
     
   end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane is placeholder-only.

## Consecutive repetition

The operator `[*]` repeats a Boolean or sequence on **adjacent assertion sampling ticks**.

| Form | Required consecutive matches |
|---|---|
| `req1[*2]` | exactly two adjacent samples of `req1==1` |
| `req2[*3:5]` | a run whose accepted endpoint is after 3, 4, or 5 adjacent true samples |
| `sig[*1:$]` | one or more adjacent true samples, with no finite upper bound |

Because both assertions use overlapped implication, the first repetition sample is the same sample on which `$rose(req)` is true:

~~~text
clock sample       T0      T1      T2      T3      T4
$rose(req1)         1
req1[*2]            1       1              -> success at T1

$rose(req2)         1
req2[*3:5]          1       1       1       -> earliest success at T2
~~~

The triggering sample counts as repetition number one. This is a common off-by-one source of confusion.

## Why does exceeding the repetition upper bound not cause an error?

The comment says that repetition beyond the upper bound does not cause an error. For this property, that is correct.

`req2[*3:5]` means that the sequence may **finish** after three, four, or five true samples. If `req2` remains high for six samples, the three-, four-, and five-sample matches already existed. The extra high sample does not erase those successful matches.

To require the run to end within the range, explicitly check the low transition after the chosen endpoint:

~~~systemverilog
// High for 3, 4, or 5 sampled clocks, then low on the next clock.
assert property (@(posedge clk)
  $rose(req2) |-> req2[*3:5] ##1 !req2
);
~~~

Now six consecutive high samples cannot satisfy the `##1 !req2` continuation of any allowed endpoint.

## The stimulus timing

`req1` is held high for 20 ns. With a 10 ns clock period, that is intended to cover two positive-edge samples. `req2` is held high for `delay2 × 10 ns`, where `delay2` is randomly 3 through 5, matching the intended repetition range.

This line is legal but easy to misread:

~~~systemverilog
repeat(delay2) #10;
~~~

It repeats a ten-nanosecond delay followed by a null statement. A clearer equivalent is:

~~~systemverilog
#(delay2 * 10);
~~~

The random initial delays can align a signal assignment with a positive clock edge. The concurrent assertion has already sampled in Preponed before an Active-region assignment at that edge, so the observed rise may move to the next positive edge. For deterministic verification, drive stimulus at `negedge clk` or through a clocking block with a defined output skew.

In the verified Questa 2025.2 run, `a1` passed at 25, 85, 135, and 195 ns; `a2` passed at 25, 85, 155, and 225 ns. Compilation and simulation both completed without errors. The exact times remain seed-dependent because both initial delays are randomized.

## “Remain stable” versus “remain high”

The source comment says “remain stable,” but the property checks `req1[*2]`, which specifically requires `req1` to be **true** twice. Stability is a different condition:

~~~systemverilog
$rose(req1) |-> $stable(req1)[*2]
~~~

Even that wording needs careful intent: `$stable` compares successive sampled values, while `req1[*2]` directly expresses the simpler protocol rule “stay asserted for two samples.” The implemented property is therefore a high-duration check, not a general stability check.

## Revision checks

1. Does the antecedent clock count as the first repetition for `|-> req[*2]`?
2. Why can six high samples still satisfy `req[*3:5]`?
3. What continuation makes “no more than five” explicit?
4. Why is `#(delay2*10)` easier to read than `repeat(delay2) #10;`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.7 and 16.9.2
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
