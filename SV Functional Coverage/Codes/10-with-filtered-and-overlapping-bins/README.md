# Part 10 — `with`-Filtered and Overlapping Bins

[← Part 09](../09-fsm-state-coverage-and-report-timing/README.md) · [Functional Coverage index](../README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the saved field |
| Stable playground | [Ztfn](https://edaplayground.com/x/Ztfn) |
| EDA code ID | `7380906` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; `run -all`, detailed covergroup report, then `quit -f` |
| Verified browser result | 32.25% aggregate: `a` 10/22 bins, `b` 4/21 bins, 0 compile/simulation errors |

After Part 10 was captured, the newer active playground
[`KN3M`](https://edaplayground.com/x/KN3M) remained open for the next lesson. It
is still in progress and is outside this archive.

The repository source below preserves the saved substantive editor content.
Trailing spaces and redundant blank lines at the end of the browser buffer are
normalized so the file remains clean in Git.

## Complete saved testbench

~~~systemverilog
/*
// bin filtering
coverpoint a {
  bina used_a[]= a with (item % 2 ==0  ) ;
  // 0,2,4,6,8 , 10  ....

}
coverpoint a {
  illegal_bins unused_a = {2,3} ;
}
coverpoint a{
  wildcard bins low = {2'b0?} ; // lsb bit is dont care for us cover the value of a as 00 / 01

}
*/

module tb;
  reg [3:0] a;   // 0 to 15
  integer i =0 ;
  int b ;
  reg [5:0] btemp ;
  covergroup c;

    option.per_instance =1 ;
    coverpoint a {

	bins track_0 = {0};
	//bins even_a  = {2, 4, 6, 8, 10, 12, 14};
    //bins odd_a   = {1, 3, 5, 7, 9, 11, 13, 15};
      bins odd_a[] = a with ((item>0) && (item %2 !=0 ));
      bins even_a[] = a with ((item>0) && (item %2 ==0 ));
      bins mul3_a[] = a with ((item>0) && (item %3 == 0 ));
      bins range0to7even = {[0:7]} with ((item %2 == 0) && (item>0 )) ;

    } // item is a special keyword each item we r tracking how we refer to item
    coverpoint b {
      bins zero = {0};
      bins bdividedBy5[] = {[1:100]} with ((item %5==0)) ; // its an array i forgot to mention []

    }
  endgroup
  c ci ;
  initial begin
    ci = new();
    for(i=0; i<10 ;i++)begin
      a = $random();
      btemp = $urandom();  // its 32 bit unsigned
      b = btemp; // and int is 32 bit
      $display("Value of a is %0d and b is %0d" , a , b ) ;
      ci.sample();
      #10 ;
    end
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    //#100;
    //$finish();
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv). The design pane contains only EDA
Playground's placeholder and is intentionally omitted.

## Exact saved `run.do`

~~~tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do).

## What `with` and `item` mean

In a bin declaration, `with` filters the candidate values used to construct the
bin or bin array. `item` is the special iterator representing one candidate
value at a time. For example:

~~~systemverilog
bins odd_a[] = a with ((item > 0) && (item % 2 != 0));
~~~

The coverpoint expression `a` is four bits, so its candidate values are 0–15.
The predicate retains 1, 3, 5, 7, 9, 11, 13, and 15. `with` does not wait until
sampling time like a coverpoint `iff` condition. It defines which values belong
to the bins; later samples increment the resulting bins.

The commented teaching fragment contains `bina used_a[]`. `bina` is a typo. If
that block is uncommented, the declaration must begin with `bins`:

~~~systemverilog
bins used_a[] = a with (item % 2 == 0);
~~~

## Why the empty brackets matter

The unsized brackets in `odd_a[]`, `even_a[]`, `mul3_a[]`, and
`bdividedBy5[]` ask the simulator to make one bin for every selected value.
Consequently, the report retains names such as `odd_a[1]`, `odd_a[3]`, and
`bdividedBy5[50]`.

Without `[]`, the selected values are grouped into one scalar bin. That is what
happens here:

~~~systemverilog
bins range0to7even = {[0:7]}
                      with ((item % 2 == 0) && (item > 0));
~~~

The predicate selects 2, 4, and 6, but all three values belong to the single bin
`range0to7even`. Hitting any one of them covers that bin. Use an array when the
coverage question is “did every value occur?” and a scalar bin when the
question is “did any member of this category occur?”

## Overlap is intentional in this model

The bins within coverpoint `a` overlap. A sampled value can therefore increment
more than one bin:

| Sample | Matching bins |
|---:|---|
| 2 | `even_a[2]`, `range0to7even` |
| 3 | `odd_a[3]`, `mul3_a[3]` |
| 4 | `even_a[4]`, `range0to7even` |
| 9 | `odd_a[9]`, `mul3_a[9]` |

Overlap is useful when these are independent requirement categories. It can be
misleading when the intended model is a mutually exclusive partition because
one sample then advances several goals. `option.detect_overlap` can ask a tool
to diagnose overlapping explicit bins, but the deeper decision is whether the
overlap matches the coverage plan.

## Questions from the commented examples, answered

### What would `illegal_bins unused_a = {2,3};` do?

It declares 2 and 3 to be forbidden sampled values for that coverpoint. A hit is
reported as an illegal-bin event rather than ordinary coverage progress. This
verified stimulus actually includes both 2 and 3, so uncommenting that example
would deliberately produce illegal-bin diagnostics.

Use `illegal_bins` to keep the coverage model honest, but do not treat it as the
only checker for prohibited design behavior. An assertion normally gives a
clearer temporal rule, failure message, and debug location.

### What does `wildcard bins low = {2'b0?};` mean?

In a wildcard bin, `?` is a don't-care bit. The two-bit pattern `0?` matches
`2'b00` and `2'b01`; the least-significant bit may be either value. Because the
active coverpoint `a` is four bits, `4'b000?` would express the intended 0/1
category more clearly in this exact testbench.

### Why are 0, even, odd, and multiple-of-three declared separately?

The predicates for even and odd values explicitly require `item > 0`, so zero
would otherwise belong to neither category. `track_0` gives zero its own goal.
Multiples of three overlap the parity bins because divisibility by three and
parity are different questions.

## The important width correction for `b`

`$urandom()` returns a 32-bit unsigned value, but the assignment target is only
six bits:

~~~systemverilog
btemp = $urandom();
b = btemp;
~~~

The first assignment keeps only the low six bits, so `btemp` and the value later
assigned to `b` are limited to 0–63. Declaring `b` as a 32-bit `int` does not
restore the discarded upper bits. Therefore the declared `bdividedBy5` bins
65, 70, ..., 100 are unreachable with this stimulus. They are model/stimulus
holes, not evidence that the random generator merely “got unlucky.”

To make all 1–100 candidates reachable, generate `b` directly in that range,
for example with `$urandom_range(100, 0)`, or narrow the coverage model to the
actual 0–63 domain if that is the intended contract.

## Reconstructing the verified result

The rerun sampled these deterministic values in Questa:

| Sample | `a` | `b` |
|---:|---:|---:|
| 1 | 4 | 35 |
| 2 | 1 | 50 |
| 3 | 9 | 10 |
| 4 | 3 | 29 |
| 5 | 13 | 56 |
| 6 | 13 | 26 |
| 7 | 5 | 0 |
| 8 | 2 | 44 |
| 9 | 1 | 50 |
| 10 | 13 | 28 |

For `a`, the covered bins are five odd bins (1, 3, 5, 9, 13), two even bins
(2, 4), two multiple-of-three bins (3, 9), and the grouped range bin. Thus 10
of 22 bins are covered:

$$
C_a=\frac{10}{22}\times100=45.45\%.
$$

For `b`, the covered bins are `zero`, 10, 35, and 50. Thus 4 of 21 bins are
covered:

$$
C_b=\frac{4}{21}\times100=19.04\%.
$$

The covergroup metric is the equal-weight average of its two coverpoints:

$$
C_c=\frac{C_a+C_b}{2}=32.25\%.
$$

The report also displays 14 covered bins out of 43 total bins:

$$
\frac{14}{43}\times100=32.56\%.
$$

That raw bin ratio is not the displayed 32.25% covergroup metric because a
covergroup combines child coverpoint scores by their weights. Both coverpoints
have the default weight 1, so a 22-bin child and a 21-bin child contribute
equally instead of every individual bin receiving equal global weight.

## Why `run -all` terminates here

Unlike Part 09's forever clock, this testbench schedules only ten iterations and
one 10 ns delay per iteration. After the loop ends at 100 ns, no process creates
more events. `run -all` can therefore return naturally, and `run.do` prints the
report before `quit -f`. The commented `$finish` is unnecessary and could
prematurely prevent the Tcl-side report in some flows.

The one total warning is Questa's existing `+acc` optimization warning. The
testbench compiles and simulates with zero errors, and the detailed coverage
report itself finishes with zero warnings.

## Revision checks

1. How is a `with` filter different from `iff` sampling?
2. What changes when `bins selected[]` becomes `bins selected`?
3. Which bins increment when `a == 3`, and why?
4. Why can this stimulus never cover `bdividedBy5[100]`?
5. Why is the covergroup metric 32.25% while the raw bin ratio is about 32.56%?
6. What typo must be fixed before uncommenting the first teaching fragment?
7. When should an illegal bin also be backed by an assertion?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [Siemens Questa simulation product page](https://eda.sw.siemens.com/en-US/ic/questa/simulation/)
