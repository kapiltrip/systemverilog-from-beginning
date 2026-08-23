# Part 04 — Automatic Bins and `auto_bin_max`

[← Part 03](../03-conditional-sampling-with-iff/README.md) · [Functional Coverage index](../README.md) · [Part 05 →](../05-explicit-bins-and-fixed-bin-arrays/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [XzxS](https://edaplayground.com/x/XzxS) |
| EDA code ID | `7380475` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; displayed total 3.51562% |

The design pane is placeholder-only. This source is especially useful because
its comments describe the **default** 64-bin behavior while the active
coverpoint overrides that default to 256. The discussion keeps those two cases
separate.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
// bins not beans  hihi
// implicit beans
/*
covergroup cover_a_b ;
  coverpoint a ;  // reg [1:0] a a may take 00 01 10 11 //
endgroup
auto_bin_max = 64 ; // bins keep track of no of time we apply a specific value to a dut */
// if i have a variable that has a size of <= 6 bit ,
// what if we have variable having a size of 7 bit
// i.e 128 beans
// 128 / 64 =2 each bin will take 2 values , i.e bean[0] will take a value of 0/1 will calc hit of these, 2 values
// if reg [7:0] a ; // 256 / 64 , we will track 4 diff values in a single value :
// bin [0] can take accout for 0,1,2,3, being hit
// of option_bin_max = 256;
module tb;
  //reg [1:0] a ;  // 00 01 10 11 no of unique value is < 64
 // reg [5:0] a; // 64 independent value for each value
  reg [6:0] a;  // 128 / 64 =2 values hit will be put on a single bin
  reg [7:0] b ;
  integer i ;

  covergroup cover_a ;
    option.per_instance=1 ;

    coverpoint a {
          option.auto_bin_max = 256 ; // can be restricted to a specific coverpoint

    }
    coverpoint b ;

  endgroup
  cover_a ci = new() ;
  initial begin
    for(i=0; i<10 ; i++)begin
      a = $urandom() ;
      ci.sample();
      #10 ;

    end
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact browser `run.do`

~~~tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do). This unchanged page was not rerun during capture;
its verified result comes from XSim. Part 09 later showed that the current EDA
Playground `qrun` flow can print covergroups without explicit `-coverage`, so no
browser result is inferred here merely from the saved option string.

## The automatic-bin rule

When a coverpoint declares no explicit bins, SystemVerilog creates automatic
bins. For an $N$-bit integral value with $2^N$ known values, the intended bin
count is bounded by `auto_bin_max`:

$$
B_\text{auto}=\min(2^N,\texttt{auto_bin_max}).
$$

The standard default for `auto_bin_max` is 64. If the value domain is no larger
than the limit, each value gets its own bin. If the domain is larger, the tool
partitions the ordered values across the limited number of bins as evenly as
possible.

Examples with the default limit:

| Expression width | Known values | Automatic bins | Values represented by each bin |
|---:|---:|---:|---:|
| 2 bits | 4 | 4 | 1 |
| 6 bits | 64 | 64 | 1 |
| 7 bits | 128 | 64 | 2 |
| 8 bits | 256 | 64 | 4 |

This is what the opening comments are trying to explain. The word is **bins**,
not “beans,” and the option spelling is `option.auto_bin_max`, not
`option_bin_max`.

## Why active `a` has 128 bins, not 64

The active coverpoint does not use the default:

~~~systemverilog
coverpoint a {
  option.auto_bin_max = 256;
}
~~~

`a` is seven bits, so it has 128 known values. The configured maximum is 256,
which is above that domain size. Therefore XSim creates 128 bins—one for every
value—not 64 two-value bins.

The nearby source comment `128 / 64 =2 values ... per bin` would describe this
alternative:

~~~systemverilog
coverpoint a; // uses the default auto_bin_max of 64
~~~

It does **not** describe the active code with `option.auto_bin_max = 256`.

`auto_bin_max` is a maximum, not a request to create empty bins. Asking for 256
does not make 256 bins for a 128-value expression.

## Why `b` has 64 bins and zero hits

`coverpoint b;` has no local override. `b` is eight bits, so its 256 known
values are partitioned into the default 64 automatic bins. XCRG names them as
ranges such as `auto[0:3]`, `auto[4:7]`, and so on.

However, the stimulus never assigns `b`. A four-state `reg` therefore remains
unknown (`X`) throughout the simulation. The ordinary automatic value bins
represent known values and none receives a hit. This is why `b` reports 0/64,
not why the coverpoint declaration failed.

The testbench also contains no DUT. The introductory phrase about values being
“applied to a DUT” is a general description of a coverage use case, not what
this executable source does.

## Reconstructing the verified result

The local XSim run sampled ten times and produced:

| Coverpoint | Expected bins | Covered | Percentage |
|---|---:|---:|---:|
| `a` | 128 automatic bins | 9 | 7.03125% |
| `b` | 64 automatic bins | 0 | 0% |

One `a` value repeated, so ten samples reached nine distinct one-value bins.
Both coverpoints retain their default weight of 1, giving:

$$
C_\text{cover\_a}=\frac{7.03125+0}{2}=3.515625\%.
$$

XCRG prints this value to five decimal places as `3.51562`; the equation shows
the exact arithmetic value before report formatting.

The exact hit values are seed-dependent. The denominator and the zero-hit
diagnosis for `b` follow from the model and do not depend on that seed.

## Automatic bins versus explicit intent

Automatic bins are convenient for small state spaces, but they answer only
“which values appeared?” They do not tell the tool which ranges have different
functional meanings. Raising `auto_bin_max` from 64 to 256 increases resolution
and denominator size; it does not improve verification intent by itself.

When a coverpoint declares explicit bins, automatic bins are not additionally
created for that coverpoint. Part 05 uses that mechanism to request a deliberate
64-bin partition of `[0:127]`.

## Questions from the source, answered

### Does one sample hit several automatic bins?

No. The automatic value bins form a partition for known values, so one sampled
value matches one of them. Repeating the same value increments the same bin's
hit count.

### Why can ten samples never close 128 one-value bins?

Each sample can add at most one previously uncovered bin. Even with no repeats,
ten samples can cover at most 10/128, or 7.8125%. Coverage below 100% is therefore
expected from this stimulus budget.

### Does `auto_bin_max = 256` affect `b`?

No. It is nested inside the `a` coverpoint and applies only there. `b` keeps the
default limit of 64.

## Revision checks

1. How many bins would seven-bit `a` have if its local override were removed?
2. Why does a limit of 256 create only 128 bins for `a`?
3. Why does `b` remain at 0% despite ten calls to `sample()`?
4. What is the maximum possible total score here after ten samples if `b` stays `X`?
5. When should explicit bins replace automatic bins?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
