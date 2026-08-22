# SystemVerilog Functional Coverage

> A top-level learning track for measuring which verification scenarios have
> actually been observed.

[All learning tracks](../README.md) · [Revision plan](../WORKING_REVISION_PLAN.md) · [Live tracker](../REVISION_TRACKER.md)

## Start here

1. Begin with [Part 01 — Basic Coverpoints](Codes/01-basic-coverpoints/README.md).
2. Use the [ordered code index](Codes/README.md) as new lessons are added.
3. Record progress and coverage holes in the [live revision tracker](../REVISION_TRACKER.md).

## What this track covers

Functional coverage answers **which meaningful situations were sampled**. It
does not replace the other verification mechanisms:

| Mechanism | Main question |
|---|---|
| Functional coverage | Which planned values, transitions, and combinations occurred? |
| Assertions | Did temporal behavior obey its rules? |
| Scoreboard | Did the observed result match the predicted result? |

The planned progression is:

1. coverage intent, covergroups, construction, and sampling;
2. coverpoints and automatic or explicit bins;
3. ranges, wildcard bins, default bins, ignored bins, and illegal bins;
4. conditional sampling and transition bins;
5. cross coverage and filtering;
6. coverage options and percentage interpretation;
7. transaction-level coverage architecture;
8. coverage-driven stimulus, hole classification, and closure.

## Current sequence

| Part | Topic | Main idea |
|---:|---|---|
| 01 | [Basic Coverpoints](Codes/01-basic-coverpoints/README.md) | Manual sampling and automatic bins for two-bit signals |

## Track structure

```text
SV Functional Coverage/
├── Codes/
│   ├── 01-basic-coverpoints/
│   │   ├── design.sv
│   │   ├── testbench.sv
│   │   ├── print-coverage-report.tcl
│   │   └── README.md
│   └── README.md
└── README.md
```

Generated simulator databases, logs, and compiled objects remain outside the
tracked learning material.
