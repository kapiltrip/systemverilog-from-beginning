# Part 19 — Rules for Generic Covergroup Arguments

[← Part 18](../18-reusable-covergroup-pass-by-value/README.md) · [Functional Coverage index](../README.md) · [Part 20 →](../20-reusable-covergroup-alu-use-case/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V085 — Things to remember while working with Generic Covergroup |
| Source playground | [`E8nM`](https://edaplayground.com/x/E8nM) |
| EDA code ID / saved Name | `7382342` / **FC S06 V085 - Generic Covergroup Rules** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 3/6 per-value bins, 50%; 0 errors; one source warning about block-local `ci` lifetime |

## Direct answer to the source question

The comment asks why one argument uses `ref` and the other uses `input`:

> `add ref and input for argument as a value ok i can search for the reason`

Use `ref` for the variable whose changing value must be observed at every
sample. Use `input` for construction-time configuration that should be copied
once. Here `variableName` must follow `a`, while `variableValue` fixes the
upper limit at 5.

The next comment has the correct idea:

> `this wont work object 5 cant be pass by ref`

More precisely, literal `5` is a value expression, not independent variable
storage. A `ref` formal must alias a compatible actual variable, so a literal
cannot be connected to it. `input int variableValue` is the right declaration.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 085: remember ref for variables and input for constant values.
module tb;
  reg [3:0] a;
  integer i = 0;
  //covergroup check_var (ref logic [3:0] varInput );
  //covergroup check_var (int varValue );
  covergroup check_var (ref logic [3:0] variableName, input int variableValue); // add ref and input for argument as a value ok i can search for the reason

    // this wont work object 5 cant be pass by ref
    option.per_instance = 1;
    coverpoint variableName {
      bins f[] = {[0:variableValue]};
    }
  endgroup
  initial begin
    check_var ci = new(a, 5);
    for(i = 0; i < 10; i++)begin
      a = $urandom();
      ci.sample();
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

## What the two commented alternatives mean

~~~systemverilog
//covergroup check_var (ref logic [3:0] varInput );
~~~

This is legal for tracking a live four-bit variable, but it provides no
constructor argument for a reusable upper bin limit.

~~~systemverilog
//covergroup check_var (int varValue );
~~~

With no direction, `varValue` defaults to `input`. If that copied formal were
also the coverpoint, the covergroup would repeatedly sample the same
construction-time integer rather than live `a`. It is suitable as bin
configuration, not as the changing signal in this example.

## Why `f[]` produces six bins

~~~systemverilog
bins f[] = {[0:variableValue]};
~~~

An unsized bin array distributes the range into individual bins. With
`variableValue == 5`, Questa creates `f[0]` through `f[5]`. The fresh run hit
values 0, 2, and 3:

| Bin | Hits | Status |
|---|---:|---|
| `f[0]` | 1 | covered |
| `f[1]` | 0 | missing |
| `f[2]` | 2 | covered |
| `f[3]` | 1 | covered |
| `f[4]` | 0 | missing |
| `f[5]` | 0 | missing |

The other six random samples were values 6–15. They match no declared bin and
do not become extra denominator bins, so the result is 3/6 = 50%.

## Warning audit

Questa warns that `ci` is implicitly static because it is a block-local
variable declared with initialization:

~~~systemverilog
check_var ci = new(a, 5);
~~~

The run remains legal and correct. For clearer lifetime and naming, declare
`check_var ci;` at module scope and assign `ci = new(a, 5);` inside `initial`.
That removes the ambiguous implicit-static declaration style without changing
the coverage model.

## Revision checks

1. Why can `a` be passed to a `ref logic [3:0]` formal but literal `5` cannot?
2. When is the `input int variableValue` copy made?
3. Why are values 6–15 unbinned rather than illegal?
4. What syntactic feature makes `f[0]` through `f[5]` separate bins?
5. How would you eliminate the implicit-static warning?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup `ref`/range example](https://accellera.org/images/eda/sv-ec/1826.html)
- [Accellera covergroup-expression restrictions for non-`ref` constructor arguments](https://accellera.org/images/eda/sv-ec/8030.html)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
