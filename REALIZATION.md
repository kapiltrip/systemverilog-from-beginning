# SystemVerilog Realizations

This file records the ideas that personally **clicked while studying**. It is deliberately separate from the formal lesson notes:

- **Learning notes** explain what SystemVerilog defines and how to use it.
- **Realizations** record the mental connection that makes the behavior intuitive.

Each entry keeps the original evidence, states the realization clearly, and then verifies why it is correct.

## Index

| No. | Realization |
|---:|---|
| 01 | [Concurrent assertions sample before same-edge blocking assignments](#01--concurrent-assertions-sample-before-same-edge-blocking-assignments) |

## 01 — Concurrent assertions sample before same-edge blocking assignments

![Conversation in which the Preponed-before-Active relationship became clear](assets/realizations/01-preponed-sampling-before-active-blocking.png)

### The realization

> A concurrent assertion can see a value that is not affected by a blocking assignment made at the same clock edge. Therefore, its value must have been sampled before that blocking assignment executed.

That reasoning is correct for ordinary static design signals used by a concurrent assertion.

### Why it happens

A clock edge creates one simulation time slot containing several ordered regions. The important ordering is:

~~~text
PREPONED  ->  ACTIVE  ->  NBA  ->  OBSERVED  ->  REACTIVE
   |             |                    |              |
   |             |                    |              +-- run assertion action
   |             |                    +-- evaluate the property
   |             +-- execute ordinary procedural blocking assignments
   +-- obtain ordinary concurrent-assertion samples
~~~

Suppose a positive edge occurs at `t = 45 ns`:

| Region | What happens | Meaning |
|---|---|---|
| **Preponed** | The concurrent assertion obtains its sample of an ordinary signal such as `a`. | The sample represents `a` immediately before the current time slot's procedural activity. |
| **Active** | An `always @(posedge clk)` block executes `a = 1'b1;`. | The blocking assignment changes the current value immediately, but it is too late to alter the sample already taken for this assertion attempt. |
| **Observed** | The concurrent property is evaluated. | It uses the earlier sampled value of `a`, not a fresh read of the value written in Active. |
| **Reactive** | The assertion's pass or fail action executes. | A plain `a` read here can show the newer current value, while `$sampled(a)` shows the value that caused the assertion decision. |

All four stages can occur at `t = 45 ns`. No simulation time needs to pass between them.

### Minimal example

~~~systemverilog
logic clk = 1'b0;
logic a   = 1'b0;

always #5 clk = ~clk;

always @(posedge clk) begin
  a = 1'b1;  // Blocking assignment executes in Active.
end

a_was_low_at_the_edge: assert property (@(posedge clk) !a)
  $info("PASS: sampled a=%0b, current a=%0b", $sampled(a), a);
else
  $error("FAIL: sampled a=%0b, current a=%0b", $sampled(a), a);
~~~

At the first positive edge:

1. Preponed supplies sampled `a = 0`.
2. Active executes the blocking assignment, so current `a` becomes `1`.
3. Observed evaluates `!a` using sampled `a = 0`, so the property passes.
4. Reactive runs the pass action. It can report `sampled a=0` and `current a=1`.

The result may initially look contradictory, but the two printed values answer different questions:

- `$sampled(a)` asks, “Which value did this assertion attempt use?”
- plain `a` in the Reactive action asks, “What is the signal's current value now?”

### The boundary of this realization

The safe memory rule is:

> Ordinary concurrent-assertion operands normally use their Preponed samples, while ordinary procedural blocking assignments normally execute later in Active.

Do not overgeneralize it into “every assertion-related expression is always sampled in Preponed.” SystemVerilog defines qualifications for clock expressions, `disable iff`, automatic or local variables, checker variables, and clocking-block inputs. The realization describes the common ordinary-static-signal case shown in the screenshot.

### One-line recall test

If a same-edge Active blocking assignment changes `a`, which value explains a concurrent assertion's decision: plain `a` in the Reactive action or `$sampled(a)`?

**Answer:** `$sampled(a)`, because it retrieves the sample used by the assertion attempt.

For the complete scheduler explanation, see [Event Scheduling Regions and Assertion Types](SV%20Assertions/Foundations/00-event-scheduling-regions-and-assertion-types/README.md).
