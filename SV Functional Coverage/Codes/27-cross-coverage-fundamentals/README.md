# Part 27 — Cross-Coverage Fundamentals

[← Part 26](../26-user-defined-sample-in-property/README.md) · [Functional Coverage index](../README.md) · [Part 28 →](../28-operation-specific-cross-covergroups/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 8, V106 — Understanding Cross Coverage |
| Source playground | [`uU5k`](https://edaplayground.com/x/uU5k) |
| EDA code ID / saved Name | `7382359` / **FC S08 V106 - Cross Coverage Fundamentals** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 60/68 raw bins; covergroup metric 95.23%; all coverpoints and the two-way cross closed, while each three-way cross reached 20/24 |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// address range , wr also din and dout ranges are also covered
// lower range , mid and high range , hit during write, and read
//wr
// rd we cover all the addresses
// during write, operation we are not verifying for all the addresses wr == 1 we are not tested for addresses

module tb;
  // address 01 all ranges of din are covered ,
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din, dout ;
  integer i =0 ;
  covergroup c ;
    option.per_instance = 1 ;
    coverpoint wr {
      bins wr_low = {0} ;
      bins wr_high = {1} ;
    }
    coverpoint addr {
      bins addr_v[] = {0,1,2,3}; // i.e all values of addresses 4 bins for address array

    }
    cross wr, addr ; // to find cross bw write and address
    coverpoint din {
      bins low = {[0:3]} ;
      bins mid = {[4:11 ]} ;
      bins high = {[12:15]} ;
    }
    coverpoint dout {
      bins low = {[0:3]} ;
      bins mid = {[4:11 ]} ;
      bins high = {[12:15]} ;
    }
    cross wr , addr , din ;   // wr 1 bit , addr 4 possible values , din 3 ranges low mid and high ,
    cross wr , addr , dout ;

  endgroup
  c ci ;
  initial begin
    ci = new();
    for(i =0 ; i< 50 ; i++)begin
      addr = $urandom();
      wr =  $urandom();
      din =  $urandom();
      dout =  $urandom();
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
| `cross wr, addr` | 8/8 | 100.00% |
| `cross wr, addr, din` | 20/24 | 83.33% |
| `cross wr, addr, dout` | 20/24 | 83.33% |
| Whole covergroup | 60/68 raw bins | **95.23%** |

The saved server copy was run directly on August 25, 2026. `qrun`, `vlog`, and
`vsim` each reported zero errors. The only warning is Questa's standard
`vopt-10587` notice that the saved `+acc` setting reduces optimization.

## What a cross adds

Independent coverpoints answer separate questions: whether both values of
`wr`, every address, and every data range were observed at least once. A cross
answers the stronger question: whether the required combinations occurred.
That is why every individual coverpoint can reach 100% while a three-way cross
still has holes.

The two-way cross has `2 × 4 = 8` automatic bins. Each three-way cross has
`2 × 4 × 3 = 24` bins because `din` and `dout` each use three range bins. The
recorded random run missed four tuples in each three-way cross, even though all
of their component bins were individually covered.

## Are all write and read address combinations verified?

They are covered as observations, not verified as correct behavior. The
`cross wr, addr` declaration requires all eight operation/address
combinations, and the recorded run hit them all. No DUT, assertion, or
scoreboard checks whether a write stores data or whether a read returns the
right value. Functional coverage says a scenario was seen; it does not prove
the scenario behaved correctly.

The source question about `wr == 1` exposes a second issue. Both three-way
crosses include both values of `wr`, so they create goals for read-time `din`
and write-time `dout`, even though those data directions may be irrelevant.
Part 28 splits the write and read goals; Part 29 demonstrates explicit
`ignore_bins` filtering.

## Why `addr_v[]` creates four bins

The unsized bin-array brackets distribute the four listed values across
separate bins:

~~~systemverilog
bins addr_v[] = {0,1,2,3};
~~~

Questa therefore reports `addr_v[0]` through `addr_v[3]`. Without `[]`, the
same set would form one bin named `addr_v`; hitting any member would cover that
single bin. This distinction becomes important because a cross uses the bins
of each participating coverpoint, not merely the variable's bit width.

## Data-range boundaries

The three bins partition every four-bit value without overlap:

- `low`: 0–3;
- `mid`: 4–11;
- `high`: 12–15.

The extra space in `[4:11 ]` is harmless whitespace. The range choice is a
coverage-model decision, not a language default; it should come from a real
verification requirement.

## Revision checks

1. Why can four independent coverpoints be 100% while a cross remains open?
2. How are the 8-bin and 24-bin cross denominators derived?
3. What changes if `addr_v[]` becomes `addr_v`?
4. Which combinations in this model are likely irrelevant to a memory
   requirement?
5. What additional checker is required before a covered write/read can be
   called correct?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
