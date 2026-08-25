# Part 29 — Cross Filtering with `binsof` and `intersect`

[← Part 28](../28-operation-specific-cross-covergroups/README.md) · [Functional Coverage index](../README.md) · [Part 30 →](../30-simple-transition-coverage-p1/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 8, V112 — Filtering Combination Method 2: `binsof(SIG) intersect {VAL}` |
| Source playground | [`S_vr`](https://edaplayground.com/x/S_vr) |
| EDA code ID / saved Name | `7382364` / **FC S08 V112 - binsof intersect** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 25/28 raw bins; covergroup metric 95.83%; filtered two-way cross 4/4 and filtered three-way cross 9/12 |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 112: compact cross filtering with binsof(...) intersect {...}.
// ranges and values in the intersact

module tb;
  // b/w wr and addr when write,is 0
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din , dout ;

  integer i =0 ;
  covergroup c;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
      bins wr_high = {1};

    }
    coverpoint addr {
      bins addr_values[] = {0,1,2,3};

    }
    cross wr , addr
    {  // wr and address ,
      ignore_bins wr_low_unused = binsof (wr) intersect {0}; // bins of signal wr intersace with a value 0 . wr == 0

    } // ignore bins to exclude the coverage from report
    coverpoint din {                    // wr == 1
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    coverpoint dout {                   // wr == 0
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross wr,addr , din {
      ignore_bins wr_low_unused_din_dout = binsof(wr) intersect {0};

    }
  endgroup

  c ci ;
  initial begin
    ci = new();
    for(i =0 ; i< 50 ; i ++)begin
      wr = $urandom() ;
      addr = $urandom();
      din  = $urandom();
      dout = $urandom();
      ci.sample();
      #10 ;

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

| Coverage item | Covered / total bins | Metric |
|---|---:|---:|
| `wr` | 2/2 | 100.00% |
| `addr` | 4/4 | 100.00% |
| `din` | 3/3 | 100.00% |
| `dout` | 3/3 | 100.00% |
| Filtered `wr × addr` | 4/4 | 100.00% |
| Filtered `wr × addr × din` | 9/12 | 75.00% |
| Whole covergroup | 25/28 raw bins | **95.83%** |

Both ignore bins recorded 28 occurrences, matching the 28 random samples for
which `wr == 0`. An ignore-bin occurrence is evidence that an excluded tuple
was observed; it is not an illegal-bin error. The page ended with zero compile
or simulation errors. Its only warning was the saved `+acc` optimization
notice.

## What `binsof(...) intersect {...}` selects

`binsof(wr)` selects the bins belonging to the implicit `wr` coverpoint in the
cross. `intersect {0}` keeps the selected bin whose value set overlaps zero.
Placing that select expression on an `ignore_bins` declaration excludes every
cross tuple containing `wr == 0` from the scored denominator.

For the two-way cross, the unfiltered product would be `2 × 4 = 8` tuples.
Ignoring the four `wr == 0` tuples leaves the four write/address goals reported
by Questa. For the three-way cross, `2 × 4 × 3 = 24` becomes twelve scored
write/address/input-range tuples. Nine were hit in this recorded random run.

The source comment says the filter is “b/w wr and addr when write is 0,” but
the declaration actually removes the `wr == 0` combinations. The remaining
cross therefore measures the `wr == 1` write operation.

## Your range question from V116

V116 added only this question to an otherwise unchanged starter:

~~~systemverilog
ignore_bins unused_d = binsof(cp_d) intersect {[5:7]}; // values of d b/w 5 : 7 ?
~~~

Yes. For a three-bit `d` with automatic per-value bins, the selection matches
the bins for 5, 6, and 7. If the cross is `wr × d`, that ignore declaration
removes those three `d` values for both operation values: six tuples.

If another ignore bin removes every `wr == 0` tuple, the ignored sets overlap.
They combine as a union; overlapping tuples are not subtracted twice. Starting
from sixteen tuples, the range filter removes six and the operation filter
removes eight, with three tuples common to both: `16 - (6 + 8 - 3) = 5`
scored tuples remain, namely `wr == 1` with `d` from 0 through 4. This answer is
kept here instead of creating a redundant V116 repository part.

## Remaining model gap

`dout` has a standalone coverpoint, but it is not in any active cross. Thus the
model can show that every output-data range appeared somewhere, not that each
read address was paired with every output-data range. A requirement for read
combinations needs a filtered `wr × addr × dout` cross that keeps `wr == 0`.

The ignore-bin name `wr_low_unused_din_dout` is also broader than its code: the
cross contains `din`, not `dout`. Renaming it to `wr_low_unused_din` would make
the report self-explanatory; the archived source preserves the original name.

## Revision checks

1. What set of tuples does `binsof(wr) intersect {0}` select?
2. Why does putting that expression in `ignore_bins` leave write goals rather
   than read goals?
3. How do 24 automatic tuples become 12 scored tuples?
4. Why can an ignore bin say `Occurred` without failing the simulation?
5. How many tuples remain after the overlapping V116 filters, and why?
6. Which read-data requirement is still absent from this source?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera cross-bin selection and `intersect` material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
