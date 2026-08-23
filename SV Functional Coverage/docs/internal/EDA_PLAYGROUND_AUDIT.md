# Functional Coverage EDA Playground Audit

This record documents the August 23, 2026 capture of the completed functional-
coverage playgrounds that preceded the newest Chrome playground. Parts 02–08
were captured through read-only inspection. Parts 09–10 record later,
user-requested saved and verified Questa reruns. Part 09 includes the FSM repair
and comments; Part 10 preserves the completed bin-filtering lesson and its Q&A.
The audit covers source identity, order, settings, and evidence.

## Final archive boundary

The preserved Chrome order is:

```text
Y9rT → pvaX → jq_V → XzxS → T8wy → HU_T → J_mr → ggV4 → Kd8_ → FU8E → Ztfn → KN3M (active)
```

`Y9rT` was already represented by Part 01. The next seven stable pages are
Parts 02–08. `Kd8_` (code ID `7380543`) is an intermediate FSM working draft and
remains outside the archive. The repaired, named `FU8E` page is Part 09, and the
completed `Ztfn` page is Part 10. The newest/current page is now active
playground [`KN3M`](https://edaplayground.com/x/KN3M) and is deliberately
excluded.

The final open-tab boundary was rechecked in Chrome before archiving Part 09.
`FU8E` was saved and independently reloaded to prove that its comments persisted.
`Ztfn` was later rerun and saved on request; its source and 32.25% report were
captured before closing it. `KN3M` was not modified, run, saved, closed, or
archived by this capture work.

## One-to-one capture map

| Part | Public page / code ID | Repository folder | Retained browser panes |
|---:|---|---|---|
| 02 | [`pvaX`](https://edaplayground.com/x/pvaX) / `7379868` | `02-instance-type-goals-and-weights` | `testbench.sv`, `run.do` |
| 03 | [`jq_V`](https://edaplayground.com/x/jq_V) / `7380397` | `03-conditional-sampling-with-iff` | `testbench.sv`, `run.do` |
| 04 | [`XzxS`](https://edaplayground.com/x/XzxS) / `7380475` | `04-automatic-bins-and-auto-bin-max` | `testbench.sv`, `run.do` |
| 05 | [`T8wy`](https://edaplayground.com/x/T8wy) / `7380484` | `05-explicit-bins-and-fixed-bin-arrays` | `testbench.sv`, `run.do` |
| 06 | [`HU_T`](https://edaplayground.com/x/HU_T) / `7380503` | `06-default-bins-for-unused-values` | `testbench.sv`, `run.do` |
| 07 | [`J_mr`](https://edaplayground.com/x/J_mr) / `7380513` | `07-multiplexer-signal-coverpoints` | `design.sv`, `testbench.sv`, `run.do` |
| 08 | [`ggV4`](https://edaplayground.com/x/ggV4) / `7380537` | `08-enumerated-state-coverpoint` | `testbench.sv`, `run.do` |
| 09 | [`FU8E`](https://edaplayground.com/x/FU8E) / `7380862` | `09-fsm-state-coverage-and-report-timing` | `design.sv`, `testbench.sv`, `run.do` |
| 10 | [`Ztfn`](https://edaplayground.com/x/Ztfn) / `7380906` | `10-with-filtered-and-overlapping-bins` | `testbench.sv`, `run.do` |

Parts 02–08 and 10 have blank saved Name fields; Part 09 is named **FSM Coverage
Report - Fixed Timing and Finish**. All nine pages select SystemVerilog and Siemens
Questa 2025.2, with compile options `-timescale 1ns/1ns`, run options
`-voptargs=+acc=npr`, and **Use run.do Tcl file** enabled. The design pane is a
placeholder except in Parts 07 and 09, where substantive RTL is retained.

The saved run options omit `-coverage`. Parts 02–08 were not claimed as
unchanged browser-verified Questa flows; they have independent XSim evidence.
Parts 09–10 directly prove that this EDA Playground qrun configuration
nevertheless collected and printed full covergroup/bin data. The older blanket
requirement has therefore been replaced by per-flow evidence.

## Source-parity fingerprints

The hashes below use UTF-8 source with CRLF normalized to LF and the terminal
newline ignored. They match the corresponding public editor contents after the
same normalization. Browser spelling and comments are preserved; corrections
appear only in the README discussion.

| Part | Testbench SHA-256 | Design SHA-256 |
|---:|---|---|
| 02 | `cb14d85f09927f3f3208f1783c07d9b827ba4857a222ffe2e25520b9015db9e7` | Placeholder omitted |
| 03 | `853a784ad056211ba35db567692de5813c70dd9a9117f8b9307dc198a110f8f2` | Placeholder omitted |
| 04 | `5685850f2984d71f3132686bcd988e11357201c920bac10e631d1b4d784a757b` | Placeholder omitted |
| 05 | `720bba723b4c0c674b3d3f0786f4e5d1a41eff5df2ad6bd24c1cb349201e4ff8` | Placeholder omitted |
| 06 | `4eeccd2292b2ef8cca3c3d2c2a030b0de8898e4b5faa698fff18fc7dbe5d918e` | Placeholder omitted |
| 07 | `8049a5ea03921113b692087f680e11ddfc6c81dece2b903a1e2ae1699de08ce5` | `0e34cb462a186f86e8338425e09e207b9e1eaa8e9790b48873195e9f9dd329b5` |
| 08 | `7b445d4b4bc94748bf5ebd0b9a795399291dae4fe70b2d8f2b0824c4e5f3c1c7` | Placeholder omitted |
| 09 | `acb7c7da6365bc8a4a77be64027e4ffe70fefdaeaa470fc17fe2fc855329714f` | `5ab142ac23ed148a6d2f69ef53d559c6d9630b520fb603f0b51437cfc1fae3a8` |
| 10 | `2060201cfad6565e864a5093f60c7b439abb0131577025dd4f9ce6c754a47ca2` | Placeholder omitted |

Parts 02–08 and 10 share the same normalized `run.do` fingerprint:
`af8b3e52c5da6fb92028f10c97351ef06e9f47f749393848becca1d4971e05e5`.
Part 09's finite-duration script fingerprint is
`290e4eabadf97b9007c8a7035f980d83e04ed68c9782d69f6a99b3bd44056006`.
Every retained source file also has one complete matching inline source block
in its part README.

## Independent local verification

The unchanged captured SystemVerilog was compiled, elaborated, simulated, and
reported with Vivado/XSim 2024.1 (`xvlog`, `xelab`, `xsim`, then `xcrg`).
Generated databases, logs, and reports remain ignored under
`_xsim_fcover_run/archive-2026-08-23/`.

| Part | XSim/XCRG result |
|---:|---|
| 02 | 84.375% total: `a` 4/4 at weight 3 and `b` 3/4 at weight 5 |
| 03 | 100%: 4/4 bins and seven accepted samples; the time-0 and time-30 reset/sample boundaries are races |
| 04 | Displayed 3.51562% (exact 3.515625%): `a` 9/128 and uninitialized `b` 0/64 |
| 05 | 7.03125%: explicit `a` 9/64 and uninitialized `b` 0/64 |
| 06 | 0%: the covergroup is constructed but never sampled; 0/10 scored bins |
| 07 | 100% and 14/14 bins; `y` records only 19 known samples because it is sampled before the combinational output settles |
| 08 | 25%: only enum bin `auto_s0` is hit; three state bins remain uncovered |

All seven flows compiled, elaborated, ran, and produced XCRG reports. Parts 03
and 08 emitted only a lifetime warning for a block-local covergroup variable;
the other captured lessons emitted no source warning that changes the reported
coverage result.

## Direct Questa verification for Parts 09–10

The saved `FU8E` page was rerun after its explanatory comments were added. The
Questa 2025.2 transcript reported zero compile and simulation errors, a named
`state` coverpoint, 2/2 covered bins, `auto[s0]` with 8 hits, `auto[s1]` with 12
hits, and 100% total covergroup coverage. The one `vopt-10587` warning concerns
the existing `+acc` optimization setting and does not alter the result.

The saved `Ztfn` page was rerun with zero compile/simulation errors. Its report
showed `a` at 10/22 bins (45.45%), `b` at 4/21 bins (19.04%), and an equal-weight
covergroup metric of 32.25%. The raw 14/43 bin ratio was 32.55%. The same
`vopt-10587` access/optimization warning was the only total warning.

## Discussion-integrity check

Each part README contains the exact source and a lesson-specific explanation,
not a generic coverage summary:

- Part 02 derives the weighted score and separates instance goals from type
  goals.
- Part 03 explains `iff` filtering and both same-time scheduling races without
  pretending the aggregate hit counts identify which boundary won.
- Part 04 distinguishes the default automatic-bin limit from the local
  `auto_bin_max = 256` override and explains the uninitialized coverpoint.
- Part 05 explains individual, range, unsized-array, and fixed-size-array bin
  declarations and maps the observed hits.
- Part 06 explains why a `default` bin is diagnostic rather than scored and why
  construction alone produces no sample.
- Part 07 explains why 100% value coverage neither proves mux correctness nor
  removes the need to let combinational logic settle before sampling.
- Part 08 explains enum-derived automatic bins, `$cast`, the single observed
  state, and the local-variable lifetime warning.
- Part 09 explains the split-label parser failure, its cascading `ci` error,
  finite-run/report ordering, the 8/12 pre-NBA sample counts, and the limits of
  100% state occupancy coverage.
- Part 10 answers every source question about `with`, `item`, bin arrays,
  wildcard and illegal bins, overlap, `$urandom` truncation, unreachable bins,
  and weighted covergroup aggregation.

The per-part revision checks and authoritative references are retained beside
the relevant code so the discussion stays usable as study material.
