# Part 08 — Enumerated-State Coverpoint

[← Part 07](../07-multiplexer-signal-coverpoints/README.md) · [Functional Coverage index](../README.md) · [Part 09 →](../09-fsm-state-coverage-and-report-timing/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [ggV4](https://edaplayground.com/x/ggV4) |
| EDA code ID | `7380537` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; `s0` covered, 1/4 bins, 25% |

The design pane is placeholder-only. The later completed FSM example is
archived as Part 09.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  typedef enum bit [1:0] {  // option.auto_bin_max is not allowed in enum
    s0 = 2'b00,
    s1= 2'b01,
    s2= 2'b10,
    s3= 2'b11

  } fsm_states;
  fsm_states var1;

  covergroup coverFsm ;
    option.per_instance = 1;

    coverpoint var1;

  endgroup
  initial begin
    coverFsm ci = new();

    $cast(var1 , 2'b00);

    ci.sample();
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact browser `run.do`

~~~tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do). This unchanged page was not rerun during capture;
its verified result comes from XSim. Part 09 later showed that the current EDA
Playground `qrun` flow can print covergroups without explicit `-coverage`, so no
browser result is inferred here merely from the saved option string.

## Why the enum creates four bins

`fsm_states` has four named values. When an enum-typed coverpoint has no
explicit bins, SystemVerilog creates one automatic bin for every named enum
value:

| Enum literal | Encoded value | XCRG bin name |
|---|---:|---|
| `s0` | `2'b00` | `auto_s0` |
| `s1` | `2'b01` | `auto_s1` |
| `s2` | `2'b10` | `auto_s2` |
| `s3` | `2'b11` | `auto_s3` |

Enum auto bins follow the named literals rather than partitioning the base
type's numeric range through `auto_bin_max`. The source comment is pointing at
this rule: `option.auto_bin_max` is not the mechanism for reducing or grouping
an enumerated coverpoint. If the coverage plan needs different groupings,
declare explicit bins using the enum literals.

XCRG labels the category `UserDefined` in its text report even though the
source declares no `bins` statement. The important evidence is the four
automatically named enum bins and their hit counts.

## What `$cast` does here

Direct assignment from an arbitrary packed value to an enum variable is
strongly type checked. `$cast` performs a run-time checked conversion:

~~~systemverilog
$cast(var1, 2'b00);
~~~

`2'b00` is the encoding of `s0`, so the cast succeeds and assigns `var1 = s0`.
Because `$cast` is used as a standalone statement, a failed cast is treated as
an error. Code that wants to handle failure explicitly can use the function
result:

~~~systemverilog
if (!$cast(var1, raw_state))
  $fatal(1, "invalid FSM encoding %b", raw_state);
~~~

For this constant, the clearer ordinary statement is simply `var1 = s0;`.
`$cast` becomes useful when `raw_state` comes from a packed bus, file, or other
untyped source and must be validated against the enum's legal set.

The enum base type is `bit [1:0]`, so it is two-state. Every one of its four
base encodings is named here. A sparse enum would still create bins for its
declared literals, not automatically turn every unnamed base representation
into a legal state.

## Reconstructing the verified result

The source constructs `ci`, casts `var1` to `s0`, and calls `ci.sample()` once.
XCRG reports:

| Bin | Hit count | Status |
|---|---:|---|
| `auto_s0` | 1 | Covered |
| `auto_s1` | 0 | Uncovered |
| `auto_s2` | 0 | Uncovered |
| `auto_s3` | 0 | Uncovered |

Therefore the coverpoint and covergroup score are both:

$$
\frac{1}{4}\times 100=25\%.
$$

The simulation has no delay and no remaining event after the initial block, so
it completes at time 0. Vivado emits one warning asking that local covergroup
variable `ci` be declared explicitly `automatic` or `static`; it does not
prevent compilation, sampling, or reporting.

## State coverage is not transition coverage

This model answers only “which named states were sampled?” Even if all four
state bins were hit, it would not prove that the FSM followed legal arcs. For
example, a direct `s0 → s3` jump and the intended `s0 → s1 → s2 → s3` path can
both produce 100% state occupancy.

Transition bins are the appropriate next layer when the requirement concerns
legal movement, reset entry, recovery, or forbidden arcs. Assertions remain the
better tool for rules that must never be violated. Do not treat 100% state-bin
coverage as proof of an FSM's transition correctness.

## Questions from the source, answered

### Why not cover the raw two-bit value instead?

A raw two-bit coverpoint also creates four value bins here, but enum bins retain
the state names in the report. That makes the coverage model align with the
design vocabulary and survives encoding changes more cleanly.

### Does `auto_bin_max = 2` merge four enum states into two bins?

No. `auto_bin_max` does not partition enum literals. Use explicit bins if the
requirements intentionally group states, and justify why losing per-state
visibility is acceptable.

### Why is only `s0` covered if `var1` is two-state and defaults to zero?

The explicit cast already establishes `s0` before sampling, so the result does
not depend on reasoning from an implicit default. More importantly, no code
ever assigns or samples `s1`, `s2`, or `s3`.

## Revision checks

1. Why does this coverpoint have four bins even though none are explicitly written?
2. What happens if a checked `$cast` receives an encoding with no enum literal?
3. Why is `var1 = s0` clearer for this exact constant?
4. What question does state occupancy answer that transition coverage does not?
5. Why is an enum-literal report more maintainable than anonymous numeric bins?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage enum example and option tables](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
