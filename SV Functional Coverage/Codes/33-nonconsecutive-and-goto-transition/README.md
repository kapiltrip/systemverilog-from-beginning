# Part 33 — Nonconsecutive and Goto Transition Repetition

[← Part 32](../32-consecutive-repetition-transition/README.md) · [Functional Coverage index](../README.md) · [Remaining Section 10 plates](../../PLATES.md)

| Field | Value |
|---|---|
| Course lesson | Section 9, V126 — Non-Consecutive Transition |
| Source playground | [`SYhE`](https://edaplayground.com/x/SYhE) |
| EDA code ID / saved Name | `7382374` / **FC S09 V126 - Nonconsecutive and Goto** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | Active goto bin covered at 100% with exactly **1** hit; zero compile/simulation errors |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 126: non-consecutive [=] versus goto [->] repetition.
module tb;
  reg clk = 0 ;
  reg data[] = {0,0,0,1,1 ,0,0 ,1,1,1, 0 , 1 , 0 };
  reg state = 0 ;
  integer i = 0 ;
  initial repeat (90) #5 clk = ~ clk ;
  initial begin
    for(i=0 ; i< 15; i++)begin
      @(posedge clk );
      state = data[i];
    end
  end
  covergroup c @(posedge clk );
    option.per_instance = 1;
    coverpoint state {
      //bins transition= (1[=5]) ; // non consecutive repetition of 1
      bins transition = (0 => 1[->5]=> 0  ) ;
    }
  endgroup
  c ci ;
  initial begin
    ci = new() ;
    //#         bin transitions                                    41          1          -    Covered
 // coming out to be 41 due to overlapping nature of this in the array
    // important is to end the stimulus
    // or to remember the starting point 0 => 1[*4]

  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The EDA design pane contains only
the shared testbench-only placeholder, so it is intentionally omitted.

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

| Coverage item | Hits / bins | Metric |
|---|---:|---:|
| `state.transition` | **1** hit; 1/1 bins | 100.00% |
| Covergroup instance `ci` | 1/1 bins | 100.00% |
| Total | One covergroup type | **100.00%** |

Questa completed `qrun`, compilation, and simulation with zero errors. The
only total warning was `vopt-10587` from the saved `+acc` visibility setting.
No array-bound warning was printed, but that does not make the over-read valid.

## What `[->5]` means

In `0 => 1[->5] => 0`, the first sampled zero is followed by the first one,
the value one must then occur five times in total, and samples unequal to one
may appear between those repeated occurrences. Goto repetition ends on the
fifth one, so the final zero must be the immediately following sampled value.

The useful part of the recorded trace is:

```text
0 → 1 → 1 → 0 → 0 → 1 → 1 → 1 → 0
    first two       remaining three   endpoint
```

The two zeros in the middle are permitted gaps. The zero immediately after the
fifth one supplies the endpoint, so the bin increments once.

## `[=5]` versus `[->5]`

Both forms count five occurrences that need not be consecutive. Their endpoint
rule differs:

- `1[->5] => 0` requires the next transition item immediately after the fifth
  one;
- `1[=5] => 0` allows the transition sequence to continue after the fifth one
  before the later endpoint is matched.

The source does not actually compare them: the `[=5]` declaration is commented
out, so the direct report verifies only `[->5]`. A wider sampled state is the
clearest comparison—for example, insert state `2` after the fifth `1` and
before endpoint `0`. Goto would reject that delayed endpoint; nonconsecutive
repetition can accept it. With a one-bit state, every non-`1` value is already
zero, so the endpoint distinction is difficult to expose.

## The copied 41-hit comments are wrong here

The four comments in the final initial block belong to the preceding
consecutive-repetition lesson. This source has no active `1[*4]` bin and the
live report says `bin transition 1`, not 41. It is therefore incorrect to
describe this result as overlapping consecutive windows or to cite
`0 => 1[*4]` as the active pattern. They are retained only to preserve the
saved browser source; this README supplies the corrected interpretation.

## The loop reads beyond the array

`data` contains 13 elements, with valid indices 0 through 12. The loop uses
`i < 15`, so its final two iterations read `data[13]` and `data[14]`. An invalid
unpacked-array read returns the default uninitialized value for the element
type; for four-state `reg`, that is X. Questa happened not to warn in this run,
and `state` becomes X after the useful trace has completed.

The robust bound is derived from the array rather than duplicated manually:

~~~systemverilog
foreach (data[i]) begin
  @(negedge clk);
  state = data[i];
end
~~~

Equivalently, use `i < $size(data)`. Negative-edge driving also removes the
same-edge ordering dependency between the stimulus and covergroup sample.

## Why 100% is still weak evidence

The model contains one active bin, so one match closes it. It does not compare
the two repetition operators, detect the invalid array reads, or check the
sample-by-sample sequence as a requirement. A stronger lesson needs separate
bins and deliberately distinguishing traces; an assertion is preferable when
the sequence is a must-pass protocol rule rather than a coverage goal.

## Revision checks

1. Which samples may occur between the five repeated ones in `[->5]`?
2. What must immediately follow the fifth one for the active bin to match?
3. How does `[=5]` change the endpoint rule?
4. Why does a one-bit state make the endpoint distinction hard to demonstrate?
5. Why are the saved 41-hit and `1[*4]` comments incorrect for this page?
6. Which two array indices are invalid, and what value can they place in state?
7. Why does one hit produce 100% without proving the intended comparison?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification — goto and nonconsecutive repetition](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera clarification — invalid array indices return the element type's default uninitialized value](https://www.accellera.org/images/eda/sv-bc/1509.html)
- [EDA Playground simulator and custom `run.do` settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
