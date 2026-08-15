# SystemVerilog from Beginning

> A structured, hands-on SystemVerilog learning repository built from first principles.

This repository is an **ordered SystemVerilog practice notebook**. Each numbered part preserves the original experiment, keeps the corresponding EDA Playground link, and adds explanations for the language and simulation behavior being explored.

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
│   └── 07-array-copying/
├── Project/
├── .gitignore
└── README.md
```

### `Codes/`

Contains the ordered learning exercises. Each numbered directory normally contains:

- `testbench.sv` — the SystemVerilog testbench used for the experiment;
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

## Why SystemVerilog for Verification?

SystemVerilog extends Verilog with features useful for both RTL design and verification. As this repository grows, the same fundamentals introduced here—data types, arrays, procedural control, timing, and simulation observability—form the basis for more advanced verification constructs such as:

- tasks and functions;
- queues and associative arrays;
- structures, enumerations, and user-defined types;
- interfaces and modports;
- classes and object-oriented programming;
- constrained randomization;
- assertions;
- functional coverage;
- mailboxes and semaphores;
- transaction-level testbench architecture;
- Universal Verification Methodology (UVM) concepts.

These are roadmap topics rather than claims about what is already implemented in the repository.

## Tools

The current exercises are designed around **EDA Playground**, which makes it convenient to run SystemVerilog examples without maintaining a local simulator installation.

The source files themselves remain ordinary SystemVerilog and can also be studied or adapted for compatible simulators and EDA environments.

## Repository Convention

- One numbered directory corresponds to one focused learning step.
- The outer README provides the global learning path.
- The part-level README contains the deeper explanation.
- The `.sv` files preserve the executable source.
- EDA Playground links provide a reproducible online simulation reference.
- New topics should be added sequentially instead of mixing unrelated concepts into existing parts.

## Current Status

The repository currently contains **7 ordered SystemVerilog exercises**, progressing from basic simulation behavior to array manipulation.

The project directory is intentionally reserved for future larger exercises.

## Author

**Kapil Tripathi**

VLSI / Digital Design / SystemVerilog learning and verification practice.

---

> The objective of this repository is not merely to collect SystemVerilog syntax, but to develop the ability to predict, explain, and debug simulator behavior from first principles.
