# SystemVerilog Basics

> A structured, hands-on SystemVerilog learning repository built from first principles.

[All learning tracks](../README.md) · [Question-to-Code Index](../QUESTION_TO_CODE_INDEX.md#sv-basics)

This track is an ordered SystemVerilog practice notebook. Each numbered part preserves the user-authored code from its saved EDA Playground, records the saved identity and stable link, and adds study notes. A design file is included only when the design pane contains real lesson code; EDA Playground's untouched `// Code your design here` placeholder is not duplicated locally. The READMEs answer questions written in the source and explain observed failures without silently replacing the learning snapshot with different code.

The 44-part path now runs from simulation time, types, arrays, classes, copying, inheritance, and constrained randomization through events, process control, semaphores, mailboxes, interfaces, virtual interfaces, layered drivers, polymorphic error injection, monitors, and scoreboards.

## Start Here

| I want to… | Open |
|---|---|
| Find a question and jump to its code/answer | [Question-to-Code Index](../QUESTION_TO_CODE_INDEX.md#sv-basics) |
| Follow the course in order | [Canonical 44-part learning index](Codes/README.md) |
| Find one concept quickly | [Quick concept lookup](Codes/README.md#quick-concept-lookup) |
| Reconcile a local part with EDA Playground | [EDA/source audit](docs/internal/EDA_PLAYGROUND_AUDIT.md) |
| Continue from the newly captured queue | [Part 30 — FIFO Transaction and Weighted Constraints](Codes/30-fifo-transaction-and-weighted-constraints/README.md) |

The detailed index groups the material into five phases, so earlier parts are no longer one undifferentiated list. Every topic row links to both the notes and its stable editable playground.

## Roadmap at a glance

| Phase | Parts | What changes in this phase |
|---|---:|---|
| 1. Simulation and collections | 01–08 | Time, clocks, scalar types, arrays, queues |
| 2. Classes and object behavior | 09–21 | Handles, methods, argument passing, construction, copying, inheritance, polymorphism |
| 3. Constrained random stimulus | 22–29 | `randc`, `inside`, external constraints, dynamic bounds, implication, distribution |
| 4. Testbench process communication | 30–39 | Transactions, events, fork/join, semaphores, mailboxes |
| 5. Layered DUT communication | 40–44 | Interfaces, modports, virtual interfaces, object snapshots, error injection, monitors, scoreboards |

## Repository Structure

```text
SV Basics/
├── Codes/
│   ├── 01-simulation-basics/
│   ├── 02-clock-generation/
│   ├── 03-phase-shifted-clocks/
│   ├── 04-data-types-and-time/
│   ├── 05-fixed-arrays-and-for-loop/
│   ├── 06-array-iteration/
│   ├── 07-array-copying/
│   ├── 08-queue-operations/
│   ├── 09-class-object-basics/
│   ├── 10-tasks-and-functions/
│   ├── 11-pass-by-reference/
│   ├── 12-array-reference-passing/
│   ├── 13-constructor-arguments/
│   ├── 14-class-composition-and-scope/
│   ├── 15-class-shallow-copy/
│   ├── 16-class-custom-copy-method/
│   ├── 17-class-deep-copy-with-nested-objects/
│   ├── 18-class-shallow-copy-with-nested-handle/
│   ├── 19-class-inheritance-basics/
│   ├── 20-polymorphism-with-virtual-methods/
│   ├── 21-constructor-arguments-and-super-keyword/
│   ├── 22-constrained-randomization-with-randc/
│   ├── 23-constrained-randomization-with-a-single-constraint/
│   ├── 24-constrained-randc-inside-and-excluded-ranges/
│   ├── 25-constraint-outside-a-class/
│   ├── 26-dynamic-range-constraints-with-post-randomize/
│   ├── 27-runtime-constraint-range-changes-with-randc/
│   ├── 28-constraint-operators-distribution-and-modes/
│   ├── 29-distribution-constraints-with-colon-equal-and-colon-slash/
│   ├── 30-fifo-transaction-and-weighted-constraints/
│   ├── ...
│   └── 44-monitor-scoreboard-separate-mailboxes/
├── Project/
├── docs/
│   └── internal/
│       ├── EDA_PLAYGROUND_AUDIT.md
│       ├── issues.md
│       └── README.md
└── README.md
```

### `Codes/`

Every numbered directory contains `README.md` and `testbench.sv`. A `design.sv` is present only when the live design pane contains substantive code; currently those are Parts 22, 30, and 40–44. Part 16 also retains the additional `editor_testbench.sv` capture that existed in the baseline. Part 44 additionally preserves the compilable single-mailbox failure snapshot that preceded its saved correction. Source tokens and comments are preserved from the canonical EDA editor contents; line endings, trailing whitespace, and CodeMirror display-only spacing characters are normalized. When saved code fails or behaves incorrectly, the learning evidence remains visible and the README explains the correction separately.

### `Project/`

Reserved for larger SystemVerilog or verification projects as the repository progresses beyond isolated language exercises.

## Complete Learning Sequence

Parts 01–29 retain their audited saved EDA names. Parts 30–42 were recovered from the queue labels 000–012 and carry descriptive saved EDA names. Parts 43–44 continue from the two later Edge playgrounds, preserving their current saved-name state and stable links. For phase grouping and concept lookup, use the [canonical learning index](Codes/README.md).

| # | Topic | Key Concepts | Resources |
|---:|---|---|---|
| 01 | **SV 01 - Simulation Basics** | Timing, `timescale`, `initial`, delays, VCD, `$monitor`, `$finish` | [Notes](Codes/01-simulation-basics/README.md) · [EDA Playground](https://edaplayground.com/x/Ucnp) |
| 02 | **SV 02 - Clock Generation** | Periodic clocks, delays, edges, simulation timestamps | [Notes](Codes/02-clock-generation/README.md) · [EDA Playground](https://edaplayground.com/x/gi86) |
| 03 | **SV 03 - Phase-Shifted Clocks** | Clock period, phase, relative timing | [Notes](Codes/03-phase-shifted-clocks/README.md) · [EDA Playground](https://edaplayground.com/x/gi8n) |
| 04 | **SV 04 - Data Types and Time** | Two-state/four-state types, `$time`, `$realtime` | [Notes](Codes/04-data-types-and-time/README.md) · [EDA Playground](https://edaplayground.com/x/giAN) |
| 05 | **SV 05 - Fixed Arrays and For Loop** | Unpacked arrays, initialization, `$size`, `%p`, indexed iteration | [Notes](Codes/05-fixed-arrays-and-for-loop/README.md) · [EDA Playground](https://edaplayground.com/x/8k9Q) |
| 06 | **SV 06 - Array Iteration** | `foreach`, `repeat`, array traversal | [Notes](Codes/06-array-iteration/README.md) · [EDA Playground](https://edaplayground.com/x/GK3p) |
| 07 | **Whole-Array Copying** | Compatible array assignment, aggregate operations | [Notes](Codes/07-array-copying/README.md) · [EDA Playground](https://edaplayground.com/x/CafY) |
| 08 | **Queue Operations** | Queue literals, `push_front`, `push_back`, `insert`, `pop_front`, `delete` | [Notes](Codes/08-queue-operations/README.md) · [EDA Playground](https://edaplayground.com/x/bKTC) |
| 09 | **Class Object Basics** | Class declarations, handles, `new`, four-state members, `null` | [Notes](Codes/09-class-object-basics/README.md) · [EDA Playground](https://edaplayground.com/x/qLDu) |
| 10 | **Tasks and Functions** | Return values, timing controls, task stimulus, clock events | [Notes](Codes/10-tasks-and-functions/README.md) · [EDA Playground](https://edaplayground.com/x/ecCx) |
| 11 | **Pass by Reference** | `ref` task arguments and caller-visible updates | [Notes](Codes/11-pass-by-reference/README.md) · [EDA Playground](https://edaplayground.com/x/Ua2v) |
| 12 | **Array Reference Passing** | `ref` function arguments and fixed unpacked arrays | [Notes](Codes/12-array-reference-passing/README.md) · [EDA Playground](https://edaplayground.com/x/ADYn) |
| 13 | **Constructor Arguments** | Default values, positional arguments, named arguments | [Notes](Codes/13-constructor-arguments/README.md) · [EDA Playground](https://edaplayground.com/x/Ud7M) |
| 14 | **Class Composition and Scope** | Public members, setter/getter methods, nested class objects | [Notes](Codes/14-class-composition-and-scope/README.md) · [EDA Playground](https://edaplayground.com/x/EasK) |
| 15 | **Class Shallow Copy** | Object copying, handle assignment, scalar-member independence | [Notes](Codes/15-class-shallow-copy/README.md) · [EDA Playground](https://edaplayground.com/x/sVdz) |
| 16 | **Class Custom Copy Method** | Explicit copy methods, copied members, independent object state | [Notes](Codes/16-class-custom-copy-method/README.md) · [EDA Playground](https://edaplayground.com/x/X4c6) |
| 17 | **Class Deep Copy with Nested Objects** | User-defined copy methods, nested handles, deep-copy behavior | [Notes](Codes/17-class-deep-copy-with-nested-objects/README.md) · [EDA Playground](https://edaplayground.com/x/gchG) |
| 18 | **Class Shallow Copy with Nested Handle** | Shallow copying, shared nested handles, object aliasing | [Notes](Codes/18-class-shallow-copy-with-nested-handle/README.md) · [EDA Playground](https://edaplayground.com/x/9FTS) |
| 19 | **Class Inheritance Basics** | Base and derived classes, inherited members, class handles | [Notes](Codes/19-class-inheritance-basics/README.md) · [EDA Playground](https://edaplayground.com/x/uVqk) |
| 20 | **Polymorphism with Virtual Methods** | Virtual methods, overriding, dynamic dispatch | [Notes](Codes/20-polymorphism-with-virtual-methods/README.md) · [EDA Playground](https://edaplayground.com/x/sPne) |
| 21 | **Constructor Arguments and Super Keyword** | Constructor formals, superclass construction, `super.new` | [Notes](Codes/21-constructor-arguments-and-super-keyword/README.md) · [EDA Playground](https://edaplayground.com/x/bpmE) |
| 22 | **Constrained Randomization with randc** | Class random variables, cyclic randomization, constraint solving | [Notes](Codes/22-constrained-randomization-with-randc/README.md) · [EDA Playground](https://edaplayground.com/x/Fqxx) |
| 23 | **Constrained Randomization with a Single Constraint** | Single constraint block, `randc` members, randomization status | [Notes](Codes/23-constrained-randomization-with-a-single-constraint/README.md) · [EDA Playground](https://edaplayground.com/x/gixd) |
| 24 | **Constrained randc: inside and Excluded Ranges** | Set-membership and negated `inside` constraints | [Notes](Codes/24-constrained-randc-inside-and-excluded-ranges/README.md) · [EDA Playground](https://edaplayground.com/x/A7hT) |
| 25 | **Constraint outside a class** | External constraint and external function declarations | [Notes](Codes/25-constraint-outside-a-class/README.md) · [EDA Playground](https://edaplayground.com/x/BCGE) |
| 26 | **Dynamic Range Constraints with post_randomize** | Bound members, `inside` ranges, and automatic callback output | [Notes](Codes/26-dynamic-range-constraints-with-post-randomize/README.md) · [EDA Playground](https://edaplayground.com/x/Zw3t) |
| 27 | **Runtime Constraint Range Changes with randc** | Two randomization phases with changed effective ranges | [Notes](Codes/27-runtime-constraint-range-changes-with-randc/README.md) · [EDA Playground](https://edaplayground.com/x/Jsd4) |
| 28 | **Constraint Operators, Distribution, and Modes** | Implication, equivalence, distribution weights, conditional constraints, and constraint mode | [Notes](Codes/28-constraint-operators-distribution-and-modes/README.md) · [EDA Playground](https://edaplayground.com/x/Lb86) |
| 29 | **Distribution Constraints with := and :/** | Per-value versus range-level distribution weights | [Notes](Codes/29-distribution-constraints-with-colon-equal-and-colon-slash/README.md) · [EDA Playground](https://edaplayground.com/x/6Yt4) |
| 30 | **SV 30 - FIFO Transaction and Weighted Constraints** | FIFO transaction roles, response fields, weighted constraints, intentional syntax diagnosis | [Notes](Codes/30-fifo-transaction-and-weighted-constraints/README.md) · [EDA Playground](https://edaplayground.com/x/gjeT) |
| 31 | **SV 31 - Event Trigger and Wait Semantics** | Named events, `@(event)`, `wait(event.triggered)` | [Notes](Codes/31-event-trigger-and-wait-semantics/README.md) · [EDA Playground](https://edaplayground.com/x/F6qC) |
| 32 | **SV 32 - Event Races and Triggered State** | Same-time-slot synchronization and missed-trigger races | [Notes](Codes/32-event-races-and-triggered-state/README.md) · [EDA Playground](https://edaplayground.com/x/Lhvp) |
| 33 | **SV 33 - Generator-Driver Completion Event** | Parallel generator/receiver processes and end-of-test control | [Notes](Codes/33-generator-driver-completion-event/README.md) · [EDA Playground](https://edaplayground.com/x/J57K) |
| 34 | **SV 34 - Two-Way Event Handshake** | Per-item acknowledgement, completion event, shared-state timing | [Notes](Codes/34-two-way-event-handshake/README.md) · [EDA Playground](https://edaplayground.com/x/9yRX) |
| 35 | **SV 35 - Fork-Join Variants** | `join`, `join_any`, `join_none`, parent/child timing | [Notes](Codes/35-fork-join-variants/README.md) · [EDA Playground](https://edaplayground.com/x/B3zJ) |
| 36 | **SV 36 - Semaphore-Controlled Resource Access** | Single-key arbitration and critical-section scope | [Notes](Codes/36-semaphore-controlled-resource-access/README.md) · [EDA Playground](https://edaplayground.com/x/gjuf) |
| 37 | **SV 37 - Generator-Driver Mailbox** | Shared mailbox handle, blocking `get`, queued data | [Notes](Codes/37-generator-driver-mailbox/README.md) · [EDA Playground](https://edaplayground.com/x/A8er) |
| 38 | **SV 38 - Constructor-Injected Mailbox** | Constructor dependency injection and shared handles | [Notes](Codes/38-constructor-injected-mailbox/README.md) · [EDA Playground](https://edaplayground.com/x/gjvi) |
| 39 | **SV 39 - Parameterized Transaction Mailbox** | Typed mailbox and object-handle transport | [Notes](Codes/39-parameterized-transaction-mailbox/README.md) · [EDA Playground](https://edaplayground.com/x/tEEA) |
| 40 | **SV 40 - Interface, Modport, and Virtual Interface** | Static interface instance, modport view, class binding | [Notes](Codes/40-interface-modport-and-virtual-interface/README.md) · [EDA Playground](https://edaplayground.com/x/VgAA) |
| 41 | **SV 41 - Layered Adder Testbench and Object Copies** | Transaction snapshots, generator, mailbox, driver, completion | [Notes](Codes/41-layered-adder-testbench-and-object-copies/README.md) · [EDA Playground](https://edaplayground.com/x/Xcxx) |
| 42 | **SV 42 - Error Injection with Inheritance** | Derived stimulus, clone/factory pitfalls, intentional compile diagnosis | [Notes](Codes/42-error-injection-with-inheritance/README.md) · [EDA Playground](https://edaplayground.com/x/Cxwq) |
| 43 | **SV 43 - Polymorphic Copy for Error Injection** | Virtual copy override, base handles, transformed transaction snapshots | [Notes](Codes/43-polymorphic-copy-error-injection/README.md) · [EDA Playground](https://edaplayground.com/x/F5HU) |
| 44 | **SV 44 - Monitor and Scoreboard with Separate Mailboxes** | Directed mailbox channels, clock-edge separation, response checking, completion gaps | [Notes](Codes/44-monitor-scoreboard-separate-mailboxes/README.md) · [EDA Playground](https://edaplayground.com/x/Rvwd) |

## How to Study This Repository

For each numbered part:

1. Read the part-level README before running the code.
2. Inspect `testbench.sv` and, when the lesson has one, `design.sv`; identify object identity, data flow, and what each process intends to do at each simulation time.
3. Open the linked EDA Playground example and run the original experiment with its recorded settings.
4. Compare the console output and waveform with your prediction.
5. Read the Questions and Answers section for the questions and doubts written in that source.
6. Treat a compile failure or surprising output as evidence: compare it with the README diagnosis rather than silently editing the example.

The [EDA Playground audit](docs/internal/EDA_PLAYGROUND_AUDIT.md) contains the one-to-one identity, settings, source-fingerprint, and question-coverage ledger for all captured parts.
