# Part 06 — Default Bins for Unused Values

[← Part 05](../05-explicit-bins-and-fixed-bin-arrays/README.md) · [Functional Coverage index](../README.md) · [Part 07 →](../07-multiplexer-signal-coverpoints/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [HU_T](https://edaplayground.com/x/HU_T) |
| EDA code ID | `7380503` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass at time 0; 0/10 scored bins covered |

The design pane for `HU_T` contains only EDA Playground's placeholder. Later
completed playgrounds continue as Parts 07–10. Intermediate `Kd8_` remains an
unarchived FSM draft; a new unsaved blank playground is now the current page.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
// to analyze the unused  value sent to dut
// default bin : implicit , i.e single if< 64 or multiple hit per bin based on the range beyond 64

// explicit bins : array , individual , range
module tb;
  reg [3:0] a;
  integer i =0 ;
  covergroup c;
    option.per_instance = 1;
    coverpoint a {
      bins a_values[] = {[0:9]};
      bins a_unused = default ;

    }
  endgroup
  c cin = new() ;

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

## The two active bin declarations

`a` is four bits wide, so its known value domain is 0 through 15.

~~~systemverilog
bins a_values[] = {[0:9]};
~~~

The unsized bin-array suffix `[]` creates ten separate regular bins—one for
each value from 0 through 9.

~~~systemverilog
bins a_unused = default;
~~~

This explicitly declares one catch-all default bin. For known four-bit values,
it receives values 10 through 15 because those values are not included in
`a_values`.

| Sampled known value | Matching bin |
|---:|---|
| 0–9 | One corresponding `a_values[n]` bin |
| 10–15 | The single `a_unused` default bin |

The source comment calling the default bin “implicit” is incorrect. The bin is
explicitly declared and named. Its **contents** are implicit: the language
derives them as the remaining values not claimed by the other value bins.

## Why the default bin does not close coverage

A default bin is useful for diagnosing values outside the modeled set, but it
is excluded from the coverpoint's coverage calculation. It is also not used to
create cross-product bins. Here the percentage denominator is the ten regular
`a_values` bins—not eleven bins.

That distinction is deliberate. If one sample of value 12 could mark a broad
catch-all bin as “covered” progress, the report could reward behavior outside
the intended 0–9 space. Instead, `a_unused` records that such behavior occurred
without weakening the ten-bin goal.

Choose the bin kind from the requirement:

| Requirement meaning | Suitable construct |
|---|---|
| Values 10–15 are possible and should be observed diagnostically | `bins ... = default` |
| Values 10–15 are irrelevant to this coverage question | `ignore_bins` with a justified range |
| Values 10–15 must never occur | Usually an assertion/checker; an `illegal_bins` report may supplement it |

A default bin is not automatically an error bin. It counts occurrences; it
does not fail the simulation.

## Why the verified result is 0%

The testbench constructs `cin`, but it declares neither a covergroup sampling
event nor an explicit call to `cin.sample()`. It also has no stimulus process.
Construction allocates the coverage object; it does not sample it.

XSim therefore reaches quiescence at time 0 and reports:

| Item | Result |
|---|---:|
| Covergroup instances | 1 |
| Scored user-defined bins | 10 |
| Covered scored bins | 0 |
| Coverage | 0% |

The unused `integer i` changes nothing. No loop exists, `a` is never driven,
and no sampling event occurs.

This is a valuable negative result: a syntactically correct coverage model can
compile perfectly and still collect no data. Always trace the full lifecycle:

1. declare the covergroup type;
2. construct an instance;
3. drive or observe a meaningful value;
4. sample at a defined event;
5. inspect the report.

This source performs steps 1 and 2 only.

## Minimal deterministic experiment

The captured source remains unchanged. To exercise the model in a separate
experiment, add stimulus and explicit sampling after `cin` is constructed:

~~~systemverilog
initial begin
  for (int value = 0; value < 16; value++) begin
    a = value[3:0];
    cin.sample();
  end
  $finish;
end
~~~

That loop would hit every one of the ten scored `a_values` bins and would also
hit `a_unused` six times. The scored coverage would be 100%, while the default
bin's count would separately reveal the six outside-set samples. Whether those
six samples are acceptable must come from the specification, not the percentage.

## Questions from the source, answered

### Does `default` create one bin for each unused value?

Not in the active declaration. `bins a_unused = default` is a single bin that
catches all unmatched values. It is different from an unsized array of bins.

### Why does XCRG list only ten expected bins?

The ten `a_values` bins contribute to the score. The default catch-all is
excluded from that denominator, so the report's expected/covered table shows
10 scored bins.

### Would assigning `a` be enough to collect coverage?

No. With no sampling event in the covergroup declaration, an assignment alone
does not update coverage. The testbench must call `cin.sample()`.

### Is an unused-value hit necessarily a DUT bug?

No. It may be a legal but uninteresting value, a stimulus mistake, an invalid
state, or evidence that the coverage model's intended range is wrong. The
requirement decides which interpretation is correct.

## Revision checks

1. How many scored bins does `a_values[] = {[0:9]}` create?
2. Which known values enter `a_unused`?
3. Why is the default bin absent from the 10-bin denominator?
4. What exact lifecycle step is missing from this testbench?
5. When should a checker replace a default bin?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera default-bin semantics discussion](https://www.accellera.org/images/eda/sv-ec/2235.html)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
