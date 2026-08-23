# Part 01 — Basic Coverpoints

[Functional Coverage home](../../README.md) · [Ordered code index](../README.md) · [All learning tracks](../../../README.md)

## Purpose

This first example separates three ideas that are easy to mix together:

- driving a value does not automatically count it as covered;
- a covergroup without a sampling event must be sampled explicitly;
- a coverpoint on a two-bit integral signal automatically creates one bin for
  each possible value: `00`, `01`, `10`, and `11`.

The DUT simply copies `a` to `b`. The testbench drives ten random values, waits
for the continuous assignment to propagate, calls `ci.sample()`, and then
checks that `b` matches `a`.

## Simulator issue record

This source came from EDA Playground `aaMC`. The Riviera-PRO flow compiled
after a missing semicolon was repaired, but simulation was blocked twice by an
unavailable Aldec license. The same example was then verified locally with
Vivado/XSim 2024.1: `PASS` at 101 ns, 0 DUT errors, and 100% functional
coverage for both coverpoints.

The report-printing problem was later reproduced in EDA Playground
[`Y9rT`](https://edaplayground.com/x/Y9rT) with Questa 2025.2. The page was
trying to open Vivado's nonexistent XCRG text file from a Questa run. Replacing
that file-reader with the tracked [`run.do`](run.do) below and enabling
`-coverage` made Questa print the covergroup, coverpoint, and bin details
directly in the Log. The verified run reported 100% functional coverage, 8/8
bins covered, and 0 errors.

See the top-level [Riviera-PRO incident and Vivado workaround](../../README.md)
for the exact simulator-specific scripts, failure chronology, Questa repair,
XSim path workaround, report commands, and verified output.

## EDA Playground Questa setup

Select **Siemens Questa 2025.2**, enable **Use run.do Tcl file**, and set the
Run Options to:

```text
-coverage -voptargs=+acc=npr
```

The testbench-side file must be named exactly `run.do`:

```tcl
# Run the simulation until all scheduled activity is complete.
run -all;

# Print SystemVerilog covergroup, coverpoint, and bin details
# directly in the Questa transcript/EDA Playground Log.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
```

This verified Part 01 command explicitly includes `-coverage`; preserve it when
reproducing that exact run. Part 09 later demonstrated that EDA Playground's
current Questa `qrun` flow can collect and print covergroup data without the
switch, so `-coverage` must not be described as universal for every invocation.
The existing `+acc` option keeps signal visibility but produces a deprecation
warning in Questa 2025.2; it does not prevent reporting or count as a simulation
error.

## Design

```systemverilog
`timescale 1ns/1ns

module top (
    input  logic [1:0] a,
    output logic [1:0] b
);
    assign b = a;
endmodule
```

Saved source: [`design.sv`](design.sv)

## Testbench

```systemverilog
`timescale 1ns/1ns

module tb;
    logic [1:0] a;
    logic [1:0] b;
    int error_count = 0;

    top dut (
        .a(a),
        .b(b)
    );

    // With no sampling event in the declaration, sample() is called manually.
    // Each 2-bit coverpoint automatically gets one bin per possible value:
    // 00, 01, 10, and 11.
    covergroup cvr_a;
        option.per_instance = 1;
        coverpoint a;
        coverpoint b;
    endgroup

    cvr_a ci = new();

    initial begin
        $timeformat(-9, 0, " ns", 8);
        a = 2'b00;
        #1;

        for (int i = 0; i < 10; i++) begin
            a = $urandom_range(3, 0);

            // Let the continuous assignment update b before sampling both
            // coverpoints and checking the DUT.
            #1;
            ci.sample();

            if (b !== a) begin
                error_count++;
                $error("Mismatch at %0t: a=%b b=%b", $time, a, b);
            end

            $display("sample=%0d time=%0t a=%b b=%b", i + 1, $time, a, b);
            #9;
        end

        if (error_count == 0) begin
            $display("PASS: all 10 samples propagated correctly; functional coverage was sampled.");
        end else begin
            $fatal(1, "FAIL: %0d propagation errors", error_count);
        end

        $finish;
    end
endmodule
```

Saved source: [`testbench.sv`](testbench.sv)

## How the coverage model works

`cvr_a` has no clocking event after its name, so the simulator samples nothing
until the testbench calls `ci.sample()`. The call is deliberately placed after
`#1`: `b` is driven by a continuous assignment and must be allowed to update
before both signals are sampled and compared.

`option.per_instance = 1` asks the simulator to retain coverage for this
particular covergroup instance. It becomes important when several instances
represent different agents, ports, or DUT instances.

Because no explicit bins are declared, the simulator partitions each two-bit
coverpoint into bins for all four values. Ten random samples do not guarantee
100% coverage; a legal value can simply fail to appear. That is a coverage hole
caused by stimulus, not necessarily a DUT failure.

## Reading the result correctly

The final `PASS` message proves only that every sampled output matched the
input. It does **not** prove that all four bins were hit. The coverage report
must be inspected separately to determine which values were observed.

[`run.do`](run.do) runs the Questa simulation and prints its native functional-
coverage report directly in the Log. [`print-coverage-report.tcl`](print-coverage-report.tcl)
is the separate Vivado/XSim helper that prints an XCRG text report only after
XCRG has generated it. Simulator databases, logs, and compiled files are
intentionally ignored by Git.

## Points to remember

- Coverage is updated only at the covergroup's sampling event.
- Sample stable, meaningful values—not values racing through a delta cycle.
- A passing self-check and 100% functional coverage answer different questions.
- Random stimulus can leave holes; first classify the hole before changing the
  model or adding stimulus.
