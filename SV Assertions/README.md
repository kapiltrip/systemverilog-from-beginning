# SystemVerilog Assertions

> An ordered practice track for SystemVerilog Assertions (SVA).

[All learning tracks](../README.md)

## Start here

1. Read [Foundation 00 — Event Scheduling Regions and Assertion Types](Foundations/00-event-scheduling-regions-and-assertion-types/README.md) for sampling, evaluation, pass/fail scheduling, immediate assertion types, the lecture screenshots, and all 17 event regions.
2. Continue through the [ordered assertion playground index](Codes/README.md), beginning with Part 01.

The foundation note remains outside `Codes/` because it is a source-checked reference rather than a captured playground. `Codes/` now contains the twenty-seven captured browser lessons in creation order. Duplicate open tabs that share one stable playground ID are represented once.

## Current sequence

| Part | Focus |
|---:|---|
| 01 | Observed-deferred immediate assertions and glitch suppression |
| 02 | Immediate assertions in combinational mux logic |
| 03 | Immediate checks versus NBA-updated DFF state |
| 04 | Assertion control tasks, labeled disable, and reset gating |
| 05 | Signals → Boolean expressions → sequences → properties → directives |
| 06 | Overlapped/nonoverlapped implication and vacuous outcomes |
| 07 | Current procedural values versus concurrent assertion samples |
| 08 | Reusable sequences, properties, and formal arguments |
| 09 | `$fell` and sampled transitions |
| 10 | Gated `$past` plus answers to the source requirement questions |
| 11 | Sampled-history and vector-inspection system functions |
| 12 | Assertion clocking events and `disable iff` abort behavior |
| 13 | Exact, ranged, and unbounded sequence delay operators |
| 14 | Strong eventual completion for an unbounded delay |
| 15 | Fixed and ranged consecutive repetition |
| 16 | Consecutive versus nonconsecutive repetition and event counting |
| 17 | Ranged nonconsecutive/goto repetition, endpoints, and strong completion |
| 18 | Alternative temporal branches with sequence `or` |
| 19 | Common-start sequence `and`, property `not`, and unbounded completion |
| 20 | Level coverage, temporal containment, and exact endpoint intersection |
| 21 | Bounded/strong eventuality and unbounded `always` |
| 22 | Weak and strong `nexttime` horizon behavior |
| 23 | Overlapped/nonoverlapped followed-by property operators |
| 24 | Weak/strong and overlapping forms of until |
| 25 | Property-local variables, match-item updates, and width wrap |
| 26 | Request/ACK snapshots, counter timing, and transaction identity |
| 27 | Local request/ACK timestamps, randomized latency, and silent weak completion |

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
│   ├── 06-overlapped-and-nonoverlapped-implication/
│   ├── 07-current-and-sampled-values/
│   ├── 08-reusable-sequences-and-properties/
│   ├── 09-fell-and-sampled-transitions/
│   ├── 10-gated-past-sampled-values/
│   ├── 11-sampled-and-vector-system-functions/
│   ├── 12-clocking-events-and-disable-iff/
│   ├── 13-delay-operators-and-ranges/
│   ├── 14-strong-unbounded-eventuality/
│   ├── 15-consecutive-repetition-ranges/
│   ├── 16-consecutive-and-nonconsecutive-repetition/
│   ├── 17-nonconsecutive-and-goto-repetition-ranges/
│   ├── 18-sequence-or-operator/
│   ├── 19-sequence-and-not-strong/
│   ├── 20-throughout-within-and-intersect/
│   ├── 21-eventually-and-always-property-operators/
│   ├── 22-nexttime-and-strong-nexttime/
│   ├── 23-followed-by-property-operators/
│   ├── 24-strong-until/
│   ├── 25-property-local-variables/
│   ├── 26-request-ack-local-snapshots/
│   ├── 27-request-ack-latency-with-local-time/
│   └── README.md
└── README.md
```
