# Part 21 — Reusable Covergroup Memory-Range Use Case

[← Part 20](../20-reusable-covergroup-alu-use-case/README.md) · [Functional Coverage index](../README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V089 — Used Cases II |
| Source playground | [`biwn`](https://edaplayground.com/x/biwn) |
| EDA code ID / saved Name | `7382346` / **FC S06 V089 - Memory Range Use Case** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | Low 100%, mid 37.50%, high 75%; type metric 70.83%; 0 source errors or warnings |
| Source warnings | None; the handles are declared at module scope and constructed in `initial` |

## One type, three independently configured address windows

The source creates three instances of `checkAddress`. All three track the same
live four-bit `address` by reference, but each copies different lower/upper
limits and a different report name:

| Instance | Window | Per-value bins |
|---|---:|---|
| `cLow` | 0–3 | `f[0]` through `f[3]` |
| `cMid` | 4–11 | `f[4]` through `f[11]` |
| `cHigh` | 12–15 | `f[12]` through `f[15]` |

Because these windows partition 0–15, each known address sample hits exactly
one instance's bin and is out of range for the other two instances.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 089: reuse one address-window covergroup for three memory regions.
module tb;
  // to check memory range ok
  reg [3:0] address;
  integer i;

  // low is 0 to 3 , mid 4 to 11 , high 12 to 15
  covergroup checkAddress (ref logic [3:0] addressCall, input int lower, input int high, input string instanceName);
    option.per_instance = 1;
    option.name = instanceName;
    coverpoint addressCall {
      bins f[] = {[lower:high]};

    }
  endgroup

  // Declare the reusable covergroup handles at module scope.
  checkAddress cLow;
  checkAddress cMid;
  checkAddress cHigh;

  initial begin
    cLow = new(address, 0, 3, "checking lower range address ");
    cMid = new(address, 4, 11, "checking mid range address ");
    cHigh = new(address, 12, 15, "checking higher range address ");
    for(i = 0; i < 20; i++)begin
      address = $urandom();
      cLow.sample();
      cMid.sample();
      cHigh.sample();
      #10;

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

The repeated run reproduced the earlier saved-tab result exactly:

| Instance / bin | Hits | Covered bins | Result |
|---|---:|---:|---:|
| Low `f[0..3]` | 2, 1, 4, 3 | 4/4 | 100% |
| Mid `f[4..11]` | 0, 0, 0, 0, 2, 1, 2, 0 | 3/8 | 37.50% |
| High `f[12..15]` | 2, 2, 1, 0 | 3/4 | 75% |
| Raw bins | — | 10/16 | 62.50% |
| Questa type metric | — | average of instance percentages | **70.83%** |

The two percentages answer a subtle report question. `10/16 = 62.50%` is the
raw hit ratio shown in the type detail. The displayed 70.83% metric is the
equal-instance average:

~~~text
(100.00% + 37.50% + 75.00%) / 3 = 70.83%
~~~

This matters because instance weighting differs from pooling every bin. The
eight-bin middle window has the same instance weight as either four-bin edge
window.

## Comment and code audit

### “to check memory range”

The model checks whether address values from each configured region were
observed. It does not check memory contents, read/write permissions, data
integrity, alignment, or that the correct slave responds. Those require a
scoreboard/assertions and possibly crosses with operation type.

### “low is 0 to 3, mid 4 to 11, high 12 to 15”

Correct. The ranges are inclusive, non-overlapping, and complete for a four-bit
address. There is no gap and no value belongs to two regions.

### Why use `ref` for `addressCall`?

All instances must observe later assignments to `address`. An `input` formal
would freeze the construction-time value, recreating Part 16's 0% problem.

### Why use `input` for limits and the name?

The limits define the bin structure for each constructed instance, and the
name labels that fixed instance. They are configuration values, not signals to
resample.

### Why does `bins f[]` make individual address bins?

The unsized array distributes `[lower:high]` into one bin per value. Removing
`[]` would create one range bin per region, which would answer only “was this
region visited at least once?” rather than “which addresses in it were seen?”

### Why sample all three instances for every address?

The instances share the same live actual but have different bin domains. Each
call evaluates that instance's own model. Since the windows partition the
domain, one call hits and the other two calls record no bin for that address.

### Why is `#10` present?

Blocking assignment makes the new address immediately visible to manual
sampling, so the delay is not required for coverage correctness here. It
advances time and separates transactions for debugging. If address came from
clocked or combinational DUT logic, sampling should instead align with the
design's valid-data event and scheduling.

## Warning audit and clean declaration pattern

The live V089 repair moves `cLow`, `cMid`, and `cHigh` from initialized
block-local declarations to explicit module-scope handles. Construction stays
procedural in `initial`:

~~~systemverilog
checkAddress cLow, cMid, cHigh;

initial begin
  cLow  = new(address, 0, 3, "checking lower range address ");
  cMid  = new(address, 4, 11, "checking mid range address ");
  cHigh = new(address, 12, 15, "checking higher range address ");
  ...
end
~~~

The fresh run reports zero `vlog` source warnings and zero `vsim` warnings. The
remaining summary warning is Questa's generic `vopt` notice for the saved
`+acc` visibility option; it is not caused by the Section 6 source and does not
affect coverage.

## Deterministic closure option

Twenty random four-bit addresses do not guarantee all sixteen per-value bins.
For deterministic coverage-model closure, drive every value once:

~~~systemverilog
for (int address_value = 0; address_value < 16; address_value++) begin
  address = address_value[3:0];
  cLow.sample();
  cMid.sample();
  cHigh.sample();
end
~~~

That would close the address-value model but still would not prove memory
functionality.

## Revision checks

1. Which constructor formal tracks live storage and which formals configure
   fixed instance structure?
2. Why does each known sample hit exactly one of the three instances?
3. Why are there 4, 8, and 4 bins rather than three total bins?
4. Why does the report show both 62.50% and 70.83%?
5. Why are the covergroup handles declared at module scope but constructed in
   `initial`?
6. What memory behavior remains unchecked even after 100% address coverage?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup constructor and range example](https://accellera.org/images/eda/sv-ec/1826.html)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
