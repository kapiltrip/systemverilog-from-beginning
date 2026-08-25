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
| 11 | [Legal, Illegal, and Out-of-Domain Opcode Bins](11-legal-illegal-and-out-of-domain-opcode-bins/README.md) | Per-value legal bins, illegal diagnostics, impossible ignore values, and why bins are not procedural arrays | Exact saved source/settings; random closure and illegal hits are seed-dependent | [KN3M](https://edaplayground.com/x/KN3M) |
| 12 | [Ignore Bins and Domain Closure](12-ignore-bins-and-domain-closure/README.md) | Width alignment, ignored-value unions, denominator math, and deterministic closure | Questa: 77/77 scored bins, 100%; 0 compile/simulation errors | [cNZW](https://edaplayground.com/x/cNZW) |
| 13 | [Illegal-Bin Precedence and Report Timing](13-illegal-bin-precedence-and-report-timing/README.md) | Overlapping legal/illegal bins, finite Tcl reporting, and pass-versus-coverage semantics | Questa: 5/5 scored bins, 100%; three intentional illegal-bin hits | [grxa](https://edaplayground.com/x/grxa) |
| 14 | [Wildcard Bins, `casez`, and the `casex` Trap](14-wildcard-bins-casez-and-casex/README.md) | Wildcard-bin grouping, exact versus wildcard case matching, expression-side X masking, and deterministic encoder checks | Questa: all 15 samples, 0 errors, 7/17 bins, 52.88%; deterministic variant 100% | [rzC3](https://edaplayground.com/x/rzC3) |
| 15 | [Counter Wildcard Bins and Finite Reporting](15-counter-wildcard-bins-and-finite-reporting/README.md) | Net-driver conflicts, reset-before-counting, pre-NBA sampling, wildcard range bins, and finite Tcl reporting | Questa: 4/4 bins, 100%; hits 2/16/9/16; 0 compile/simulation errors | [fTK4](https://edaplayground.com/x/fTK4) |
| 16 | [Reusable Covergroup Fundamentals](16-reusable-covergroup-fundamentals/README.md) | Construction-time input copies versus live sampled variables | Questa: legal run and 30 sample calls, but frozen X inputs leave both instances 0/16, total 0% | [VnNY](https://edaplayground.com/x/VnNY) |
| 17 | [Reusable Covergroup: Pass by Reference](17-reusable-covergroup-pass-by-reference/README.md) | One type tracks two live variables through strict `ref` bindings | Questa: `A` 14/16, `B` 16/16; type total 93.75%; 0 errors | [bCAQ](https://edaplayground.com/x/bCAQ) |
| 18 | [Reusable Covergroup: Pass Configuration by Value](18-reusable-covergroup-pass-by-value/README.md) | Live `ref` data plus copied names and range boundaries | Questa: both instances 3/3 range bins, 6/6 total, 100%; 0 errors | [mzj8](https://edaplayground.com/x/mzj8) |
| 19 | [Rules for Generic Covergroup Arguments](19-generic-covergroup-rules/README.md) | Why signals use `ref`, constants use `input`, and `bins f[]` makes per-value goals | Questa: 3/6 bins, 50%; 0 errors; one implicit-static source warning | [E8nM](https://edaplayground.com/x/E8nM) |
| 20 | [Reusable Covergroup ALU Use Case](20-reusable-covergroup-alu-use-case/README.md) | Reusing operand/opcode models while separating coverage closure from functional checking | Exact source: 14/14 bins, 100%, but duplicate case labels break the ALU; corrected XSim variant passes and reaches 100% | [KXaD](https://edaplayground.com/x/KXaD) |
| 21 | [Reusable Covergroup Memory-Range Use Case](21-reusable-covergroup-memory-range-use-case/README.md) | Three per-instance address windows and raw-bin versus instance-average metrics | Questa: low 100%, mid 37.50%, high 75%; type metric 70.83%; 0 errors | [biwn](https://edaplayground.com/x/biwn) |
| 22 | [Automatic Covergroup Event Sampling](22-covergroup-event-sampling/README.md) | A declared `posedge` event samples automatically; opposite-edge driving avoids races | Questa: 12 samples, 4/4 bins, 100%; 0 source errors or warnings | [twJN](https://edaplayground.com/x/twJN) |
| 23 | [Manual Prebuilt `sample()`](23-manual-prebuilt-sample-method/README.md) | The caller chooses the transaction boundary for the normal no-argument method | Questa: 8 calls, 3/4 bins, 75%; 0 source errors or warnings | [EfZj](https://edaplayground.com/x/EfZj) |
| 24 | [User-Defined `sample()` in a Task](24-user-defined-sample-in-task/README.md) | A task passes its processed value into an argument-taking sample method | Questa: 50 calls, 14/16 bins, 87.50%; finite-clock repair; 0 source errors or warnings | [L5Mb](https://edaplayground.com/x/L5Mb) |
| 25 | [User-Defined `sample()` in a Function](25-user-defined-sample-in-function/README.md) | Decode raw controls to an enum and sample the semantic result | Questa: `write/read/NOP/error` hits 0/1/7/2, 75%; `void` repair removes source warnings | [cGiB](https://edaplayground.com/x/cGiB) |
| 26 | [User-Defined `sample()` in a Property](26-user-defined-sample-in-property/README.md) | Property-local snapshots, sequence match items, and assertion-versus-coverage evidence | Questa: all 3 address regions covered, 100%; assertion passes at 25/45/65 ns | [hfW3](https://edaplayground.com/x/hfW3) |
| 27 | [Cross-Coverage Fundamentals](27-cross-coverage-fundamentals/README.md) | Cartesian-product goals and why independent closure can hide missing combinations | Questa: 60/68 raw bins; displayed 95.23%; both three-way crosses 20/24 | [uU5k](https://edaplayground.com/x/uU5k) |
| 28 | [Operation-Specific Cross Covergroups](28-operation-specific-cross-covergroups/README.md) | Separate write/read models, range bins versus bin arrays, and metric weighting | Questa: write 100%, read 97.91%; combined 98.95%; 0 errors | [gsC6](https://edaplayground.com/x/gsC6) |
| 29 | [Cross Filtering with `binsof` and `intersect`](29-binsof-intersect-cross-filtering/README.md) | Removing irrelevant tuples and combining overlapping ignore selections | Questa: 25/28 raw bins; displayed 95.83%; filtered crosses 4/4 and 9/12 | [S_vr](https://edaplayground.com/x/S_vr) |
| 30 | [Simple FSM Transition Coverage, Part 1](30-simple-transition-coverage-p1/README.md) | Legal toggles versus holds, `iff`, filtered crosses, and same-edge sampling | Questa: `c1` 100%, `c2` 80%, total 90%; 0 errors | [v_s9](https://edaplayground.com/x/v_s9) |
| 31 | [Simple FSM Transition Coverage, Part 2](31-simple-transition-coverage-p2/README.md) | Reset-gated hold transitions and coverage-metric weighting | Questa: `cp_d` 100%, `cp_state` 50%, total 75%; 0 errors | [gsCG](https://edaplayground.com/x/gsCG) |
| 32 | [Consecutive Repetition Transition Bins](32-consecutive-repetition-transition/README.md) | Overlapping `[*]` windows, endpoint intent, and finite sampling | Questa: one bin at 100% with exactly 41 hits; 0 errors | [M9vN](https://edaplayground.com/x/M9vN) |
| 33 | [Nonconsecutive and Goto Transition Repetition](33-nonconsecutive-and-goto-transition/README.md) | `[=]` versus `[->]`, endpoint timing, stale comments, and array-bound repair | Questa: active goto bin at 100% with exactly 1 hit; 0 errors | [SYhE](https://edaplayground.com/x/SYhE) |

## Archive boundary

The pre-Section-6 sequence runs from `Y9rT` through `fTK4`. `Y9rT` was already
represented by Part 01, Parts 02–08 archive the next seven stable pages, and
Part 09 stores the repaired FSM from `FU8E`. Intermediate `Kd8_` remains an
unarchived working draft; Parts 10–13 store the later completed lessons through
`grxa`. The separate `CBg2` page is only a preserved repair copy of the already
archived FSM lesson, not a new ordered part. Part 14 captures the public `rzC3`
source plus a deterministic, locally verified variant. Its inherited 200 ns
Tcl window was repaired to `run -all`, saved, and directly verified in Questa.
Part 15 repairs `fTK4` by removing a competing net driver, establishing a
known reset value before counting, enabling its custom Tcl script, and using a
finite 450 ns reporting window.
Parts 16–21 then archive the six completed Section 6 reusable-covergroup pages
in course order: `VnNY`, `bCAQ`, `mzj8`, `E8nM`, `KXaD`, and `biwn`. Part 20
preserves the exact coverage-closed but functionally faulty ALU and adds a
separate deterministic correction.
Parts 22–26 archive the five substantive Section 7 sampling-method pages in
course order: `twJN`, `EfZj`, `L5Mb`, `cGiB`, and `hfW3`. V092 was a minimal
overview without a coverpoint, so its useful `// sampling event` note was moved
to Part 22. V102 was a generated recap with no personal comment or new lesson
code, so both overview pages are intentionally omitted rather than padded into
separate parts.
Parts 27–29 archive the three authored Section 8 cross-coverage pages in course
order: `uU5k`, `gsC6`, and `S_vr`. V108, V110, and V114 remained byte-for-byte
equivalent to their generated starters after whitespace normalization, so they
are not padded into ordered parts. V116 differed from its starter only by the
question about `intersect {[5:7]}`; Part 29 preserves and answers that question,
including the union math for overlapping ignore selections.
Parts 30–33 archive the four retained Section 9 transition-bin pages in course
order: `v_s9`, `gsCG`, `M9vN`, and `SYhE`. V128 (`XxV6`) is omitted because its
testbench remains exactly equal to the generated summary starter after removing
whitespace; it contains no authored code or comment that needs migration.
The full record is in the
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

Parts 11–13 follow the same source-plus-Q&A contract. Parts 11 and 12 use the
common finite-event-queue `run.do`; Part 13 uses a 200 ns window so reporting
occurs after its 15 samples but before HDL-side `$finish`. Placeholder design
panes are omitted. Corrections and recommended rewrites remain in discussion,
while the saved source spelling is retained.

Part 14 is intentionally dual-layered. `design.sv`, `testbench.sv`, and
`run.do` preserve the exact current public panes, including the saved
`run -all` timing repair. The `verified-*` files provide deterministic stimulus
and self-check the matching semantics. The README includes every source in
full, records the direct Questa result and XSim's exact-X/Z-bin limitation, and
answers the 17 `case`/`casez`/`casex` questions beside the wildcard-bin example.

Part 15 stores the repaired public `design.sv`, `testbench.sv`, and `run.do`.
Its README records the original exit-137/no-report fault, explains the
continuous-driver and X-propagation problems, reconstructs every pre-NBA sample
and bin hit, and separates 100% coverage closure from functional checking.

Parts 16–19 and 21 store the exact saved testbench and common `run.do`; their
placeholder design panes are omitted. Part 20 stores the exact substantive
testbench, design, and `run.do`, plus `verified-*` design, testbench, and Tcl
files. Every Section 6 README answers its source comments/questions, records a
fresh direct Questa run, and distinguishes coverage evidence from functional
correctness. Browser spelling is retained in meaning and code comments while
horizontal/trailing whitespace is normalized for study readability.

Parts 22–26 store the five retained Section 7 testbenches and common `run.do`;
all placeholder-only design panes are omitted. Their READMEs distinguish
automatic event sampling, manual prebuilt sampling, and user-defined argument
sampling in a task, function, and property. The live V097 clock was made finite
so `run -all` can reach the report, V098's side-effect helper was correctly
declared `void`, and V100's generated header now identifies the sample call as
a property sequence match item. Every natural-language source comment is
answered beside the complete source.

Parts 27–29 store the three substantive Section 8 testbenches and the common
`run.do`; all placeholder-only design panes are omitted. Their READMEs derive
every Cartesian-product denominator, distinguish one range bin from an
unsized bin array, explain weighted metrics versus raw-bin ratios, and answer
all source comments about write/read filtering and `binsof ... intersect`.
The V116 range/overlap question is consolidated into Part 29 rather than kept
as a comment-only variation of a generated starter.

Parts 30–33 store the four retained Section 9 testbenches and common `run.do`.
Parts 30 and 31 also retain their substantive two-state FSM design panes; Parts
32 and 33 omit the shared placeholder design. Their READMEs reconstruct the
exact transition traces and metrics, explain consecutive, nonconsecutive, and
goto repetition, preserve and correct every authored comment, identify V126's
two invalid array reads, and distinguish coverage closure from functional
checking. The untouched V128 summary is intentionally not an ordered part.

## Simulator-setting evidence

All archived pages select Questa 2025.2 and enable `run.do`. Part 01 used the
following explicit Run Options in its verified flow:

~~~text
-coverage -voptargs=+acc=npr
~~~

Parts 02–33 save only `-voptargs=+acc=npr`. Parts 02–08 and Part 14's
deterministic layer were verified locally with Vivado/XSim. Parts 09, 10, 12,
13, 14, and 15 directly prove that the current EDA Playground `qrun` flow can
collect and print SystemVerilog covergroup data without an explicit `-coverage`
switch. Part 11 retains source/settings evidence without claiming deterministic
random-bin closure. Part 14's direct Questa run executed all fifteen random
samples and reported 52.88%; its `verified-*` result is deterministic and 100%.
XSim rejects the public source's exact X/Z output bins, so it is not used as
coverage-model parity there. The exact setting is recorded per lesson instead
of being treated as a universal requirement across every Questa invocation.
Parts 16–21 were freshly rerun in their saved Questa configurations on August
24, 2026. Part 20's separate corrected layer was also compiled, self-checked,
and reported at 100% with Vivado/XSim 2024.1. Parts 22–26 were freshly rerun in
Chrome on August 25, 2026 (IST). Every retained Section 7 page completed with
zero compile/simulation errors and printed its detailed coverage report; the
only remaining warning on each is the shared `+acc` optimization notice.
Parts 27–29 were then freshly rerun from their saved Section 8 pages on August
25. All three completed with zero compile/simulation errors and the same single
`+acc` optimization notice.
Parts 30–33 were freshly rerun from their saved Section 9 pages on August 25.
All four completed with zero compile/simulation errors and the same single
`+acc` optimization notice. V126's live result is one hit, correcting its
copied 41-hit comment; its 15-iteration loop also over-reads a 13-element array.
