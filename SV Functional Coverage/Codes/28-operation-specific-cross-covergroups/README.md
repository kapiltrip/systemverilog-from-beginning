# Part 28 — Operation-Specific Cross Covergroups

[← Part 27](../27-cross-coverage-fundamentals/README.md) · [Functional Coverage index](../README.md) · [Part 29 →](../29-binsof-intersect-cross-filtering/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 8, V107 — Demonstration P1 |
| Source playground | [`gsC6`](https://edaplayground.com/x/gsC6) |
| EDA code ID / saved Name | `7382360` / **FC S08 V107 - Cross Demonstration P1** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | Write model 100% (8/8 raw bins); read model 97.91% (19/20 raw bins); combined metric 98.95% |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 107: construct address and data-range crosses for a memory-like DUT.
module tb;
  // wr = 1 , wr =0 all of the addresses are covered once
  // address = all of the ranges of din are checked
  // din ranges for write, operations
  // dout / address cross filter
  // wr addr and din
  // wr 0 , addr , dout
  // we will consider 2 covergroup
  reg wr ;
  reg [1:0] addr ;
  reg [3:0] din , dout ;
  integer i ;
  /*
  covergroup c ;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
      bins wr_high = {1};

    }
    coverpoint addr {
      bins addr_values = {0,1 ,2,3};

    }
    cross wr , addr ;
    coverpoint din {
      bins low = {[0:3]} ;
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    coverpoint dout {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross wr , addr , din ;
    cross wr , addr , dout ;

  endgroup
  */
  covergroup wr_din_addr ;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_high = {1};
    }
    coverpoint addr {
      bins addr_values = {0,1,2,3};
    }
    coverpoint din {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross addr , wr, din ;

  endgroup
  covergroup wr_low_dout_address;
    option.per_instance = 1;
    coverpoint wr {
      bins wr_low = {0};
    }
    coverpoint addr  {
      bins addr_value[] = {0,1,2,3};
    }
    coverpoint dout {
      bins low = {[0:3]} ; // i wont make low an array i.e low[]
      bins mid = {[4:11]};
      bins high = {[12:15]} ;
    }
    cross addr, dout , wr ;

  endgroup
  wr_din_addr ci1 ;
  wr_low_dout_address ci2 ;
  initial begin
    ci1 = new();
    ci2 = new();

  for(i =0 ; i< 50 ; i++)begin
    wr = $urandom();
    addr  = $urandom();
    din  = $urandom();
    dout  = $urandom();
    ci1.sample();
    ci2.sample();

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

| Covergroup / item | Covered / total bins | Metric |
|---|---:|---:|
| `wr_din_addr` type | 8/8 | 100.00% |
| Its `addr × wr × din` cross | 3/3 | 100.00% |
| `wr_low_dout_address` type | 19/20 | 97.91% |
| Its `addr × dout × wr` cross | 11/12 | 91.66% |
| Equal average of the two covergroup types | 27/28 raw bins | **98.95%** displayed |

The page completed with zero `qrun`, `vlog`, or `vsim` errors. The only warning
was the saved `+acc` optimization notice. The displayed percentages are
coverage-item weighted, not simply the raw covered-bin ratio: for example,
the read covergroup averages three 100% coverpoints with its 91.66% cross,
giving 97.91% even though 19/20 raw bins were hit.

## How the two covergroups filter combinations

`wr_din_addr` declares only the `wr_high` bin, so its cross has write tuples
only. `wr_low_dout_address` declares only `wr_low`, so its cross has read tuples
only. Samples with the other operation value do not match that coverpoint bin
and cannot hit its cross. This removes the irrelevant read/`din` and
write/`dout` goals created by Part 27's unfiltered three-way crosses.

Both covergroups are still sampled on every loop iteration. That is legal; the
inactive covergroup simply records no matching operation bin. In a transaction
monitor, calling only the matching covergroup can make intent clearer, provided
the sampling decision uses a stable accepted transaction.

## Important address-bin difference

The two active covergroups do not model address closure in the same way:

~~~systemverilog
// One bin containing all four values:
bins addr_values = {0,1,2,3};

// Four bins, one for each value:
bins addr_value[] = {0,1,2,3};
~~~

Therefore the write cross has only `1 × 1 × 3 = 3` bins. Its 100% result proves
that all three data ranges occurred during some write, but it does not prove
that every address was crossed with every data range. The read cross has
`4 × 3 × 1 = 12` bins and independently tracks each address; one of those
twelve tuples was absent in the recorded run.

If the requirement is “each write address with each input-data range,” the
write address declaration also needs `[]`. This is the main correction to the
source comment saying all addresses are covered once.

## Why `low` is not an array

The comment `i wont make low an array` is accurate. A declaration such as
`bins low = {[0:3]};` makes one range bin; any value from 0 through 3 hits that
same goal. `bins low[] = {[0:3]};` would distribute the range into per-value
bins and multiply the cross size. Use per-value bins only when the verification
plan requires each value independently.

## Commented monolithic model

The large `/* ... */` block is inactive source history showing the unfiltered
single-covergroup approach. It is retained because this is an exact archive of
the authored playground, but it contributes no bins or simulation behavior.
The active pair below it is the lesson implementation.

## Revision checks

1. Why does the write cross have only three bins instead of twelve?
2. Which brackets turn an address set into four independent bins?
3. How does a one-bin `wr` coverpoint remove irrelevant cross tuples?
4. Why is 97.91% different from the raw 19/20 ratio?
5. When would conditional covergroup calls be clearer than sampling both
   instances every time?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
