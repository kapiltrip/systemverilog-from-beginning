# Part 01 — Observed-Deferred Immediate Assertion

[SV Assertions index](../README.md) · [Foundation 00](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md) · [Part 02 →](../02-immediate-assertions-in-a-mux/README.md)

| Saved-playground field | Value |
|---|---|
| EDA Playground Name | `SVA 01 - Observed Deferred Assertion` |
| Stable playground | [NgZs](https://edaplayground.com/x/NgZs) |
| Simulator used for verification | Aldec Riviera Pro 2025.04 |
| Compile result | 0 errors, 0 warnings |
| Observed run | Pass at 0 ns; failures at 10 ns and 20 ns |

This first browser lesson asks three connected questions: what distinguishes nontemporal and temporal assertions, what `assert #0` actually defers, and how deferred immediate assertions avoid reporting temporary combinational glitches.

## Exact browser source

The source below is preserved exactly as it appeared in the EDA Playground testbench pane. Spelling and spacing are retained because this repository treats the browser code as learning evidence.

~~~systemverilog
// Code your testbench here
// or browse Examples
//assertions working on non temporal domain 
// assertions working on temporal domain 
//OBSERVED / FINAL DEFFERED ASSERTIONS 
// HOW THEY ARE ABLE TO REMOVE GLITCHES, WRT THE VARIOUS REGIONS 

module tb;
  reg am=0;
  reg bm=0; 
  wire a,b; 
  assign a= am;  //active region 
  assign b=bm;
  initial begin
    am=1;
    bm=1;
    #10;
    am=0;
    bm=1;
    #10;
    am=1;
    bm=0;
    #10;
  end
  always_comb begin
    a1: assert #0 (a==b) $info("a and b are equal at %0t" , $time) ; 
    else $info("assertion failed at time %0t" , $time);
  end
endmodule 
~~~

Local source: [testbench.sv](testbench.sv)

## 1. Nontemporal versus temporal assertion logic

`a == b` is a **nontemporal Boolean expression**. It asks one question about one evaluation instant: are the two current values equal? It contains no clock, no cycle delay, and no obligation extending into a later sampling event.

The statement in this playground is therefore a deferred **immediate** assertion:

~~~systemverilog
a1: assert #0 (a == b) ...
~~~

The word *immediate* describes when the Boolean expression is evaluated: when execution reaches the statement. The `#0` does not convert it into a temporal property.

A temporal assertion instead describes a relationship across sampled clock events. For example:

~~~systemverilog
request_gets_grant: assert property (
  @(posedge clk)
  request |-> ##[1:3] grant
);
~~~

That property can start an obligation when `request` is sampled and keep it alive for later clock ticks. This playground contains comments about the temporal domain, but its executable assertion is nontemporal.

## 2. What `assert #0` actually means

The token `#0` has a special assertion meaning here. It is not the procedural delay used in code such as `#0 statement;`.

When the `always_comb` process reaches `a1`:

1. `(a == b)` is evaluated during that execution of the process, normally in the Active region.
2. A pending pass or failure report is placed on the process's deferred-assertion queue.
3. If the combinational process is triggered again during the same time slot, the earlier pending report can be flushed and replaced by the later evaluation.
4. An observed-deferred report that survives to the Observed region matures there.
5. Its permitted pass or fail subroutine call executes in the Reactive region.

So the precise memory rule is:

> `assert #0` defers the report/action, not the evaluation of the Boolean expression.

This is why replacing the statement with an ordinary procedural `#0` is not equivalent. A procedural `#0` suspends a process into the Inactive region; it does not use the deferred-assertion queue or its flush semantics.

## 3. How glitch suppression works region by region

Consider a combinational result that briefly has the wrong value while several zero-time updates settle.

| Region or phase | What can happen |
|---|---|
| Active and later Active iterations | Inputs, continuous assignments, and combinational procedures may update in an order that temporarily makes the assertion expression false. The deferred immediate assertion evaluates on each relevant execution. |
| Deferred queue flush point | If the same combinational process is awakened again, an earlier pending result from that process can be discarded. A transient failure therefore need not become a visible error. |
| Observed | The last unflushed result of an `assert #0` instance matures. |
| Reactive | The surviving `$info` or `$error` call executes. |
| Postponed | A final-deferred `assert final` report would mature here, after all iterative regions have settled. |

The protection is not “wait some arbitrary amount of simulation time.” It is “allow zero-time combinational settling within this time slot, then report the result that survives the defined deferred-assertion flushing rules.”

### A clearer glitch experiment

The captured source changes `a` and `b` to genuinely unequal final values at 10 ns and 20 ns, so those failures are correct and should not be filtered. A classic transient-only experiment is:

~~~systemverilog
logic a;
wire not_a = !a;

always_comb begin
  simple_check:   assert    (not_a != a) else $error("transient seen");
  deferred_check: assert #0 (not_a != a) else $error("settled failure");
end
~~~

When `a` changes, `always_comb` can execute once before `not_a` has reacted and again after it has settled. The simple assertion may print the first temporary failure immediately. The observed-deferred assertion can flush that first pending failure when the process re-executes and keep the final passing result.

## 4. Exact timeline of this playground

### Time 0

The declarations initialize `am` and `bm` to 0. The `initial` block then assigns both to 1 without advancing time. Continuous assignments copy them to `a` and `b`, and the combinational assertion can execute through multiple zero-time iterations. The final equality is true, so the surviving report is:

~~~text
a and b are equal at 0
~~~

### Time 10 ns

`am` becomes 0 while `bm` remains 1. After settling, `a != b`, so the final result is a real failure:

~~~text
assertion failed at time 10
~~~

### Time 20 ns

`am` becomes 1 and `bm` becomes 0. The final result remains unequal, producing the second real failure.

### Time 30 ns

The stimulus block ends. No `$finish` is required here because the simulator stops when no future events remain.

## 5. Observed-deferred versus final-deferred

Both forms are deferred immediate assertions and both use a nontemporal expression.

| Form | Expression evaluation | Report maturity | Practical distinction |
|---|---|---|---|
| `assert #0 (expr)` | When the statement executes | Observed; action in Reactive | Can suppress ordinary combinational transient reports while still allowing a Reactive action call |
| `assert final (expr)` | When the statement executes | Postponed | Uses the final read-only end of the current time slot; its action cannot modify simulation state |

“Final” means the final region of the **current time slot**, not the end of the entire simulation.

## 6. Answers to the comments in the source

### Do immediate assertions work in a nontemporal domain?

Yes. Simple, observed-deferred, and final-deferred immediate assertions test a nontemporal expression. They do not track a multi-clock history by themselves.

### Which assertion family handles a temporal domain?

Concurrent assertions expressed with `assert property`, `assume property`, or `cover property` are the normal temporal form. Their sequences and properties can express delays, repetitions, implications, and overlapping attempts.

### How do observed/final deferred assertions remove glitches?

They do not change the circuit or force a stable value. They prevent a temporary same-time-slot evaluation from immediately becoming a visible report. Pending results can be flushed during combinational re-evaluation; surviving observed-deferred reports mature in Observed, while final-deferred reports mature in Postponed.

## 7. What this run proves—and what it does not

The live Edge run compiled with 0 errors and produced one pass plus two failures. It proves that the simulator accepts the captured `assert #0` syntax and that the final values at 10 ns and 20 ns violate equality.

It does **not** by itself demonstrate a transient failure being flushed, because the two reported inequalities are stable final values for their time slots. Use the `not_a` experiment above when you specifically want to contrast a false transient with a correct settled result.

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 4.4 and 16.4
- [Accellera deferred-immediate-assertion proposal and examples](https://www.accellera.org/images/eda/sv-bc/att-7234/AssertDefer071026es.pdf)
