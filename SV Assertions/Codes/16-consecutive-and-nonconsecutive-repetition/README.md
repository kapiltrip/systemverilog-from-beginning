# Part 16 — Consecutive and Nonconsecutive Repetition

[← Part 15](../15-consecutive-repetition-ranges/README.md) · [SV Assertions index](../README.md) · [Part 17 →](../17-nonconsecutive-and-goto-repetition-ranges/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 16 - Consecutive and Nonconsecutive Repetition` |
| Stable playground | [M3RC](https://edaplayground.com/x/M3RC) |
| Simulator | Siemens Questa 2025.2 |
| Live result | `vlog`: 0 errors; `vopt`: 1 error — unresolved `info` at line 75 because `$` is missing |
| EPWave | Enabled by the source's VCD dump |

## Exact browser source

The original is intentionally preserved, including the error, so the learning record shows what was written and what needed correction.

~~~systemverilog
// Code your testbench here
// or browse Examples
//[*lower:$] // not known upper bound 

//psel high until( after ) penable deassert 
//a1: assert property (@(posedge clk) $rose(psel) |-> psel[*1:$] ##1 $fell(penable)) $info("success at %0t", $time); 
// 5 write cycles during when reset is disabled
//  5 read cycles 
//  read cycles must stay high for 2 clock ticks consecutive repetition operation 
  // read adn wr should stay low 

module tb;
 
 reg clk = 0;
 
 reg rd = 0;
 reg wr = 0;
 reg rst = 0;
 
 reg done = 0;
 
 int delayw,delayr;
 
 always #5 clk = ~clk;
 
 initial begin
 rst = 1;
 #20;
 rst = 0; 
 end
 
 task write();
 for(int i = 0; i<5 ; i++) 
 begin
 @(negedge clk);
 delayw = $urandom_range(1,3);
 wr = 1;
 @(posedge clk);
 wr = 0; 
 repeat(delayw) @(posedge clk); 
 end
 endtask
 
 task read();
 for(int i = 0; i<5 ; i++) 
 begin
 @(negedge clk);
 delayr = $urandom_range(1,3);
 repeat(delayr) @(posedge clk);
 rd = 1;
 repeat(2)@(posedge clk);
 rd = 0; 
 end 
 endtask
 

 initial begin
 #20;
 fork
 write();
 read();
 join
 end
 
 initial begin
 #295;
 done = 1;
 #10;
 done = 0;
 
 end
  a1: assert property (@(posedge clk) $rose(rd) |-> rd[*2] ##1 !rd ) $info("Read high for 2 clock ticks and then it went 0 at time %0t " , $time); 
// 5 read adn write cycles with the dut 
    a2: assert property (@(posedge clk) $fell(rst) |-> wr[=5]) $info("5 write successful"); 
      a3: assert property (@(posedge clk ) $fell(rst) |-> $rose(rd) [=5] ) info("five read cycles "); 
        
  
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #310;
 $finish();
 end

endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane is placeholder-only.

## The compile problem and its correction

This action statement is wrong:

~~~systemverilog
info("five read cycles ");
~~~

`$info` is a SystemVerilog system task; the `$` is part of its name. Without it, `info` is treated as an ordinary user subroutine call, but no such task or function is declared. The corrected assertion is:

~~~systemverilog
a3: assert property (@(posedge clk)
  $fell(rst) |-> $rose(rd)[=5]
) $info("five read cycles");
~~~

This correction belongs in the explanation, not silently in the archived source.

## `[*2]`: consecutive high duration

~~~systemverilog
$rose(rd) |-> rd[*2] ##1 !rd
~~~

At the sampled rise of `rd`, the overlapped consequent begins immediately. It requires `rd` high on that sample and the next one, then low one additional clock later. This expresses “exactly two sampled high clocks, then low,” not merely “at least two.”

The `read` task assigns `rd=1` after a positive-edge wait. The assertion sampled earlier in Preponed, so it sees the rise on the following positive edge. Likewise, deasserting `rd` in Active at a positive edge becomes visible to the assertion on the next sample.

## `[=5]`: nonconsecutive repetition

`wr[=5]` means five sampled occurrences of `wr==1`, with zero or more nonmatching samples allowed between occurrences. The five occurrences do not need to be adjacent.

Compare the three families:

| Operator | Meaning |
|---|---|
| `b[*5]` | five consecutive matches |
| `b[->5]` | five nonconsecutive matches, ending on the fifth match |
| `b[=5]` | five nonconsecutive matches, with a trailing nonmatch gap permitted before the following sequence item |

`a2` counts sampled **levels**, not transactions. If one `wr` pulse stayed high for two sampled clocks, it would contribute two matches. For counting write transactions, `$rose(wr)[=5]` is safer than `wr[=5]`.

`a3` already uses `$rose(rd)[=5]`, so it counts distinct sampled rising transitions rather than the number of high samples.

## Do these properties prove “exactly five before done”?

No. `done` is generated but never appears in `a2` or `a3`. The assertions ask for five eventual occurrences after reset falls; they do not delimit the observation window, reject a sixth occurrence, or prove that the fifth happened before `done`.

A practical testbench can use a sampled counter and check it at `done`:

~~~systemverilog
int wr_count, rd_count;
logic wr_q, rd_q;

always @(posedge clk) begin
  if (rst) begin
    wr_count <= 0;
    rd_count <= 0;
    wr_q <= 0;
    rd_q <= 0;
  end else begin
    if (wr && !wr_q) wr_count <= wr_count + 1;
    if (rd && !rd_q) rd_count <= rd_count + 1;
    wr_q <= wr;
    rd_q <= rd;
  end
end

assert property (@(posedge clk) $rose(done) |->
  (wr_count == 5 && rd_count == 5));
~~~

In production code, use sampled-state functions and counter update timing carefully; the example shows the architectural idea. A purely temporal solution is possible, but the endpoint and “no sixth event” rule must both be stated explicitly.

## The commented unbounded `psel` property

~~~systemverilog
$rose(psel) |-> psel[*1:$] ##1 $fell(penable)
~~~

`psel[*1:$]` describes one or more consecutive high samples of `psel`. It searches for a finite endpoint followed one tick later by `$fell(penable)`. Because the repetition is unbounded, use `strong(...)` if lack of a finite completion must fail at simulation end:

~~~systemverilog
$rose(psel) |-> strong(psel[*1:$] ##1 $fell(penable))
~~~

Also verify that this ordering matches the protocol. The expression says `psel` is high through the repetition endpoint and `penable` falls on the next sampled clock; it does not say that `psel` falls when `penable` falls.

## Stimulus race to notice

The test starts the fork at exactly 20 ns, which is also a falling edge of this clock. Whether the task catches that same edge or waits for the next one can depend on same-time process ordering. Start work on an explicitly chosen later clock event to remove the ambiguity:

~~~systemverilog
@(negedge clk);
fork
  write();
  read();
join
~~~

## Revision checks

1. Why does missing `$` before `info` prevent the original code from compiling/elaborating?
2. What is the difference among `[*5]`, `[->5]`, and `[=5]`?
3. Why is `$rose(wr)[=5]` a better transaction count than `wr[=5]`?
4. What requirement is missing because `done` is never used by the properties?
5. Why should an unbounded completion property usually be wrapped in `strong(...)`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.9.2, 16.12.1, and 20.10
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
