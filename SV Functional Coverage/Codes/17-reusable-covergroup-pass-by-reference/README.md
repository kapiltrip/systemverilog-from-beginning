# Part 17 — Reusable Covergroup: Pass by Reference

[← Part 16](../16-reusable-covergroup-fundamentals/README.md) · [Functional Coverage index](../README.md) · [Part 18 →](../18-reusable-covergroup-pass-by-value/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V081 — Pass by reference |
| Source playground | [`bCAQ`](https://edaplayground.com/x/bCAQ) |
| EDA code ID / saved Name | `7382336` / **FC S06 V081 - Pass by Reference - Boilerplate** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | `A` 14/16, `B` 16/16; type total 30/32 = 93.75%; 0 compile/simulation errors |

## The one change that makes reuse functional

~~~systemverilog
covergroup variable_cg(ref logic [3:0] value, input string instance_name);
~~~

`ref` binds the formal `value` to the actual variable for the lifetime of the
covergroup instance. `cg_a` observes the current `a`; `cg_b` observes the
current `b`. The string is intentionally `input`: each instance needs a
one-time name, not a live reference to mutable text.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 081: pass live variables by reference into one reusable covergroup.
module tb;
  logic [3:0] a, b;

  covergroup variable_cg(ref logic [3:0] value, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_value: coverpoint value;
  endgroup

  variable_cg cg_a, cg_b;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);

    cg_a = new(a, "variable A");
    cg_b = new(b, "variable B");

    repeat (50) begin
      a = $urandom;
      b = $urandom;
      cg_a.sample();
      cg_b.sample();
      #10;
    end
    // TODO: reuse the same covergroup type for another live signal.
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Complete saved `run.do`

~~~tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
~~~

Local script: [run.do](run.do).

## Verified result and what it proves

| Instance | Covered bins | Missing bins | Result |
|---|---:|---|---:|
| `variable A` | 14/16 | values 6 and 13 | 87.50% |
| `variable B` | 16/16 | none | 100% |
| Type total | 30/32 | two instance bins | 93.75% |

Each instance received fifty samples, so the nonzero counts prove that `ref`
tracks live assignments. The exact percentage is seed-dependent: a different
random run can miss different values or close both instances.

## Comment and code audit

- **“pass live variables by reference”** is exact. A copied input formal would
  retain only the construction-time value, as Part 16 demonstrates.
- Ref argument matching is intentionally strict. The actual must denote
  compatible variable storage; a literal, concatenation, or incompatible type
  is not a substitute for a four-bit `logic` variable.
- The TODO says to reuse the type for another live signal. The source already
  proves reuse with `a` and `b`; the intended extension is a third declaration,
  instance, assignment, and sample call—not a second covergroup definition.
- `cp_value:` is a label used in the report. It does not create another
  coverpoint or alter automatic binning.
- The sample calls occur immediately after blocking assignments, so they see
  the new `a` and `b`. The later `#10` only advances time.
- `per_instance` matters here: without retained instance detail, an aggregate
  type result could hide the fact that `A` missed two values while `B` closed.

## Revision checks

1. What storage does `cg_a.value` track after construction?
2. Why is `instance_name` better as `input` than `ref`?
3. Why can one covergroup type produce different per-instance percentages?
4. What four edits are needed to add a third sampled signal?
5. Why does 93.75% not indicate a functional failure?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup `ref` example](https://accellera.org/images/eda/sv-ec/1826.html)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
