# SystemVerilog from Beginning

> A structured, hands-on SystemVerilog learning repository built from first principles.

This repository is an ordered SystemVerilog practice notebook. Each numbered part preserves the user-authored source captured from its saved EDA Playground panes, records the exact saved playground name and link, and adds study notes. The READMEs explain questions written in the source; they do not replace, correct, or improve the source code.

The current learning path covers simulation time, concurrent procedural execution, clocks and phase, data types, arrays and iteration, queues, classes and handles, functions and tasks, argument passing, constructors, composition, and object copying.

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

Each numbered directory contains the corresponding `design.sv` and `testbench.sv` panes when present, a part README, and in part 16 the additional `editor_testbench.sv` capture that existed in the baseline. The source files are preserved verbatim from the canonical EDA Playground editor contents apart from line-ending normalization. No corrected or self-checking substitute is part of the learning source.

### `Project/`

Reserved for larger SystemVerilog or verification projects as the repository progresses beyond isolated language exercises.

## Learning Sequence

The bold index titles below are the exact saved EDA Playground Names for parts 01–16.

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

## How to Study This Repository

For each numbered part:

1. Read the part-level README before running the code.
2. Inspect the verbatim `testbench.sv` and identify what the source intends to do at each simulation time.
3. Open the linked EDA Playground example and run the original experiment with its recorded settings.
4. Compare the console output and waveform with your prediction.
5. Read the Questions and Answers section for the questions and doubts written in that source.
6. Record the reason for any unexpected simulator result rather than silently editing the example.

The [EDA Playground audit](EDA_PLAYGROUND_AUDIT.md) contains the one-to-one identity, settings, source-fingerprint, and question-coverage ledger for all captured parts.
