# Part 16 — Reusable Covergroup Fundamentals

[← Part 15](../15-counter-wildcard-bins-and-finite-reporting/README.md) · [Functional Coverage index](../README.md) · [Part 17 →](../17-reusable-covergroup-pass-by-reference/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V080 — Fundamentals |
| Source playground | [`VnNY`](https://edaplayground.com/x/VnNY) |
| EDA code ID / saved Name | `7382335` / **FC S06 V080 - Fundamentals - Boilerplate** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 0 compile/simulation errors; both instances 0/16 bins; total 0% |

## Why a program that calls `sample()` fifteen times reports 0%

The covergroup's first formal has no direction:

~~~systemverilog
covergroup c (reg [3:0] variable, input string varId);
~~~

A directionless covergroup formal defaults to `input`, so its actual value is
copied when `new(...)` executes. Both instances are constructed at module
initialization, before the procedural stimulus assigns `a` or `b`; the copied
four-state value is therefore X. Later assignments change `a` and `b`, but do
not change either copied `variable`. Every `sample()` sees the same X, which
does not hit any of the sixteen ordinary automatic bins.

This is the intended bridge to Part 17. The source is legal and the simulator
is working; the missing `ref` changes the data model.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

module tb;
  // reusable covergroups
  // generic covergroup
  reg [3:0] a, b;
  covergroup c (reg [3:0] variable, input string varId);
    option.name = varId;
    option.per_instance = 1;
    coverpoint variable;

  endgroup
  c cia = new(a, "variable a ");
  c cib = new(b, "variable b ");
  initial begin
    for(int i = 0; i < 15; i++)begin
      a = $urandom();
      b = $urandom();
      cia.sample();
      cib.sample();
      #10;

    end
  end
  initial begin
    $dumpfile("dump.vcd ");
    $dumpvars;

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

## Comment and code audit

- **“reusable covergroups / generic covergroup”** — correct goal. `c` is one
  covergroup type and `cia`/`cib` are two instances with different names.
  Reuse of the type does not automatically make the sampled formal live.
- `option.name = varId` gives each instance a readable report name. It does
  not affect bins or sampling.
- `option.per_instance = 1` asks the simulator to retain separate results for
  `cia` and `cib`. The direct report proves this with **variable a** and
  **variable b**, each having sixteen bins.
- `coverpoint variable;` creates automatic bins for the four-bit domain. In
  this Questa run that is one bin per value, 0 through 15.
- `$urandom()` is 32 bits; assignment to four-bit `a` or `b` keeps the low four
  bits. Fifteen random draws do not guarantee all sixteen values.
- The delay is not needed to make blocking assignments visible to this manual
  sample call, but it separates iterations in simulation time and waveforms.
- The filename contains a trailing space: `"dump.vcd "`. That does not affect
  coverage, but it can create an awkward waveform filename. Prefer
  `"dump.vcd"` in a cleaned-up version.

## Verified report

| Instance | Covered / total bins | Result |
|---|---:|---:|
| `variable a` | 0/16 | 0% |
| `variable b` | 0/16 | 0% |
| Type `c` | 0/32 instance bins | 0% |

Questa compiled with zero source warnings. The only warning was the existing
`+acc` optimization warning from `vopt`; it does not change coverage.

## Revision checks

1. When is a directionless covergroup formal copied?
2. Why do later assignments to `a` and `b` not update `variable`?
3. Why does calling `sample()` prove neither that the sampled value is known
   nor that a bin was hit?
4. Which one-word change makes the first formal track a live variable?
5. What do `option.name` and `option.per_instance` change independently?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup constructor example](https://accellera.org/images/eda/sv-ec/1826.html)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
