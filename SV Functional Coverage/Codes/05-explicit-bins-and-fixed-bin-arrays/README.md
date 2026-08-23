# Part 05 — Explicit Bins and Fixed-Size Bin Arrays

[← Part 04](../04-automatic-bins-and-auto-bin-max/README.md) · [Functional Coverage index](../README.md) · [Part 06 →](../06-default-bins-for-unused-values/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [T8wy](https://edaplayground.com/x/T8wy) |
| EDA code ID | `7380484` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; 7.03125% total coverage |

The design pane contains only the default placeholder. The active lesson is the
fixed-size bin-array declaration; the individual, range, and unsized-array
forms remain commented examples.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
// explicit bins
module tb;
  //reg [1:0] a ;  // 00 01 10 11 no of unique value is < 64
 // reg [5:0] a; // 64 independent value for each value
  reg [6:0] a;  // 128 / 64 =2 values hit will be put on a single bin
  reg [7:0] b ;
  integer i ;

  covergroup cover_a ;
    option.per_instance=1 ;

    coverpoint a {
      /*
      bins zero = {0}; // keep the track of value 0
      bins one = {1};
      bins two = {2};
      bins three = {3}; // explicit bins
      bins bin0 = {0,1}; // [min: max]
      bins bin1 = {[2:3]};
      */
      // bins bin0nlyA = {[1:3]}; use array to create a specific bins
      //bins binArrayDynamic[] = {[0:127]}; // ok done array concept
      bins binArrayDynamic[64] = {[0:127]}; // build an array , 2 values will be tracked by single bin
      // EXPLICIT BINS
      // bins a = {0,1,2,3}
      // or
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

## Reading the four explicit-bin shapes

The commented declarations represent different partitions:

| Declaration | Number of bins | Meaning |
|---|---:|---|
| `bins zero = {0};` | 1 | One bin matches only value 0 |
| `bins bin0 = {0,1};` | 1 | One bin matches either 0 or 1 |
| `bins bin1 = {[2:3]};` | 1 | One bin matches the inclusive range 2 through 3 |
| `bins values[] = {[0:127]};` | 128 | An unsized bin array creates one bin per value in this range |
| `bins values[64] = {[0:127]};` | 64 | A fixed-size bin array partitions the range across 64 bins |

Braces describe the set assigned to a declaration. Square brackets after the
bin name describe an **array of bins**. These are different operations:
`bins bin0 = {0,1}` groups two values into one bin, while
`bins values[] = {0,1}` creates separate array elements for the two values.

The active identifier `binArrayDynamic` is only a name. Because the declaration
uses `[64]`, the language construct is a fixed-size bin array. Renaming it would
improve clarity but the captured source is preserved.

## How the active 64-bin partition works

`a` is seven bits, and `[0:127]` contains 128 values. The declaration requests
64 bins, so the values are distributed across the 64 bins in increasing order,
two values per bin:

| Bin | Values |
|---|---|
| `binArrayDynamic[0]` | 0 and 1 |
| `binArrayDynamic[1]` | 2 and 3 |
| ... | ... |
| `binArrayDynamic[63]` | 126 and 127 |

A hit on either member covers that bin. Hitting both members increases the bin's
hit count but does not add another covered bin.

Because `a` contains an explicit bin declaration, the simulator does not also
create automatic bins for it. `option.auto_bin_max` is therefore irrelevant to
this coverpoint's active model.

## Reconstructing the verified result

XSim reported:

| Coverpoint | Bin kind | Expected | Covered | Percentage |
|---|---|---:|---:|---:|
| `a` | 64 user-defined array bins | 64 | 9 | 14.0625% |
| `b` | 64 automatic bins | 64 | 0 | 0% |

The nine covered `a` array elements were 2, 5, 16, 22, 25, 40, 45, 51, and 54.
Array element 45 received two hits, so ten samples covered only nine distinct
bins.

`b` is never assigned. It remains `X`, so none of its known-value automatic
bins is hit. With equal default weights, the group score is:

$$
C_\text{cover\_a}=\frac{14.0625+0}{2}=7.03125\%.
$$

Ten samples can cover at most ten of `a`'s 64 bins, so even an ideal no-repeat
run can reach only $10/64=15.625\%$ on `a`. If `b` remains unknown, the total
can be at most 7.8125%. A low result here is a predictable consequence of the
model and stimulus budget, not evidence of a simulator failure.

## Explicit bins are requirements, not just compression

The active partition mechanically groups adjacent values in pairs. That is
useful for learning syntax, but a production coverage model should choose bins
because the specification gives those ranges different meanings—for example
empty, low occupancy, middle occupancy, almost full, and full.

Arbitrary grouping can hide a useful distinction: if values 0 and 1 represent
different protocol states, putting them in one bin allows one value to cover
the other. The denominator becomes smaller, but the verification question also
becomes weaker.

## Questions from the source, answered

### Is `{0,1}` the same as `{[0:1]}`?

For this contiguous two-value case, both range lists select values 0 and 1. The
important distinction is whether the declaration creates one bin or uses an
array suffix to split the selected values across several bins.

### What would the commented `bins binArrayDynamic[] = {[0:127]};` do?

The empty array size asks the tool to create one bin for each selected value,
so this range produces 128 bins. It is not the same as the active `[64]`
declaration.

### Why are there no extra automatic bins for `a`?

Explicit value bins replace the automatic value-bin generation for that
coverpoint. Values outside all explicit bins would be untracked unless another
explicit bin—such as a `default` bin—catches them.

## Revision checks

1. How many bins does `{[0:127]}` create with `[]`, `[64]`, and no array suffix?
2. Which values map to `binArrayDynamic[17]` in the active partition?
3. Why did ten samples cover nine bins in the verified run?
4. Why does the identifier `binArrayDynamic` not make the array dynamic?
5. When would grouping two adjacent values in one bin be a coverage-model error?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
