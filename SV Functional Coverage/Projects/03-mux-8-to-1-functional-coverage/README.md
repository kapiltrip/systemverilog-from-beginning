# Project 03 — 8:1 Mux Functional Coverage

[Functional Coverage home](../../README.md) · [Projects index](../README.md) · [Section 10 plates](../../PLATES.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `FC S10 V130 - 8-to-1 Mux P1` |
| Stable playground | [dMGx](https://edaplayground.com/x/dMGx) |
| Course position | Section 10 project group, Videos 130–132 — 8:1 Mux P1–P3 |
| Captured project plate | V130, the single Mux page used for the project archive |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` / custom `run.do` |
| Fresh live result | 0 source errors; 41/42 scored bins; 97.22% covergroup metric |
| Only missing bin in that run | `cross_f_sel` with `sel == 5` and `f == 1` |

Namaste FPGA groups the three Mux videos inside Section 10 — Projects. This
folder preserves the one saved Mux playground that was actually used; the V131
and V132 starter plates are not duplicated here. It remains outside `Codes/`
because this is a design-and-coverage project, not another numbered syntax
lesson.

The tracked source preserves the browser code and comments while normalizing
horizontal spacing. Corrections and review findings are kept in Discussion so
the original learning evidence remains auditable.

Whitespace-insensitive fingerprints match the captured browser panes:

| Pane | SHA-256 |
|---|---|
| `design.sv` | `504bb7e16a8b3c7310431062c18fcf0ea8bef2323b12240ad7c76a7d15371cce` |
| `testbench.sv` | `cf08cbadaef0f44427bbecef01235cacea6f14441c1b3d66e6fa8c9932a6a93f` |
| `run.do` | `65de6824eb8c4baf3c4a6e4a236852a4b3efae55a53c971ffabde972ecdf41bc` |

## Exact browser design

```systemverilog
`timescale 1ns/1ps

// Video 130: begin with a small, readable 8:1 mux DUT.
module mux(
  input a, b, c, d, e, f, g, h,
  input [2:0] sel,
  output reg y
);

  always @(*) begin
    case (sel)
      0: y = a;
      1: y = b;
      2: y = c;
      3: y = d;
      4: y = e;
      5: y = f;
      6: y = g;
      7: y = h;
      default: y = 0;
    endcase
  end

endmodule
```

Local source: [design.sv](design.sv).

## Exact browser testbench and coverage model

```systemverilog
`timescale 1ns/1ps

// Video 130: direct stimulus plus the first coverage goal--visit every input.
module tb;
  reg a, b, c, d, e, f, g, h;
  reg [2:0] sel;
  wire y;
  mux dut (a, b, c, d, e, f, g, h, sel, y);

  covergroup cover_mux;
    option.per_instance = 1;

    coverpoint a { bins a_low = {0}; bins a_high = {1}; }
    coverpoint b { bins b_low = {0}; bins b_high = {1}; }
    coverpoint c { bins c_low = {0}; bins c_high = {1}; }
    coverpoint d { bins d_low = {0}; bins d_high = {1}; }
    coverpoint e { bins e_low = {0}; bins e_high = {1}; }
    coverpoint f { bins f_low = {0}; bins f_high = {1}; }
    coverpoint g { bins g_low = {0}; bins g_high = {1}; }
    coverpoint h { bins h_low = {0}; bins h_high = {1}; }
    coverpoint sel;
    coverpoint y;

    // sel also is responsible where, we have to send the o/p to the mux
    // sel and b sel 0 b 0 sel b1 , sel can be 0 to 7 i.e 8 unique values
    cross_a_sel: cross sel, a { // sel , a relevant when sel is 00 and a can be both ?
      ignore_bins sel_other = binsof(sel) intersect {[1:7]};
    }
    cross_b_sel: cross sel, b {
      ignore_bins sel_other = binsof(sel) intersect {0, [2:7]};
    }
    cross_c_sel: cross sel, c {
      ignore_bins sel_other = binsof(sel) intersect {[0:1], [3:7]};
    }
    cross_d_sel: cross sel, d {
      ignore_bins sel_other = binsof(sel) intersect {[0:2], [4:7]};
    }
    cross_e_sel: cross sel, e {
      ignore_bins sel_other = binsof(sel) intersect {[0:3], [5:7]};
    }
    cross_f_sel: cross sel, f {
      ignore_bins sel_other = binsof(sel) intersect {[0:4], [6:7]};
    }
    cross_g_sel: cross sel, g {
      ignore_bins sel_other = binsof(sel) intersect {[0:5], 7};
    }
    cross_h_sel: cross sel, h {
      ignore_bins sel_other = binsof(sel) intersect {[0:6]};
    }
  endgroup

  cover_mux ci;

  initial begin
    ci = new();
    for (int i = 0; i < 50; i++) begin
      sel = $urandom();
      {a, b, c, d, e, f, g, h} = $urandom();
      ci.sample();
      #10;
    end
  end
endmodule
```

The compact inline form above preserves every declaration, bin, cross, and
comment. The whitespace-normalized full source is in
[testbench.sv](testbench.sv).

## Exact Questa report script

```tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
```

Local source: [run.do](run.do).

## Discussion

### Why cross `sel` with each input instead of relying on separate coverpoints?

Separate coverpoints prove only that each input became both 0 and 1 and that
each select value appeared. They do not prove the meaningful relationship:
the selected input was exercised at both logic values while it controlled the
output. For example, `a == 1` while `sel == 6` says nothing useful about the
Mux path from `a` to `y`.

Each cross therefore retains only the select value that makes that input
relevant. `cross_a_sel` keeps `sel == 0`; `cross_b_sel` keeps `sel == 1`; the
pattern continues through `cross_h_sel`, which keeps `sel == 7`.

### When `sel == 0`, can `a` be both 0 and 1?

Yes. That is exactly why `cross_a_sel` has two scored bins after filtering:

```text
(sel == 0, a == 0)
(sel == 0, a == 1)
```

The comment's `00` is best read as numeric select value zero, not a two-bit
encoding; `sel` is three bits and the canonical spelling is `3'b000`.
`ignore_bins` removes all tuples with `sel` from 1 through 7 because `a` does
not drive `y` in those configurations.

### What does `binsof(sel) intersect {...}` select?

`binsof(sel)` denotes the bins belonging to the `sel` coverpoint. `intersect`
keeps the values listed in braces. When that expression is assigned to an
`ignore_bins`, every cross tuple containing those select values is removed
from the coverage denominator.

For `cross_f_sel`, the ignored set is `0:4` plus `6:7`, leaving only select
value 5. The two remaining legal goals are therefore `(5, 0)` and `(5, 1)`.

### Why did the fresh run stop at 97.22%?

The 50 samples are random. In the verified run, 41 of 42 scored bins were hit.
The only miss was `(sel == 5, f == 1)` inside `cross_f_sel`; `(sel == 5,
f == 0)` was hit three times. All individual coverpoints and the other seven
filtered crosses reached 100%.

This is a seed-dependent stimulus hole, not a compile failure. A future run
may close that tuple and miss a different rare tuple. Deterministic nested
stimulus—select each input and explicitly drive it low and high—would close all
16 meaningful path combinations in exactly 16 planned samples.

### Is the output sampled after the Mux has settled?

Not guaranteed. The testbench assigns `sel` and the inputs, then immediately
calls `ci.sample()` in the same time slot. The `always @(*)` process may update
`y` later in the active-event scheduling region. The input and select coverage
is still valid, but the sampled `y` can describe the preceding combination.

If output coverage or a scoreboard is added, drive on one edge and sample on
the opposite edge, or insert a small settling delay before `sample()`.

### Does high coverage prove that the Mux is correct?

No. Coverage measures which declared scenarios were observed; it does not
compare `y` with the expected selected bit. This project still needs a checker
such as `assert (y === expected)` after settling, where `expected` is selected
from `{h, g, f, e, d, c, b, a}` using `sel`.

The positional DUT connection also works only while the testbench argument
order exactly matches the module port order. Named connections would make the
mapping easier to audit.

## Revision checks

1. Why can all ten independent coverpoints be 100% while a selected-input
   cross still has a hole?
2. Which two tuples remain after filtering `cross_a_sel`?
3. Why does `cross_h_sel` ignore `sel` values 0 through 6?
4. What deterministic stimulus closes every meaningful selected-input tuple?
5. Why can immediate `ci.sample()` record a stale value of `y`?
6. What checker is needed before 100% coverage can support a correctness
   claim?
