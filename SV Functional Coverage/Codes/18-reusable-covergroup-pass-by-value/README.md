# Part 18 — Reusable Covergroup: Pass Configuration by Value

[← Part 17](../17-reusable-covergroup-pass-by-reference/README.md) · [Functional Coverage index](../README.md) · [Part 19 →](../19-generic-covergroup-rules/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V083 — Pass by Value |
| Source playground | [`mzj8`](https://edaplayground.com/x/mzj8) |
| EDA code ID / saved Name | `7382338` / **FC S06 V083 - Pass by Value - Boilerplate** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | Both instances 3/3 bins; 6/6 total, 100%; 0 compile/simulation errors |

## Live data and fixed configuration have different directions

The sampled signal is passed by reference, while the name and range boundaries
are copied once:

~~~systemverilog
covergroup c (
  ref reg [3:0] variable,
  input string variableId,
  input int low,
  input int mid,
  input int high
);
~~~

This is the reusable-covergroup pattern: `variable` changes at every sample;
`low`, `mid`, and `high` configure the instance's bin structure when it is
constructed.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 083: pass constant range limits by value with input arguments.
module tb;
  reg [3:0] a, b; // low 0 to 3 mid 4 to 10 and high 11 to 15
  integer i = 0;

  covergroup c (ref reg [3:0] variable, input string variableId, input int low, input int mid, input int high);
    option.per_instance = 1;
    option.name = variableId;
    coverpoint variable {
      bins lower_value = {[0:low]};
      bins mid_value = {[low+1:mid]};
      bins high_value = {[mid+1:high]}; // we create 3 bins
    }
  endgroup
  c cia = new(a, "Variable a ", 3, 10, 15);
  c cib = new(b, "Variable b ", 3, 10, 15);
  initial begin
    for(i = 0; i < 10; i++)begin
      a = $urandom();
      b = $urandom();
      cia.sample();
      cib.sample();
      #10;

    end
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

## Range and bin audit

The comments and constructor values agree:

| Bin | Inclusive values | Number of values | Number of scored bins |
|---|---|---:|---:|
| `lower_value` | 0–3 | 4 | 1 |
| `mid_value` | 4–10 | 7 | 1 |
| `high_value` | 11–15 | 5 | 1 |

These are three named range bins, not sixteen per-value bins. The absence of
`[]` is important: any value in a range increments its one named bin.

The recorded random seed produced:

| Instance | Lower hits | Mid hits | High hits | Result |
|---|---:|---:|---:|---:|
| `Variable a` | 6 | 3 | 1 | 100% |
| `Variable b` | 4 | 2 | 4 | 100% |

Ten random samples happened to hit every range for both instances. That is a
verified result for this seed, not a guarantee for every ten-draw run.

## Comment and code audit

- **“pass constant range limits by value”** is correct. The formals need not be
  literal constants syntactically, but the values used by this constructed
  coverage model are the copies supplied to `new`.
- **“we create 3 bins”** is correct per instance: lower, middle, and high.
- `low+1` and `mid+1` prevent overlap at the boundaries. With 3, 10, and 15,
  the three ranges form a complete, gap-free partition of the four-bit domain.
- A reusable utility should validate configuration assumptions such as
  `0 <= low < mid < high <= 15`. Bad ordering can create empty, overlapping,
  or unintended ranges without changing the covergroup type.
- Both instances use identical boundaries here. Reuse becomes more visible if
  a third instance is constructed with a different legal partition.
- `$urandom()` truncates to the low four bits when assigned to `a` or `b`.

## Revision checks

1. Which formal must follow changing signal data, and which formals configure
   the instance once?
2. Why does `bins lower_value = {[0:low]};` make one bin rather than `low+1`
   bins?
3. How do `low+1` and `mid+1` prevent boundary overlap?
4. Why can this run be 100% after only ten samples?
5. What constructor checks would make the range utility safer?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup constructor and range example](https://accellera.org/images/eda/sv-ec/1826.html)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
