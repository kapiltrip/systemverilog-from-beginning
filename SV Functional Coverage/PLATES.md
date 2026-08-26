# Functional Coverage Video Plates — Section 10

One runnable starter is provided for every teaching video in Section 10.
Agenda entries, separate **Code** entries, and assignments are intentionally
excluded, leaving **11 video plates**. Completed Sections 6–9 are archived as
Parts 16–33 in the [ordered code track](Codes/README.md).

Namaste FPGA shows Section 10 — Projects at 17/17 complete and groups the
videos into five projects. The [Projects archive](Projects/README.md) now keeps
one actually used saved page for each project: Mux, Priority Encoder, FIFO,
SPI, and Counter. P2/P3 continuation starters that were not used are not
duplicated into `Projects/`.

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

## Section 10 — Projects

| Video | Local starter | EDA Playground |
|---|---|---|
| [V130 — 8:1 Mux P1](https://namaste-fpga.com/student/learn/35) | [Starter plate](plates/section-10-projects/130-mux-8-to-1-p1) · [Archived Project 03](Projects/03-mux-8-to-1-functional-coverage/README.md) | [Open used EDA](https://edaplayground.com/x/dMGx) |
| [V131 — 8:1 Mux P2](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/131-mux-8-to-1-p2) | [Open EDA](https://edaplayground.com/x/ik4p) |
| [V132 — 8:1 Mux P3](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/132-mux-8-to-1-p3) | [Open EDA](https://edaplayground.com/x/q9rf) |
| [V134 — Priority Encoder with Verilog TB](https://namaste-fpga.com/student/learn/35) | [Starter plate](plates/section-10-projects/134-priority-encoder) · [Archived Project 04](Projects/04-priority-encoder-functional-coverage/README.md) | [Open used EDA](https://edaplayground.com/x/vYdX) |
| [V136 — FIFO P1](https://namaste-fpga.com/student/learn/35) | [Starter plate](plates/section-10-projects/136-fifo-p1) · [Archived Project 01](Projects/01-fifo-functional-coverage/README.md) | [Open used EDA](https://edaplayground.com/x/Au83) |
| [V137 — FIFO P2](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/137-fifo-p2) | [Open EDA](https://edaplayground.com/x/GHuu) |
| [V138 — FIFO P3](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/138-fifo-p3) | [Open EDA](https://edaplayground.com/x/Mggk) |
| [V140 — Usage of Transition bins: Serial Peripheral Interface](https://namaste-fpga.com/student/learn/35) | [Starter plate](plates/section-10-projects/140-spi-transition-bins) · [Archived Project 05](Projects/05-spi-transition-coverage/README.md) | [Open used EDA](https://edaplayground.com/x/T6Uc) |
| [V142 — Counter P1](https://namaste-fpga.com/student/learn/35) | [Starter plate](plates/section-10-projects/142-counter-p1) · [Archived Project 02](Projects/02-counter-functional-coverage/README.md) | [Open used EDA](https://edaplayground.com/x/h54t) |
| [V143 — Counter P2](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/143-counter-p2) | [Open EDA](https://edaplayground.com/x/du4L) |
| [V144 — Counter P3](https://namaste-fpga.com/student/learn/35) | [Unused continuation plate](plates/section-10-projects/144-counter-p3) | [Open EDA](https://edaplayground.com/x/jHrC) |

## Working pattern

1. Open the exact video entry from the Namaste FPGA link.
2. Open its independent EDA Playground plate.
3. Finish only the marked `TODO` portions while following the video.
4. Run the saved `run.do` to see detailed covergroup/bin results in the Log.
5. Copy the used project page into `Projects/`, preserving its exact source and
   real run status. Never append Section 10 project work to `Codes/`.
6. Do not copy unused P2/P3 continuation plates merely to fill an archive
   number.
