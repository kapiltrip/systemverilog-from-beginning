# Part 28 — Measuring a Clock Period with Property-Local Time

[← Part 27](../27-request-ack-latency-with-local-time/README.md) · [SV Assertions index](../README.md) · Latest captured numbered part

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [8V8G](https://edaplayground.com/x/8V8G) |
| EDA code ID | `7377831` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Verified live result | Nine 10 ns measurements; passes at 15–95 ns; 0 compile/simulation errors |
| Open EPWave after run | Disabled |

This playground asks how a property can measure the interval between consecutive assertion clock events. The exact browser source is preserved below. Its design pane contains only the default placeholder, so this numbered lesson needs only `testbench.sv`.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg clk =0;
  always #5 clk = ~clk ; 
  property p1;
    time starttime =0; 
    time currtime=0; 
    time count =0; 
    (1'b1 , starttime = $realtime ) ##1 (1'b1, currtime =$realtime, count = (currtime - starttime) , $display("The time period in nsec is %0t" , count)); 
    //HOW IS IT WORKING , TELL ME THAT AS WELL . 
  endproperty 
  assert property (@(posedge clk ) p1 ) $info("Success at time %0t" , $time); 
    
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars; 
      $assertvacuousoff(0); 
      #100; 
      $finish();
    end
    
endmodule
    
    /*
    boolean operator 
    both a and b must be high 
    (a && b )
    either fo one a or b could be high || 
    one of the signal is high while other must be low 
    both must be low 
    implication operator : antecedant |-> or |=> consequent 
      delay : ##[] fixed or range , fixed range , ##2 a , 
      if a assert a must remain high for 2 clock ticks 
        $rose(a) |-> ##2 a ##1 !a ; // it will not guranteee that a is high for 2 clock ticks 
        $rose(a) |-> [*2]a ##1 !a ; 
    
        $rose(a) |=> (a && $past(a))
        if a assert b should assert after 4 clock ticks 
          $rose(a) |-> ##4 $rose(b); 
        a followed by b followed by c 
        a ##1 b ##1 c 
       repetition :
      matching operator : 
      
    boolean operator 
    unbounded deiay 
    if a assert b must assert at same clock tick 
      $rose(a) |-> ##[0:$] b ;                             //b can be high in the samme clock tick
    if a assert b deassert in the next clock tick or somewhere during simulation 
      $rose(a) |=> ##[0:$] $fall(b) 
      $rose(a) |-> s_eventually !b ; 
    b must become high anytime later during simulation 
    s_eventually b ; 
    rst should become low within 4 to 5 clock ticks 
    ##[4:5] !rst 
    ack should be granted / given to new req within 0 to 1 clock tick 
    $rose(req) |-> ##[0:1] ack;
    repetition operator 
    // consecutive and non consecutive and goto operator 
    rd assert then it must be high for 2 clock tick s
      $rose(rd) |-> rd[*2]; 
    // 3 write s consecutive 
    wr[*3] |=> rd[*2]; 
    if rst deassert ce must remain high 
      $fell(rst) |-> ce[*1:$]; 
    difference b/w goto and non consecutive repetition operator 
    */
~~~

Local source: [testbench.sv](testbench.sv).

## Q&A

### Q: How is this property working?

The assertion clock is `@(posedge clk)`. A new attempt starts at every positive edge because the property is a bare sequence with no antecedent that would gate it.

The first match item is:

~~~systemverilog
(1'b1, starttime = $realtime)
~~~

`1'b1` always matches, and the attached assignment records the current simulation time in that attempt's local `starttime`. The property then waits for `##1`, meaning the next occurrence of the property clock—not one nanosecond.

At that next positive edge, the second always-true match item records the new time, subtracts the old time, and prints the result:

~~~systemverilog
(1'b1,
 currtime = $realtime,
 count = currtime - starttime,
 $display(...))
~~~

The clock toggles every 5 ns, so consecutive positive edges are 10 ns apart. That is why every completed attempt prints `10`.

| Attempt | First match | `##1` match | Result |
|---:|---:|---:|---:|
| 1 | 5 ns | 15 ns | 10 ns |
| 2 | 15 ns | 25 ns | 10 ns |
| … | … | … | … |
| 9 | 85 ns | 95 ns | 10 ns |

At each edge from 15 ns onward, one older attempt completes while a new one starts.

### Q: Why do overlapping attempts not overwrite one another?

`starttime`, `currtime`, and `count` are property-local variables. Every active assertion attempt owns a separate copy. The attempt that starts at 15 ns therefore cannot overwrite the timestamps belonging to the attempt that started at 5 ns.

This is the main reason to keep temporal snapshots local instead of using one module-level variable shared by all attempts.

### Q: When does the assertion's `$info` run?

The action block belongs to the complete property:

~~~systemverilog
assert property (@(posedge clk) p1)
  $info("Success at time %0t", $time);
~~~

It runs only after the second match item succeeds. The fresh run therefore printed successes at 15, 25, 35, …, 95 ns. The embedded `$display` prints the measured interval as part of that same completed match.

### Q: Why are there nine passes instead of ten?

Positive edges occur at 5, 15, …, 95 ns. An attempt needs two positive edges. The attempt started at 95 ns would need the 105 ns edge, but the testbench calls `$finish` at 100 ns. It remains incomplete and produces no pass message before simulation ends.

### Q: Is `1'b1` creating the delay?

No. It only makes each endpoint unconditionally match. `##1` creates the one-clock-event separation. Replacing the 10 ns-period clock with a 20 ns-period clock would make the same property print 20 ns without changing `##1`.

### Q: Does `$assertvacuousoff(0)` affect this assertion?

No useful behavior changes here. Vacuous success is associated with implications whose antecedent does not match. This property contains no `|->` or `|=>` implication; each attempt directly evaluates a two-endpoint sequence.

### Q: When should `$realtime` be used instead of cycle delays?

Use `$realtime` when the physical interval itself matters—for example, checking a generated clock's measured period. Use `##N` when the protocol requirement is stated in sampled clock events. The current `-timescale 1ns/1ns` makes this integer 10 ns measurement exact; fractional periods would deserve careful choice of `realtime`/`real` storage and time precision.

## Answers to the preserved assertion scratchpad

The block comment mixes Boolean expressions, sequence fragments, and complete properties. They are not interchangeable: a Boolean describes one sample, a sequence describes one or more sampled clocks, and a complete assertion supplies a clock and a property context.

### Boolean operators

For known one-bit values:

| Requirement | Expression | Important distinction |
|---|---|---|
| Both high | `a && b` | Logical AND |
| At least one high | `a || b` | Inclusive OR; both high also passes |
| Exactly one high | `a ^ b` | XOR; both high fails |
| Both low | `!a && !b` or `!(a || b)` | De Morgan-equivalent forms |

With four-state signals, X or Z may make these expressions unknown. If unknown inputs must be reported rather than tolerated, add an explicit `$isunknown({a,b})` check.

### “After `a` rises, keep it high for two clocks”

The scratchpad's first attempt:

~~~systemverilog
$rose(a) |-> ##2 a ##1 !a
~~~

checks `a` only at clock 2 and `!a` at clock 3. It says nothing about clock 1, so it does **not** prove a continuous two-clock hold.

The second attempt has the repetition operator in the wrong place: `[*2]a` is invalid. The repeated sequence item comes first:

~~~systemverilog
$rose(a) |-> a[*2] ##1 !a
~~~

With `|->`, the two highs are clocks 0 and 1, and low is required at clock 2. If “two clocks after the rise” means clocks 1 and 2, use `$rose(a) |=> a[*2]` and add the desired clock-3 endpoint separately.

The alternative:

~~~systemverilog
$rose(a) |=> (a && $past(a))
~~~

checks at clock 1 that `a` is currently high and was high at clock 0. Because `$rose(a)` already proves the clock-0 high, `$past(a)` is redundant here; the form effectively proves high at clocks 0 and 1. `$past` becomes more useful when the antecedent does not already establish the historical value.

### Fixed delay and ordered sequence

~~~systemverilog
$rose(a) |-> ##4 $rose(b)
~~~

requires a new B edge exactly four sampled clocks after the A edge. The fragment `a ##1 b ##1 c` means A, then B one clock later, then C one more clock later. A trigger-oriented complete property is:

~~~systemverilog
assert property (@(posedge clk)
  $rose(a) |-> ##1 b ##1 c
);
~~~

Use `$rose(b)`/`$rose(c)` if stretched high levels must not count as new events.

### Same-clock or eventual B

~~~systemverilog
$rose(a) |-> ##[0:$] b
~~~

allows `b` on the trigger clock because the minimum delay is zero. It also uses an unbounded weak search; a pending attempt may end without failure at a finite `$finish`. If “must eventually rise” is mandatory, write:

~~~systemverilog
$rose(a) |-> strong(##[0:$] $rose(b))
~~~

Choose minimum 1 instead of 0 when “later” excludes the trigger sample. Also decide whether a high level (`b`) or a new edge (`$rose(b)`) is the real requirement.

### B falls on the next or a later clock

The correct sampled-value function is `$fell`, not `$fall`:

~~~systemverilog
$rose(a) |=> strong(##[0:$] $fell(b))
~~~

Because `|=>` shifts the consequent, the earliest fall is the next clock. This checks a transition. By contrast:

~~~systemverilog
$rose(a) |=> s_eventually !b
~~~

checks that B is eventually sampled low, even if no observable high-to-low edge occurs within the attempt. Edge and level requirements are not equivalent.

### Standalone eventual and delay fragments need context

`s_eventually b` and `##[4:5] !rst` are property/sequence fragments, not self-starting simulation checks. A one-shot eventual-B check can be written as:

~~~systemverilog
initial begin : eventual_b_check
  eventual_b: assert property (@(posedge clk)
    strong(##[1:$] $rose(b))
  );
end
~~~

A reset-window requirement needs a trigger, for example:

~~~systemverilog
$rose(start) |-> ##[4:5] !rst
~~~

That means reset is sampled low on either clock 4 or clock 5; it does not require reset low throughout both clocks or forever afterward.

### ACK within zero to one clock

~~~systemverilog
$rose(req) |-> ##[0:1] ack
~~~

This bounded consequent accepts ACK high on the request clock or the next clock. Use `$rose(ack)` if the protocol requires a new grant edge. If the request and ACK can overlap across multiple transactions, a tag or transaction identity may be needed beyond this timing rule.

### Repetition examples

~~~systemverilog
$rose(rd) |-> rd[*2]
~~~

requires RD high on the rise sample and the next sample. It does not require RD low afterward; append `##1 !rd` for an exactly-two-sample pulse.

~~~systemverilog
wr[*3] |=> rd[*2]
~~~

matches three consecutive high WR samples, then requires two consecutive high RD samples beginning one clock after the third WR. If WR remains high longer, overlapping three-WR antecedent matches can launch overlapping RD obligations. Count `$rose(wr)` events instead when the English means three distinct transactions rather than three high samples.

### Why `ce[*1:$]` does not mean “CE remains high forever”

~~~systemverilog
$fell(rst) |-> ce[*1:$]
~~~

has a legal one-sample match, so the attempt may pass as soon as CE is high once. The `$` supplies an unbounded **maximum**, not a demand to choose an infinite repetition. Wrapping it in `strong` would require some finite match and still would not mean forever.

If the actual invariant is “CE must be high on every sampled clock while active-high reset is deasserted,” state that directly:

~~~systemverilog
assert property (@(posedge clk) disable iff (rst) ce);
~~~

If CE may assert later or may stop at a transaction endpoint, define those start/end events and use an `until`/`throughout` property that matches that finite window.

### Goto versus nonconsecutive repetition

Both forms permit gaps before and between qualifying samples, but their endpoints differ:

| Form | Completion point |
|---|---|
| `a[->2]` | Exactly on the second qualifying `a` sample |
| `a[=2]` | May include a trailing run of non-`a` samples after the second occurrence |

That difference becomes visible when another item follows:

~~~systemverilog
a[->2] ##1 b  // b must be one clock after the second a
a[=2]  ##1 b  // the allowed false tail can postpone the point before b
~~~

Use `strong(...)` when an unbounded-gap sequence is a mandatory liveness obligation and finite noncompletion must fail.

## Verified live output

The browser run produced nine copies of:

~~~text
The time period in nsec is 10
** Info: Success at time ...
~~~

The last pass was at 95 ns. Questa reported 0 `vlog` and 0 `vsim` errors; its single summary warning came from the optimization option rather than the assertion source.

## Revision checks

1. What clock event does `##1` use here?
2. Why is one local timestamp copy needed per attempt?
3. Why does the first pass occur at 15 ns rather than 5 ns?
4. What remains unfinished when `$finish` executes at 100 ns?
5. When is a cycle-based assertion clearer than subtracting `$realtime`?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16 (Assertions)
- [Accellera SystemVerilog Assertions tutorial](https://www.accellera.org/resources/videos/systemverilog-assertions-tutorial-2016)
