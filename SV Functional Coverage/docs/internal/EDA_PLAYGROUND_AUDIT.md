# Functional Coverage EDA Playground Audit

This record documents the August 23–24, 2026 capture of the known functional-
coverage playground sequence through `fTK4`. Parts 02–08 were captured through
read-only inspection. Parts 09–13 record later saved lessons and repairs. Part
09 includes the FSM repair and comments; Part 10 preserves filtered and
overlapping bins; Parts 11–13 cover legal/illegal bins, ignore-bin closure, and
report timing. Part 14 captures the saved wildcard-bin/encoder source, its live
Questa timing repair, and a deterministic local verification variant. Part 15
captures the repaired counter wildcard-bin lesson and its live finite-window
Questa report. The
audit covers source identity, order, settings, and evidence.

## Final archive boundary

The preserved Chrome order is:

```text
Y9rT → pvaX → jq_V → XzxS → T8wy → HU_T → J_mr → ggV4 → Kd8_ → FU8E → Ztfn → KN3M → cNZW → grxa → rzC3 → fTK4
```

`Y9rT` was already represented by Part 01. The next seven stable pages are
Parts 02–08. `Kd8_` (code ID `7380543`) is an intermediate FSM working draft and
remains outside the archive. The repaired, named `FU8E` page is Part 09, and the
completed `Ztfn` page is Part 10. `KN3M`, `cNZW`, and `grxa` are Parts 11–13.
[`rzC3`](https://edaplayground.com/x/rzC3) (code ID `7381709`) is Part 14, and
[`fTK4`](https://edaplayground.com/x/fTK4) (code ID `7382217`) is Part 15.

The final open-tab boundary was rechecked in Chrome before archiving Part 09.
`FU8E` was saved and independently reloaded to prove that its comments persisted.
`Ztfn` was later rerun and saved on request; its source and 32.25% report were
captured before closing it. `cNZW` was repaired to align its width, ignore list,
and deterministic stimulus. `grxa` received a finite report window. `CBg2` is a
separate saved copy of the FSM repair and is excluded because Part 09 already
represents that lesson. The `rzC3` source changed while Part 14 was being
prepared, so it was fetched again before the final parity check. Its current
saved SystemVerilog is repaired. Its inherited 200 ns `run.do` was then changed
to `run -all`, saved to the public page, and rerun through all 15 samples in
Questa 2025.2. The final report printed successfully with zero compile or
simulation errors. The `fTK4` page was then repaired in its existing
background tab: its competing `y` net driver was removed, reset was established
before counting, custom `run.do` was enabled, and a finite 450 ns window
replaced the never-ending default `run -all` flow.

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
| 11 | [`KN3M`](https://edaplayground.com/x/KN3M) / `7381043` | `11-legal-illegal-and-out-of-domain-opcode-bins` | `testbench.sv`, `run.do` |
| 12 | [`cNZW`](https://edaplayground.com/x/cNZW) / `7381556` | `12-ignore-bins-and-domain-closure` | `testbench.sv`, `run.do` |
| 13 | [`grxa`](https://edaplayground.com/x/grxa) / `7381590` | `13-illegal-bin-precedence-and-report-timing` | `testbench.sv`, `run.do` |
| 14 | [`rzC3`](https://edaplayground.com/x/rzC3) / `7381709` | `14-wildcard-bins-casez-and-casex` | exact `design.sv`, `testbench.sv`, `run.do`; deterministic `verified-*` additions |
| 15 | [`fTK4`](https://edaplayground.com/x/fTK4) / `7382217` | `15-counter-wildcard-bins-and-finite-reporting` | repaired public `design.sv`, `testbench.sv`, `run.do` |

Parts 02–08 and 10–15 have blank saved Name fields; Part 09 is named **FSM
Coverage Report - Fixed Timing and Finish**. All fourteen pages select SystemVerilog and Siemens
Questa 2025.2, with compile options `-timescale 1ns/1ns`, run options
`-voptargs=+acc=npr`, and **Use run.do Tcl file** enabled. The design pane is a
placeholder except in Parts 07, 09, 14, and 15, where substantive RTL is retained.

The saved run options omit `-coverage`. Parts 02–08 were not claimed as
unchanged browser-verified Questa flows; they have independent XSim evidence.
Parts 09, 10, 12, 13, 14, and 15 directly prove that this EDA Playground qrun
configuration nevertheless collected and printed full covergroup/bin data.
Part 11 is retained as exact saved-source/settings evidence without claiming a
deterministic result from ten random samples. Part 14 also demonstrates that
Questa accepts exact X/Z singleton coverage bins that XSim 2024.1 rejects. The
older blanket requirement has therefore been replaced by per-flow evidence.

## Source-parity fingerprints

The hashes below use UTF-8 source with CRLF normalized to LF, trailing
horizontal whitespace removed per line, and the terminal newline ignored. They
match the corresponding public editor contents after the same normalization.
Browser spelling and comments are preserved; corrections appear only in the
README discussion.

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
| 11 | `f7f094c278d3d6b38603ae5f0e65aaf7ee055a3aca6f59dc8540e59a20b5c5fb` | Placeholder omitted |
| 12 | `851272069153787f4b414acc4c2ef184b1d8c41d0eea27adcfb1f6ab3b83b730` | Placeholder omitted |
| 13 | `9ae526050570268fe10035474e50f0a4f7b9ced15970920b383d94e007a63f9a` | Placeholder omitted |
| 14 | `b0b0ed15e0a5282c982ba23fbe60489fafe99e3260711880864a376849cd8d1c` | `075106306ac66de2f4f1bd1edee61825dbc88e11a7b0b4ba12775437535405ba` |
| 15 | `54d89a1d1241e71b7568f54740c27b447abe0e2ed393f2957a054ac752ef083d` | `d8b1fe0f80a00ebdf992b8e2edafd0069394006be05b1f853ab119d88ff123c8` |

Parts 02–08 and 10–12 share the same normalized `run.do` fingerprint:
`af8b3e52c5da6fb92028f10c97351ef06e9f47f749393848becca1d4971e05e5`.
Part 09's finite-duration script fingerprint is
`290e4eabadf97b9007c8a7035f980d83e04ed68c9782d69f6a99b3bd44056006`.
Part 13's intentional 200 ns script fingerprint is
`2007f62371921cc681bed7498b2b4c06b8d3a48ed9d76a7157ed3b304cb3b2b1`.
Part 14's repaired public `run -all` script fingerprint is
`dafda1aa3478e58913c6c3dccfc90ce0027bbb19ac4335a99314c11b02b25667`.
Part 14's deterministic additions have fingerprints
`84813a6b86b9291e07c9a08cb6efd5972aebb4c4287b310dc51d9599637b54f2`
(`verified-testbench.sv`),
`82cfa986ce7308f09033aff988b61884af5f5a145157ec721499fec5797dea6b`
(`verified-design.sv`), and
`e4d9ecbe554a6ac7928147ab427674e984c319f2e2f72f4182decf2421ba90d8`
(`verified-run.do`).
Part 15's finite-window `run.do` fingerprint is
`ff635d868e40d9d28d2b2a338595b9784974158c65a16f72633f3887ea753bde`.
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

## Direct Questa verification for Parts 09–15

The saved `FU8E` page was rerun after its explanatory comments were added. The
Questa 2025.2 transcript reported zero compile and simulation errors, a named
`state` coverpoint, 2/2 covered bins, `auto[s0]` with 8 hits, `auto[s1]` with 12
hits, and 100% total covergroup coverage. The one `vopt-10587` warning concerns
the existing `+acc` optimization setting and does not alter the result.

The saved `Ztfn` page was rerun with zero compile/simulation errors. Its report
showed `a` at 10/22 bins (45.45%), `b` at 4/21 bins (19.04%), and an equal-weight
covergroup metric of 32.25%. The raw 14/43 bin ratio was 32.55%. The same
`vopt-10587` access/optimization warning was the only total warning.

`KN3M` was captured from its exact public saved source and settings. Its ten
random opcode samples and possible illegal hits are deliberately not presented
as deterministic closure evidence.

The repaired `cNZW` page was saved, reloaded, and rerun. Questa reported 77/77
scored bins, 100% coverage, and zero compile/simulation errors. The original
13.33% result came from a six-bit signal, out-of-domain declarations, and only
ten random samples.

The repaired `grxa` page was saved, reloaded, and rerun. Its 200 ns Tcl window
allowed the report to execute after all 15 samples and before the testbench's
400 ns `$finish`. Questa reported 5/5 scored bins and 100% coverage, plus three
intentional illegal-bin errors. The coverage goal is closed, but the run is not
a positive-test pass because forbidden values occurred.

The `rzC3` page was saved with `run -all`; after Run was triggered, it was left
in its existing tab while Questa completed all fifteen random samples and
printed the detailed report after quiescence. `qrun`, `vlog`, and `vsim` each
ended with zero errors;
the one total warning was the existing `+acc` optimization warning. The recorded
seed covered `x` at 3/4 bins (75.00%) and `y` at 4/13 bins (30.76%), producing
the equal-coverpoint-weight metric 52.88%. Seven of seventeen raw bins were
covered. The missing `x.two`/`y.valid_at0p[2]` pair was a random miss. Of nine
declared exact X/Z output bins, only `zz` was reachable and hit.

The repaired `fTK4` page ran with `-do run.do` and returned normally after its
finite 450 ns window. Questa reported all 4 coverpoint bins covered and 100%
total coverage: `count_off` 2 hits, `countLow` 16, `countMid` 9, and
`countHigh` 16. `qrun`, `vlog`, and `vsim` each ended with zero errors; the
existing `+acc` optimization warning was the only total warning.

## Part 14 local XSim verification

The exact current `rzC3` testbench and design compiled, elaborated, and ran to
event-queue exhaustion in Vivado/XSim 2024.1. XSim accepted the encoder and
known-value wildcard bins, but warned that each exact X/Z singleton output bin
was invalid and removed `undef_atOP`. It therefore cannot reproduce Questa's
13-bin output model or serve as coverage-model parity for the public source.
The direct Questa run is the authoritative evidence for those four-state bins.

The `verified-*` variant also compiled, elaborated, ran, and produced XCRG data.
Its deterministic stimulus covered the four input bins with 1, 2, 2, and 2
hits and the four output bins with the same counts. It self-checked that plain
`case` does not wildcard `?`, that `casez` does not ignore expression-side X
against a concrete item bit, and that `casex` does. The transcript printed
`0`, `0`, and `1` for those three comparisons, followed by `PASS`; total
functional coverage was 100%.

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
- Part 11 explains per-value opcode goals, seed-dependent closure, impossible
  8/9 ignore values for a three-bit signal, and why a bin name is not a
  procedural array that `$display` can print.
- Part 12 derives the 23-value ignored union and 77-bin denominator, documents
  the six-bit-to-eight-bit repair, and contrasts ignore bins with illegal bins.
- Part 13 explains the time-0 no-data failure, why `$finish` can prevent a
  post-`run -all` report, illegal-bin precedence at overlapping value 5, and
  why 100% coverage can coexist with a failed run.
- Part 14 preserves the exact changing-page boundary, derives the 10-of-15
  sample timing fault and its saved `run -all` repair, separates exact X/Z bins
  from wildcard coverage and wildcard case matching, verifies expression-side
  X behavior, and answers all 17 deep `case`/`casez`/`casex` questions.
- Part 15 diagnoses the exit-137/no-report failure, the declaration-assignment
  driver conflict and X propagation, reconstructs the 2/16/9/16 pre-NBA hit
  counts, and explains why coverage closure is not a counter correctness proof.

The per-part revision checks and authoritative references are retained beside
the relevant code so the discussion stays usable as study material.
