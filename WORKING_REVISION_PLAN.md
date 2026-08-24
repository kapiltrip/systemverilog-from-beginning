# Working Revision and Functional Coverage Plan

- **Prepared:** August 22, 2026
- **Calibration weekend:** August 22–23, 2026
- **Main cycle:** August 24–September 20, 2026
- **Duration:** 4 weeks
- **Companion:** [Live revision tracker](REVISION_TRACKER.md)

## The decision

Run one integrated program with three lanes:

1. retrieve and apply the material in [SystemVerilog from Beginning](README.md);
2. retrieve and apply the subjects in [Revision Atlas](https://github.com/kapiltrip/RevisionAtlas);
3. learn SystemVerilog functional coverage through one synchronous-FIFO
   verification capstone.

The capstone is the bridge. It prevents functional coverage from becoming a
third disconnected course:

```text
SV basics
  transactions + constraints + interfaces + mailboxes + monitor/scoreboard
                              |
                              v
Revision Atlas FIFO ----> synchronous FIFO capstone <---- SV assertions
                              |
                              v
                 functional coverage and closure
                              |
                              v
                    protocol coverage exercises
```

This is a short, intensive pass. The target is roughly **10–11 focused hours
per week**. It gives every scope a retrieval attempt, while deep repair is
reserved for material marked `H` or `M`.

## What “revise both repositories” means

Revision does not mean rereading every line. Every listed unit must receive a
closed-book retrieval attempt, but only hesitant or missed material is reopened
for repair.

| Source | Actual boundary in this cycle | Proof that it was revised |
|---|---|---|
| SystemVerilog Basics | 44 lessons in five phases | Predict or reconstruct one behavior from each lesson cluster; rebuild the layered-testbench data flow from memory |
| SystemVerilog Assertions | Scheduler foundation, 28 lessons, and two projects | Write, explain, and deliberately fail properties without copying them |
| Revision Atlas digital design | FIFO, 13 frequency-divider pages, and `/2`–`/5` RTL practice | Trace state, flags, ratios, duty cycle, and edge cases; run one self-checking application |
| Revision Atlas protocols | I2C, SPI, UART, AHB, APB, and all nine AXI course sections through lesson 128 | Draw transfers closed-book and state ownership, sampling, completion, response, and error behavior |
| Revision Atlas timing and devices | 25 STA pages and five MOSFET/CMOS notebooks containing 110 source pages | Reproduce diagrams, signs, assumptions, equations, and at least one unseen application |
| Revision Atlas architecture | Current RISC-versus-CISC foundation | Explain ISA versus microarchitecture and solve one CPU-time comparison |
| New learning | Functional coverage from intent through closure | A requirement-linked FIFO coverage model, meaningful results, justified exclusions, and a closure report |

“All” therefore means **every scope above is touched and tested once during the
four-week pass**. It does not mean every page is rewritten or every example is
rerun. Weak items can remain on the Day 1/3/7/14/30 ladder after September 20.

## Why the schedule uses these hours

Git history is only a proxy for working time, not a measurement of attention.
Across the two repositories it shows 115 commits over 22 active days from July
17 through August 21. Work commonly finished in three windows:

- morning, especially around 10:00–12:00;
- afternoon, especially around 15:00–17:00;
- late evening through roughly 01:00.

Use that evidence as a menu, not a demand:

| Block | Suggested time | Use |
|---|---|---|
| Primary A | 10:00–11:40 | Main session when the morning is clear |
| Primary B | 15:00–16:40 | Main session when the afternoon is stronger |
| Light recall | 21:30–22:00 | Due reviews and oral recall only |
| Late-shift alternative | 23:15–00:55 | May replace A or B; it must not become a second main session |

Choose **one** primary block on a normal day. The optional light block is not a
second syllabus. Activity after midnight proves that late work sometimes
happens; it is not the baseline workload.

## Three workload modes

The plan survives uneven days because success has three sizes.

| Mode | Time | Required result |
|---|---:|---|
| Minimum viable day | 30 minutes | 10 minutes of due recall, one 15-minute retrieval/application, and a 5-minute queue update |
| Standard day | 100 minutes | 15 minutes due recall, 45 minutes repo revision, 35 minutes functional coverage, and 5 minutes logging |
| Deep integration day | 140 minutes | 20 minutes due recall, 55 minutes revision, 55 minutes building/debugging, and 10 minutes logging |

Weekly rhythm:

- Monday–Friday: standard days;
- Saturday: one deep integration day;
- Sunday: a 20-minute gate/buffer; if the week is complete, take it off.

A missed day becomes a minimum day tomorrow. It does not double tomorrow’s
payload.

## The standard session

### 1. Due retrieval — 15 minutes

Open only the tracker. Answer the due prompt before opening either repository.
Use the mark honestly:

- `R`: correct, causal, and confident without a hint;
- `H`: basically correct but hesitant, incomplete, or dependent on a hint;
- `M`: materially wrong, blank, or unable to apply.

### 2. Repository revision — 45 minutes

1. State the unit map or signal flow from memory.
2. Predict the output, waveform, equation sign, state transition, or protocol
   outcome.
3. Check the source.
4. Repair only the missing causal link.
5. Complete one small proof: code, waveform trace, drawing, derivation, or oral
   interview answer.

For the 44-lesson Basics week, retrieve seven or eight related lesson titles
per day. Give each lesson a prediction or one-sentence causal explanation, then
reopen only the `H` and `M` lessons. Do not spend the block passively reading.

### 3. Functional coverage — 35 minutes

1. State the verification requirement in plain language.
2. Decide the exact event on which it should be sampled.
3. Predict which bins a stimulus will hit.
4. Compile or run only after making the prediction.
5. Explain every hole before adding stimulus or changing the model.

### 4. Queue — 5 minutes

Record one proof and the weakest causal link. Schedule:

- `M`: tomorrow, with a second example;
- `H`: in three days, with a contrast question;
- `R`: in seven days, then Day 14 and Day 30.

Do not create one queue item for every sentence or image. Bundle a coherent
concept and add no more than three new weak items in one session. When more than
five items are due, do the `M` items first and pause new material for that day.

## Functional coverage learning spine

Use the active [IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
as the language authority. Simulator documentation remains the authority for
coverage database, reporting, and merge commands.

| Stage | Learn | Required proof |
|---:|---|---|
| 1 | Coverage intent: requirement, observable event, sample, bin, hit, hole, and closure | Turn five FIFO requirements into measurable questions without writing syntax |
| 2 | `covergroup`, construction, coverpoints, event-based versus explicit `sample()` | Predict exactly when a value is and is not sampled |
| 3 | Automatic and explicit bins, ranges, arrays of bins, `default`, wildcard bins, `ignore_bins`, and `illegal_bins` | Explain the denominator and purpose of every bin |
| 4 | Conditional sampling with `iff` and transition bins | Cover meaningful state movement rather than raw snapshots alone |
| 5 | Cross coverage, `binsof`, `intersect`, and filtered crosses | Build only requirement-backed crosses and prevent combinatorial explosion |
| 6 | Instance/type coverage and useful options such as `per_instance`, `goal`, `weight`, `at_least`, and `auto_bin_max` | Explain why the displayed percentage has that value |
| 7 | Reusable coverage architecture around transactions and a monitor | Sample accepted, stable transactions instead of racing live pins |
| 8 | Coverage-driven stimulus and closure | Classify every hole as stimulus, design reachability, model error, exclusion, or genuine bug |

Three boundaries matter throughout:

- functional coverage answers **what scenarios were observed**;
- assertions answer **whether temporal behavior obeyed a rule**;
- a scoreboard answers **whether the observed result matched the prediction**.

`illegal_bins` is not a replacement for an assertion, and a high coverage
percentage is not proof that the model represents the specification.

## FIFO capstone boundary

The first coverage project stays plain SystemVerilog. Do not add UVM during this
cycle; the current repository already has enough machinery to learn the idea
directly.

The capstone eventually combines:

- a synchronous FIFO contract from Revision Atlas;
- constrained read/write transactions;
- an interface and virtual-interface connection;
- generator, driver, monitor, reference model, and scoreboard flow;
- SVA for reset, flags, pointer/occupancy rules, overflow, and underflow;
- a coverage model sampled from accepted monitor transactions.

The coverage plan should include, when supported by the design contract:

- accepted operation: idle, write, read, and simultaneous read/write;
- occupancy classes: empty, one item, middle, almost full, and full;
- occupancy transitions and boundary entry/exit;
- flag assertion and deassertion;
- reset timing and first legal operation after reset;
- operation crossed with pre-operation occupancy;
- simultaneous operation crossed with empty/full boundary behavior;
- attempted overflow and underflow as negative scenarios checked by assertions.

Do not cross raw payload values with every state. Cover data classes only when
the specification gives them meaning; use the scoreboard to check arbitrary
payload integrity.

## Four-week sprint map

| Week | Dates | Revision lane | Functional-coverage lane | End-of-week proof |
|---:|---|---|---|---|
| 1 | Aug 24–30 | All 44 SV Basics lessons in six clustered retrieval blocks; include the task/function TODO and completed Section 6 Parts 16–21 in the weak queue | Intent, covergroups, sampling, coverpoints, and bin forms | Rebuild the layered-testbench flow and compile one small coverage example from a blank editor |
| 2 | Aug 31–Sep 6 | Scheduler foundation, all 28 SVA lessons, both projects, and a FIFO property set | Conditional/transition coverage, crosses, filtering, and useful options | Explain scheduler sampling, write five FIFO properties, and justify a FIFO coverage specification |
| 3 | Sep 7–13 | FIFO, frequency dividers/RTL, I2C, SPI, UART, AHB, APB, and AXI Sections 1–9 | Transaction-level coverage architecture; implement the FIFO collector/model | Draw every protocol family’s transfer and hit operation/occupancy coverage in the FIFO model |
| 4 | Sep 14–20 | All 25 STA pages, five MOSFET/CMOS notebooks, Computer Architecture, and final mixed retrieval | Coverage results, hole classification, targeted stimulus, exclusions, and closure | Pass the mixed test and give a 10-minute FIFO verification teach-back |

### How the compression works

- Start each block with a two-minute map and no notes.
- Give every assigned unit one prediction, definition, trace, or causal sentence.
- Mark it immediately; reopen only `H` and `M` material.
- Spend at least half of the revision block on the weakest two or three items.
- Saturday produces the integration proof; Sunday is buffer, not a new chapter.

For AXI, one section is a map unit: retrieve every lesson title and its role,
then deeply reopen only `H` and `M` lessons. For MOSFET/CMOS, give every source
page a fast recognition/retrieval attempt, then deeply repair only the weakest
three pages in that notebook. This is a revision pass, not note reconstruction.

## Calibration weekend: exact first steps

### Saturday, August 22

- [ ] Without opening either README, draw the three-lane map at the top of this
  plan.
- [ ] Explain the synchronous FIFO contract: accepted read/write, occupancy,
  empty/full, simultaneous operation, reset, overflow, and underflow.
- [ ] Continue the already planned “Assertions in FIFO — Part 1” session.
- [ ] Define `coverage model`, `covergroup`, `coverpoint`, `bin`, `sample`, and
  `coverage hole` in your own words; do not write code yet.
- [ ] Enter the baseline marks in [REVISION_TRACKER.md](REVISION_TRACKER.md).

### Sunday, August 23

- [ ] Recite the five SV Basics phases and the SVA scheduler flow.
- [ ] Put the existing task-versus-function TODO and completed Section 6 Parts
  16–21 into the weakness queue without editing over current uncommitted notes.
- [ ] Write five FIFO requirements and the observation event for each.
- [ ] Select either the morning or afternoon primary block for Week 1.
- [ ] Stop after scheduling Monday; Sunday is not a catch-up marathon.

### Monday, August 24

- [ ] Retrieve SV Basics 01–08 without notes and predict one behavior from each.
- [ ] Learn the covergroup lifecycle and choose explicit versus event sampling.
- [ ] Only now create the first learning example inside `SV Functional Coverage/`.
- [ ] Record one proof, one weak link, and the next due date.

## Milestone gates

### Gate 1 — Basics, end of Week 1

From a blank page, draw the transaction-object path through generator, mailbox,
driver, interface, monitor, scoreboard, and completion control. Explain object
copying and where aliasing would corrupt the result.

### Gate 2 — Assertions, end of Week 2

Write and explain at least five FIFO properties. Deliberately inject one failure
for each major rule and identify the sampled values that caused it.

### Gate 3 — Digital/protocol integration, end of Week 3

Trace a FIFO operation, divider waveform, serial transfer, AHB transfer, APB
transfer, and AXI VALID/READY exchange. State what coverage can observe and what
still needs an assertion or scoreboard.

### Gate 4 — Final, end of Week 4

Complete one 45-minute closed-book mixed test:

1. explain one SV object/process question;
2. write one SVA property;
3. trace one FIFO or protocol waveform;
4. solve one STA or CPU-time calculation;
5. explain one MOSFET/CMOS mechanism;
6. diagnose one functional-coverage hole;
7. give a 10-minute FIFO verification teach-back.

The cycle is complete when each answer has evidence and every remaining `H` or
`M` has a date. A dashboard saying 100% is not the completion condition.

## Guardrails that keep this manageable

- Predict before running; retrieve before reading.
- Add notes only for a repeated gap, not for every forgotten phrase.
- Keep Revision Atlas source evidence unchanged during ordinary revision.
- Do not modify the current uncommitted TODO or Revision Atlas worktree as part
  of this plan setup.
- Do not learn UVM in parallel with functional-coverage fundamentals.
- Do not create a cross merely because two coverpoints exist.
- Do not chase 100% by weakening the model or declaring reachable holes ignored.
- Stop a standard session at 100 minutes and write the next action while it is
  obvious.
- One recovery day is part of the plan, not a failure of it.

## After September 20

Keep only the Day 14/30 reviews and unresolved `H`/`M` items. Then choose the
next new layer from evidence:

- UVM only if the plain-SV coverage collector and FIFO environment are clear;
- code coverage only if functional-coverage intent is already understood;
- asynchronous FIFO only after the synchronous contract and CDC ownership are
  secure;
- a second protocol coverage model only after the FIFO capstone closes honestly.
