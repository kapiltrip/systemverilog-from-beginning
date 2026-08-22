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
│   └── README.md
├── WORKING_REVISION_PLAN.md
├── REVISION_TRACKER.md
├── REALIZATION.md
└── README.md
```

- [SV Basics](SV%20Basics/README.md)
- [SV Assertions](SV%20Assertions/README.md)
- [SV Functional Coverage — Riviera-PRO issue and Vivado workaround](SV%20Functional%20Coverage/README.md)
- [SystemVerilog Realizations](REALIZATION.md)
- [4-week revision and functional-coverage sprint](WORKING_REVISION_PLAN.md)
- [Live revision tracker](REVISION_TRACKER.md)

## Functional coverage simulator note

The first coverage lab reached Aldec Riviera-PRO on EDA Playground after a
testbench semicolon fix, but simulation was blocked twice by an unavailable
Aldec license. The same source was verified locally in Vivado/XSim 2024.1 at
101 ns with 100% functional coverage. See the complete
[Riviera-PRO incident, `run.do`, diagnosis, and Vivado workaround](SV%20Functional%20Coverage/README.md).

## Next study session

- **August 22–23, 2026:** Run the calibration weekend, including
  **Assertions in FIFO — Part 1** and a closed-book baseline.
- **August 24, 2026:** Begin Week 1 of the integrated four-week sprint.
