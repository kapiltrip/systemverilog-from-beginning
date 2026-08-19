# Part 05 — From Signals to Assertion Directives

[← Part 04](../04-assertion-control-and-disable/README.md) · [SV Assertions index](../README.md) · Next part not captured yet

| Playground field | Value |
|---|---|
| EDA Playground Name | `SVA 05 - Assertion Building Blocks` |
| Stable playground | [MSmm](https://edaplayground.com/x/MSmm) |
| Simulator used for status check | Aldec Riviera Pro 2025.04 |
| Compile result | 0 errors, 1 warning: no modules defined |
| Simulation result | Initialization stops because no Verilog top module exists yet |

This is an unfinished browser outline, not a completed testbench. Its central chain is valuable:

~~~text
signal -> Boolean expression -> sequence -> property -> directive
~~~

The chain describes increasing levels of verification meaning, but it is a learning map rather than a mandatory grammar pipeline. A property can directly contain a Boolean expression, and an immediate assertion does not require a sequence at all.

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
//signal -> boolean   exp -> sequence-> property-> assert 
~~~

Local source: [testbench.sv](testbench.sv)

The nonbreaking space in the final comment is retained from the live editor. No design file is stored because the design pane contains only EDA Playground's untouched placeholder.

## 1. Why the current playground does not simulate

Comments are legal SystemVerilog input, so parsing them produces no syntax error. However, there is no `module`, `interface`, `program`, or other top-level design unit to elaborate. The observed tool result is therefore:

~~~text
WARNING: No modules defined.
Compile success: 0 Errors, 1 Warning.
VSIM: No Verilog top modules found.
Simulation initialization failed.
~~~

This is the correct current status. The source is a concept outline that you had begun writing; it has not been silently expanded into a different browser program.

## 2. Level 1 — signals and sampled values

A **signal** is the raw design quantity: `req`, `grant`, `state`, `count`, `ready`, and so on. An assertion does not gain meaning merely because it names a signal. You must define:

- which values matter;
- at which event they are observed;
- whether unknown values are legal;
- whether reset disables the check;
- whether the relationship is instantaneous or extends over time.

For a concurrent assertion, ordinary static design signals are normally sampled at the assertion's clocking event using the Preponed value. That sampling rule protects the property from racing with design code that executes on the same edge.

Example raw signals:

~~~systemverilog
logic clk;
logic rst_n;
logic req;
logic grant;
~~~

At this level there is still no requirement—only data that a requirement may reference.

## 3. Level 2 — Boolean expressions

A **Boolean expression** turns signals into one present-time proposition:

~~~systemverilog
req && !grant
state inside {IDLE, BUSY}
count < DEPTH
!(read && write)
~~~

Each asks whether one condition is true at one evaluation or sampling point.

### Four-state values matter

SystemVerilog signals can contain `0`, `1`, `X`, and `Z`. For a simple immediate assertion, an expression that evaluates to `0`, `X`, or `Z` is a failure; only a definite true value passes.

In a concurrent sequence, an `X`/`Z` Boolean expression does not produce a true sequence match. The final property outcome then depends on context. For example, an unknown antecedent may mean the antecedent did not match, which can make an implication pass vacuously. This is why unknown detection often deserves an explicit check:

~~~systemverilog
known_request: assert property (@(posedge clk) !$isunknown(req));
~~~

### A Boolean expression can be enough

You do not always need a named sequence:

~~~systemverilog
never_read_and_write: assert property (
  @(posedge clk)
  !(read && write)
);
~~~

The Boolean expression itself is a one-cycle property at each clock tick.

## 4. Level 3 — sequences

A **sequence** describes a temporal pattern of Boolean matches over one or more assertion clock ticks. It is not a sequence of procedural statements and does not execute assignments like a task.

### Fixed delay

~~~systemverilog
sequence request_then_grant_next_cycle;
  req ##1 grant;
endsequence
~~~

If `req` matches now, `grant` must match exactly one assertion clock later for this sequence to match.

### Ranged delay

~~~systemverilog
sequence request_then_grant_window;
  req ##[1:3] grant;
endsequence
~~~

This permits `grant` one, two, or three assertion clocks after `req`. The delay is counted in assertion clock ticks, not simulator nanoseconds unless the assertion clock itself is defined that way.

### Repetition

~~~systemverilog
busy[*3]     // busy on three consecutive assertion clocks
busy[=3]     // three nonconsecutive matches; gaps are allowed
busy[->3]    // goto repetition; the sequence ends on the third match
~~~

Repetition describes matching structure. It is not a loop that assigns or updates `busy`.

### “Linear or nonlinear” is not the standard classification

The source note uses “linear or non linear” as an intuition for simple versus flexible timing. The language specification instead talks in terms of sequence composition, fixed/ranged delays, consecutive/nonconsecutive/goto repetition, `and`, `or`, `intersect`, `throughout`, `within`, and match-selection constructs such as `first_match`.

A more precise learning replacement is:

~~~text
single path with exact timing
versus
multiple legal match paths caused by ranges, alternatives, or repetition
~~~

When a ranged delay or repetition admits several endpoints, one antecedent can create multiple candidate sequence matches. Understanding which endpoint satisfies a property is a major part of advanced SVA reasoning.

## 5. Level 4 — properties

A **property** turns Boolean/sequence behavior into a complete verification rule. It can add:

- a clocking event;
- reset/abort behavior;
- implication;
- negation and logical composition;
- local variables;
- another named sequence or property.

Example:

~~~systemverilog
property p_request_gets_grant;
  @(posedge clk)
  disable iff (!rst_n)
  req |-> ##[1:3] grant;
endproperty
~~~

The parts mean:

1. sample and advance the property on each `posedge clk`;
2. abort checking while reset is active;
3. whenever `req` matches, create an obligation;
4. require `grant` to match one to three clocks later.

### Overlapped and nonoverlapped implication

| Operator | Consequent starts |
|---|---|
| `|->` | On the same assertion clock where the antecedent completes |
| `|=>` | On the next assertion clock after the antecedent completes |

For a one-cycle antecedent:

~~~systemverilog
req |-> grant       // grant is required in the same sampled cycle
req |=> grant       // grant is required beginning on the next sampled cycle
req |-> ##1 grant   // also asks for grant one clock later
~~~

The third form makes the delay explicit in the consequent; it is often easier for beginners to trace.

### Vacuous success

An implication only creates a consequent obligation when its antecedent matches. If `req` never becomes true, `req |-> ##[1:3] grant` can pass vacuously. That does not prove the request/grant path was exercised. Add coverage:

~~~systemverilog
request_seen: cover property (@(posedge clk) req);
~~~

## 6. Level 5 — assertion directives

A named property describes behavior. A **directive** tells a tool what verification role that behavior has.

### `assert property`

~~~systemverilog
request_must_complete: assert property (p_request_gets_grant)
  else $error("grant did not arrive within three clocks");
~~~

This says the property is an obligation. A nonvacuous failure is an error in the design or verification assumptions.

### `assume property`

~~~systemverilog
environment_is_legal: assume property (
  @(posedge clk)
  disable iff (!rst_n)
  req |-> !illegal_mode
);
~~~

In formal verification, an assumption constrains legal environment behavior. A bad assumption can make proofs meaningless by excluding real behavior, so assumptions must be reviewed as carefully as RTL. In simulation, tool behavior and reporting options for assumptions should be checked rather than assuming they act exactly like formal constraints.

### `cover property`

~~~systemverilog
three_cycle_response_seen: cover property (
  @(posedge clk)
  req ##3 grant
);
~~~

Coverage asks whether a behavior occurs. Failure to hit a cover property is not automatically a design assertion failure; it is evidence that the scenario was not observed or may be unreachable.

## 7. The complete hierarchy, with one correction

The source ends with:

~~~text
signal -> boolean exp -> sequence -> property -> assert
~~~

A more complete map is:

~~~text
design signals
   │
   ▼
Boolean expressions
   │
   ├──────────────► immediate assertion
   │
   ▼
sequence expressions (optional named layer)
   │
   ▼
property expression
   │
   ├── assert property  : obligation
   ├── assume property  : environment premise
   └── cover property   : reachability/observation goal
~~~

The important correction is “sequence optional.” These are all valid:

~~~systemverilog
assert (count < DEPTH);                              // immediate
assert property (@(posedge clk) count < DEPTH);     // concurrent Boolean
assert property (@(posedge clk) req ##1 grant);     // concurrent sequence
assert property (p_request_gets_grant);              // named property
~~~

## 8. A runnable end-to-end example

This example is explanatory material; it is not substituted into the captured browser source.

~~~systemverilog
module request_grant_example;
  timeunit 1ns;

  logic clk = 0;
  logic rst_n = 0;
  logic req = 0;
  logic grant = 0;

  always #5 clk = ~clk;

  sequence s_request_pulse;
    req ##1 !req;
  endsequence

  property p_request_gets_grant;
    @(posedge clk)
    disable iff (!rst_n)
    req |-> ##[1:3] grant;
  endproperty

  a_request_gets_grant: assert property (p_request_gets_grant)
    else $error("grant deadline missed at %0t", $time);

  c_request_pulse: cover property (
    @(posedge clk)
    disable iff (!rst_n)
    s_request_pulse
  );

  initial begin
    repeat (2) @(negedge clk);
    rst_n = 1;

    @(negedge clk) req = 1;
    @(negedge clk) req = 0;
    @(negedge clk) grant = 1;
    @(negedge clk) grant = 0;

    repeat (3) @(negedge clk);
    $finish;
  end
endmodule
~~~

Stimulus changes on `negedge clk`, away from the assertion's positive-edge sampling event. That separation makes the teaching trace deterministic.

## 9. Revision questions

1. Why is a sequence not a procedural task?
2. What is the difference between `##1` and `#1`?
3. When does `|->` begin its consequent compared with `|=>`?
4. Why can an implication pass even if its consequent was never tested?
5. What different verification roles do `assert`, `assume`, and `cover` assign?
6. Why can an immediate assertion skip the sequence/property naming layers?
7. What does `disable iff` do to an active temporal attempt?
8. Why should unknown values be checked explicitly in control signals?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clause 16
- [Accellera DVCon SystemVerilog Assertions tutorial](https://www.accellera.org/images/resources/videos/SystemVerilog_Assertions_Tutorial_2016.pdf)
- [Foundation 00 — sampling, regions, and assertion families](../../Foundations/00-event-scheduling-regions-and-assertion-types/README.md)
