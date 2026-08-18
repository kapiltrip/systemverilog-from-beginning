# SystemVerilog Learning Index

[Repository home](../README.md) · [EDA/source audit](../EDA_PLAYGROUND_AUDIT.md)

This is the canonical study index for all 42 captured parts. Repository part numbers describe the learning order. Parts 30–42 came from the newly saved EDA queue labels 000–012; that original label is recorded in every matching README so the browser list, stable short link, and local folder can always be reconciled.

## Phase 1 — Simulation and collections

| Part | Topic | Main idea | Playground |
|---:|---|---|---|
| 01 | [Simulation Basics](01-simulation-basics/README.md) | Time zero, delays, monitoring, finish | [Ucnp](https://edaplayground.com/x/Ucnp) |
| 02 | [Clock Generation](02-clock-generation/README.md) | Periodic clocks and timestamp reasoning | [gi86](https://edaplayground.com/x/gi86) |
| 03 | [Phase-Shifted Clocks](03-phase-shifted-clocks/README.md) | Period, phase, and relative timing | [gi8n](https://edaplayground.com/x/gi8n) |
| 04 | [Data Types and Time](04-data-types-and-time/README.md) | Two/four-state values, `$time`, `$realtime` | [giAN](https://edaplayground.com/x/giAN) |
| 05 | [Fixed Arrays and For Loop](05-fixed-arrays-and-for-loop/README.md) | Unpacked arrays, `$size`, `%p`, indexed traversal | [8k9Q](https://edaplayground.com/x/8k9Q) |
| 06 | [Array Iteration](06-array-iteration/README.md) | `foreach`, `repeat`, array traversal | [GK3p](https://edaplayground.com/x/GK3p) |
| 07 | [Whole-Array Copying](07-array-copying/README.md) | Compatible aggregate assignment | [CafY](https://edaplayground.com/x/CafY) |
| 08 | [Queue Operations](08-queue-operations/README.md) | Push, insert, pop, delete | [bKTC](https://edaplayground.com/x/bKTC) |

## Phase 2 — Classes and object behavior

| Part | Topic | Main idea | Playground |
|---:|---|---|---|
| 09 | [Class Object Basics](09-class-object-basics/README.md) | Class declarations, handles, `new`, null | [qLDu](https://edaplayground.com/x/qLDu) |
| 10 | [Tasks and Functions](10-tasks-and-functions/README.md) | Return values, timing controls, task stimulus | [ecCx](https://edaplayground.com/x/ecCx) |
| 11 | [Pass by Reference](11-pass-by-reference/README.md) | Caller-visible `ref` updates | [Ua2v](https://edaplayground.com/x/Ua2v) |
| 12 | [Array Reference Passing](12-array-reference-passing/README.md) | Fixed unpacked arrays passed by `ref` | [ADYn](https://edaplayground.com/x/ADYn) |
| 13 | [Constructor Arguments](13-constructor-arguments/README.md) | Default, positional, and named arguments | [Ud7M](https://edaplayground.com/x/Ud7M) |
| 14 | [Class Composition and Scope](14-class-composition-and-scope/README.md) | Nested objects, setters, getters | [EasK](https://edaplayground.com/x/EasK) |
| 15 | [Class Shallow Copy](15-class-shallow-copy/README.md) | New outer object and copied properties | [sVdz](https://edaplayground.com/x/sVdz) |
| 16 | [Class Custom Copy Method](16-class-custom-copy-method/README.md) | Explicit independent copy policy | [X4c6](https://edaplayground.com/x/X4c6) |
| 17 | [Deep Copy with Nested Objects](17-class-deep-copy-with-nested-objects/README.md) | Recursive copy of nested handles | [gchG](https://edaplayground.com/x/gchG) |
| 18 | [Shallow Copy with Nested Handle](18-class-shallow-copy-with-nested-handle/README.md) | Aliasing through a copied nested handle | [9FTS](https://edaplayground.com/x/9FTS) |
| 19 | [Class Inheritance Basics](19-class-inheritance-basics/README.md) | Base/derived classes and inherited members | [uVqk](https://edaplayground.com/x/uVqk) |
| 20 | [Polymorphism with Virtual Methods](20-polymorphism-with-virtual-methods/README.md) | Overriding and dynamic dispatch | [sPne](https://edaplayground.com/x/sPne) |
| 21 | [Constructor Arguments and `super`](21-constructor-arguments-and-super-keyword/README.md) | Superclass construction | [bpmE](https://edaplayground.com/x/bpmE) |

## Phase 3 — Constrained random stimulus

| Part | Topic | Main idea | Playground |
|---:|---|---|---|
| 22 | [Constrained Randomization with `randc`](22-constrained-randomization-with-randc/README.md) | Cyclic random variables and solver status | [Fqxx](https://edaplayground.com/x/Fqxx) |
| 23 | [Single Constraint](23-constrained-randomization-with-a-single-constraint/README.md) | One constraint block over `randc` members | [gixd](https://edaplayground.com/x/gixd) |
| 24 | [`inside` and Excluded Ranges](24-constrained-randc-inside-and-excluded-ranges/README.md) | Set membership and negated `inside` | [A7hT](https://edaplayground.com/x/A7hT) |
| 25 | [Constraint Outside a Class](25-constraint-outside-a-class/README.md) | External constraint and method bodies | [BCGE](https://edaplayground.com/x/BCGE) |
| 26 | [Dynamic Range Constraints](26-dynamic-range-constraints-with-post-randomize/README.md) | Bound variables and `post_randomize` | [Zw3t](https://edaplayground.com/x/Zw3t) |
| 27 | [Runtime Range Changes](27-runtime-constraint-range-changes-with-randc/README.md) | Changing effective ranges across phases | [Jsd4](https://edaplayground.com/x/Jsd4) |
| 28 | [Constraint Operators and Modes](28-constraint-operators-distribution-and-modes/README.md) | Implication, equivalence, `dist`, modes | [Lb86](https://edaplayground.com/x/Lb86) |
| 29 | [`:=` and `:/` Distribution](29-distribution-constraints-with-colon-equal-and-colon-slash/README.md) | Per-value versus range-level weights | [6Yt4](https://edaplayground.com/x/6Yt4) |

## Phase 4 — Testbench process communication

| Part | Original queue | Topic | Main idea | Live result | Playground |
|---:|---:|---|---|---|---|
| 30 | 000 | [FIFO Transaction and Weighted Constraints](30-fifo-transaction-and-weighted-constraints/README.md) | Stimulus/response fields, weighted control constraints | Compile lesson: `dist` separator error | [gjeT](https://edaplayground.com/x/gjeT) |
| 31 | 001 | [Event Trigger and Wait Semantics](31-event-trigger-and-wait-semantics/README.md) | `@(event)` versus `wait(event.triggered)` | Pass | [F6qC](https://edaplayground.com/x/F6qC) |
| 32 | 002 | [Event Races and Triggered State](32-event-races-and-triggered-state/README.md) | Same-time event ordering | Pass | [Lhvp](https://edaplayground.com/x/Lhvp) |
| 33 | 003 | [Generator–Driver Completion Event](33-generator-driver-completion-event/README.md) | Shared-state weakness and end-of-test event | Pass | [J57K](https://edaplayground.com/x/J57K) |
| 34 | 004 | [Two-Way Event Handshake](34-two-way-event-handshake/README.md) | Per-item acknowledgement plus completion | Pass | [9yRX](https://edaplayground.com/x/9yRX) |
| 35 | 005 | [`fork...join` Variants](35-fork-join-variants/README.md) | `join`, `join_any`, `join_none` timing | Pass | [B3zJ](https://edaplayground.com/x/B3zJ) |
| 36 | 006 | [Semaphore-Controlled Access](36-semaphore-controlled-resource-access/README.md) | Single-key critical section | Pass | [gjuf](https://edaplayground.com/x/gjuf) |
| 37 | 007 | [Generator–Driver Mailbox](37-generator-driver-mailbox/README.md) | Shared untyped mailbox | Pass | [A8er](https://edaplayground.com/x/A8er) |
| 38 | 008 | [Constructor-Injected Mailbox](38-constructor-injected-mailbox/README.md) | Explicit component dependency | Pass | [gjvi](https://edaplayground.com/x/gjvi) |
| 39 | 009 | [Parameterized Transaction Mailbox](39-parameterized-transaction-mailbox/README.md) | Typed object transport | Pass | [tEEA](https://edaplayground.com/x/tEEA) |

## Phase 5 — Layered DUT communication

| Part | Original queue | Topic | Main idea | Live result | Playground |
|---:|---:|---|---|---|---|
| 40 | 010 | [Interface, Modport, and Virtual Interface](40-interface-modport-and-virtual-interface/README.md) | Bind a class driver to static DUT signals | Pass | [VgAA](https://edaplayground.com/x/VgAA) |
| 41 | 011 | [Layered Adder Testbench and Object Copies](41-layered-adder-testbench-and-object-copies/README.md) | Generator, copy, mailbox, driver, completion event | Pass | [Xcxx](https://edaplayground.com/x/Xcxx) |
| 42 | 012 | [Error Injection with Inheritance](42-error-injection-with-inheritance/README.md) | Derived stimulus, clone/factory pitfalls | Compile lesson: missing `copy()` | [Cxwq](https://edaplayground.com/x/Cxwq) |

## Quick concept lookup

| If you want to revise… | Go to |
|---|---|
| Simulation time and clocks | Parts 01–04 |
| Arrays and queues | Parts 05–08 |
| Object construction and copying | Parts 09, 13–18 |
| Inheritance and dynamic dispatch | Parts 19–21 and 42 |
| Constraint syntax and probability | Parts 22–30 |
| Events and parallel-process control | Parts 31–35 |
| Shared-resource arbitration | Part 36 |
| Mailbox transport and handle identity | Parts 37–39 and 41 |
| Interfaces, modports, and class-to-DUT binding | Parts 40–42 |
| Why a generated transaction is not yet a checked result | Parts 41–42 |

## Per-part file contract

Every numbered directory contains:

- `README.md` — navigation, saved settings, inline code, technical explanation, source-question answers, and live-result evidence;
- `testbench.sv` — the captured testbench code.

`design.sv` is intentionally optional. It is kept only when the live design pane contains substantive lesson code: Parts 22, 30, and 40–42 currently have one. When EDA Playground contains only its untouched `// Code your design here` placeholder, neither an empty local file nor an empty README code block is created. Part 16 separately retains `editor_testbench.sv`, an additional baseline capture.

The source files are learning evidence. A compile failure is retained when it is present in the saved playground and is explained in the README rather than silently corrected.
