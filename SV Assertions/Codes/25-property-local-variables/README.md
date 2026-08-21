# Part 25 — Property-Local Variables

[← Part 24](../24-strong-until/README.md) · [SV Assertions index](../README.md) · [Part 26 →](../26-request-ack-local-snapshots/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `(1)` |
| Stable playground | [mJvr](https://edaplayground.com/x/mJvr) |
| EDA code ID | `7376028` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile/assertion errors; `p2` passes at 85 ns and displays a wrapped 2-bit count of 2 |
| Open EPWave after run | Enabled |

The design pane contains only the default placeholder. This is the only new playground whose browser Name field is nonblank, so `(1)` is recorded exactly.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
//section 10 
module tb;
 reg clk = 0;
 reg start = 0;
 always #5 clk =~clk;
 initial begin
   
   #20;
   start = 1;
   #60;
   start = 0;
 end
 
  
 
 /*
 default clocking ; 
   @(posedge clk ); 
 endclocking 
 */
  
//reg in hardware , 
  //in sva property or sequence block 
  // reg temp ; if i dont add any expression local variable dont play any role 
  // triggering |-> how the value of local varialbe will be updated 
  
  property p1;
    logic [1:0] count =0 ; 
   // $rose(start) |-> ## [1:$] $rose(start) ##[1:$] $rose(start) 
    //($rose(start) , count++ , $display("COUNT value is %0d from a local varialbe ", count));  
    //3 rising edges of the clock 
    
    ($rose(start) , count=1) |-> ## [1:$] ($rose(start) , count++)   ## [1:$] ($rose(start) , count++ , $display("COUNT value is %0d from a local varialbe ", count )); 
  endproperty 
  property p2;
    logic [1:0] count2 =0 ; 
    // no of clock ticks for which start is high 
    //$rose(start) |-> start[*1:$] ##1 !start ;  // start high and then start got low 
    $rose(start) |-> (start, count2++)[*1:$] ##1 (!start , $display("The value of count through the property p2 is %0d" , count2)); 
  endproperty 
  
  a1: assert property (@(posedge clk ) p1 ) $info("success at time %0t" , $time);
    a2: assert property (@(posedge clk) p2) $info("start is high for x clock cycles at the time %0t" , $time) ; 
      
initial begin
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0); 
 #120;
 $finish;
end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Why a property-local variable matters

A variable declared inside a property belongs to an individual property evaluation attempt. Assignment match items can capture or update it while the sequence advances:

~~~systemverilog
($rose(start), count = 1)
(start, count2++)[*1:$]
~~~

If several antecedent events overlap, each resulting assertion thread keeps its own local state. A module variable, by contrast, is shared and can change while older attempts are still pending.

### Q: What does `p2` count?

`start` is sampled high at the positive edges 25, 35, 45, 55, 65, and 75 ns. It is driven low at 80 ns and is first sampled low at 85 ns. Therefore this branch can select six consecutive high samples before `##1 !start` matches at 85 ns.

The match item increments `count2` once for each selected high sample. The pass action and the embedded `$display` both execute when the complete sequence matches at 85 ns.

### Q: Why does the display say 2 instead of 6?

`count2` is only two bits wide:

~~~systemverilog
logic [1:0] count2 = 0;
~~~

A two-bit value wraps modulo 4. Six increments produce binary `10`, which is decimal 2. The log is therefore evidence of width truncation, not evidence that `start` was high for only two clocks. Use an `integer`, `int unsigned`, or a sufficiently wide packed type when the count must not wrap.

### Q: Why does `p1` produce no result?

`p1` starts when `start` rises at 25 ns, then waits for two additional future rises through unbounded `##[1:$]` ranges. The stimulus keeps `start` continuously high and supplies no second or third rise. No finite `p1` match is found before `$finish`, and this source does not make that unbounded search strong, so the live log contains neither its pass message nor an assertion error.

Whitespace in the source forms `## [1:$]` and `##[1:$]` does not create a second operator; Questa parses both as the same ranged cycle delay. A separate exact delay followed by a bare range is a different grammar question, documented with the screenshot in Part 19.

## Local does not mean persistent across attempts

The initializer creates the starting value for each attempt; it does not define one counter shared forever by the property. This is exactly why local variables are useful for overlapping transactions, accumulated lengths, and captured data values. It also means a later attempt cannot directly read an earlier attempt's local variable.

Sequence match-item assignments should serve the assertion model. They are not a replacement for RTL state, and tools place restrictions on how locals flow through complex sequence branches. Keep the capture point and the comparison point explicit.

## Revision checks

1. Which six samples contribute to `p2`'s repetition?
2. Why does a two-bit counter report 2 after six increments?
3. Why do local variables avoid cross-talk among overlapping assertion attempts?
4. What two future events are missing from `p1`?
5. Is whitespace between `##` and its range semantically significant here?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.10 and 16.12
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)

