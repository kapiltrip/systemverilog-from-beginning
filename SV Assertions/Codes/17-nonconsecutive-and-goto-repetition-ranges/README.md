# Part 17 — Nonconsecutive and Goto Repetition Ranges

[← Part 16](../16-consecutive-and-nonconsecutive-repetition/README.md) · [SV Assertions index](../README.md) · [Part 18 →](../18-sequence-or-operator/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [SGyj](https://edaplayground.com/x/SGyj) |
| EDA code ID | `7371864` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | Compilation stops with 1 error at line 69: a bare property expression appears after `endmodule` |
| Open EPWave after run | Enabled |

The browser Name field was blank, so this README records that state instead of inventing a saved EDA title. The design pane is placeholder-only. The testbench is preserved exactly, including the unfinished requirement scratchpad after `endmodule` that prevents simulation.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
//consecutive no of repetitions is not equal then specified its failure [*3] to restrict teh count to 3 then a[*3] ##1 !a 
//a range (min , max) [*min:max] a[*1:3] ## !a 
//non consecutive repetition operator 
// [=] fail is weak in nature until we add a strong qualifier 
// 2 repetitionfor signal a , $rose(b) |-> a[=2] ##1 !a 
//goto 
// a[->2] = !a[*0:$] ##1 a ##1 !a[*0:$] ##1 a ;
// a[=2] =  !a[*0:$] ##1 a ##1 !a[*0:$] ##1 a ## !a[*0:$]  will add a series of 0's 
// in non consecutive the delay we specify is the min delay in the tail and it can match it throughout the expression , and also its weak in nature 

module tb;
 
 reg clk = 0;
 
 reg a = 0;
 reg b = 0;
 reg c = 0;
 
 
 always #5 clk = ~clk;
 
 initial begin
 #15;
 a = 1;
 #10;
 a = 0;
 
 end
 
 initial begin
   #20;
   b = 1;
   repeat(3) @(posedge clk); 
   b = 0; 
   #70;
   b=1;
   #10;
   b=0;
 end

 initial begin
 #94;
 c = 1;
 #10;
 c = 0;
 
 end
 
  A1: assert property (@(posedge clk) $rose(a) |->  b[=3:5] ) $info("Non-consecutive operator used here ,  Success @ %0t",$time); 
  A2: assert property (@(posedge clk) $rose(a) |-> strong( b[->3:5]) ) $info("GOTO Success @ %0t",$time); else $error("used strong qualifier ");
  a3: assert property (@(posedge clk) $rose(a) |-> b[=3] ##1 b ) $info("3 repetitions of b (non consecutive) done after a became high at time %0t ", $time) ;  
  a4: assert property (@(posedge clk) $rose(a) |-> b[->3] ##1 b ) $info("goto operator used in the assertion ") ; 
        
  //3 non consecutive repetitions of b then in the next clock tick b becomes high in the next clock tick non consecutive and goto operator both we will try 
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #200;
 $finish();
 end
 
endmodule
        
//write req must be followed by read req , if read do not assert before timeout , then system should reset 
    (!rst[*1:$] ##1 timeout) |-> rst ;
    (!rst[*1:$] ##1 tout ) [*n] |-> rst ;
    2) write request must be followed by read request 
    $rose(wr)|=> $rose(rd)
    3)if a assert b must assert in 5 clock tick
      $rose(a) |-> ##5 $rose(b) 
      4) if reset is deasserted then ce must assert within to 1 to 3 clock ticks 
        $fell(rst) |-> ##[1:3] $rose(ce)
      5) if req assert and ack not recieved in 3 clock ticks then req must reassert 
        $rose(req) |-> ##3 $rose(req)
        $rose(req) ##1 !ack[*3] |-> $rose(req)
        6) if a assert a must remin high for 3 clock ticks
          $rose(a) |-> a[*3]; 
    7) system must start with rst asserted for three consecutive clock ticks 
      initial a1: assert property (@(posedge clk) rst[*3])
    8) ce must assert somewhere, during simulation if reset deassert 
          $fell(rst) |->##[1:$] rose(ce)   // go to or non consecutive repetition 
          
    9) transaction starts with ce become high and ends with ce becomes low , each transaction must contain at least one read and write request 
          $rise(ce)|-> (rd[->] and wr[->]) ##1 !ce;
    10) if ce assert somewhere, after rst deassert then we must receive at least one write, request 
          $fell(rst) |-> ##[1:$] $rose(ce) |-> wr[->] ##1 !wr; 
    11)  a must assert twice during simulation  a[=2] 
      12) is a became high somewhere, then b must become high in the immediate next clock tick 
      $rose(a)|=> $rose(b)
      
      13)
      if req is received and all the data is sent to slave indicated by done signal then ready must be high in the next clock tick 
        
      $rose(req) |-> ##[1:$] done |-> $rose(ready)
        $rose(req) ##1 done[->] ##1 rdy ; 
        
~~~

Local source: [testbench.sv](testbench.sv).

## Why the exact source does not compile

The `tb` module ends at line 66. Line 69 then begins a bare temporal expression:

~~~systemverilog
(!rst[*1:$] ##1 timeout) |-> rst;
~~~

This is not inside a `sequence`, `property`, assertion directive, or module. Questa consequently stops at line 69 with `vlog-13069`, reporting an unexpected `(`. Later lines mix numbered prose, undeclared signals, incomplete repetitions such as `[->]`, missing semicolons, and temporal expressions that are also outside any assertion context.

This compile failure is part of the learning snapshot. The source should not be silently rewritten merely to produce a green run. A runnable experiment can be made separately by keeping lines 1–66 as the testbench and moving the post-module requirements into comments or a dedicated notes file before translating them one at a time into complete properties.

Because compilation stops, none of `A1` through `a4` reaches simulation in the verified run.

## The three repetition families

| Form | Matching rule | Where the match ends |
|---|---|---|
| `b[*n]` | `n` adjacent samples on which `b` is true | On the `n`th consecutive true sample |
| `b[->n]` | `n` true samples with zero or more false samples before and between them | Exactly on the `n`th true sample |
| `b[=n]` | `n` true samples with gaps before/between and an allowed trailing false gap | At or after the `n`th true sample |

The range forms `[->m:n]` and `[=m:n]` accept any repetition count from `m` through `n`. “Nonconsecutive” does not mean arbitrary extra true samples are ignored; each true sample contributes to the repetition count, while false samples form the permitted gaps.

The source's expansion comments capture the central endpoint difference. In simplified form:

~~~systemverilog
// Goto: the sequence finishes on the second a.
a[->2]

// Nonconsecutive: a false tail may follow the second a before completion.
a[=2]
~~~

That tail becomes observable when another sequence item follows the repetition.

## Reading the four active assertions

### `A1`: ranged nonconsecutive repetition

~~~systemverilog
$rose(a) |-> b[=3:5]
~~~

After the sampled rise of `a`, this accepts three, four, or five sampled occurrences of `b`. The occurrences need not be adjacent, and `[=]` permits a trailing false gap. Since the consequent has no following sequence item, the property mainly demonstrates event counting rather than the tail distinction.

### `A2`: ranged goto repetition with finite completion

~~~systemverilog
$rose(a) |-> strong(b[->3:5])
~~~

Goto repetition finishes on a qualifying `b` occurrence. Because arbitrary false gaps are allowed, a required occurrence could otherwise remain pending indefinitely. `strong(...)` requires at least one finite match; if only two `b` occurrences arrive before simulation ends, the attempt must fail instead of passing weakly through noncompletion.

### `a3` versus `a4`: the endpoint matters

~~~systemverilog
b[=3]  ##1 b
b[->3] ##1 b
~~~

For the goto form, the sequence ends on the third `b`; `##1 b` therefore demands another `b` on the immediately following clock. For the nonconsecutive form, a false tail can extend the repetition before the `##1 b` continuation. A later `b` can therefore satisfy the continuation after a gap. These two expressions are not alternate spellings of the same timing rule.

## Sampling the stimulus

The clock's positive edges occur at 5, 15, 25, 35, 45 ns, and so on. `a` is assigned high at 15 ns in the Active region, after the concurrent assertion has taken its Preponed sample. Its sampled rise is therefore seen at 25 ns. At that same 25 ns time slot, the procedural block schedules `a = 0` after the assertion sample, so the sampled rise remains visible.

`b` is set high at 20 ns and remains high across the 25, 35, and 45 ns samples. The `repeat(3) @(posedge clk)` process deasserts `b` in the Active region at 45 ns, after the assertion has sampled the third high. Later it produces another pulse around 115–125 ns. That delayed pulse is useful for exposing the different tail behavior of `[=3] ##1 b` and `[->3] ##1 b` once the compile-blocking scratchpad is separated.

`c` is stimulated but is not referenced by any active assertion.

## Translating the scratchpad safely

The post-module lines are requirement notes, not yet legal SVA. Each needs three separate decisions before coding:

1. Choose the sampling clock and reset/abort policy.
2. Define an unambiguous start and finite endpoint.
3. Decide whether levels, transitions, or transaction counts are intended.

The examples below assume an active-high `rst`, positive-edge sampling, and pulse-like request/response events. If the real protocol uses active-low reset, level handshakes, overlapping transactions, or IDs, the properties must change. These are requirement translations, not edits to the preserved playground.

### 1. Write request, read response, or timeout reset

The saved expressions mention reset and timeout but never connect them to `$rose(wr)` or a read response. First define the boundary. If `TIMEOUT` means “accept a new read rise on clocks 1 through `TIMEOUT-1`; otherwise require reset on clock `TIMEOUT`,” one bounded formulation is:

~~~systemverilog
parameter int TIMEOUT = 4; // must be greater than 1 for this form

assert property (@(posedge clk)
  $rose(wr) |=>
    (($rose(rd)[->1]) within 1'b1[*TIMEOUT-1])
    or
    ((!$rose(rd))[*TIMEOUT-1] ##1 rst)
);
~~~

Because `|=>` starts the consequent on clock 1, the fixed window covers clocks 1 through `TIMEOUT-1`; the second branch checks reset on the following clock. Do not add `disable iff (rst)` using the same reset being checked—the reset endpoint would abort the attempt instead of satisfying it. If `timeout` is an actual DUT signal, replace the counted boundary with that signal only after defining whether it is a pulse or a level.

### 2. Write followed by read

~~~systemverilog
$rose(wr) |=> $rose(rd)
~~~

This is legal, but it means **exactly the next sampled clock**. English “followed by” is incomplete until the latency is specified. Use `|-> ##[1:N] $rose(rd)` for a bounded later window, or a strong unbounded sequence only when eventual completion is truly intended.

### 3. `b` exactly five clocks after `a`

~~~systemverilog
$rose(a) |-> ##5 $rose(b)
~~~

With overlapped implication, the trigger is clock 0 and `b` must rise at clock 5. `|=> ##5` would add the nonoverlapped one-clock shift and check clock 6, so it is not an equivalent rewrite.

### 4. CE within one to three clocks after reset deassertion

~~~systemverilog
$fell(rst) |-> ##[1:3] $rose(ce)
~~~

This is correct only for an active-high reset, where falling means deassertion, and only if a **new CE edge** is required. Use `ce` instead of `$rose(ce)` if CE may already be high and a high level is sufficient. For active-low `rst_n`, deassertion is `$rose(rst_n)`.

### 5. Reassert request only if no ACK arrives in three clocks

The saved `$rose(req) |-> ##3 $rose(req)` ignores ACK, while `$rose(req) ##1 !ack[*3] |-> ...` has an unclear endpoint. If the next three clocks are the response window and reassertion is required on clock 4 only when no **new ACK rise** occurred, write both outcomes explicitly:

~~~systemverilog
assert property (@(posedge clk)
  $rose(req) |=>
    (($rose(ack)[->1]) within 1'b1[*3])
    or
    ((!$rose(ack))[*3] ##1 $rose(req))
);
~~~

Timeline: request at clock 0; ACK may rise at clocks 1, 2, or 3; otherwise request must rise again at clock 4. If “three-clock timeout” means reassert on clock 3 instead, shorten the no-ACK portion accordingly. If ACK is a level rather than an event, use `ack`/`!ack` consistently.

### 6. Hold `a` high for three sampled clocks

~~~systemverilog
$rose(a) |-> a[*3]
~~~

This includes the trigger sample: `a` is required at clocks 0, 1, and 2. It means **at least** those three samples because it says nothing about clock 3. For exactly three sampled highs followed by low, use `$rose(a) |-> a[*3] ##1 !a`. For three full clocks *after* the rise, use nonoverlapped implication.

### 7. Reset high for the first three sampled clocks

One explicit one-shot check is:

~~~systemverilog
initial begin : startup_reset_check
  startup_reset: assert property (@(posedge clk) rst[*3]);
end
~~~

This launches one three-sample attempt from the `initial` process; it is not an always-active property that restarts on every clock. It also assumes the assertion is enabled before the first relevant edge. A procedural `repeat (3) @(posedge clk) assert (rst);` is often clearer for a pure startup test.

### 8. CE must eventually rise after reset deassertion

~~~systemverilog
$fell(rst) |-> strong(##[1:$] $rose(ce))
~~~

The source misspells `$rose` as `rose`. The unbounded range permits any finite later clock, and `strong` converts noncompletion at the end of simulation into failure. This still needs an environment-defined simulation or transaction endpoint; “sometime during simulation” is otherwise an open-ended liveness requirement.

### 9. Every CE transaction contains at least one read and one write

Define the transaction window from CE's rise through its first sampled low. The following version counts new request edges while CE is high and requires the CE window to finish:

~~~systemverilog
assert property (@(posedge clk)
  $rose(ce) |-> strong(
    ((($rose(rd) && ce)[->1]) and (($rose(wr) && ce)[->1]))
      within (ce[*1:$] ##1 !ce)
  )
);
~~~

Sequence `and` lets read and write arrive in either order; the compound match ends with the later one. `within` confines both to the CE transaction, and `strong` requires a finite CE-low endpoint. Replace `$rose(rd)`/`$rose(wr)` with levels only if a stretched-high request should count as one valid transaction. The source's `$rise` is a typo, and `[->]` is incomplete without a count such as `[->1]`.

### 10. After reset, eventually start a CE transaction containing a write

This combines two liveness stages into one explicitly nested sequence:

~~~systemverilog
assert property (@(posedge clk)
  $fell(rst) |-> strong(
    ##[1:$] (
      $rose(ce) ##0
      (($rose(wr) && ce)[->1] within (ce[*1:$] ##1 !ce))
    )
  )
);
~~~

It requires a finite future CE rise, at least one write rise while CE is high, and a finite CE-low endpoint. The source's unparenthesized chain of two implications does not define those boundaries clearly and can create vacuity or precedence surprises. If many CE transactions may occur and only one must contain a write, say whether the first CE transaction decides the result or a later one may rescue it.

### 11. `a` asserts twice during the run

`a[=2]` is only a sequence fragment. It needs a clock, an assertion context, and a completion policy. To require at least two **rising events** in a one-shot simulation check:

~~~systemverilog
initial begin : two_a_events_check
  two_a_events: assert property (@(posedge clk) strong($rose(a)[=2]));
end
~~~

Using `a[=2]` counts two sampled high levels, not necessarily two separate assertions. Neither form means “exactly two over the entire run”; excluding a third occurrence requires a defined end-of-test event and an additional no-third-event condition.

### 12. `b` on the immediate clock after `a`

~~~systemverilog
$rose(a) |=> $rose(b)
~~~

This is the same exact-next-clock relationship as item 2. It does not mean “one or more clocks later.”

### 13. Ready one clock after completion of a request

If the first new `done` edge after the request completes the transfer and `ready` must be high on the following clock:

~~~systemverilog
assert property (@(posedge clk)
  $rose(req) |-> strong(##1 $rose(done)[->1] ##1 ready)
);
~~~

The leading `##1` excludes a same-clock `done`; goto repetition selects the first later `done` rise, and `strong` requires it to occur finitely. Use `$rose(ready)` instead of `ready` only if a new ready edge—not merely a high ready level—is required. The source's chained implication can allow the first subproperty to succeed without enforcing one coherent request→done→ready attempt, and `done[->]` is missing its repetition count.

## Revision checks

1. Why is line 69 illegal even though its temporal expression resembles SVA?
2. Where does `[->3]` finish, and how is that different from `[=3]`?
3. Why does `strong` matter when nonconsecutive matches may be separated by unbounded gaps?
4. Which sampled clock first observes the rise of `a`, and why?
5. How can the later `b` pulse distinguish `b[=3] ##1 b` from `b[->3] ##1 b`?
6. What must be decided before translating each post-module English requirement into an assertion?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.9.2 and 16.12.1
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
