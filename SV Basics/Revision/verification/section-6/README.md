# Section 6 randomization: verification record

[Study guide](../../Section-6-Randomization.md) · [Examples](../../examples/section-6/README.md) · [Revision index](../../README.md)

## Result

Checks were run on 26 September 2026 with **AMD Vivado Simulator 2024.1, 64-bit software build 5076996**. Five of the eight exact examples passed. Three reference examples encountered specific simulator limitations; these results are retained rather than weakening the checks to obtain a blanket PASS.

| Example | Exact-source result | Evidence |
|---|---|---|
| 01: excluded ranges | PASS | Ten legal samples, unchanged nonrandom `y`, displays at 0-90 ns, completion at 100 ns. |
| 02: cyclic ranges | PASS | Two complete ten-value cycles for each independent field; no repeat within either cycle. |
| 03: external constraints | PASS | Ten samples satisfy both external ranges and call the external display method. |
| 04: callbacks and ranges | Discrepancy detected | The impossible solve returns zero and skips `post_randomize`, but XSim changes the random fields. The unchanged-data check stops the run. |
| 05: distribution weights | PASS | 12,000 successful calls; both histograms total 12,000. Frequencies are observations, not exact-count assertions. |
| 06: final control program | Unsupported operator | Elaboration reports `XSIM 43-4398`, unsupported binary operator in a constraint, at `<->`. |
| 07: mode comparison | Unsupported operator | The same `<->` elaboration limitation prevents an exact-source run. |
| 08: conditional addresses | PASS | Original read branch permits `waddr=7`; optional extra rule rejects it; all four implication pairs have the expected acceptance status. |

The [runner](../../../../scripts/verify_randomization_examples.py) extracts the eight tagged code blocks from the Markdown to their `.sv` files, compiles and elaborates each separately, then requires the correct PASS marker. It exits nonzero when an exact example does not pass. That behavior is intentional: known tool limitations are not silently counted as successful tests.

```text
python scripts/verify_randomization_examples.py
python scripts/verify_randomization_examples.py --only 01 02 03 05 08
```

The `--extract-only` option refreshes the example files and checks the arithmetic without running a simulator. An alternate Vivado installation can be selected with `--vivado-bin`. Compiler products and full local logs are kept under the ignored `output/section-6-randomization/` directory.

For one individual example, use a scratch build directory:

```text
xvlog -sv <absolute-path-to-example.sv>
xelab <top-module> -s example_sim
xsim example_sim -runall
```

## Failure preservation and callback evidence

IEEE 1800-2017 §18.6.3 requires the random fields to retain their prior values on a failed solve and says that `post_randomize()` is not called. The pre-hook in Example 04 increments a counter and does not assign the random fields.

A diagnostic copy of Example 04 added a print immediately after the deliberately impossible solve. The `randc` version printed:

```text
FAILURE TRACE old=13/15/28 now=4/5/28 counters=3/2
Fatal: Failed solve unexpectedly changed the data
```

The triples are `a/b/y`; the counters are attempts/successes. The result shows the failed attempt reached the pre-hook, did not reach the post-hook, and preserved the derived `y`, but did not preserve `a` and `b`. Repeating the diagnostic with ordinary `rand` fields gave `old=13/15/28 now=9/5/28 counters=3/2`, so this observation was not limited to cyclic fields.

The reference example retains its field-preservation check. Its recovery step is a language-based expected sequence and is not claimed as a completed step in that exact XSim run. The practical stimulus rule remains to terminate or skip consumption on failure.

## Equivalence and frozen-variable diagnostics

The exact `<->` source is preserved because it is valid SystemVerilog and is the operator in the supplied practice. XSim 2024.1's elaboration limitation applies even when the constraint would later be disabled.

A temporary diagnostic of Example 06 replaced `(wr == 1) <-> (oe == 0)` with `((wr == 1) == (oe == 0))`. The operands are two-state Boolean conditions, so the expressions specify the same relation. This variant reached:

```text
PASS control_demo: mode=0 on all ten calls
```

That result checks the final disabled-equivalence configuration, not active `<->` support.

For Example 07, a diagnostic using the simpler two-state equivalent `wr != oe` produced:

```text
MODE TRACE w=0 o=0 ok=0 actual=0,1
MODE TRACE w=0 o=1 ok=1 actual=0,1
MODE TRACE w=1 o=0 ok=1 actual=1,0
MODE TRACE w=1 o=1 ok=0 actual=0,0
Fatal: Frozen illegal pair should fail
```

The trace confirms the four enabled-pair acceptance checks. The four disabled-pair checks also completed before the fatal check. When both fields were then fixed at zero with `rand_mode(0)` and the relation was enabled, XSim returned success. IEEE 1800-2017 §§18.8 and 18.11 require state values still to satisfy active constraints. This diagnostic was **not** a full PASS. A separate equality-of-Boolean-conditions variant did not pass its first truth-table check either, reinforcing the need to distinguish mathematical equivalence from this tool's constraint implementation.

No new run on a second simulator is claimed. The attempted Chrome connection for EDA Playground was unavailable. Prior saved course-playground results are supporting lesson context and are not relabeled as runs of these new examples.

## Recorded distribution sample

Example 05 has independent ordinary `rand` fields and uses the supplied weights. The counts from the recorded run were:

| Value | `var1` count | Derived expected count | `var2` count | Derived expected count |
|---|---:|---:|---:|---:|
| 0 | 1527 | 1500 | 2955 | 3000 |
| 1 | 3481 | 3500 | 3021 | 3000 |
| 2 | 3474 | 3500 | 2931 | 3000 |
| 3 | 3518 | 3500 | 3093 | 3000 |
| Total | 12000 | 12000 | 12000 | 12000 |

There were 8408 writes and 8362 reads, compared with an expected count of 8400 for each. The check verifies solve success and count accounting; it does not assert exact sample frequencies or certify a statistical implementation.

## Independent arithmetic and source checks

Finite enumeration confirmed the 121 excluded-range pairs; 108 pairs in the union-range example; four representable values for bounds 12-33; no values for bounds 16-33; the three allowed implication pairs; the two allowed equivalence pairs; and 5 write triples versus 80 read triples for the isolated asymmetric address rule. Exact rational arithmetic checked the `:=` and `:/` probabilities.

The eight example files are extracted directly from the final guide. The original attached source is retained byte-for-byte. The local IEEE reference is consulted for clause checks and is not redistributed with this commit.
