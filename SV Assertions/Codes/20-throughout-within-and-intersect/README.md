# Part 20 — `throughout`, `within`, and `intersect`

[← Part 19](../19-sequence-and-not-strong/README.md) · [SV Assertions index](../README.md) · [Part 21 →](../21-eventually-and-always-property-operators/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [FH_u](https://edaplayground.com/x/FH_u) |
| EDA code ID | `7374462` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile and assertion errors; `a1`, `a2`, and `a3` all pass at 65 ns after starting at 35 ns |
| Open EPWave after run | Enabled |

The design pane contains only EDA Playground's placeholder. The browser Name field is blank, so the descriptive local title is not presented as a saved EDA name. The requirement scratchpad after `endmodule` is inside a block comment and does not participate in compilation.

## Exact browser source

~~~systemverilog
module tb;
 reg a = 0, b = 0, c = 0; //Data Signal
 reg clk = 0; // Clock
 
 
 always #5 clk = ~clk; ///Generation of 10 ns Clock


 initial begin
 #28;
 b = 1;
 #30;
 b= 0; 
 end
 

 initial begin
 #63;
 c = 1;
 #10;
 c= 0; 
 end
 

 initial begin
 #28;
 a = 1;
 #40;
 a = 0; 
 end
 
 /////////reference sequence
 
 sequence seq_bc;
 b[*3] ##1 c;
 endsequence
 sequence seq_a;
   a[*4];
 endsequence
  
  a1: assert property (@(posedge clk) $rose(b) |-> a throughout seq_bc) $info ("A is high throughout the seq_bc at time %0t" , $time );  
 //To stay constant throughout seq_bc b stable 1 for 3 clock tick , a high for 4 clock ticks consecutive 
  a2: assert property (@(posedge clk) $rose (b) |-> seq_a within seq_bc) $info("Within operator passed at time %0t " , $time) ; 
    a3: assert property (@(posedge clk) $rose(b) |-> seq_a intersect seq_bc) $info("intersection happened at time %0t" , $time ) ; 
      
 initial begin
 $dumpfile("dump.vcd");
 $dumpvars;
 #150;
 $finish;
 end
 
 
endmodule
/*     
      //sclk toggles for entire duration of chip select 
      assert property (@(posedge clk) $fell(cs) |=> !cs throughout ($changed(sclk)) ); 
      
      SCLK MUST TOGGLE FOR ENTIRE DURATION OF CHIP SELECTION 
        assert property (@(posedge clk) !cs |=> !cs throughout ($changed(sclk ) ) ;     
        assert property (@(posedge clk) !cs |=> !cs throughout ($changed (sclk))) ; 
        assert property (@(posedge clk) ce|=> ce throughout (dout == $past(dout) +1 ))
        
        TWO REQUEST FROM A AND THREE REQUEST FROM B MUST COMPLETE AT SAME TIME 
        assert property (@(posedge clk) $rose (start) |-> a[->2] intersect b[->3]) ; 
        // a must hold till master received three requests from b 
        assert property (@(posedge clk) $rose(start) |-> a throughout b [->3]) ; 
        rst must remain deasserted for atleast one read and write, request 
        !rst throughout rd[->1] and wr[->1]
        req must be followed by ack after completionof data transfer . 
        load must assert at same clock tick when ack is received 
        req ##1 ack[->1] intersect load[->1] 
        between start adn stop there must be atleast one request followed by ack 
        $rose(start) |-> (req[->] ##1 ack) within stop[->1 ] ;   
        
        read and write request must not occur at same time 
        $rose(rd) |->not (wr[->1]) within rd[*2] //-< this is the reference 
*/
~~~

Local source: [testbench.sv](testbench.sv).

## One timeline, three temporal relationships

The 10 ns clock has positive edges at 5, 15, 25, 35 ns, and so on. The assignments at 28 ns make both `a` and `b` visible as high at the 35 ns assertion sample. That sample is also the first sampled rise of `b`.

| Sample | `b` | `c` | `a` | Role |
|---:|---:|---:|---:|---|
| 35 ns | 1 | 0 | 1 | `$rose(b)`; first `b[*3]` and first `a[*4]` sample |
| 45 ns | 1 | 0 | 1 | second repetition |
| 55 ns | 1 | 0 | 1 | third `b`; third `a` |
| 65 ns | 0 | 1 | 1 | delayed `c`; fourth `a`; common endpoint |

Therefore `seq_bc = b[*3] ##1 c` spans 35–65 ns, while `seq_a = a[*4]` spans exactly the same four sampled clocks. All three assertions consequently complete at 65 ns, exactly as the live log reports.

## Comparing the operators

| Expression | Essential relationship |
|---|---|
| `a throughout seq_bc` | Boolean `a` must be true on every sample of the chosen `seq_bc` match |
| `seq_a within seq_bc` | A complete `seq_a` match must fit inside a complete `seq_bc` match; outer padding is allowed |
| `seq_a intersect seq_bc` | Both sequences must start together and finish together |

These operators answer different questions even though this stimulus makes all three true.

### Q: Why does `throughout` cover the delayed endpoint?

The reference sequence does not end after the third `b`. Its `##1 c` item extends the match through 65 ns. Consequently `a throughout seq_bc` requires `a` at 35, 45, 55, **and** 65 ns. Driving `a` low before the 65 ns sample would fail `a1` even though it covered all three `b` samples.

### Q: How is `within` less strict than `intersect`?

`within` permits the contained sequence to start later than the container and/or finish earlier. Here the two matches happen to share both boundaries, so `intersect` also succeeds. If `seq_bc` were extended by an extra leading or trailing sample while `seq_a` stayed in its middle, `within` could still pass but `intersect` would not.

### Q: How does this differ from sequence `and` in Part 19?

Sequence `and` requires a common start and successful matches of both operands, but their endpoints may differ; the compound match ends at the later endpoint. `intersect` additionally requires the endpoints to coincide. This playground deliberately arranges an exact 35–65 ns overlap to demonstrate that stronger relationship.

## Reading the commented requirements

The block comment is a useful requirement scratchpad, not runnable source. Before activating any line, resolve its clock, start event, endpoint, repetition count, and whether “assert” means a sampled high level or a new edge.

Keep the operand shapes straight:

| Operator | Left operand | Right operand | Meaning |
|---|---|---|---|
| `throughout` | Boolean expression | Sequence | Boolean must hold on every sample of the chosen sequence match |
| `within` | Sequence | Sequence | Complete left match must fit inside a complete right match |
| `intersect` | Sequence | Sequence | Both matches must have the same start and the same endpoint |

The corrected examples below assume `clk` is a reference clock fast enough to observe the protocol and use edges when the English describes transactions.

### 1. SCLK toggles for the entire active-low chip-select window

The saved `!cs throughout $changed(sclk)` has a one-sample right operand, so it cannot describe an entire transaction. It also needs a finite end to the CS-low window. One explicit version is:

~~~systemverilog
assert property (@(posedge clk)
  $fell(cs) |-> strong(
    ($changed(sclk) || cs)
      throughout ((!cs)[*1:$] ##1 $rose(cs))
  )
);
~~~

While `cs` is low, the left Boolean reduces to `$changed(sclk)`; at the final CS-rise sample, `cs` itself makes the endpoint legal. `strong` requires chip select eventually to end. This demands an SCLK change on **every reference-clock sample** while selected, which may be stricter than a real serial-clock specification. If the requirement is a particular SCLK period or alternating edges, write that rate explicitly. Sampling only on `posedge sclk` would be a poor check because `$changed(sclk)` is then nearly tautological and falling edges are invisible.

### 2. DOUT increments while CE enables counting

The saved expression:

~~~systemverilog
ce |=> ce throughout (dout == $past(dout) + 1)
~~~

does not mean “throughout the CE window.” Its right-hand sequence is only one Boolean sample, so `throughout` merely combines two conditions at that one endpoint. For a synchronous counter whose sampled high CE at clock 0 causes a value one larger at clock 1, the direct invariant is clearer:

~~~systemverilog
assert property (@(posedge clk) disable iff (rst)
  ce |=> dout == $past(dout) + 1
);
~~~

Every high CE sample launches a next-clock check, so a multi-clock high naturally creates overlapping checks for every increment. If the DUT instead uses the next sample's CE to decide the update, require both samples explicitly. Also size the `+ 1` expression to the counter width when overflow behavior matters.

### 3. Two A requests and three B requests finish on the same clock

~~~systemverilog
assert property (@(posedge clk)
  $rose(start) |-> strong(
    $rose(a)[->2] intersect $rose(b)[->3]
  )
);
~~~

`intersect` gives both request-counting sequences the same start (the `start` sample) and requires their second-A and third-B endpoints to coincide. Using `a[->2]`/`b[->3]` instead would count sampled high levels; that is different if a request can remain high for multiple clocks. `strong` prevents a run with too few requests from ending silently.

### 4. A remains high until the third B request

~~~systemverilog
assert property (@(posedge clk)
  $rose(start) |-> strong(a throughout $rose(b)[->3])
);
~~~

The goto sequence spans from the start sample through the third B rise, and `a throughout ...` requires `a` at every sample including that endpoint. It does not require `a` to fall afterward. Add an explicit continuation if deassertion timing also matters.

### 5. Reset remains deasserted until both a read and a write occur

~~~systemverilog
assert property (@(posedge clk)
  $fell(rst) |-> strong(
    !rst throughout
      (($rose(rd)[->1]) and ($rose(wr)[->1]))
  )
);
~~~

Sequence `and` allows read and write in either order and completes when the later event occurs. `throughout` requires reset to remain low over that entire match, and `strong` requires both events eventually. Parentheses matter: without them, operator precedence can group `throughout` with only one side of `and`. If the actual reset is active low, rename it `rst_n` and use the correct assertion/deassertion edge.

### 6. LOAD is asserted on the same clock as the first ACK after REQ

The clearest form combines the endpoint conditions instead of making `intersect` discover their coincidence:

~~~systemverilog
assert property (@(posedge clk)
  $rose(req) |-> strong(
    ##1 $rose(ack)[->1] ##0 $rose(load)
  )
);
~~~

Goto repetition selects the first ACK rise at least one clock after the request; `##0` requires the LOAD rise on that same sampled clock. Use `load` instead of `$rose(load)` if a pre-existing high level is acceptable. The scratchpad's `req ##1 ack[->1] intersect load[->1]` also makes the first LOAD since the common start part of the endpoint rule, which is stronger and more timing-dependent than the English sentence makes clear.

### 7. Between START and STOP, a request is followed by an ACK

~~~systemverilog
assert property (@(posedge clk)
  $rose(start) |-> strong(
    ($rose(req) ##1 $rose(ack)[->1])
      within (1'b1 ##1 $rose(stop)[->1])
  )
);
~~~

The consequent starts at the START sample. Its outer sequence extends at least one clock and finishes on the first later STOP rise. The complete REQ→ACK sequence must fit inside that window. If REQ must be strictly later than START rather than allowed at the trigger sample, add a leading `##1` to the contained sequence. The saved `[->]` is incomplete without a count, and `stop[->1]` counts a high level rather than a new stop event.

### 8. Read and write must never occur together

This is a per-sample mutual-exclusion invariant, so no repetition operator is needed:

~~~systemverilog
assert property (@(posedge clk) !(rd && wr));
~~~

If only simultaneous **new requests** are forbidden, use `!($rose(rd) && $rose(wr))`. The saved `not (wr[->1]) within rd[*2]` asks a multi-clock sequence question and does not directly encode same-clock exclusion. Prefer the smallest temporal structure that matches the requirement.

## Revision checks

1. Which four samples form the successful `seq_bc` match?
2. Why is `a` required at 65 ns by `throughout`?
3. Can `seq_a within seq_bc` pass when their start times differ?
4. What extra endpoint condition does `intersect` add beyond sequence `and`?
5. Why should the commented requirement lines be completed one at a time before activation?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16, Assertions
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
