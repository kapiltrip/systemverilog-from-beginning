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

The block comment is a useful requirement scratchpad, not runnable source. Before activating any line, resolve its clock, start event, endpoint, repetition count, and parentheses. For example, “two requests from A and three from B must complete at the same time” naturally suggests:

~~~systemverilog
$rose(start) |-> a[->2] intersect b[->3]
~~~

By contrast, “A must remain high until the third B request” asks for a level constraint over a temporal match:

~~~systemverilog
$rose(start) |-> a throughout b[->3]
~~~

Those statements use `intersect` and `throughout` for different protocol intentions.

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

