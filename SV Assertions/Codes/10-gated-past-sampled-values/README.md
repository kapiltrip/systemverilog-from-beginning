# Part 10 — Gated `$past` and Sampled-Value Requirements

[← Part 09](../09-fell-and-sampled-transitions/README.md) · [SV Assertions index](../README.md) · [Part 11 →](../11-sampled-and-vector-system-functions/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 10 - Gated Past Sampled Values` |
| Stable playground | [tNt9](https://edaplayground.com/x/tNt9) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 errors; gated history advances while `en=1` and freezes after `en=0` |
| EPWave | Enabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg a =1 , clk =0;
  reg en =0;
  reg [3:0] b =2; 
  always #5 clk = ~clk ; 
  initial begin
    en =1;
    #100;
    en =0;
    
  end
  initial begin
    for(int i =0; i<15;i++)begin
      a = $urandom_range(0,1); 
      b= $urandom_range(0,15); 
      @(posedge clk); // this is the delay its gonna experience
    end
  end
  /*
  always @(posedge clk)begin
    $display("value of a if %0d and b is %0d " , $sampled(a) , $sampled(b)); 
    $display("value of past a is %0d and past b is %0d" , $past(a) , $past(b)); 
    $display("------------------------------------------------------------------");
  end
  */
  always @(posedge clk)begin
    $display("value of a if %0d and b is %0d and en is (%0d) and time is %0t" , $sampled(a) , $sampled(b) , en , $time); 
    $display("value of past a is %0d and past b is %0d and en is (%0d)" , $past(a,1,en) , $past(b,1,en) , en ) ; 
    $display("------------------------------------------------------------------");
  end
  initial begin
    repeat (20) @(posedge clk); 
    $finish();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars ; 
    
  end
/*
if a is asserted b must assert in next clock tick 
  assert property (@(posedge clk) $rose(a) |=> $rose(b)
each new request must be followed by ack
  assert property (@(posedge clk) $rose(req) |=> $rose(ack))

if rst deassert , ce must assert in same clock tick 
  assert property (@(posedge cllk) ($fell(rst)) |-> ($rose(ce))); 
    
wr request must be folowed by rd request    
    assert property (@(posedge clk) $rose(wr) |=> $rose(ack))
   
current value of addr must be one greater than previous value if start asserted 
  assert property (@(posedge clk) ($rose(start) |-> (addr == $past(addr)+1 ) )) ; 
                   
if rst deassert dout must be 0 
  assert property (@(posedge clk) $fall(rst) |-> dout==0)

if loading deassert dout must be equal to load value 
  
if rst deassert output of the shift reg must be shifted to left by 1 in the next clock tick
  $fell(rst) |=> sout== {sout[6:0] , 0} ; // left shift 
if rst deaddert current value and past value of the signal differ only in a single bit 
  $fall(rst) |=> $onehot(a ^ $past(a)) // then its in gray ,cause 1  bit change 
a dff output must remain constant if ce is low 
  $fell(c) |-> (q == $past(q))
in a tff if ce assert output must toggle 
  $rose(ce) |-> (q== ~$past(q)) ; 
    assertvacuousoff(0)
*/                 
                                    
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The large requirement list is a block comment, so only the sampling/display testbench is compiled.

## `$past` as sampled history

The general form is:

~~~systemverilog
$past(expression, number_of_ticks, gate, clocking_event)
~~~

Arguments after the expression are optional. `$past(a)` means the value sampled one relevant clock tick earlier. `$past(a,2)` means two sampling ticks earlier. It is assertion-clock history—not a `#` time delay and not necessarily “10 ns ago.”

In this procedural `always @(posedge clk)` context, the clock is inferred from the enclosing event. The browser calls:

~~~systemverilog
$past(a,1,en)
$past(b,1,en)
~~~

The third argument is a **gate**. History advances only on sampled clock ticks for which the gate is true. Therefore “one past tick” means one prior **enabled sampling tick**, not simply the immediately previous `posedge clk`.

## What the verified run proves

`en` begins high and becomes low at 100 ns. While it is sampled high, the gated-history queue accepts new samples of `a` and `b`. Once it is low, new clock edges do not advance that queue. The rerun showed the previous enabled values freezing at `a=1` and `b=11` through the later display lines.

This is the key realization:

~~~text
clock keeps ticking + gate false = gated $past history does not advance
~~~

The current `$sampled(a)` and `$sampled(b)` can continue to change while `$past(...,1,en)` still returns the last prior enabled sample.

## Source requirements answered and corrected

The commented questions are valuable specifications, but several need a choice between **level** and **edge** semantics. `$rose(x)` means “x made a sampled transition to 1”; plain `x` means “x is sampled high.” Those are different requirements.

### 1. “If `a` is asserted, `b` must assert in the next clock tick”

If “asserted” means the level is high:

~~~systemverilog
assert property (@(posedge clk) a |=> b);
~~~

If the requirement explicitly means one rising edge must be followed by another rising edge:

~~~systemverilog
assert property (@(posedge clk) $rose(a) |=> $rose(b));
~~~

The second is stronger. It fails when `b` was already high, because no new rise occurred.

### 2. “Each new request must be followed by ack”

For one-cycle-later acknowledgment of every newly observed request edge:

~~~systemverilog
assert property (@(posedge clk) $rose(req) |=> ack);
~~~

Use `$rose(ack)` only if the protocol requires a new acknowledgment edge. If acknowledgment may already be high, the level check is correct.

### 3. “If reset deasserts, CE must assert in the same clock tick”

For active-high reset and CE required high:

~~~systemverilog
assert property (@(posedge clk) $fell(rst) |-> ce);
~~~

The source has `cllk`, which should be `clk`. It also uses `$rose(ce)`, which demands an actual CE edge. Choose that only if the requirement says CE must transition low-to-high, not merely be high. For active-low `rst_n`, deassertion is `$rose(rst_n)`.

### 4. “Write request must be followed by read request”

~~~systemverilog
assert property (@(posedge clk) $rose(wr) |=> $rose(rd));
~~~

The source consequent says `ack`, which does not match its English requirement. Again, use `rd` instead of `$rose(rd)` if the required condition is simply a high read request next cycle.

### 5. “Address must be one greater than its previous value if start is asserted”

If `start` is a qualifier for an already-observed state relation on the **same** sample:

~~~systemverilog
assert property (@(posedge clk)
  disable iff (!rst_n)
  start |-> addr == $past(addr) + 1
);
~~~

For the more common synchronous interpretation—`start` sampled high on clock 0 commands the register update that becomes observable on clock 1—use:

~~~systemverilog
assert property (@(posedge clk)
  disable iff (!rst_n)
  start |=> addr == $past(addr) + 1
);
~~~

The two properties differ at a change of `start`; choose from the RTL's control-to-state timing, not from wording alone. `$rose(start)` checks only the first cycle of a high stretch. A reset/history guard prevents either form from relying on pre-reset or first-tick default history.

### 6. “If reset deasserts, `dout` must be 0”

~~~systemverilog
assert property (@(posedge clk) $fell(rst) |-> dout == '0);
~~~

The sampled function is `$fell`, not `$fall`. This checks the same sampled tick. Use `|=>` if the design promises zero on the following clock.

### 7. “If loading deasserts, `dout` must equal the load value”

This is ambiguous until the signal names and timing are defined. If `load` is an active-high control and `load_data` was captured while it was high:

~~~systemverilog
assert property (@(posedge clk)
  $fell(load) |-> dout == $past(load_data)
);
~~~

If the design instead makes `dout` equal the **current** sampled `load_data` on the deassertion edge, remove `$past`. The specification must decide which data cycle is meant.

### 8. “After reset deasserts, shift left by one on the next tick”

For an eight-bit shift register with a zero shifted into bit 0:

~~~systemverilog
assert property (@(posedge clk)
  $fell(rst) |=> sout == {$past(sout[6:0]), 1'b0}
);
~~~

The right-hand side must use the previous sample. The original `{sout[6:0],0}` uses the same consequent-cycle sample of `sout`, creating a self-referential comparison instead of checking the state transition.

### 9. “Current and previous values differ in one bit” — Gray-code transition

~~~systemverilog
assert property (@(posedge clk)
  $fell(rst) |=> $onehot(a ^ $past(a))
);
~~~

XOR marks each changed bit. `$onehot` requires exactly one marked bit. Use `$onehot0` if unchanged values are also legal. The source again needs `$fell`, not `$fall`.

### 10. “A DFF output remains constant if CE is low”

For the usual synchronous interpretation—CE sampled low on clock 0 controls the update visible on clock 1—write:

~~~systemverilog
assert property (@(posedge clk)
  disable iff (rst)
  !ce |=> $stable(q)
);
~~~

At the consequent sample, `$stable(q)` compares `q` with its clock-0 value. An equivalent current-state invariant uses the prior CE explicitly: `!$past(ce) |-> q == $past(q)`. The shorter `!ce |-> $stable(q)` is correct only if the **current** CE value qualifies the already-observed current transition. The source's `$fell(c)` checks a transition of a different signal and only on that one transition tick; it does not express “for every clock while CE is low.”

### 11. “In a TFF, if CE is asserted, output toggles”

For a synchronous T flip-flop whose current CE sample controls the next state:

~~~systemverilog
assert property (@(posedge clk)
  disable iff (rst)
  ce |=> q == ~$past(q)
);
~~~

The same-sample state-invariant form is `$past(ce) |-> q == ~$past(q)`. Use `$rose(ce)` only if toggling is required after the first enable edge and not after every enabled clock. Again, align the implication with when the RTL samples CE and when its nonblocking state update becomes visible.

### 12. `assertvacuousoff(0)`

The executable system task is `$assertvacuousoff(0);`. In this playground the text is inside a block comment and lacks `$`, so it has no effect. The live display test contains no assertion directives anyway.

## Stimulus race to remember

The random loop waits on `@(posedge clk)` and then immediately assigns new values on its next loop iteration. The display block also wakes at `posedge clk`. Both are Active-region processes, so their relative ordering is not a robust way to define which random value the display should see. Driving at `negedge clk` or through a clocking block removes that ambiguity.

## Revision checks

1. With gating, does `$past(x,1,en)` always mean the immediately preceding clock?
2. Why is `$rose(b)` stronger than simply `b`?
3. Why must a shift transition compare against `$past(sout)`?
4. When should `$onehot0` replace `$onehot` in a Gray-code check?
5. Why does `!ce |-> $stable(q)` describe an interval better than `$fell(ce)`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.9.3 and 20.9
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
