# Part 26 — Request/ACK Local Snapshots

[← Part 25](../25-property-local-variables/README.md) · [SV Assertions index](../README.md) · [Part 27 →](../27-request-ack-latency-with-local-time/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [Edgi](https://edaplayground.com/x/Edgi) |
| EDA code ID | `7376252` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | 0 compile errors; one pass at 35 ns (attempt from 15 ns), then one failure at 105 ns (attempt from 35 ns) |
| Open EPWave after run | Disabled |

The open discussion for this playground asked what benefit the local copies provide and whether they actually solve request/ACK matching. This Q&A answers those questions against the exact live source. The design pane is placeholder-only.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
 
 reg clk = 0;
 
 reg req = 0;
 reg ack = 0;
 integer reqcnt = 0;
 integer ackcnt = 0;  // to identify the ack 
 
 always #5 clk = ~clk;
 
 initial begin
 #10;
 req = 1;
 #10;
 req = 0;
 #10;
 req = 1;
 #10;
 req = 0;
 #20;
 ack = 1;
 #10;
 ack = 0;
 #30;
 ack = 1;
 #10;
 ack = 0;
 end
 


 // assert property (@(posedge clk) $rose(req) |-> ##[1:6] $rose(ack) ) $info("Suc at %0t",$time);
 
 
 
 
 
 
 
 
 
  always @(posedge clk )begin
    if(req)
      reqcnt<= reqcnt +1; 
    if(ack)
      ackcnt <= ackcnt+1; 
  end
 
 

  property p1;
    integer rcnt=0;
    integer acnt =0; 
    ($rose(req) , rcnt = reqcnt) |->  ## [1:7] ($rose(req) , acnt = ackcnt  ) ##0 (acnt == rcnt ) ; 
  endproperty 
 assert property (@(posedge clk) p1) $info("Suc at %0t",$time);
 
 initial begin 
 $dumpfile("dump.vcd");
 $dumpvars;
 $assertvacuousoff(0);
 #200;
 $finish();
 end

endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Q&A

### Q: What benefit do `rcnt` and `acnt` provide?

The module counters `reqcnt` and `ackcnt` are global and continue changing. A property-local variable is private to one assertion attempt:

~~~systemverilog
($rose(req), rcnt = reqcnt)
~~~

When a request starts an attempt, this match item preserves the counter value that attempt saw. If another request starts before the first attempt finishes, the two threads can retain different `rcnt` snapshots instead of both consulting the latest global value.

### Q: Does copying the values solve request/ACK pairing by itself?

No. A local variable preserves an identifier; it does not establish that a later event belongs to that request. The current property has an even more direct bug: its consequent waits for another request rise, not an ACK rise.

~~~systemverilog
##[1:7] ($rose(req), acnt = ackcnt)
              // ^ source checks req again
~~~

As written, ACK pulses do not terminate the property. The first request attempt starts at 15 ns, sees the second request at 35 ns, captures `ackcnt=0`, compares it with `rcnt=0`, and passes. The second request attempt starts at 35 ns, sees no third request in its seven-clock window, and fails at 105 ns. Those are exactly the timestamps in the verified log.

### Q: What is the minimal in-order correction?

If the protocol guarantees that acknowledgments return in request order, the intended experiment is likely:

~~~systemverilog
property p_req_ack_in_order;
  integer rcnt = 0;
  integer acnt = 0;

  ($rose(req), rcnt = reqcnt)
  |-> ##[1:7]
      ($rose(ack), acnt = ackcnt)
      ##0 (acnt == rcnt);
endproperty
~~~

This corrected example is explanatory; [testbench.sv](testbench.sv) remains the exact browser source.

Because the global counters use nonblocking assignments, the property samples their pre-NBA values on the request/ACK edge. In this stimulus those old values act as zero-based ordinals: request 1 and ACK 1 both capture 0, then request 2 and ACK 2 both capture 1.

### Q: What if ACKs can return out of order?

Counters are insufficient. “First ACK belongs to first request” is an ordering assumption, not a fact established by the counter. An out-of-order protocol needs a real transaction/tag ID carried by both request and response. The property should capture the request tag locally and compare it with the ACK tag when the ACK arrives.

### Q: Why use local snapshots instead of comparing globals later?

Suppose request 1 starts with `reqcnt=0`, then request 2 increments the global counter before ACK 1 arrives. A delayed comparison against the live `reqcnt` would see the newer value and lose request 1's identity. The local `rcnt` for attempt 1 remains 0 while the local `rcnt` for attempt 2 remains 1.

## Sampled counter timing

| Sample | Event | Pre-NBA value captured | NBA update scheduled |
|---:|---|---:|---:|
| 15 ns | first `$rose(req)` | `reqcnt=0` | `reqcnt<=1` |
| 35 ns | second `$rose(req)` | `reqcnt=1` | `reqcnt<=2` |
| 65 ns | first `$rose(ack)` | `ackcnt=0` | `ackcnt<=1` |
| 105 ns | second `$rose(ack)` | `ackcnt=1` | `ackcnt<=2` |

This pre-NBA timing is consistent only because both sides use the same ordinal convention. If the RTL counters or sampling scheme changes, reconsider what identifier is being compared.

## Revision checks

1. Why does the first source attempt pass at 35 ns even though the first ACK is at 65 ns?
2. Which signal must replace the second `$rose(req)` for the intended request/ACK check?
3. Why do nonblocking counter updates make the property capture old values?
4. What state is private to each overlapping assertion thread?
5. Why are explicit transaction IDs required for out-of-order responses?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.10 and 16.12
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
