# SystemVerilog from Beginning

## Directory structure

```text
systemverilog-from-beginning/
├── SV Basics/
│   ├── Codes/
│   ├── Project/
│   ├── docs/
│   └── README.md
├── SV Assertions/
│   ├── Codes/
│   ├── Foundations/
│   ├── Projects/
│   └── README.md
├── SV Functional Coverage/
│   ├── Codes/
│   ├── docs/
│   └── README.md
├── WORKING_REVISION_PLAN.md
├── REVISION_TRACKER.md
├── REALIZATION.md
└── README.md
```

- [SV Basics](SV%20Basics/README.md)
- [SV Assertions](SV%20Assertions/README.md)
- [SV Functional Coverage — ordered playground lessons and simulator verification](SV%20Functional%20Coverage/README.md)
- [SystemVerilog Realizations](REALIZATION.md)
- [4-week revision and functional-coverage sprint](WORKING_REVISION_PLAN.md)
- [Live revision tracker](REVISION_TRACKER.md)

## Functional coverage simulator note

The first coverage lab reached Aldec Riviera-PRO on EDA Playground after a
testbench semicolon fix, but simulation was blocked twice by an unavailable
Aldec license. A later Questa 2025.2 run was repaired with a native `run.do`
that printed 100% functional coverage (8/8 bins, 0 errors) directly in the Log.
The source was also verified locally in Vivado/XSim 2024.1 at 101 ns with 100%
functional coverage. See the complete [Questa repair, Riviera-PRO incident,
and Vivado workaround](SV%20Functional%20Coverage/README.md).

The ordered coverage track now continues through Part 15 with goals/weights,
conditional `iff` sampling, automatic-bin limits, explicit bin arrays, default
bins, mux signal coverage, enum-state bins, and a repaired FSM state-coverage
flow, followed by filtered/overlapping bins, legal and illegal opcode bins,
ignored-domain closure, report timing around `$finish`, and a corrected
wildcard-bin/priority-encoder lesson with deep `case`/`casez`/`casex` Q&A,
followed by a repaired counter wildcard-bin lesson with reliable finite
reporting.
Parts 02–08 pair the public source with local XSim/XCRG evidence; later parts
add direct Questa evidence, complete source-specific Q&A, detailed bin-count
reconstruction, Part 14's repaired all-sample report plus deterministic 100%
wildcard-coverage variant, and Part 15's verified 4/4-bin counter report.

## Next study session

- **August 22–23, 2026:** Run the calibration weekend, including
  **Assertions in FIFO — Part 1** and a closed-book baseline.
- **August 24, 2026:** Begin Week 1 of the integrated four-week sprint.
