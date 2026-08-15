# Part 04 — Data types and simulation time

EDA Playground: [https://edaplayground.com/x/giAN](https://edaplayground.com/x/giAN)

This part explores two-state and four-state types, integer widths, `$time`, `$realtime`, procedural outputs, and hierarchical construction from half adders.

## Answers and notes

- `bit` is a two-state type (`0` or `1`) and defaults to `0`. `logic` and legacy `reg` are four-state types (`0`, `1`, `x`, `z`) and default to `x`.
- `byte`, `shortint`, `int`, and `longint` are signed two-state/four-state integral types according to their declaration, with widths of 8, 16, 32, and 64 bits respectively. The built-in SystemVerilog integer types listed here are four-state except `bit`-based vectors.
- `$time` returns an integer simulation time rounded to the current time unit. `$realtime` returns a real value, preserving fractional time such as 12.23 ns.
- `%0t` formats a time value using the simulator's time-format settings. `%0f` is useful when the exact fractional `realtime` value is the focus.
- A signal assigned inside a procedural block cannot be a Verilog net (`wire`). Legacy Verilog uses `output reg y`; idiomatic SystemVerilog uses `output logic y` with `always_comb`.
- The half-adder outputs are driven continuously. Intermediate connections `f`, `g`, and `h` should be declared as `wire` in Verilog or `logic` in SystemVerilog. A `logic` may have a single driver, including a module output.
- Two half adders create the full-adder sum, and OR-ing their carry signals produces the full-adder carry output.

