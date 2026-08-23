# Part 13 — Illegal-Bin Precedence and Report Timing

[← Part 12](../12-ignore-bins-and-domain-closure/README.md) · [Functional Coverage index](../README.md) · [Part 14 →](../14-wildcard-bins-casez-and-casex/README.md)

| Playground field | Value |
|---|---|
| Saved playground | [grxa](https://edaplayground.com/x/grxa) |
| EDA code ID | `7381590` |
| Saved Name | Blank |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; finite 200 ns run, report, then `quit -f` |
| Verified report | 5/5 scored bins, 100%; three intentional illegal-bin hits |

The source spelling `precidence` is preserved; the intended word is
“precedence.” The placeholder design pane is omitted and redundant blank lines
retain their editor positions with whitespace-only indentation normalized.

## Complete saved testbench

~~~systemverilog
module tb;

  reg [2:0] a;

  covergroup c;
    option.per_instance  = 1;
    coverpoint a {

      bins a_Valid[] = {[0:5]};
      illegal_bins a_invalid[] = {[5:7]}; // illegal bins have precidence


    }



  endgroup


  c ci;

  initial begin
     ci = new();



    for (int i = 0; i <15; i++) begin
      a = $urandom();
      ci.sample();
      #10;
    end


  end




  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    #400;
    $finish();
  end





endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact saved `run.do`

~~~tcl
# Run through all 15 samples, but stop before the testbench's later $finish.
run 200ns;

# Print SystemVerilog covergroup, coverpoint, and bin details
# after the covergroup has been constructed and sampled.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do).

## Why the report originally said no data

The previous `run.do` had `run -all` commented out. Tcl therefore executed
`coverage report` at simulation time 0, before the initial block constructed
`ci` and before any call to `ci.sample()`. Questa correctly reported “No
matching coverage data found.” Compilation success alone does not create
runtime covergroup data.

Uncommenting `run -all` is also wrong for this exact testbench. The delayed
`$finish` at 400 ns ends the simulator while Tcl is still inside `run -all`, so
the later report command may never execute. The repaired script runs to 200 ns:
all 15 samples finish by 150 ns, the 400 ns `$finish` has not fired, and Tcl can
print the report before quitting cleanly.

## Why only five ordinary bins are scored

The declarations overlap at value 5:

~~~systemverilog
bins a_Valid[] = {[0:5]};
illegal_bins a_invalid[] = {[5:7]};
~~~

Illegal-bin classification takes precedence for the overlapping value. Thus 5
is not an ordinary scored bin; the five scored legal bins correspond to 0–4.
This is why the verified report shows 5/5 rather than 6/6.

This overlap demonstrates a tool rule, but it is clearer coverage-model style
to declare the intended legal and illegal sets without overlap:

~~~systemverilog
bins a_valid[] = {[0:4]};
illegal_bins a_invalid[] = {[5:7]};
~~~

## Why 100% does not mean the test passed

The saved run covered all five ordinary bins, so the coverage metric is 100%.
It also sampled an illegal value three times, and Questa reported three
simulation errors. Coverage closure answers “did every scored legal goal
occur?” Illegal bins answer “did forbidden behavior occur?” A verification run
must satisfy both conditions.

For a positive-only test, constrain `a` to 0–4. To verify illegal-bin handling,
use a deliberate negative test and mark the expected diagnostics separately;
do not treat a red simulator summary as an ordinary passing regression.

## Timeline of the repaired flow

| Time | Event |
|---:|---|
| 0 ns | Construct `ci`, generate the first value, and sample it |
| 10–140 ns | Generate and sample the remaining fourteen values |
| 150 ns | Stimulus loop finishes |
| 200 ns | Tcl regains control and prints detailed coverage |
| 400 ns | The scheduled `$finish` would occur, but `quit -f` has already ended the run |

The existing `+acc` optimization warning is unrelated to covergroup reporting.
The important result is that the report is now generated after sampling and
before the HDL-side termination.

## Revision checks

1. Why did reporting at time 0 find no coverage data?
2. Why can `$finish` prevent a command after `run -all` from executing?
3. Which declaration owns overlapping value 5?
4. Why are there five scored bins instead of six?
5. Can a run with 100% coverage still fail verification?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground custom run options](https://eda-playground.readthedocs.io/en/latest/settings.html)
