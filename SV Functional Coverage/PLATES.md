# Functional Coverage Video Plates — Sections 9–10

One runnable starter is provided for every teaching video from Sections 9
through 10. Agenda entries, separate **Code** entries, and assignments are
intentionally excluded, leaving **16 video plates**. Completed Sections 6–8
are now archived as Parts 16–29 in the
[ordered code track](Codes/README.md). Section 8 retains only its three authored
programs; unchanged generated starters were omitted, and V116's sole range
question was consolidated into Part 29.

Each plate already contains the repetitive setup (`timescale`, declarations,
covergroup construction, `$dumpfile`, `$dumpvars`, finite stimulus, and a
focused `TODO`). Project videos also include a starter `design.sv` where it is
useful. Every plate contains its own `run.do`; the canonical
[`run.do`](plates/run.do) flow is `run -all`, detailed covergroup reporting,
then a clean exit.

Namaste FPGA currently keeps all lessons on one course-page URL rather than
giving each expanded video a separate browser URL. Therefore, every video
title below opens the course page; its video number and exact title identify
the matching entry. The EDA link opens that video's independent boilerplate.

## Section 9 — Transition Bins

| Video | Local starter | EDA Playground |
|---|---|---|
| [V121 — Simple Transition Coverage P1](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-09-transition-bins/121-simple-transitions-p1) | [Open EDA](https://edaplayground.com/x/v_s9) |
| [V122 — Simple Transition Coverage P2](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-09-transition-bins/122-simple-transitions-p2) | [Open EDA](https://edaplayground.com/x/gsCG) |
| [V124 — Consecutive Repetition Transition](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-09-transition-bins/124-consecutive-repetition) | [Open EDA](https://edaplayground.com/x/M9vN) |
| [V126 — Non-Consecutive Transition](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-09-transition-bins/126-nonconsecutive-and-goto) | [Open EDA](https://edaplayground.com/x/SYhE) |
| [V128 — Summary](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-09-transition-bins/128-summary) | [Open EDA](https://edaplayground.com/x/XxV6) |

## Section 10 — Projects

| Video | Local starter | EDA Playground |
|---|---|---|
| [V130 — 8:1 Mux P1](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/130-mux-8-to-1-p1) | [Open EDA](https://edaplayground.com/x/dMGx) |
| [V131 — 8:1 Mux P2](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/131-mux-8-to-1-p2) | [Open EDA](https://edaplayground.com/x/ik4p) |
| [V132 — 8:1 Mux P3](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/132-mux-8-to-1-p3) | [Open EDA](https://edaplayground.com/x/q9rf) |
| [V134 — Priority Encoder with Verilog TB](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/134-priority-encoder) | [Open EDA](https://edaplayground.com/x/vYdX) |
| [V136 — FIFO P1](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/136-fifo-p1) | [Open EDA](https://edaplayground.com/x/Au83) |
| [V137 — FIFO P2](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/137-fifo-p2) | [Open EDA](https://edaplayground.com/x/GHuu) |
| [V138 — FIFO P3](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/138-fifo-p3) | [Open EDA](https://edaplayground.com/x/Mggk) |
| [V140 — Usage of Transition bins: Serial Peripheral Interface](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/140-spi-transition-bins) | [Open EDA](https://edaplayground.com/x/T6Uc) |
| [V142 — Counter P1](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/142-counter-p1) | [Open EDA](https://edaplayground.com/x/YVGU) |
| [V143 — Counter P2](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/143-counter-p2) | [Open EDA](https://edaplayground.com/x/du4L) |
| [V144 — Counter P3](https://namaste-fpga.com/student/learn/35) | [Open plate](plates/section-10-projects/144-counter-p3) | [Open EDA](https://edaplayground.com/x/jHrC) |

## Working pattern

1. Open the exact video entry from the Namaste FPGA link.
2. Open its independent EDA Playground plate.
3. Finish only the marked `TODO` portions while following the video.
4. Run the saved `run.do` to see detailed covergroup/bin results in the Log.
5. Copy the completed version into the ordered `Codes/` archive only after the
   lesson is finished and verified.
