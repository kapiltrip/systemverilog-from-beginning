# Part 09 — FSM State Coverage and Report Timing

[← Part 08](../08-enumerated-state-coverpoint/README.md) · [Functional Coverage index](../README.md) · [Part 10 →](../10-with-filtered-and-overlapping-bins/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | FSM Coverage Report - Fixed Timing and Finish |
| Stable playground | [FU8E](https://edaplayground.com/x/FU8E) |
| EDA code ID | `7380862` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; finite 200 ns run, detailed covergroup report, then `quit -f` |
| Verified browser result | 100%: named `state` coverpoint, 2/2 enum bins, 0 compile/simulation errors |

The next completed playground, [`Ztfn`](https://edaplayground.com/x/Ztfn), is
archived as Part 10; the ordered archive later continues through Part 13.
Newest playground [`rzC3`](https://edaplayground.com/x/rzC3) remains excluded.

## Exact saved testbench

~~~systemverilog
// FSM coverage repair note:
// The coverpoint label was accidentally split across lines as `stat` and `e:`.
// Questa then reported a syntax error near `e`, followed by a cascading
// "Undefined variable: ci" error because the covergroup declaration did not parse.
// Fix: keep the label as one token: `state: coverpoint dut.state;`.
// The custom run.do also runs for 200 ns before printing coverage and quitting,
// so the forever clock/sampler cannot block the report and no early $finish can skip it.
module tb;
  reg x = 0;
  reg rst = 0;
  reg clk = 0;
  wire y;

  fsm dut (x, clk, rst, y);

  always #5 clk = ~clk;

  initial begin
    rst = 1;
    #30;
    rst = 0;
    #40;
    x = 1;
    #10;
    x = 0;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  covergroup c;
    option.per_instance = 1;
    // Keep the label as one token so the report names this coverpoint state.
    state: coverpoint dut.state;
  endgroup

  c ci;
  initial begin
    ci = new();
    forever begin
      @(posedge clk);
      ci.sample();
    end
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact saved FSM design

~~~systemverilog
// Code your design here
// mealy fsm
module fsm(
  input wire x,clk ,rst,
  output reg y
);
  typedef enum bit {
    s0= 1'b0,
    s1=1'b1
  } state_t;
  state_t state, next_state;

  always_ff @(posedge clk or posedge rst) begin
    if(rst)
      state <= s0;
    else
      state <= next_state;
  end

  always_comb begin
    next_state = s0;
    y=1'b0;
    case (state)
      s0: begin
        if(x)begin
          next_state = s1;
          y=1'b1;
        end else begin
          next_state = s0;
        end
      end
      s1: begin
        if(x)begin
          y=1'b1;
          next_state = s0;
        end else begin
          next_state = s1;
        end
      end
      default: next_state = s0;
    endcase
  end
endmodule
~~~

Local source: [design.sv](design.sv).

## Exact saved `run.do`

~~~tcl
# Run for a finite duration so the forever clock/sampler cannot hang.
run 200ns;

# Print SystemVerilog covergroup, coverpoint, and bin details.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do).

## What broke, and why the second error was misleading

The coverpoint declaration must use one identifier followed by a colon:

~~~systemverilog
state: coverpoint dut.state;
~~~

The saved editor text was accidentally split into `stat` and `e:` on separate
lines. Questa stopped parsing the covergroup at `e` and reported:

~~~text
testbench.sv(32): near "e": syntax error, unexpected IDENTIFIER, expecting ':'
~~~

It then reported `Undefined variable: 'ci'`. That was a cascading parser error,
not a separate construction bug. Because the malformed covergroup prevented the
later declarations from being understood correctly, the simulator could not
resolve `ci = new()`. Repair the earliest syntax error first; later name errors
often disappear automatically, as they did here.

The label is not cosmetic. It makes the detailed report say `Coverpoint state`
instead of assigning an anonymous generated name, so the report remains tied to
the design concept being measured.

## Why the report now prints reliably

The clock and sampler are both infinite processes. Therefore `run -all` would
never naturally return: each clock edge schedules another future clock edge.
The script instead owns the simulation endpoint:

1. `run 200ns` advances through exactly 20 rising clock edges;
2. `coverage report -cvg -details` reads the populated covergroup database;
3. `quit -f` closes the batch simulator after the report is printed.

There is deliberately no testbench `$finish`. An early `$finish` could end the
simulator before the Tcl script reaches its report command. Keeping termination
in `run.do` gives the finite run, report, and exit one explicit order.

## Reconstructing the 8/12 bin counts

The 10 ns clock has positive edges at 5, 15, ..., 195 ns. Reset holds the FSM in
`s0` until 30 ns, and `x` remains zero until 70 ns. At the 75 ns edge, the DUT
schedules the `s0 → s1` state update with a nonblocking assignment. The explicit
`ci.sample()` executes in the active region and therefore still observes the
pre-NBA value `s0` at that edge.

| Sample edges | State seen by coverage | Hits |
|---|---|---:|
| 5–65 ns | `s0` | 7 |
| 75 ns | old `s0`, before the NBA update becomes visible | 1 |
| 85–195 ns | `s1` | 12 |
| **Total** | both enum states | **20** |

The verified Questa report therefore contains:

| Bin | Hit count | Status |
|---|---:|---|
| `auto[s0]` | 8 | Covered |
| `auto[s1]` | 12 | Covered |

Both bins are covered, so the state coverpoint and covergroup report 100%.
If the coverage intent were specifically to observe the post-update state at
each rising edge, a monitor should sample in a later region or at a stable edge,
for example through a clocking block. The present source is preserved because
the observed pre-NBA timing is part of this lesson.

## What 100% does and does not prove

This coverpoint proves that both encoded states were sampled. It does not prove:

- that every legal transition occurred;
- that an illegal transition can never occur;
- that Mealy output `y` is correct for every state/input combination;
- that reset timing is correct; or
- that the state was sampled after, rather than before, each NBA update.

Transition bins can measure required arcs, crosses can relate `state`, `x`, and
`y`, and assertions can reject illegal behavior. State occupancy is one layer of
an FSM verification plan, not the entire plan.

## Questa option evidence

This saved page used only `-voptargs=+acc=npr` in Run Options yet its Questa
2025.2 `qrun` flow printed complete covergroup and enum-bin data. That observed
result means the earlier blanket statement that EDA Playground always needs an
explicit `-coverage` switch for covergroups was too broad. Part 01 retains the
exact `-coverage` command that was verified there; Part 09 records that this
newer qrun invocation collected covergroup coverage without it.

The only run warning is `vopt-10587`, which says `+acc` disables some
optimizations and may be deprecated in favor of newer access/debug controls. It
does not change the coverage result: compilation and simulation both finish
with zero errors, and the coverage report itself has zero warnings.

## Revision checks

1. Why did the undefined-`ci` error disappear when only the label was repaired?
2. Why would `run -all` hang with this testbench even after all stimulus ends?
3. Why can an early `$finish` prevent a Tcl-side coverage report from printing?
4. Why does the 75 ns sample count toward `s0` rather than `s1`?
5. What additional model would prove that only legal FSM transitions occurred?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [Siemens Questa command reference landing page](https://eda.sw.siemens.com/en-US/ic/questa/simulation/)
