# Part 03 — Clocked Immediate Assertion and NBA Timing

[← Part 02](../02-immediate-assertions-in-a-mux/README.md) · [SV Assertions index](../README.md) · [Part 04 →](../04-assertion-control-and-disable/README.md)

| Saved-playground field | Value |
|---|---|
| EDA Playground Name | `SVA 03 - Immediate Assertion and NBA Timing` |
| Stable playground | [gmZQ](https://edaplayground.com/x/gmZQ) |
| Simulator used for verification | Aldec Riviera Pro 2025.04 |
| Compile result | 0 errors, 0 warnings |
| Observed run | 20 passes at 5, 15, …, 195 ns; finishes at 200 ns |

The assertion passes at every positive edge, but the most important lesson is **which state it checks**. Because the D flip-flop uses nonblocking assignments, the simple immediate assertion sees the old register values in Active—not the values being scheduled for the current edge.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg d = 0;
  reg clk = 0;
  reg rstn = 0;
  wire q, qbar;
  
  dff dut (d,rstn, clk, q, qbar);
  
  always #5 clk = ~clk;
  
  always #13 d = ~d;
  
  initial begin
    rstn = 0;
    #30;
    rstn = 1;
  end
  
  
    initial begin 
    #200;
    $finish();
  end

endmodule
~~~

Local source: [testbench.sv](testbench.sv)

## Exact browser design

~~~systemverilog
// Code your design here
module dff (input d,  
              input rstn,  
              input clk,  
              output q, qbar);  
  
  
    reg temp_q    = 0;
    reg temp_qbar = 1;
  
  
   always @ (posedge clk)  
    begin      
      if (!rstn) 
        begin 
          
          temp_q    <= 1'b0;
          temp_qbar <= 1'b1;
        end
       else 
         begin
          temp_q    <= d; 
          temp_qbar <= ~d;
         end
    end

    always@(posedge clk)
    begin
      A1: assert (temp_q == ~temp_qbar) $info("Success at %0t",$time);  else $info("Error at %0t", $time);
    end
    
   assign q    = temp_q;
   assign qbar = temp_qbar;
  
endmodule 
~~~

Local source: [design.sv](design.sv)

## 1. The two positive-edge processes

At each `posedge clk`, two independent `always` processes awaken:

1. the state-update process evaluates reset or data and schedules nonblocking assignments;
2. the assertion process evaluates `temp_q == ~temp_qbar`.

Both normally execute in the Active region. Their relative order is unspecified, but the use of nonblocking assignments makes that order harmless for this particular check: neither `temp_q <= ...` nor `temp_qbar <= ...` changes its left-hand side during Active.

## 2. Region-by-region timeline at one edge

Assume the old values before the edge are `temp_q=0`, `temp_qbar=1`, `d=1`, and `rstn=1`.

| Region | State-update process | Assertion process | Visible register state |
|---|---|---|---|
| Preponed | No procedure has run yet | No procedure has run yet | `temp_q=0`, `temp_qbar=1` |
| Active | Evaluates RHS values and schedules `temp_q <= 1`, `temp_qbar <= 0` | Immediately evaluates `0 == ~1`, which is true | Still `0/1` |
| NBA | Queued LHS updates are applied | Already finished | Becomes `1/0` |
| Later Active iteration | Continuous assignments update `q` and `qbar` from the registers | No new assertion trigger, because its event is only `posedge clk` | Outputs become `1/0` |

The pass message belongs to the pre-update invariant. It does not confirm that the current edge captured `d` correctly.

## 3. Why all 20 checks pass

The assertion is:

~~~systemverilog
temp_q == ~temp_qbar
~~~

The initial values are complementary: `0` and `1`. Every reset update schedules the same complementary pair. Every data update schedules `d` and `~d`, which are also complementary for a known one-bit `d`.

Therefore, the state stored from the **previous** edge is complementary at every later edge. The immediate assertion observes that old pair and passes 20 times:

~~~text
Success at 5
Success at 15
...
Success at 195
~~~

This is a valid invariant check, but it is not the same check as “the new `q` equals the `d` sampled at this edge.”

## 4. Reset timing in this stimulus

`rstn` starts at 0 and becomes 1 at 30 ns. Positive clock edges occur at 5, 15, 25, 35 ns, and so on.

- At 5, 15, and 25 ns, reset is active; the DFF schedules `0/1`.
- At 30 ns, reset is released between clock edges.
- At 35 ns, the first non-reset data capture is scheduled.

The assertion is not reset-gated. It runs during reset as well, which is acceptable here because the reset state satisfies the complementary-output invariant.

## 5. Why changing `assert` to `assert #0` would not check the new NBA value

This is a common trap. In a deferred immediate assertion:

~~~systemverilog
A1: assert #0 (temp_q == d) ...
~~~

the Boolean expression is still evaluated when the process reaches the statement in Active. Only its report/action is deferred. The change would not make `temp_q` magically update before expression evaluation.

Likewise, `assert final` defers report maturity; it does not delay expression evaluation until Postponed.

## 6. How to check the architectural DFF relationship

For a clocked design, express the relationship in clocked sampled terms. Before the current edge's NBA updates, `q` represents the value captured on the preceding edge. Therefore compare sampled `q` with the preceding assertion-clock sample of `d`:

~~~systemverilog
logic past_valid = 1'b0;

always_ff @(posedge clk) begin
  if (!rstn)
    past_valid <= 1'b0;
  else
    past_valid <= 1'b1;
end

dff_capture: assert property (
  @(posedge clk)
  disable iff (!rstn)
  past_valid |-> (q == $past(d) && qbar == ~$past(d))
)
  $info("DFF state matches the preceding sampled d");
else
  $error("DFF capture mismatch");
~~~

Why `$past(d)`? At the current assertion sampling event, `q` still contains the result of the preceding DFF edge. That architectural state should equal the data sampled on that preceding edge.

The reset-aware `past_valid` guard avoids treating `$past(d)` as meaningful before a valid non-reset assertion clock exists. A production property should make this history policy explicit rather than relying on `$past` immediately after reset release.

## 7. A separate complement invariant

If the intended requirement is simply “the two outputs are always complements at every clock,” the current assertion can be written as a concurrent property:

~~~systemverilog
complementary_outputs: assert property (
  @(posedge clk)
  q == ~qbar
);
~~~

This still checks the sampled pre-edge architectural state. That is appropriate for a state invariant. It does not attempt to observe the NBA result from the same edge.

## 8. What the live run proves

The run proves:

- the design and testbench compile;
- at every positive edge, the pre-NBA internal register pair is complementary;
- reset and normal data updates preserve that invariant for this known-valued stimulus.

The run does not prove:

- that `q` equals the `d` sampled on every edge;
- that unknown `d` values are handled as intended;
- that reset assertion/deassertion meets any asynchronous timing requirement;
- that the pass messages describe post-NBA state.

## 9. Small coding improvements

- Named port connections are safer than the positional `dff dut (d,rstn, clk, q, qbar)` connection because a future port-order change cannot silently rewire the instance.
- `logic` can replace most `reg` declarations in SystemVerilog.
- A fail action should normally use `$error` rather than `$info`; otherwise automated regressions may treat a functional failure as ordinary informational output.
- Add an explicit reset policy to the property rather than relying only on the reset state happening to satisfy the invariant.

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 4.4, 10.4.2, and 16
- [Foundation 00 — event regions and assertion types](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
