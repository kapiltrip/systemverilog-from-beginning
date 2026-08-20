# Part 12 — Clocking Events and `disable iff`

[← Part 11](../11-sampled-and-vector-system-functions/README.md) · [SV Assertions index](../README.md) · [Part 13 →](../13-delay-operators-and-ranges/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 12 - Clocking Events and Disable Iff` |
| Stable playground | [GeAH](https://edaplayground.com/x/GeAH) |
| Simulator | Siemens Questa 2025.2 |
| Live result | 0 compile errors; 19 intentional assertion failures from the chosen stimulus |
| EPWave | Disabled |

## Exact browser source

~~~systemverilog
// Code your testbench here
// or browse Examples
/*
boolean operation  series of operations 
sequence linear or non linear , relationship known , or non linear relationship not known delay , repetition matching 
property select, implication 
  assertion => assert assume cover 
 */
//signal -> boolean   exp -> sequence-> property-> assert 
// clocking block
// disable concurrent assertion 
// 
module tb;
  reg clk=0; 
  reg temp=0;
  reg a =0; 
  reg rst = 0; 
  reg en=1; 
  
  initial begin
    temp=1 ; 
    @(posedge clk);
    temp=0;
    
  end
  initial begin
    rst=1; 
    #7; 
    rst=0; 
    #5;
    rst = 1; 
    
  end
  always #5 clk = ~clk ; 
  //always #5 clk = ~clk ; 
  clocking c1 @(posedge clk);
  endclocking 
  
  default clocking c2 @(negedge clk);
  endclocking 
  
  always #40 a = ~a ;
  a1 : assert property (@(c1) disable iff(!en) (a == 1'b1)) $info("a1 success at %0t" , $time) ; else $error("A1 fail at %0t" , $time);
       initial a2 : assert property (@(posedge clk) (a == 1'b1)) $info("a1 success at %0t" , $time) ; else $error("A1 fail at %0t" , $time);
       check_posedge : assert property (@(posedge clk) en |-> rst ) $info("posedge success at %0t" , $time) ; else $error("posedge fail at %0t" , $time);
       check_negedge : assert property (@(negedge clk) en |-> rst ) $info("negedge success at %0t" , $time) ; else $error("negedge fail at %0t" , $time);
       check_edge : assert property (@(edge clk) en |-> rst ) $info("edge success at %0t" , $time) ; else $error("edge fail at %0t" , $time);
     initial begin
       repeat (30) @(posedge clk );
       $finish();
     end
         
         
    // valid clock edges posedge negedge edge 
    
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane was placeholder-only.

## Assertion clocking events

A concurrent assertion advances only at its clocking event. This source compares four forms:

| Form | Sampling event |
|---|---|
| `@(c1)` | the event declared by named clocking block `c1`, here `posedge clk` |
| `@(posedge clk)` | rising edge only |
| `@(negedge clk)` | falling edge only |
| `@(edge clk)` | either rising or falling edge |

`@(edge clk)` therefore creates twice as many sampling opportunities as a positive-edge-only property for this free-running clock.

## Named and default clocking blocks

~~~systemverilog
clocking c1 @(posedge clk);
endclocking

default clocking c2 @(negedge clk);
endclocking
~~~

`c1` is named and is explicitly selected by `@(c1)`. `c2` establishes a default clocking block in its scope. A default is used only where the language construct relies on the default; it does not override an explicit `@(posedge clk)`, `@(negedge clk)`, `@(edge clk)`, or `@(c1)`.

Clocking blocks can also declare input/output skews and directions. This playground uses empty clocking blocks only to study their events.

## `disable iff` is an abort condition

~~~systemverilog
@(c1) disable iff (!en) (a == 1'b1)
~~~

`disable iff` is not a Boolean antecedent and is not the same as `!en |-> ...`. When its expression is true, current attempts are disabled and no pass or failure is produced for those aborted attempts. It is commonly used for reset:

~~~systemverilog
assert property (@(posedge clk)
  disable iff (!rst_n)
  req |-> ##[1:3] grant
);
~~~

The disable expression is asynchronous/unsampled relative to the property's sampled Boolean expressions. That distinction can matter when reset changes on the clock edge. If synchronous sampled-reset semantics are required, write the property deliberately for them instead of assuming `disable iff` is sampled like the antecedent.

In this playground `en` starts at `1` and never changes. Therefore `!en` is always false, so `a1` is never disabled.

## Why the live run reports many failures

`a` begins at `0` and toggles every 40 ns. Module-scope `a1` has the verification statement's implicit repeated evaluation, so it demands `a==1` on every positive edge. It fails on 16 positive edges during the four long low intervals.

`rst` is high initially, becomes low at 7 ns, and returns high at 12 ns. Since `en` is always high, each edge-based property reduces to “`rst` must be high on every selected edge.” Checks whose sampled event falls within the low-reset window fail:

- the `negedge` and `edge` checks can sample the falling clock edge at 10 ns;
- positive-edge checking samples at 5, 15, 25 ns and therefore does not sample `rst` low at 10 ns;
- the `edge` property checks both sets of edges and naturally generates more results.

The procedural `a2` statement creates one attempt when the `initial` process reaches it, so it fails once at the first positive edge. The reset checks fail twice at 10 ns: once for `check_negedge` and once for `check_edge`. The complete count is therefore `16 + 1 + 2 = 19`. Compile success and assertion failure are different facts: the code is legal, while the stated properties are false for the applied stimulus.

## The procedural `initial a2` form

Questa accepts the concurrent assertion statement inside the `initial` process:

~~~systemverilog
initial a2 : assert property (@(posedge clk) (a == 1'b1)) ...
~~~

The process reaches the statement at time zero and starts **one** property evaluation attempt. It is not the same as a module-scope verification statement, whose assertion evaluation is implicitly repeated. That distinction explains why this `a2` produces only the first failure rather than failing throughout every later low interval.

For a check on every clock, the module-scope form is clearer:

~~~systemverilog
a2: assert property (@(posedge clk) a);
~~~

An explicit property `always` operator can also express repeated temporal behavior inside the procedural concurrent assertion, but the module-scope form above is the normal direct spelling. This should not be confused with a simple immediate assertion: `assert property` still uses concurrent sampled-property semantics.

## Sampled property values versus action blocks

For each explicit assertion event, ordinary design expressions such as `en`, `rst`, and `a` are sampled in Preponed. The property is evaluated in Observed. Pass/fail action blocks containing `$info` or `$error` run in Reactive. Thus the message time is the assertion event time, but the property decision is based on the sample, not on a later Active-region update.

## Better reset examples

Disable a property while active-low reset is asserted:

~~~systemverilog
grant_deadline: assert property (@(posedge clk)
  disable iff (!rst_n)
  req |-> ##[1:2] grant
);
~~~

Check reset itself on both clock edges without using disable:

~~~systemverilog
reset_known_both_edges: assert property (@(edge clk)
  !$isunknown(rst)
);
~~~

These are different intentions: the first aborts a functional rule under reset; the second verifies the reset signal.

## Revision checks

1. Why does `default clocking c2` not change `@(posedge clk)` assertions?
2. How many assertion events does `@(edge clk)` see per full clock period?
3. Why is `disable iff` different from an implication antecedent?
4. Why can a test compile with zero errors yet end with assertion errors?
5. Which regions sample, evaluate, and report a concurrent assertion?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 4.4, 14, 16.12, and 16.14.6
- [Foundation 00 — event regions and assertion types](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
