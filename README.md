# SV Practice (Initial)

This repository follows the initial directory structure from my handwritten plan:

- `Codes/` contains my SystemVerilog code and answers to questions raised while writing it.
- `Project/` is reserved for projects and is empty for now.
- This outermost `README.md` indexes every code part and its appropriately named EDA Playground link.

## Index

| Part | Topic | EDA Playground |
| ---: | --- | --- |
| 01 | [Simulation basics, timescale, dump, monitor, and finish](Codes/01-simulation-basics/README.md) | [SV 01 - Simulation Basics](https://edaplayground.com/x/Ucnp) |
| 02 | [Clock generation and sensitivity-list reasoning](Codes/02-clock-generation/README.md) | [SV 02 - Clock Generation](https://edaplayground.com/x/gi86) |
| 03 | [Phase-shifted clocks](Codes/03-phase-shifted-clocks/README.md) | [SV 03 - Phase-Shifted Clocks](https://edaplayground.com/x/gi8n) |
| 04 | [Data types, `$time`, and `$realtime`](Codes/04-data-types-and-time/README.md) | [SV 04 - Data Types and Time](https://edaplayground.com/x/giAN) |
| 05 | [Fixed arrays, initialization, and `for`](Codes/05-fixed-arrays-and-for-loop/README.md) | [SV 05 - Fixed Arrays and For Loop](https://edaplayground.com/x/8k9Q) |
| 06 | [Array iteration with `foreach` and `repeat`](Codes/06-array-iteration/README.md) | [SV 06 - Array Iteration](https://edaplayground.com/x/GK3p) |
| 07 | [Whole-array copying](Codes/07-array-copying/README.md) | [SV 07 - Array Copying](https://edaplayground.com/x/CafY) |

## Repository convention

- `Codes/<numbered-part>/testbench.sv` contains the original EDA Playground testbench.
- `Codes/<numbered-part>/design.sv` mirrors the design pane from EDA Playground.
- Each part-level `README.md` explains the example and answers its questions.
- The numeric folder prefixes and this outermost index are the authoritative learning sequence.

