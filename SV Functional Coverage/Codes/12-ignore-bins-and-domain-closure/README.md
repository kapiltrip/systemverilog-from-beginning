# Part 12 — Ignore Bins and Domain Closure

[← Part 11](../11-legal-illegal-and-out-of-domain-opcode-bins/README.md) · [Functional Coverage index](../README.md) · [Part 13 →](../13-illegal-bin-precedence-and-report-timing/README.md)

| Playground field | Value |
|---|---|
| Saved playground | [cNZW](https://edaplayground.com/x/cNZW) |
| EDA code ID | `7381556` |
| Saved Name | Blank |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; `run -all`, detailed report, then `quit -f` |
| Verified result | 77/77 scored bins, 100%; 0 compile/simulation errors |

This is the saved repair of the width and stimulus problem visible in the
original lesson. The design pane is only a placeholder and is omitted.

## Complete saved testbench

~~~systemverilog
// 8-bit signal: wide enough to represent every value in [1:100].
// Ignore 23, 45, 67, 89, 93 and the four unused ranges below.
module tb;
  reg [7:0] a;
  integer i = 0;

  covergroup c;
    option.per_instance = 0;
    coverpoint a {
      bins value_a[] = {[1:100]};
      ignore_bins unused_a_ignored[] = {23, 45, 67, 89, 93};
      ignore_bins unused_range_1[] = {[3:7]};
      ignore_bins unused_range_2[] = {[32:36]};
      ignore_bins unused_range_3[] = {[47:50]};
      ignore_bins unused_range_4[] = {[61:64]};
    }
  endgroup

  c ci;

  initial begin
    ci = new();

    // Visit the complete declared domain once. Ignored values are not scored.
    for (i = 1; i <= 100; i++) begin
      a = i;
      ci.sample();
      #1;
    end
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

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

## The original failure and the repair

The original signal was `reg [5:0] a`, whose maximum value is 63, while the
coverage model requested bins through 100. Questa therefore bounded the model
to 63 and warned that 64–100 were outside the coverpoint domain. Ten random
samples then covered only 6 of 45 scored bins, producing 13.33%.

The saved repair changes `a` to eight bits and deterministically samples every
value from 1 through 100. It also fixes the single-value typo from 3 to 23 so
the code agrees with its teaching comment. This makes the declared domain and
stimulus intent explicit instead of relying on random luck.

## How ignore bins change the denominator

`value_a[]` initially proposes 100 individual bins. The ignore declarations
remove these 23 unique values from scoring:

- five single values: 23, 45, 67, 89, and 93;
- five values in 3–7;
- five values in 32–36;
- four values in 47–50;
- four values in 61–64.

Therefore the number of scored bins is

$$
100-(5+5+5+4+4)=77.
$$

The sweep samples all 100 values. Hits in ignored values may be shown as
occurrences in a detailed report, but they neither help nor hurt the 77-bin
coverage score. Every non-ignored value is sampled once, so the result is
77/77 and 100%.

## Ignore bins versus illegal bins

An ignored value is intentionally outside the current coverage plan. Sampling
it is allowed and it is removed from the coverage denominator. An illegal
value represents forbidden behavior; sampling it produces a diagnostic and
should normally fail the test.

Do not use `ignore_bins` merely to hide coverage holes. Each ignored value
should trace to a requirement explaining why it is irrelevant or reserved.

## Why `option.per_instance = 0` does not block the report

This option disables separate per-instance scoring as a coverage-model choice;
it does not disable the covergroup or its type-level data. There is only one
instance, `ci`, so the essential 77/77 result is unchanged. Set it to 1 when
separate statistics for multiple instances are required.

## Why `run -all` is correct here

This testbench has no forever clock. The loop schedules exactly 100 one-nanosecond
delays and then ends. Once no events remain, `run -all` returns, the Tcl script
prints the detailed report, and `quit -f` closes the batch simulator. The saved
rerun reported only the existing `+acc` optimization warning outside simulation;
compile and simulation completed without errors.

## Revision checks

1. Why could a six-bit variable never close bins 64–100?
2. How many unique values are ignored, and why are 77 bins scored?
3. Does sampling an ignored value count as an error?
4. Why is deterministic iteration better than ten random draws for closure?
5. When would `option.per_instance = 1` matter?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground custom run options](https://eda-playground.readthedocs.io/en/latest/settings.html)
