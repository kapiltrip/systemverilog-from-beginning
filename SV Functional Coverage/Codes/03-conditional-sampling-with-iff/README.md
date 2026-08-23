# Part 03 — Conditional Sampling with `iff`

[← Part 02](../02-instance-type-goals-and-weights/README.md) · [Functional Coverage index](../README.md) · [Part 04 →](../04-automatic-bins-and-auto-bin-max/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [jq_V](https://edaplayground.com/x/jq_V) |
| EDA code ID | `7380397` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; 4/4 bins covered from 7 accepted samples |

The design pane is placeholder-only and is omitted locally. The exact captured
testbench is intentionally not repaired; the discussion identifies the reversed
comment and the reset-boundary race.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb ;
  reg [1:0] a =0;
  reg rst =0;
  integer i =0;
  initial begin
    rst =1;
    #30;
    rst =0 ;

  end
  covergroup c ;
    option.per_instance =1 ;
    coverpoint a iff(!rst); // all value of sample where rst low will not be taken
  endgroup

  initial begin
    c ci = new();
    for(i =0 ; i< 10 ; i++)begin
      a = $urandom();
      ci.sample(); // tell cover group to sample the value of a so that we could calculate the coverage
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

## What `iff (!rst)` actually means

The `iff` expression is a guard evaluated whenever the coverpoint is sampled.
For this declaration:

~~~systemverilog
coverpoint a iff (!rst);
~~~

- when `rst == 0`, `!rst` is true and the current value of `a` is counted;
- when `rst == 1`, `!rst` is false and this coverpoint ignores that sampling
  attempt;
- an ignored attempt is not queued for later and does not increment any bin.

The source comment says low-reset samples “will not be taken.” That is reversed.
Low reset is exactly when samples **are** taken. The likely intent is: ignore
stimulus while reset is asserted high.

`ci.sample()` is still called on every loop iteration. `iff` controls whether
this particular coverpoint accepts each call; it does not prevent the method
call itself.

## Timeline of the saved source

The stimulus thread assigns and samples at 0, 10, 20, ..., 90 time units. The
reset thread asserts `rst` at time 0 and deasserts it at time 30.

| Time | Intended `rst` state | Intended coverage effect |
|---:|---:|---|
| 0 | 1 | Intended ignore, but this boundary is racy in the saved source |
| 10 | 1 | Ignore |
| 20 | 1 | Ignore |
| 30 | 0 | Accept, but this boundary is racy in the saved source |
| 40–90 | 0 | Accept six more samples |

XSim accepted seven samples total. Its four bin hit counts were 2, 1, 1, and
3, which sum to 7 and yielded 100% coverage. That result demonstrates the guard,
but it does not by itself identify which boundary samples were accepted.

## The races at times 0 and 30

The declaration initializer gives `rst` the value 0 before the explicit
processes begin. At time 0, two separate `initial` processes can then run in the
Active region: one assigns `rst = 1`, while the other assigns `a` and calls
`ci.sample()`. The sample can therefore see either the initialized 0 or the new
1 depending on process ordering.

At time 30, the same two processes again become runnable in the Active region:

1. the reset process executes `rst = 0`;
2. the stimulus process executes `a = $urandom()` and `ci.sample()`.

SystemVerilog does not guarantee an ordering between those independent Active-
region processes. If reset executes first, the time-30 sample is accepted. If
sampling executes first, it sees `rst == 1` and is ignored. The total of seven
accepted samples proves that exactly one of the two boundary samples was
accepted, but it cannot prove which one: XSim could accept time 0 and reject
time 30, or reject time 0 and accept time 30. An instrumented trace is needed
to identify the individual accepted attempt.

A deterministic learning version should avoid putting reset deassertion on the
same time slot as a sample. For example, deassert at time 25, or drive reset on
one clock edge and sample through a clocking block/monitor on a defined later
phase. The captured file is left unchanged so the race remains visible as part
of the lesson.

## Why `iff` is not a reset mechanism

`iff` gates coverage collection; it does not reset the covergroup database.
Bins hit before reset remain hit. If a later reset pulse occurs, samples during
that pulse are ignored, but earlier counts are not erased.

It also does not verify reset behavior. If the requirement says the DUT output
must clear during reset, that needs a scoreboard or assertion. Coverage can
record which values were observed outside reset, but it cannot prove that the
DUT behaved correctly.

## Construction and lifetime note

`c ci = new();` constructs the covergroup inside an `initial` block before the
loop. Vivado warns that `ci` should be declared explicitly `automatic` or
`static`, but compilation and simulation succeed. Declaring lifetime explicitly
would make the intent clearer; it would not change the `iff` rule.

The final loop delay ends at time 100. With no further scheduled activity,
`run -all` exits by quiescence even though the testbench never calls `$finish`.

## Questions from the source, answered

### Does `sample()` calculate the final coverage percentage immediately?

It evaluates the covergroup at that instant and updates matching bin counts.
The simulator/reporting tool later derives percentages from those counts. A
sample can match an already covered bin, so another call need not increase the
percentage.

### Why are there seven accepted samples but only four covered bins?

`a` is two bits wide, so it has four automatic bins. Several accepted samples
repeat values and increment existing bin hit counts. Coverage measures distinct
required bins reached, not simply the number of calls.

### Should reset be in the coverpoint expression instead?

No. Making `{rst,a}` one combined expression would create bins for reset-state
combinations rather than exclude invalid sampling windows. Use `iff` when the
requirement says the coverpoint is meaningful only under a condition. Add a
separate reset coverpoint only if reset scenarios themselves are part of the
coverage plan.

## Revision checks

1. Which reset level makes `iff (!rst)` true?
2. Do ignored samples get counted after reset deasserts?
3. Why are the time-0 and time-30 samples nondeterministic in the language model?
4. Why can the 7-hit total not identify which boundary sample was accepted?
5. Why does 100% functional coverage not prove correct reset behavior?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
