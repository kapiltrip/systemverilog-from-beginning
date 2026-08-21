# Part 27 — Request/ACK Latency with Local Time

[← Part 26](../26-request-ack-local-snapshots/README.md) · [SV Assertions index](../README.md) · [Part 28 →](../28-measuring-clock-period-with-property-local-time/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [HwSU](https://edaplayground.com/x/HwSU) |
| EDA code ID | `7376313` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile/assertion errors; no `$info` or latency `$display` output before `$finish` at 500 ns |
| Open EPWave after run | Disabled |

This playground was found in the requested final Edge rescan after Parts 20–26 were documented. The accompanying discussion asked why the success information did not print. The exact randomized source is preserved below; corrected forms remain explanatory only. The design pane is placeholder-only.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 int delay = 0; // random generated delay

 
 always #5 clk = ~clk;
 
 initial begin
   for(int i = 0; i < 5 ; i ++)  begin
     @(posedge clk);
     delay = $urandom_range(4, 6);
     req = 1;
     @(posedge clk);
     req = 0;
     repeat(delay) @(posedge clk);
     ack = 1;
     @(posedge clk);
    ack = 0;
   end
 end

  property p1 (count);
    time reqTime ; 
    time ackTime ; 
    ($rose(req), reqTime = $realtime ) |-> ##[1:$] ($rose(ack) , ackTime = $realtime ) ##0 (((ackTime-reqTime ) == count ), $display("difference b/w ack and request is  %0t" , ackTime- reqTime )); 
  endproperty 

 assert property (@(posedge clk) p1(50)) $info("Suc at %0t",$time);
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #500;
 $finish();
 end

endmodule

~~~

Local source: [testbench.sv](testbench.sv).

## Q&A

### Q: Why does `$info` print nothing?

The pass action runs only when the **complete** property matches:

~~~systemverilog
assert property (@(posedge clk) p1(50))
  $info("Suc at %0t", $time);
~~~

A request attempt captures `reqTime`. A later ACK candidate captures `ackTime`, but the sequence succeeds only if their difference is exactly the formal argument `count`, here 50 ns:

~~~systemverilog
(ackTime - reqTime) == 50
~~~

The verified run reached 500 ns with no complete 50 ns match, so the pass action never ran.

### Q: Why is there also no `$display` for a wrong latency?

The display is a match item attached to the Boolean expression that demands equality:

~~~systemverilog
(((ackTime-reqTime) == count),
  $display(...))
~~~

Sequence match items execute when their associated sequence expression matches. If the equality is false, that endpoint does not match, so this display is not a general “print every ACK latency” probe.

To print each ACK candidate before testing equality, attach the display to the ACK match and compare on the same sampled endpoint afterward:

~~~systemverilog
($rose(ack),
  ackTime = $realtime,
  $display("latency = %0t", ackTime - reqTime))
##0 ((ackTime - reqTime) == count)
~~~

### Q: Why are there no assertion errors either?

The consequent searches with an unbounded delay:

~~~systemverilog
##[1:$] ($rose(ack), ...)
~~~

When an ACK arrives with the wrong difference, that candidate endpoint fails, but the unbounded search can continue looking for a later ACK that might satisfy the equality. The source does not wrap the consequent in `strong(...)` or otherwise force the first ACK to decide the property. At the finite simulation horizon, unmatched attempts may therefore remain weakly incomplete instead of reporting an error.

Silence does not prove that the latency requirement passed. In this run it means no finite successful endpoint was reported and no strong failure was demanded.

### Q: How does the generated delay map to sampled latency?

The stimulus drives `req` and `ack` with blocking assignments in the Active region immediately after positive-edge event controls. Concurrent assertions already sampled that edge in the Preponed region, so each new level is observed on the following positive edge.

For this source, a generated repeat count `d` produces a sampled request-to-ACK interval of approximately `(d + 1) × 10 ns`:

| `delay` | Sampled `ackTime - reqTime` |
|---:|---:|
| 4 | 50 ns |
| 5 | 60 ns |
| 6 | 70 ns |

Thus `p1(50)` can pass only for the 4-repeat case. Driving on the negative edge would remove the positive-edge testbench/assertion race and make the next positive-edge sample intentional.

### Q: Is `$urandom_range(4, 6)` the portable order?

The SystemVerilog system function takes the maximum value first and the minimum second. For an inclusive 4–6 range, write:

~~~systemverilog
delay = $urandom_range(6, 4);
~~~

The exact browser source uses the reversed arguments and Questa runs it, but portable teaching code should use the standard max/min order.

### Q: What property checks exactly five sampled clocks?

If the protocol requirement is “ACK rises exactly five clock events after the sampled request rise,” express that directly and let the target edge decide success or failure:

~~~systemverilog
assert property (@(posedge clk)
  $rose(req) |-> ##5 $rose(ack)
);
~~~

For a 5–7 clock window, use `##[5:7]`. If the first ACK must decide the result, use a construction that selects the first ACK rather than an unbounded search that can skip a wrong candidate.

## Why local `time` variables are still useful

`reqTime` and `ackTime` are property-local. Each request attempt retains its own request timestamp, so overlapping requests do not overwrite one shared time variable. That solves snapshot isolation, but it does not decide which ACK belongs to which request. As in Part 26, out-of-order protocols require a transaction/tag identity, not only timing.

Also remember that `time` measures simulation time under the current time unit. A cycle-based protocol is usually clearer and more portable when expressed with `##N` or `##[m:n]` rather than subtracting `$realtime`.

## Revision checks

1. What exact condition must be true before the pass `$info` executes?
2. Why does the embedded `$display` not print every ACK latency?
3. How can an unbounded weak search end silently at `$finish`?
4. Why does `delay=4` correspond to a sampled 50 ns interval here?
5. What is the standard argument order for `$urandom_range`?
6. When should a protocol use cycle delays instead of `$realtime` subtraction?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16 (Assertions) and 18.13 (random-number system functions)
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
