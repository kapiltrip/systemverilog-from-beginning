# Revision and Functional Coverage Tracker

[Working plan](WORKING_REVISION_PLAN.md) | [Repository home](README.md)

**Cycle:** August 22–September 20, 2026

This file is the control surface. Keep long explanations in their subject
notes; keep only marks, proof, weak causal links, and dates here.

## Marking rule

| Mark | Meaning | Next action |
|---|---|---|
| `R` | Correct, causal, confident, and closed-book | Review in 7 days, then Day 14 and Day 30 |
| `H` | Hesitant, incomplete, or correct only after a hint | Review in 3 days with a contrast question |
| `M` | Missed or materially wrong | Review tomorrow; repair the prerequisite and solve another example |

Status values for the cycle dashboard are `NS` (not started), `IP` (in
progress), `D` (done), and `B` (blocked by a named prerequisite).

## Cycle dashboard

| Week | Dates | Main scope | Status | End proof | Weak items left |
|---:|---|---|:---:|---|---:|
| 1 | Aug 24–30 | All SV Basics + coverage foundations/bins | NS | Layered bench map + compiled covergroup | 0 |
| 2 | Aug 31–Sep 6 | All SVA + transitions/crosses/options | NS | FIFO properties + coverage specification | 0 |
| 3 | Sep 7–13 | FIFO/dividers/all protocols + FIFO coverage model | NS | Transfer drawings + operation/occupancy hits | 0 |
| 4 | Sep 14–20 | STA/MOSFET/architecture + coverage closure | NS | Mixed test + FIFO teach-back | 0 |

## Full scope ledger

Fill `Baseline` before revision, then update `Latest`, `Last`, and `Next`.
`Proof / weakest link` should be a short description or a link, not “read it.”

### SystemVerilog from Beginning

| Scope | Baseline | Latest | Last | Next | Proof / weakest link |
|---|:---:|:---:|---|---|---|
| Basics 01–08 — simulation and collections | — | — | — | — | — |
| Basics 09–21 — classes and object behavior | — | — | — | — | — |
| Basics 22–29 — constrained random stimulus | — | — | — | — | — |
| Basics 30–39 — process communication | — | — | — | — | — |
| Basics 40–44 — layered DUT communication | — | — | — | — | — |
| Repair: task versus function | — | — | — | — | Existing TODO; preserve current edit |
| Repair: Section 6 reusable-covergroup use cases | — | — | — | — | Repository repair complete: [Parts 16–21](SV%20Functional%20Coverage/Codes/README.md); learner retrieval still unmarked |
| Repair: Section 7 sampling methods | — | — | — | — | Repository repair complete: [Parts 22–26](SV%20Functional%20Coverage/Codes/README.md); learner retrieval still unmarked |
| Repair: Section 8 cross coverage | — | — | — | — | Repository repair complete: [Parts 27–29](SV%20Functional%20Coverage/Codes/README.md); learner retrieval still unmarked |
| Repair: Section 9 transition bins | — | — | — | — | Repository repair complete: [Parts 30–33](SV%20Functional%20Coverage/Codes/README.md); learner retrieval still unmarked |
| SVA scheduler foundation | — | — | — | — | — |
| SVA 01–07 | — | — | — | — | — |
| SVA 08–14 | — | — | — | — | — |
| SVA 15–21 | — | — | — | — | — |
| SVA 22–28 | — | — | — | — | — |
| SVA project — FSM verification | — | — | — | — | — |
| SVA project — counter assertions with `bind` | — | — | — | — | — |

### Revision Atlas

| Scope | Baseline | Latest | Last | Next | Proof / weakest link |
|---|:---:|:---:|---|---|---|
| FIFO | — | — | — | — | — |
| Frequency Dividers — 13 pages | — | — | — | — | — |
| Programmable Divider RTL — `/2` through `/5` | — | — | — | — | — |
| I2C | — | — | — | — | — |
| SPI | — | — | — | — | — |
| UART | — | — | — | — | — |
| AMBA AHB | — | — | — | — | — |
| AMBA APB | — | — | — | — | — |
| AXI Section 1 | — | — | — | — | — |
| AXI Section 2 | — | — | — | — | — |
| AXI Section 3 | — | — | — | — | — |
| AXI Section 4 | — | — | — | — | — |
| AXI Section 5 | — | — | — | — | — |
| AXI Section 6 | — | — | — | — | — |
| AXI Section 7 | — | — | — | — | — |
| AXI Section 8 | — | — | — | — | — |
| AXI Section 9 | — | — | — | — | — |
| Static Timing Analysis — 25 pages | — | — | — | — | — |
| MOSFET/CMOS notebook 1 | — | — | — | — | — |
| MOSFET/CMOS notebook 2 | — | — | — | — | — |
| MOSFET/CMOS notebook 3 | — | — | — | — | — |
| MOSFET/CMOS notebook 4 | — | — | — | — | — |
| MOSFET/CMOS notebook 5 | — | — | — | — | — |
| Computer Architecture — RISC/CISC foundation | — | — | — | — | — |

### Functional coverage

| Scope | Baseline | Latest | Last | Next | Proof / weakest link |
|---|:---:|:---:|---|---|---|
| 1. Requirements and coverage intent | — | — | — | — | — |
| 2. Covergroup lifecycle and sampling | — | — | — | — | — |
| 3. Coverpoints and bin forms | — | — | — | — | — |
| 4. Conditions and transition bins | — | — | — | — | — |
| 5. Cross coverage and filtering | — | — | — | — | — |
| 6. Options and percentage interpretation | — | — | — | — | — |
| 7. Transaction-level coverage architecture | — | — | — | — | — |
| 8. Coverage-driven stimulus and closure | — | — | — | — | — |
| FIFO capstone | — | — | — | — | — |

## Calibration weekend

| Date | Block | Work | Mark | Proof / weak link | Next due |
|---|---|---|:---:|---|---|
| 2026-08-22 | Primary | Two-repo map + FIFO contract + FIFO SVA Part 1 | — | — | — |
| 2026-08-22 | New | Define six functional-coverage terms; no code | — | — | — |
| 2026-08-23 | Recall | Five Basics phases + SVA scheduler | — | — | — |
| 2026-08-23 | New | Five FIFO requirements and sampling events | — | — | — |

## Four-week daily sprint

| Date | Revision target | Functional-coverage target | Required proof | Done |
|---|---|---|---|:---:|
| Mon, Aug 24 | Basics 01–08 | Intent, covergroup lifecycle, sampling | Eight predictions + minimal covergroup | [ ] |
| Tue, Aug 25 | Basics 09–16 | Coverpoints, automatic and explicit bins | Object/copy trace + predicted bin hits | [ ] |
| Wed, Aug 26 | Basics 17–24 | Ranges, arrays of bins, wildcard/default bins | Inheritance/randomization contrast + justified partitions | [ ] |
| Thu, Aug 27 | Basics 25–31 | `ignore_bins`, `illegal_bins`, and `iff` | Constraint/event trace + explain each exclusion | [ ] |
| Fri, Aug 28 | Basics 32–39 | Transition bins | Process/mailbox timing trace + state transition bins | [ ] |
| Sat, Aug 29 | Basics 40–44 + TODO repair | Integrate and compile | Blank-page layered bench flow + saved experiment | [ ] |
| Sun, Aug 30 | Week 1 gate/buffer | Repair only | Gate 1 + due dates | [ ] |
| Mon, Aug 31 | SVA foundation + 01–05 | Assertion versus coverage sampling | Scheduler trace | [ ] |
| Tue, Sep 1 | SVA 06–10 | Conditional and transition coverage | Implication/sample-value trace | [ ] |
| Wed, Sep 2 | SVA 11–15 | Cross coverage fundamentals | Temporal trace + first requirement-backed cross | [ ] |
| Thu, Sep 3 | SVA 16–20 | `binsof`, `intersect`, filtering | Repetition trace + controlled cross | [ ] |
| Fri, Sep 4 | SVA 21–24 | Coverage options and metrics | Property-operator contrast + percentage explanation | [ ] |
| Sat, Sep 5 | SVA 25–28 + both projects | FIFO coverage specification | Five FIFO properties + written model | [ ] |
| Sun, Sep 6 | Week 2 gate/buffer | Repair only | Gate 2 + due dates | [ ] |
| Mon, Sep 7 | FIFO + frequency dividers/RTL | Implement FIFO operation/occupancy coverpoints | FIFO occupancy and divider waveform trace | [ ] |
| Tue, Sep 8 | I2C, SPI, UART | Accepted-transfer sampling | Three transfer drawings + ownership | [ ] |
| Wed, Sep 9 | AHB and APB | Wait/response/error scenarios | AHB/APB transfer comparison | [ ] |
| Thu, Sep 10 | AXI Sections 1–3 | READY/VALID and backpressure coverage | Handshake/stream map | [ ] |
| Fri, Sep 11 | AXI Sections 4–6 | AXI-Lite channel coverage | Independent-channel trace | [ ] |
| Sat, Sep 12 | AXI Sections 7–9 | Burst/boundary/response coverage | FIXED/INCR/WRAP trace + FIFO model run | [ ] |
| Sun, Sep 13 | Week 3 gate/buffer | Repair only | Gate 3 + due dates | [ ] |
| Mon, Sep 14 | STA pages 01–12 | Coverage-result reading | One setup/hold trace | [ ] |
| Tue, Sep 15 | STA pages 13–25 + Computer Architecture | Hole classification | One timing calculation + CPU-time comparison | [ ] |
| Wed, Sep 16 | MOSFET/CMOS notebook 1 | Target legitimate FIFO holes | Device-state drawing + targeted run | [ ] |
| Thu, Sep 17 | MOSFET/CMOS notebook 2 | Repair coverage-model errors | Region/condition explanation + model repair | [ ] |
| Fri, Sep 18 | MOSFET/CMOS notebook 3 | Justify exclusions | Inverter/device chain + exclusion evidence | [ ] |
| Sat, Sep 19 | MOSFET/CMOS notebooks 4–5 | FIFO closure and final regression | Delay/power/sizing trace + explained holes | [ ] |
| Sun, Sep 20 | Final mixed gate | Ten-minute teach-back | Gate 4 + remaining H/M dates | [ ] |

## Weak-item queue

Keep at most three new entries per session. Delete nothing; when repaired, mark
the row `R` and retain the evidence.

| Item | Subject | Mark | Last reviewed | Next due | Repair action | Result/evidence |
|---|---|:---:|---|---|---|---|
| — | — | — | — | — | — | — |

## Daily session log

Copy this block for each actual session.

```text
Date and time:
Mode: minimum | standard | deep
Energy before (1–5):

Due items attempted:
Repository scope retrieved:
Prediction/application made before looking:
Functional-coverage concept or build:

Proof produced:
Mark: R | H | M
Weakest causal link:
Next due date:
Exact first action for next session:

Energy after (1–5):
Actual focused minutes:
```

## Weekly review

Complete this on Saturday after the integration proof.

```text
Week:
Focused hours:
Scopes touched / scopes planned:
R / H / M totals:
Strongest proof:
Repeated prerequisite gap:
Functional-coverage hole classification:
One thing to stop doing:
One thing to preserve:
First task next Monday:
```

## Coverage-hole register

Use this only after the FIFO model exists.

| Hole/bin | Requirement | Reachable? | Classification | Action | Evidence | Closed? |
|---|---|:---:|---|---|---|:---:|
| — | — | — | stimulus / design / model / exclusion / bug | — | — | — |
