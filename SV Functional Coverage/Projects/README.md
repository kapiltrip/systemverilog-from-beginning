# SystemVerilog Functional Coverage — Projects

[Functional Coverage home](../README.md) · [Ordered lesson index](../Codes/README.md) · [Section 10 plates](../PLATES.md) · [All learning tracks](../../README.md)

Projects combine substantive RTL, stimulus, and a functional-coverage model.
They remain outside `Codes/` so a project does not consume a numbered
syntax-lesson part.

Namaste FPGA marks all 17 entries in Section 10 — Projects as completed. Those
entries form five design projects: 8:1 Mux, Priority Encoder, FIFO, SPI, and
Counter. This archive retains the single saved playground actually used for
each project rather than duplicating every P1/P2/P3 starter plate.

“Archived” means the page was captured and reviewed exactly. It does not hide
failed elaboration, incomplete stimulus, or a broken coverage model. The live
status column states what each saved page really proves. Unused continuation
plates remain in `plates/` and are not padded into this project archive.

| Project | Focus | Verified live result | Playground |
|---:|---|---|---|
| 01 | [Synchronous FIFO Design and Functional Coverage](01-fifo-functional-coverage/README.md) | Questa compiled with 0 source errors; 17/26 scored bins and 64.10% covergroup metric | [Au83](https://edaplayground.com/x/Au83) |
| 02 | [Counter P1 and Functional Coverage](02-counter-functional-coverage/README.md) | Clean 3,995 ns run with 0 source errors; the result pane printed no numeric coverage table | [h54t](https://edaplayground.com/x/h54t) |
| 03 | [8:1 Mux Functional Coverage](03-mux-8-to-1-functional-coverage/README.md) | 0 source errors; 41/42 bins and 97.22% covergroup metric | [dMGx](https://edaplayground.com/x/dMGx) |
| 04 | [Priority Encoder Functional Coverage](04-priority-encoder-functional-coverage/README.md) | Runs with 0 compile errors, but RTL/bin defects leave 8/67 bins and 6.25% | [vYdX](https://edaplayground.com/x/vYdX) |
| 05 | [SPI Transition Coverage](05-spi-transition-coverage/README.md) | Parsing succeeds; elaboration fails because `spi_controller` is undefined beside a `dac` design | [T6Uc](https://edaplayground.com/x/T6Uc) |

## Namaste FPGA project mapping

| Course project | Course entries | Used archive page | Unused continuations not copied |
|---|---|---|---|
| 8:1 Mux | V130–V132 | Project 03 from V130 | V131, V132 |
| Priority Encoder | V134 | Project 04 | None |
| FIFO | V136–V138 | Project 01 from V136 | V137, V138 |
| SPI transition bins | V140 | Project 05 | None |
| Counter | V142–V144 | Project 02 from V142 | V143, V144 |

## Project file contract

Each project directory contains:

- `README.md` — browser metadata, complete inline RTL/testbench, design and
  coverage discussion, answered source questions, and honest live-result
  analysis;
- `design.sv` — the substantive design pane used in the project;
- `testbench.sv` — the substantive stimulus and functional-coverage pane;
- `run.do` — the exact custom Questa report flow.

Browser spelling and comments are preserved in the source files. Corrections
and deeper explanations belong in the project Discussion so the original
learning evidence remains auditable.
