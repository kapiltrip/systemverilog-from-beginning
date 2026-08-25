# Part 26 — User-Defined `sample()` Inside a Property

[← Part 25](../25-user-defined-sample-in-function/README.md) · [Functional Coverage index](../README.md)

| Field | Value |
|---|---|
| Course lesson | Section 7, V100 — User-Defined Sample Method Inside a Property Block |
| Source playground | [`hfW3`](https://edaplayground.com/x/hfW3) |
| EDA code ID / saved Name | `7382357` / **FC S07 V100 - User sample() in Property** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | `lower`, `mid`, and `high` each hit once; 3/3 bins, 100%; assertion successes at 25, 45, and 65 ns |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps
// to cover all the ranges during reading as well , ok

// Video 100: call user-defined sample() from a property sequence match item.
module tb;
  reg rd = 0, wr = 0;
  reg clk = 0;
  reg [4:0] addr;
  reg [7:0] din;
  reg [7:0] dout;

  initial repeat (50) #5 clk = ~clk;
  covergroup c with function sample (reg [4:0] addrIn);  // is sample user defined ?
    option.per_instance = 1;
    coverpoint addrIn{
      bins lower = {[0:7]};
      bins mid = {[15:20]};
      bins high = {[27:31]};
    }
  endgroup
  c ci;
  initial begin
    ci = new();
    @(posedge clk);  // write
    addr = 3;
    wr = 1;
    rd = 0;
    din = 12;
    @(posedge clk);
    wr = 0;
    rd = 1;
    addr = 3;
    dout = 12;
    @(posedge clk); //
    addr = 17;
    wr = 1;
    rd = 0;
    din = 21;
    @(posedge clk);
    wr = 0;
    rd = 1;
    addr = 17;
    dout = 21;
    @(posedge clk); //28
    addr = 28;
    wr = 1;
    rd = 0;
    din = 67;
    @(posedge clk);
    wr = 0;
    rd = 1;
    dout = 67;
    addr = 28;

  end


  property p1;
    bit [4:0] addrs;
    bit [7:0] dvariable;
    @(posedge clk) (wr |-> (wr, addrs = addr, dvariable = din, ci.sample(addrs)) ##[1:50] rd [*1:50] ##0 (addrs == addr) ##0 (dout == dvariable));
    // what is this wr
  endproperty
    a1: assert property (p1) $info("success at %0t", $time);

    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      $assertvacuousoff(0);
      //#500;
      //$finish ();

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

| Coverage bin | Range | Hits | Status |
|---|---:|---:|---|
| `lower` | 0–7 | 1 | Covered |
| `mid` | 15–20 | 1 | Covered |
| `high` | 27–31 | 1 | Covered |
| Total | Three selected regions | 3/3 | **100%** |

The assertion action block printed success at 25, 45, and 65 ns. `qrun`,
`vlog`, and `vsim` reported zero errors and zero source warnings. The one
summary warning is the saved `+acc` optimization notice.

## Is `sample()` user-defined here?

Yes. The declaration

~~~systemverilog
covergroup c with function sample (reg [4:0] addrIn);
~~~

defines the signature accepted by `ci.sample(addrs)`. The coverpoint observes
the formal `addrIn`, so a property thread can pass its captured address instead
of relying on whichever value the module-level `addr` happens to contain later.

The corrected video comment says “property sequence match item.” The call is
inside the comma-separated match-item list `(wr, addrs = addr, ...,
ci.sample(addrs))`. It is not inside the assertion pass action block. The pass
action block is the later `$info(...)` statement.

## What is the first `wr` in the property?

The source question points to the antecedent of the overlapping implication:

~~~systemverilog
wr |-> (...)
~~~

At every `posedge clk`, a property attempt begins. If sampled `wr` is zero, the
implication passes vacuously and starts no write/read check. If sampled `wr` is
one, the consequent starts in that same sampled cycle because `|->` is
overlapping. The second `wr` inside the consequent is redundant here—it is
already known true from the antecedent—but it makes the write-cycle condition
visible inside the match-item group.

## Property-local snapshots

`addrs` and `dvariable` are local to each concurrent property attempt. When a
write is observed, the comma-separated match items copy the sampled `addr` and
`din` into those local variables and call `ci.sample(addrs)`. Later read cycles
are compared against the same attempt's captured values, even if another
attempt exists concurrently.

The remaining sequence means:

- `##[1:50]`: wait between 1 and 50 clock ticks;
- `rd[*1:50]`: require `rd` on 1 through 50 consecutive sampled clocks;
- `##0 (addrs == addr)`: on the final repeated-read clock, require the address
  to equal the captured write address;
- `##0 (dout == dvariable)`: on that same clock, require read data to equal the
  captured write data.

Because repetition and delay ranges can create multiple matching threads, this
form is more permissive and potentially more expensive than a tightly bounded
single-read protocol property. If the intended protocol has one response,
replace the broad ranges with its actual latency and pulse rules.

## Scheduling timeline

The procedural stimulus assigns values immediately after each positive-edge
event. Concurrent assertions sample in the preponed region, so an assignment
made at an edge becomes visible to the property on the next edge:

| Edge | Procedural action after edge | Property sees before action | Result |
|---:|---|---|---|
| 5 ns | Drive write at address 3/data 12 | Initial `wr = 0` | Vacuous |
| 15 ns | Drive matching read | Write at 3/12 | Sample `lower` |
| 25 ns | Drive write at 17/21 | Read at 3/12 | First assertion success |
| 35 ns | Drive matching read | Write at 17/21 | Sample `mid` |
| 45 ns | Drive write at 28/67 | Read at 17/21 | Second assertion success |
| 55 ns | Drive matching read | Write at 28/67 | Sample `high` |
| 65 ns | No new stimulus | Read at 28/67 | Third assertion success |

This timing reconstructs both the three one-hit coverage bins and the three
`$info` messages.

## Does this cover “all ranges during reading”?

Only indirectly. `ci.sample(addrs)` executes when a write antecedent is
recognized, before the later read has proved successful. The assertion then
checks that a matching read arrives, but a coverage hit is not rolled back if
that later check fails. Therefore the model covers write addresses that launch
property attempts, while the assertion separately verifies the readback.

If the requirement is coverage only for successfully matched readbacks, move
the sampling side effect to the final successful sequence element or publish a
completed transaction from a monitor and sample there. Keep the assertion and
coverage goals conceptually separate: assertion pass/fail is correctness
evidence; covergroup closure is scenario-observation evidence.

## Other source comments

- `// write` correctly labels the first transaction setup, but because of
  preponed sampling the property recognizes it one clock later.
- `//28` identifies the high-range test value. Address 28 lies in `[27:31]`.
- the bare `//` carries no information and is preserved only as source history.
- the commented `$finish` is unnecessary because the 50-half-cycle clock is
  finite; after 250 ns the event queue drains and `run -all` returns.

## Revision checks

1. Which `sample()` declaration makes `addrIn` an explicit method argument?
2. Why does the property detect the write one edge after procedural stimulus?
3. What does overlapping `|->` change compared with `|=>`?
4. Why can coverage be recorded even if the later readback fails?
5. Which evidence comes from the covergroup and which comes from the assertion?
6. Why do the three successful attempts print at 25, 45, and 65 ns?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
