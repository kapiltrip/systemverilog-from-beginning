# SV Functional Coverage — Ordered Learning Index

[Functional Coverage home](../README.md) · [All learning tracks](../../README.md)

| Part | Topic | Main idea | Verified result | Playground |
|---:|---|---|---|---|
| 01 | [Basic Coverpoints](01-basic-coverpoints/README.md) | Explicit/event sampling, automatic bins, and simulator-specific report generation | Questa 2025.2 printed 100% (8/8 bins, 0 errors); Vivado/XSim also passed at 101 ns | [Y9rT](https://edaplayground.com/x/Y9rT) |
| 02 | [Instance/Type Goals and Coverpoint Weights](02-instance-type-goals-and-weights/README.md) | `per_instance`, `option.goal`, `type_option.goal`, and weighted aggregation | XSim: `a` 4/4, `b` 3/4; weighted total 84.375% | [pvaX](https://edaplayground.com/x/pvaX) |
| 03 | [Conditional Sampling with `iff`](03-conditional-sampling-with-iff/README.md) | Reset-gated sampling, ignored attempts, and the time-0/time-30 races | XSim: 7 accepted samples, 4/4 bins, 100%; one lifetime warning | [jq_V](https://edaplayground.com/x/jq_V) |
| 04 | [Automatic Bins and `auto_bin_max`](04-automatic-bins-and-auto-bin-max/README.md) | Default bin limits, coverpoint-local overrides, and unknown values | XSim: `a` 9/128, `b` 0/64; displayed total 3.51562% | [XzxS](https://edaplayground.com/x/XzxS) |
| 05 | [Explicit Bins and Fixed-Size Bin Arrays](05-explicit-bins-and-fixed-bin-arrays/README.md) | Individual/range bins, unsized arrays, and a 64-way explicit partition | XSim: `a` 9/64, `b` 0/64; total 7.03125% | [T8wy](https://edaplayground.com/x/T8wy) |
| 06 | [Default Bins for Unused Values](06-default-bins-for-unused-values/README.md) | A catch-all diagnostic bin and the covergroup lifecycle | XSim: compile/run pass at time 0; no sampling, 0/10 scored bins | [HU_T](https://edaplayground.com/x/HU_T) |
| 07 | [Multiplexer Signal Coverpoints](07-multiplexer-signal-coverpoints/README.md) | Per-signal bins, combinational settling, and the limits of 100% coverage | XSim: 14/14 bins, 100%; `y` has only 19 known samples because it is sampled stale | [J_mr](https://edaplayground.com/x/J_mr) |
| 08 | [Enumerated-State Coverpoint](08-enumerated-state-coverpoint/README.md) | One automatic bin per enum literal and checked conversion with `$cast` | XSim: `auto_s0` 1 hit; 1/4 bins, 25%; one lifetime warning | [ggV4](https://edaplayground.com/x/ggV4) |
| 09 | [FSM State Coverage and Report Timing](09-fsm-state-coverage-and-report-timing/README.md) | Named enum-state coverage, parser-error cascades, finite Tcl runs, and pre-NBA sampling | Questa: `state` 2/2 bins, 100%; `s0` 8 hits, `s1` 12 hits | [FU8E](https://edaplayground.com/x/FU8E) |
| 10 | [`with`-Filtered and Overlapping Bins](10-with-filtered-and-overlapping-bins/README.md) | Iterator filtering, unsized bin arrays, overlap, width truncation, and weighted aggregation | Questa: `a` 10/22, `b` 4/21; weighted total 32.25% | [Ztfn](https://edaplayground.com/x/Ztfn) |

## Archive boundary

The completed sequence now runs from `Y9rT` through `Ztfn`. `Y9rT` was already
represented by Part 01, Parts 02–08 archive the next seven stable pages, and
Part 09 stores the repaired FSM from `FU8E`. Intermediate `Kd8_` remains an
unarchived working draft; Part 10 stores the later completed `Ztfn` lesson. The
newest/current browser page is now active playground
[`KN3M`](https://edaplayground.com/x/KN3M), so it remains open and outside the
archive. The full record is in the
[internal audit](../docs/internal/EDA_PLAYGROUND_AUDIT.md).

## Per-part file contract

Parts 02–08 contain:

- `README.md` — navigation, exact saved-link metadata, complete inline source,
  local verification evidence, source-comment corrections, deep discussion,
  revision checks, and authoritative references;
- `testbench.sv` — the exact substantive browser testbench normalized to LF;
- `run.do` — the exact custom Questa report script present in the playground.

Their design panes are omitted when they contain only EDA Playground's default
placeholder. Part 07 has substantive multiplexer RTL and therefore also stores
`design.sv`. Browser spelling is preserved in source files; corrections belong
in the README discussion.

Part 01 remains the curated, self-checking simulator-workaround lab established
before this verbatim archive pass. It additionally contains `design.sv` and the
Vivado report-printing helper.

Part 09 contains the exact saved `testbench.sv`, substantive FSM `design.sv`,
and finite-duration `run.do`. Its README preserves the repaired browser source,
the original syntax/cascade diagnosis, the 8/12 bin-count reconstruction, and
the verified Questa transcript result.

Part 10 contains the substantive saved testbench and the common `run.do`; its
placeholder design pane is omitted. Browser trailing spaces and redundant
terminal blank lines are normalized, while every declaration and code comment
is retained. Its README answers every code question and correction beside the
complete rendered source.

## Simulator-setting evidence

All archived pages select Questa 2025.2 and enable `run.do`. Part 01 used the
following explicit Run Options in its verified flow:

~~~text
-coverage -voptargs=+acc=npr
~~~

Parts 02–10 save only `-voptargs=+acc=npr`. Parts 02–08 were verified locally
with Vivado/XSim rather than being claimed as unchanged Questa runs. Parts 09
and 10 directly prove that the current EDA Playground `qrun` flow can collect
and print SystemVerilog covergroup data without an explicit `-coverage` switch.
The exact setting is therefore recorded per lesson instead of treating one
switch as a universal requirement across every Questa invocation.
