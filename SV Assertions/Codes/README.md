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
| 06 | [Overlapped and Nonoverlapped Implication](06-overlapped-and-nonoverlapped-implication/README.md) | Consequent timing, nonvacuous success, failure, and vacuity | `a1` passes; three intentional next-cycle `a2` failures | [eX_T](https://edaplayground.com/x/eX_T) |
| 07 | [Current and Sampled Values](07-current-and-sampled-values/README.md) | Preponed samples versus Active and Reactive execution | Current `a=0`, sampled `a=1`; 0 errors | [JGnz](https://edaplayground.com/x/JGnz) |
| 08 | [Reusable Sequences and Properties](08-reusable-sequences-and-properties/README.md) | Formal arguments and reusable temporal definitions | `p1` passes at 35 ns; `p2` at 45 ns | [Mx6p](https://edaplayground.com/x/Mx6p) |
| 09 | [`$fell` and Sampled Transitions](09-fell-and-sampled-transitions/README.md) | Clocked transition history and scalar/vector meaning | Sampled falls detected; 0 errors | [gnQU](https://edaplayground.com/x/gnQU) |
| 10 | [Gated `$past` and Sampled Requirements](10-gated-past-sampled-values/README.md) | Enabled history plus corrected source requirements | Gated history freezes after `en=0`; 0 errors | [tNt9](https://edaplayground.com/x/tNt9) |
| 11 | [Sampled and Vector System Functions](11-sampled-and-vector-system-functions/README.md) | `$stable`, one-hot/one-cold, unknowns, and bit counts | Function trace completes with 0 errors | [JE4r](https://edaplayground.com/x/JE4r) |
| 12 | [Clocking Events and `disable iff`](12-clocking-events-and-disable-iff/README.md) | Named/default clocks, both-edge events, and abort semantics | 0 compile errors; 19 intentional assertion failures | [GeAH](https://edaplayground.com/x/GeAH) |
| 13 | [Delay Operators and Delay Ranges](13-delay-operators-and-ranges/README.md) | Exact/ranged cycle delays and implication timing arithmetic | Final live rerun pending | [LSZN](https://edaplayground.com/x/LSZN) |
| 14 | [Strong Unbounded Eventuality](14-strong-unbounded-eventuality/README.md) | Why an unbounded eventual response needs `strong(...)` | Expected strong failure because `ack` never rises | [ZTL5](https://edaplayground.com/x/ZTL5) |
| 15 | [Consecutive Repetition Ranges](15-consecutive-repetition-ranges/README.md) | `[*n]`, `[*m:n]`, accepted endpoints, and explicit termination | Final live rerun pending | [EZ5Z](https://edaplayground.com/x/EZ5Z) |
| 16 | [Consecutive and Nonconsecutive Repetition](16-consecutive-and-nonconsecutive-repetition/README.md) | `[*]` versus `[=]`, event counting, and source correction | Original `info(...)` call blocks compilation | [M3RC](https://edaplayground.com/x/M3RC) |

## Per-part file contract

Every numbered directory contains:

- `README.md` — navigation, browser name/link, exact inline source, deep explanation, source-question answers, and live-result interpretation;
- `testbench.sv` — the exact captured testbench pane.

`design.sv` is stored only when the design pane contains substantive lesson code. Parts 02 and 03 currently have one. Browser spelling and spacing are preserved in source files; corrections belong in the explanation rather than being silently written over the learning evidence.
