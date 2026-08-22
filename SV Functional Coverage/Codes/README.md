# SV Functional Coverage — Ordered Learning Index

[Functional Coverage home](../README.md) · [All learning tracks](../../README.md)

| Part | Topic | Main idea | Verified result | Files |
|---:|---|---|---|---|
| 01 | [Basic Coverpoints](01-basic-coverpoints/README.md) | Explicit `sample()` calls and automatically created bins | Riviera-PRO blocked by shared-license failure; Vivado/XSim passed at 101 ns with 100% coverage | [`design.sv`](01-basic-coverpoints/design.sv) · [`testbench.sv`](01-basic-coverpoints/testbench.sv) |

## Per-part file contract

Each numbered directory should contain:

- `README.md` — the complete saved source, technical explanation, expected
  coverage behavior, and any simulator-specific reporting notes;
- `design.sv` — the DUT when the lesson needs one;
- `testbench.sv` — the executable coverage example;
- optional scripts that produce or display a coverage report.

Generated simulator output is not part of the learning index.
