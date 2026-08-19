# Part 04 — Assertion Control and Procedural Disable

[← Part 03](../03-clocked-immediate-assertion-and-nba-timing/README.md) · [SV Assertions index](../README.md) · [Part 05 →](../05-assertion-building-blocks/README.md)

| Saved-playground field | Value |
|---|---|
| EDA Playground Name | `SVA 04 - Assertion Control and Disable` |
| Stable playground | [hACs](https://edaplayground.com/x/hACs) |
| Simulator used for verification | Aldec Riviera Pro 2025.04 |
| Compile result | 0 errors, 0 warnings |
| Observed run | One pass at 59 ns; no failure while assertions are off |

This playground combines two different control mechanisms: the global assertion-control tasks `$assertoff`/`$asserton`, and procedural `disable` applied to the labeled deferred assertion `a1`. They solve different problems and should not be treated as interchangeable reset syntax.

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg a; 
  reg rst; 
  initial begin
    $assertoff(); // to turn off an assertion check 
    a =0 ; 
    #59;
    $asserton(); 
    a=1;
  end
  always @(*) begin
    a1: assert #0 (a==1) $info("success at time %0t " , $time ); else $error("Failure at time %0t" , $time);
    if(rst == 1'b1) 
      disable a1; // only for deferred immediate assertion or use if else block in immediate assertion 
  end
    initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars; 
    #300; 
    $finish; 
    
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv)

## 1. `$assertoff()` and `$asserton()`

Assertion control system tasks change whether selected assertions are checked.

- `$assertoff()` prevents the selected assertions from starting normal checking until they are re-enabled.
- `$asserton()` re-enables them.
- `$assertkill()` is stronger for temporal assertions because it also terminates active assertion attempts.
- `$assertcontrol(...)` is the more general control interface when fine-grained control by assertion/directive type is required.

With no scope arguments, `$assertoff()` and `$asserton()` apply broadly to all assertions in the model. That makes the source concise, but it is often too wide for a large verification environment. A targeted scope or labeled assertion is safer when unrelated checkers must remain active.

## 2. Exact timeline of the live run

### Time 0

`$assertoff()` executes before `a = 0` in the same `initial` process. The assignment to `a` awakens the `always @(*)` checker, but assertion checking is disabled. Therefore:

- `(a == 1)` does not produce a visible failure;
- neither the pass action nor the fail action runs;
- the log remains quiet.

### Time 59 ns

The process resumes and executes:

~~~systemverilog
$asserton();
a = 1;
~~~

The assertion system is enabled before `a` changes. The change awakens the combinational checker, `(a == 1)` is true, and the observed-deferred pass action survives to produce:

~~~text
success at time 59
~~~

### Time 300 ns

The second `initial` block calls `$finish`. No later stimulus changes `a` or `rst`, so there is no additional checker execution.

## 3. Why `rst` does nothing in the captured source

`rst` is declared but never initialized or assigned. A four-state `reg` therefore begins as `X`.

The condition is:

~~~systemverilog
if (rst == 1'b1)
~~~

When `rst` is `X`, the equality expression is `X`, not `1`. An `if` condition only takes the true branch for a true value; an unknown condition does not make this branch execute. Consequently, `disable a1` is never reached in the live run.

This is why the one pass at 59 ns demonstrates `$assertoff`/`$asserton`, but it does **not** demonstrate reset-driven `disable` behavior.

## 4. What `disable a1` means here

`a1` labels the deferred immediate assertion statement. The code first evaluates the assertion and queues its deferred result, then conditionally executes `disable a1`.

For a deferred immediate assertion, disabling the labeled statement before its pending report matures can cancel that current pending report. This timing is why the source comment contrasts it with a simple immediate assertion:

- a simple immediate fail action runs immediately when the assertion statement executes;
- a following `disable` cannot “unprint” that already executed action;
- a deferred immediate action is still pending, so there is an opportunity to cancel the current deferred result.

The important scope limitation is:

> `disable a1` controls the current procedural activation/pending result; it is not a persistent global “turn this assertion off forever” setting.

When the containing `always` process executes again with reset inactive, `a1` can be evaluated normally again.

## 5. Global control, procedural disable, and `disable iff`

These three mechanisms answer different questions.

| Mechanism | Typical purpose | Duration and scope |
|---|---|---|
| `$assertoff` / `$asserton` | Testbench-controlled assertion enable window | Persists until another control task; can affect a hierarchy or the entire model |
| `disable label` | Terminate the current activation of a named statement/block or cancel its pending deferred work | Procedural and activation-specific |
| `disable iff (reset)` in a concurrent property | Abort/disable temporal attempts while a reset condition is true | Defined as part of the property's temporal semantics |

Do not use `$assertoff()` as the default substitute for every reset. It can accidentally hide unrelated failures throughout the model.

## 6. A clearer immediate-assertion reset structure

For an immediate combinational checker, gate execution before reaching the assertion:

~~~systemverilog
always_comb begin
  if (!rst) begin
    a1: assert #0 (a == 1)
      $info("success at time %0t", $time);
    else
      $error("failure at time %0t", $time);
  end
end
~~~

This expresses the intent directly: while reset is active, do not evaluate or queue the assertion. It is easier to review than queuing a result first and disabling its label afterward.

For a clocked temporal requirement, use property-level reset control:

~~~systemverilog
a_stays_high: assert property (
  @(posedge clk)
  disable iff (rst)
  enable |-> a
);
~~~

Here `disable iff` aborts active temporal attempts when `rst` is true. It is not the same construct as procedural `disable a1`.

## 7. How to make the captured experiment actually demonstrate reset disable

A minimal teaching extension would initialize and drive `rst`:

~~~systemverilog
initial begin
  rst = 1'b1;
  #20 rst = 1'b0;
end
~~~

However, simply adding this stimulus is not enough to learn everything. You should also print reset transitions and compare two versions:

1. the original “assert, then `disable a1`” version;
2. the clearer “if reset is inactive, execute the assertion” version.

That comparison shows the difference between canceling pending work and preventing the assertion from being evaluated in the first place.

## 8. What the live result proves—and what remains unanswered

The run proves that the tool accepts the assertion-control tasks and suppresses the time-zero failure while checking is off. It also proves that checking resumes before the 59 ns assignment and that the deferred pass action runs.

It does not prove the behavior of `disable a1`, because `rst` remains unknown and the disable branch never executes. It also does not show selective hierarchical assertion control because the no-argument tasks affect every assertion in the model.

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 16.4 and 20.12
- [Accellera SystemVerilog draft assertion-control description](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf)
