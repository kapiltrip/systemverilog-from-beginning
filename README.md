# SystemVerilog from Beginning

> A structured, hands-on SystemVerilog learning repository built from first principles.

This repository is an **ordered SystemVerilog practice notebook**. Each numbered part preserves the original experiment, keeps the corresponding EDA Playground link, and adds explanations for the language and simulation behavior being explored. Where a deterministic correction is useful for local verification, the exact captured pane remains in `testbench.sv` and the corrected version is kept separately as `self_checking_testbench.sv`.

The emphasis is not only on *what the syntax does*, but also on **why the simulator behaves that way**—including timing, concurrency, data representation, arrays, and testbench-oriented programming concepts.

## Repository Goals

The repository is intended to build SystemVerilog knowledge progressively through small executable examples.

The current learning path focuses on:

- simulation time, time units, and time precision;
- procedural execution and concurrent `initial` blocks;
- clock generation and phase relationships;
- SystemVerilog data types and simulation-time system functions;
- packed-versus-unpacked data reasoning;
- fixed and dynamic array fundamentals;
- array initialization and traversal;
- `for`, `foreach`, and `repeat` constructs;
- whole-array operations and copying;
- queues and queue methods;
- classes, objects, handles, and constructors;
- functions, tasks, timing controls, and pass-by-reference arguments;
- waveform and console-based debugging using simulator system tasks.

The examples are intentionally small so that one language or simulation concept can be isolated and understood before moving to the next topic.

## Repository Structure

```text
systemverilog-from-beginning/
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
│   └── 16-class-custom-copy-method/
├── Project/
├── EDA_PLAYGROUND_AUDIT.md
├── .gitignore
└── README.md
```

### `Codes/`

Contains the ordered learning exercises. Each numbered directory normally contains:

- `testbench.sv` — the exact captured EDA Playground testbench pane;
- `self_checking_testbench.sv` — a corrected, deterministic verification version when the original page is incomplete, nondeterministic, or unsafe;
- `editor_testbench.sv` — a captured unsaved editor buffer when it differs from the saved EDA Playground field;
- `design.sv` — the corresponding EDA Playground design pane when applicable;
- `README.md` — explanation of the code, simulator behavior, observations, and important concepts.

The numeric prefixes define the intended study sequence.

### `Project/`

Reserved for larger SystemVerilog or verification projects as the repository progresses beyond isolated language exercises.

## Learning Sequence

| # | Topic | Key Concepts | Resources |
|---:|---|---|---|
| 01 | **Simulation Basics** | Timing, `` `timescale ``, `initial`, delays, VCD, `$monitor`, `$finish` | [Notes](Codes/01-simulation-basics/README.md) · [EDA Playground](https://edaplayground.com/x/Ucnp) |
| 02 | **Clock Generation** | Periodic clocks, delays, edges, simulation timestamps | [Notes](Codes/02-clock-generation/README.md) · [EDA Playground](https://edaplayground.com/x/gi86) |
| 03 | **Phase-Shifted Clocks** | Clock period, phase, relative timing | [Notes](Codes/03-phase-shifted-clocks/README.md) · [EDA Playground](https://edaplayground.com/x/gi8n) |
| 04 | **Data Types and Time** | Two-state/four-state types, `$time`, `$realtime` | [Notes](Codes/04-data-types-and-time/README.md) · [EDA Playground](https://edaplayground.com/x/giAN) |
| 05 | **Fixed Arrays and `for` Loops** | Unpacked arrays, initialization, `$size`, `%p`, indexed iteration | [Notes](Codes/05-fixed-arrays-and-for-loop/README.md) · [EDA Playground](https://edaplayground.com/x/8k9Q) |
| 06 | **Array Iteration** | `foreach`, `repeat`, array traversal | [Notes](Codes/06-array-iteration/README.md) · [EDA Playground](https://edaplayground.com/x/GK3p) |
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

## How to Study This Repository

For each numbered part:

1. Read the part-level `README.md` before running the code.
2. Inspect `testbench.sv` and identify what is expected to happen at each simulation time.
3. Open the linked EDA Playground example and run the simulation.
4. Compare the console output and waveform with your prediction.
5. Modify one thing at a time—for example a delay, data type, array bound, or loop condition—and predict the new behavior before rerunning.
6. Record the reason for any unexpected simulator result rather than only recording the output.

This approach turns the repository from a code collection into a **simulation-reasoning notebook**.

## Example: Simulation Time

```systemverilog
`timescale 1ns/1ps

initial begin
    signal = 1'b0;
    #10;
    signal = 1'b1;
end
```

With `` `timescale 1ns/1ps ``, the delay `#10` corresponds to **10 ns**, while the simulator can represent timing to **1 ps precision** for that compilation unit.

An important recurring theme in this repository is that separate procedural blocks execute concurrently, while statements inside one procedural block execute sequentially unless timing or event controls alter when execution resumes.
