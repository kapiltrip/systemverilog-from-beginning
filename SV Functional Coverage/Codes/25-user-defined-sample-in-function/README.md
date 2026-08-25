# Part 25 — User-Defined `sample()` Inside a Function

[← Part 24](../24-user-defined-sample-in-task/README.md) · [Functional Coverage index](../README.md) · [Part 26 →](../26-user-defined-sample-in-property/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 7, V098 — User-Defined Sample Method Inside a Function Block |
| Source playground | [`cGiB`](https://edaplayground.com/x/cGiB) |
| EDA code ID / saved Name | `7382356` / **FC S07 V098 - User sample() in Function** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | Enum bins: `write` 0, `read` 1, `NOP` 7, `error` 2; 75%; 0 source errors or warnings |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 098: decode a transaction in functions, then sample the enum result.
module tb;
  reg rd, wr, en;
  reg [1:0] din;
  integer i = 0;
  typedef enum int
    {
      write,
      read,
      NOP,
      error
    } opstate;
  opstate o1, o2;

  function opstate detect_state (input rd, input wr, input en);
    if(en == 0)
      return NOP;
    else if (en == 1 && wr == 1 && rd == 0)
      return write;
    else if (en == 1 && wr == 0 && rd == 1)
      return read;
    else
      return error;

  endfunction
  function bit [1:0] decode_state (input opstate oin);
    if(oin == NOP)
      return 2'b00;
    else if(oin == write)
      return 2'b01;
    else if (oin == read)
      return 2'b10;
    else if (oin == error)
      return 2'b11;

  endfunction

  function void check_coverage (input bit rd, input bit wr, input bit en);
    o1 = detect_state(rd, wr, en);
    //din = decode_state(o1);  // 2 bit value , now i will see the coverage of that 2 bit value
    ci.sample(o1);  // cause o1 holds the state
  endfunction
  //covergroup c with function sample(input bit [1:0] cin );
  covergroup c with function sample(input opstate cin); // opstate is the enum type

    option.per_instance = 1;
    coverpoint cin;

  endgroup
  c ci;
  initial begin
    ci = new();
    for(i = 0; i < 10; i++)begin
      wr = $urandom();
      rd = $urandom();
      en = $urandom();
      check_coverage(rd, wr, en);  // the main function
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

## Fresh direct Questa result

| Enum bin | Hits | Status |
|---|---:|---|
| `auto[write]` | 0 | Missing |
| `auto[read]` | 1 | Covered |
| `auto[NOP]` | 7 | Covered |
| `auto[error]` | 2 | Covered |
| Total | 10 samples, 3/4 bins | **75%** |

After the `void` repair, `qrun`, `vlog`, and `vsim` reported zero errors and
zero source warnings. The only remaining summary warning is the standard
Questa `+acc` optimization notice.

## Transaction decoding pipeline

The code separates three responsibilities:

1. `detect_state()` converts raw `rd`, `wr`, and `en` bits into semantic enum
   value `write`, `read`, `NOP`, or `error`.
2. `check_coverage()` orchestrates that decoding and calls the covergroup.
3. `ci.sample(o1)` snapshots the decoded enum rather than the three raw pins.

The truth table is:

| `en` | `wr` | `rd` | Result |
|---:|---:|---:|---|
| 0 | X | X | `NOP` |
| 1 | 1 | 0 | `write` |
| 1 | 0 | 1 | `read` |
| 1 | 0 | 0 | `error` |
| 1 | 1 | 1 | `error` |

Assigning `$urandom()` to a one-bit variable keeps only its low bit. Ten draws
are therefore ten random input combinations; they are not guaranteed to visit
all four semantic states. The saved seed happened to miss `write`.

## Why `check_coverage` is `function void`

The original page declared `function check_coverage` without a return type.
That implicitly creates a one-bit value-returning function, but the body never
assigned a return value and the caller discarded it. Questa consequently
issued warnings for a missing return and an implicit void cast.

The function is intended only to perform side effects—decode, store `o1`, and
sample—so `function void check_coverage` states the contract accurately and
removes those warnings without changing behavior.

## Answers to the source comments

### “2 bit value, now I will see the coverage of that 2 bit value”

Not in the current active code. Both the assignment
`din = decode_state(o1)` and the bit-vector form of the covergroup are
commented out. `din` and `decode_state()` therefore do not affect the result.
The active model samples `opstate`, so Questa reports readable enum bin names.

If the bit-vector lines were enabled, the numeric codes `00`, `01`, `10`, and
`11` would be covered instead. That can be useful for encoding coverage, but it
loses some semantic readability and would not by itself prove that the enum-to-
code mapping is correct.

### “cause o1 holds the state”

Correct. `detect_state()` returns an `opstate`, which is assigned to `o1` before
the sampling call. Because the method formal is an input, that enum value is
copied into `cin` for the current sample.

### “opstate is the enum type”

Correct and important. The formal type constrains valid semantic values and
lets an implicit enum coverpoint generate one bin per enumerator with names
`write`, `read`, `NOP`, and `error`.

### “the main function”

`check_coverage()` is the top-level helper invoked by stimulus. It is not the
program's entry point; its role is to keep transaction interpretation and the
coverage call together.

## Closure and checking limits

A deterministic test can drive all eight combinations of `en`, `wr`, and `rd`
to guarantee all four state bins. Even 100% state coverage would only prove
that the decoder produced every classification. Add assertions or a scoreboard
to prove that `detect_state()` and `decode_state()` implement the intended
protocol and encoding.

## Revision checks

1. Why does `en == 0` dominate both `rd` and `wr`?
2. Which active line determines whether coverage tracks enum names or bits?
3. Why was `void` the correct repair for `check_coverage()`?
4. How does `$urandom()` become a one-bit input here?
5. Why can ten samples miss a state whose input combination is legal?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
