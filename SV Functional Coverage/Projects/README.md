# SystemVerilog Functional Coverage — Projects

[Functional Coverage home](../README.md) · [Ordered lesson index](../Codes/README.md) · [Section 10 plates](../PLATES.md) · [All learning tracks](../../README.md)

Projects combine substantive RTL, stimulus, and a functional-coverage model.
They remain outside `Codes/` so a completed project does not consume a numbered
syntax-lesson part.

Only a project that was actually completed in its EDA Playground is copied
here. Unused Section 10 starter plates remain in `plates/` and are not padded
into the project archive.

| Project | Focus | Verified live result | Playground |
|---:|---|---|---|
| 01 | [Synchronous FIFO Design and Functional Coverage](01-fifo-functional-coverage/README.md) | Questa compiled with 0 source errors; 17/26 scored bins and 64.10% covergroup metric | [Au83](https://edaplayground.com/x/Au83) |

## Project file contract

Each project directory contains:

- `README.md` — browser metadata, complete inline RTL/testbench, design and
  coverage discussion, corrected source questions, and live-result analysis;
- `design.sv` — the substantive design pane used in the project;
- `testbench.sv` — the substantive stimulus and functional-coverage pane;
- `run.do` — the exact custom Questa report flow.

Browser spelling and comments are preserved in the source files. Corrections
and deeper explanations belong in the project Discussion so the original
learning evidence remains auditable.
