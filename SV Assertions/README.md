# SystemVerilog Assertions

> An ordered practice track for SystemVerilog Assertions (SVA).

[All learning tracks](../README.md)

## Start here

1. Read [Foundation 00 — Event Scheduling Regions and Assertion Types](Foundations/00-event-scheduling-regions-and-assertion-types/README.md) for sampling, evaluation, pass/fail scheduling, immediate assertion types, the lecture screenshots, and all 17 event regions.
2. Continue through the [ordered assertion playground index](Codes/README.md), beginning with Part 01.

The foundation note remains outside `Codes/` because it is a source-checked reference rather than a captured playground. `Codes/` now contains the five browser lessons in creation order.

## Current sequence

| Part | Focus |
|---:|---|
| 01 | Observed-deferred immediate assertions and glitch suppression |
| 02 | Immediate assertions in combinational mux logic |
| 03 | Immediate checks versus NBA-updated DFF state |
| 04 | Assertion control tasks, labeled disable, and reset gating |
| 05 | Signals → Boolean expressions → sequences → properties → directives |

## Track structure

```text
SV Assertions/
├── Foundations/
│   ├── README.md
│   └── 00-event-scheduling-regions-and-assertion-types/
│       ├── images/
│       ├── examples.sv
│       └── README.md
├── Codes/
│   ├── 01-observed-deferred-immediate-assertion/
│   ├── 02-immediate-assertions-in-a-mux/
│   ├── 03-clocked-immediate-assertion-and-nba-timing/
│   ├── 04-assertion-control-and-disable/
│   ├── 05-assertion-building-blocks/
│   └── README.md
└── README.md
```
