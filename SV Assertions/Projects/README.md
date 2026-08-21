# SystemVerilog Assertions — Projects

[SV Assertions home](../README.md) · [Ordered lesson index](../Codes/README.md) · [All learning tracks](../../README.md)

Projects combine substantive RTL with verification code. They remain outside `Codes/` so project work does not consume a numbered lesson part.

| Project | Focus | Verified live result | Playground |
|---:|---|---|---|
| 01 | [FSM Verification with SVA](01-fsm-verification-with-sva/README.md) | Compiles cleanly; two documented assertion failures at 5 ns and 85 ns | [8hjZ](https://edaplayground.com/x/8hjZ) |

## Project file contract

Each project directory contains:

- `README.md` — browser metadata, exact inline RTL/testbench, design behavior, verification findings, Q&A, and live-result interpretation;
- `design.sv` — exact substantive design pane;
- `testbench.sv` — exact testbench and assertion pane.

Browser spelling and spacing are preserved in source files. Suggested corrections and stronger properties belong in the explanation so the original evidence remains auditable.
