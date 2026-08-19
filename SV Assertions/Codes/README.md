# SV Assertions — Ordered Learning Index

[SV Assertions home](../README.md) · [Foundation 00](../Foundations/00-event-scheduling-regions-and-assertion-types/README.md) · [All learning tracks](../../README.md)

Before Part 01, study [event scheduling regions and assertion types](../Foundations/00-event-scheduling-regions-and-assertion-types/README.md). It explains the scheduler foundation without claiming to be a captured playground.

| Part | Topic | Main idea | Verified live result | Playground |
|---:|---|---|---|---|
| 01 | [Observed-Deferred Immediate Assertion](01-observed-deferred-immediate-assertion/README.md) | `assert #0`, deferred queues, and same-slot glitch suppression | Pass at 0 ns; failures at 10 and 20 ns | [NgZs](https://edaplayground.com/x/NgZs) |
| 02 | [Immediate Assertions in a Multiplexer](02-immediate-assertions-in-a-mux/README.md) | Procedural assertions, standalone deferred forms, and an Active-region race | Completes at 300 ns; implicit-net diagnostic for `y` | [FfSr](https://edaplayground.com/x/FfSr) |
| 03 | [Clocked Immediate Assertion and NBA Timing](03-clocked-immediate-assertion-and-nba-timing/README.md) | Why a simple assertion beside NBAs sees old state | 20 pre-NBA invariant passes | [gmZQ](https://edaplayground.com/x/gmZQ) |
| 04 | [Assertion Control and Procedural Disable](04-assertion-control-and-disable/README.md) | `$assertoff`, `$asserton`, labeled `disable`, and reset gating | One pass at 59 ns; `rst` remains `X` | [hACs](https://edaplayground.com/x/hACs) |
| 05 | [From Signals to Assertion Directives](05-assertion-building-blocks/README.md) | Boolean expressions, sequences, properties, `assert`, `assume`, and `cover` | Concept outline: no top module yet | [MSmm](https://edaplayground.com/x/MSmm) |

## Per-part file contract

Every numbered directory contains:

- `README.md` — navigation, browser name/link, exact inline source, deep explanation, source-question answers, and live-result interpretation;
- `testbench.sv` — the exact captured testbench pane.

`design.sv` is stored only when the design pane contains substantive lesson code. Parts 02 and 03 currently have one. Browser spelling and spacing are preserved in source files; corrections belong in the explanation rather than being silently written over the learning evidence.
