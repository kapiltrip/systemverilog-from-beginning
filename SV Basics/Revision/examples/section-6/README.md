# Section 6: Randomization examples

[Revision guide](../../Section-6-Randomization.md) · [Printable PDF](../../Section-6-Randomization.pdf) · [Verification](../../verification/section-6/README.md)

Each file is an exact copy of a complete code block in the guide. Compile and run one top module at a time. The original pasted programs are preserved separately in [the source archive](../../sources/randomization-practice-2026-09-26.txt).

| File | Top module | Study topic |
|---|---|---|
| [01-excluded-ranges.sv](01-excluded-ranges.sv) | `exclusion_demo` | Excluded values, nonrandom state, explicit simulation time |
| [02-cyclic-ranges.sv](02-cyclic-ranges.sv) | `cyclic_demo` | Two complete ten-value cycles per field on a retained object |
| [03-external-constraints.sv](03-external-constraints.sv) | `external_demo` | Qualified external constraint and display-method bodies |
| [04-callbacks-and-runtime-ranges.sv](04-callbacks-and-runtime-ranges.sv) | `range_demo` | Default bounds, four-bit domain, automatic callbacks, failure and recovery |
| [05-distribution-weights.sv](05-distribution-weights.sv) | `distribution_demo` | `:=` and `:/` histograms over 12,000 calls |
| [06-final-control-program.sv](06-final-control-program.sv) | `control_demo` | The supplied final configuration: weighted controls, implication, disabled equivalence |
| [07-constraint-and-rand-modes.sv](07-constraint-and-rand-modes.sv) | `mode_demo` | Equivalence truth table, mode toggling, frozen random fields |
| [08-conditional-addresses.sv](08-conditional-addresses.sv) | `address_demo` | The asymmetric address branches, optional inactive-address rule, implication truth table |

Examples 04, 07, and 08 deliberately request impossible solutions and check that `randomize()` returns zero. Their expected randomization warnings are explained in the verification record. No test relies on an exact pseudorandom sequence or an exact finite-sample histogram.

The [verification script](../../../../scripts/verify_randomization_examples.py) extracts the tagged code blocks from the Markdown and checks them with XSim. The Markdown is the editable source of truth; after changing a complete example there, run the script to refresh the corresponding source file and evidence.
