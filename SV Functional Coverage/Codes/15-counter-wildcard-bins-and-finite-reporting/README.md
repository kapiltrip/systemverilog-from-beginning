# Part 15 — Counter Wildcard Bins and Finite Reporting

[← Part 14](../14-wildcard-bins-casez-and-casex/README.md) · [Functional Coverage index](../README.md)

| Field | Value |
|---|---|
| Source playground | [`fTK4`](https://edaplayground.com/x/fTK4) |
| EDA code ID | `7382217` |
| Language / simulator | SystemVerilog / Siemens Questa 2025.2 |
| Compile options | `-timescale 1ns/1ns` |
| Run options | `-voptargs=+acc=npr` |
| Custom Tcl | **Use run.do Tcl file** enabled |
| Verified result | 4/4 bins, 100%; 0 compile/simulation errors |

## What was broken

The page compiled, but its coverage report did not appear. **Use run.do Tcl
file** was disabled, so the earlier run used qrun's default `run -all` command
while the testbench generated a clock forever:

~~~systemverilog
always #5 clk = ~clk;
~~~

Because the event queue could never become empty, `run -all` never returned.
The saved custom script—which contained the coverage-report command—was not
active at all. EDA Playground eventually terminated the job and reported exit
status 137. Its old 100 ns custom window would have printed a partial report if
enabled, but it ended before the intended 200 ns count, reset, and second-count
phases completed.

Two source problems also prevented meaningful coverage even if a report had
been printed:

~~~systemverilog
wire [3:0] y = 0;
...
initial begin
  en = 1;
~~~

For a net, the declaration assignment is a continuous driver. The DUT was a
second driver of `y`, so any DUT 1 conflicted with the testbench's permanent 0
and resolved to X. In addition, `en` changed to 1 at time 0, before any rising
edge could execute the `!en` reset branch. The DUT register therefore began at
X, and `X + 1` remained X.

The saved repair:

1. removes the testbench's permanent zero driver from `y`;
2. holds `en = 0` across two rising edges so the counter becomes known;
3. enables the custom `run.do`;
4. uses a finite `run 450ns` window before printing the report.

## Exact saved testbench

~~~systemverilog
// Counter coverage with wildcard bins
module tb;
  reg clk = 0;
  reg en = 0;
  wire [3:0] y;

  counter dut (clk, en, y);

  always #5 clk = ~clk;

  initial begin
    // Hold reset active across two rising edges so y becomes known.
    en = 0;
    #20;

    // Exercise every enabled counter range.
    en = 1;
    #200;

    // Exercise the disabled/zero bin, then count again.
    en = 0;
    #20;
    en = 1;
  end

  covergroup c @(posedge clk);
    option.per_instance = 1;

    coverpoint {en, y} {
      bins count_off = {5'b00000};
      wildcard bins countLow  = {5'b100??}; // enabled, count 0 to 3
      wildcard bins countMid  = {5'b101??}; // enabled, count 4 to 7
      wildcard bins countHigh = {5'b11???}; // enabled, count 8 to 15
    }
  endgroup

  c ci;

  initial begin
    ci = new();
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Exact saved design

~~~systemverilog
// Code your design here
module counter(
  input clk , en ,
  output reg [3:0] y
);

  always_ff @(posedge clk ) begin
    if(!en)begin
      y<= 4'd0;
    end else
      y<= y+ 4'd1;

  end
endmodule
~~~

Local source: [design.sv](design.sv).

Although the signal is named `en`, it has two synchronous meanings: 0 clears
the counter and 1 increments it. It is not an asynchronous reset because the
`if (!en)` test occurs only inside `@(posedge clk)`.

## Exact saved `run.do`

~~~tcl
# The testbench has a forever clock, so use a finite report window.
run 450ns;

# Print covergroup, coverpoint, and bin details after all intended phases.
coverage report -cvg -details;

# Close the batch simulator cleanly after printing the report.
quit -f;
~~~

Local script: [run.do](run.do).

The finite Tcl window is intentional. HDL-side `$finish` is another valid way
to end a forever-clock testbench, but then report ordering must be checked
carefully: some batch flows terminate immediately at `$finish` before later
Tcl commands can execute. Here, Tcl owns the stopping point and therefore
reliably reaches `coverage report`.

## Verified Questa result

The repaired public page was saved and run in its existing background Chrome
tab on August 24, 2026. The actual Questa 2025.2 command used `-do run.do`,
proving that the custom script was active. The report printed:

| Coverpoint bin | Meaning | Hits | Status |
|---|---|---:|---|
| `count_off` | `en=0` and `y=0` | 2 | Covered |
| `countLow` | `en=1` and `y=0..3` | 16 | Covered |
| `countMid` | `en=1` and `y=4..7` | 9 | Covered |
| `countHigh` | `en=1` and `y=8..15` | 16 | Covered |
| Total | 4/4 scored bins | — | **100.00%** |

`qrun`, `vlog`, and `vsim` each ended with zero errors. The only warning was
`vopt-10587`, caused by the saved `+acc` visibility option; it does not change
the functional-coverage result.

## How the five-bit coverpoint works

The concatenation `{en, y}` is five bits wide. `en` becomes the most
significant bit and `y[3:0]` occupies the remaining four bits:

~~~text
{en, y} = {en, y[3], y[2], y[1], y[0]}
~~~

The four declarations partition the intended known-value behavior:

| Pattern | Expanded values | Meaning |
|---|---|---|
| `00000` | only `00000` | disabled and cleared |
| `100??` | `10000`–`10011` | enabled, counts 0–3 |
| `101??` | `10100`–`10111` | enabled, counts 4–7 |
| `11???` | `11000`–`11111` | enabled, counts 8–15 |

The `?` digits are intentional wildcard positions in a `wildcard bins`
declaration. They match either 0 or 1 in a known sampled value. They do not
make a sampled X or Z count as a hit.

## Sampling order and exact hit reconstruction

The covergroup and DUT are both triggered by `posedge clk`. The covergroup
samples in the current time slot before the DUT's nonblocking assignment
updates `y` in the NBA region. Coverage therefore observes the **old** counter
value at each edge.

The exact counts follow from that scheduling:

- At 5 ns, `y` is still X when coverage samples; the reset assignment becomes
  visible afterward. At 15 ns, `{en,y}=00000` hits `count_off` once.
- From 25 through 215 ns there are 20 enabled samples: `0..15`, then `0..3`.
  That contributes 8 low, 4 mid, and 8 high hits.
- At 225 ns, `en=0` but coverage still sees the old nonzero `y=4`, so no
  declared bin matches. The reset update then makes `y=0`.
- At 235 ns, `count_off` receives its second hit.
- From 245 through 445 ns there are 21 enabled samples: `0..15`, then `0..4`.
  That contributes 8 low, 5 mid, and 8 high hits.

Adding the two enabled phases gives 16 low, 9 mid, and 16 high hits. The two
stable disabled/zero samples give the two `count_off` hits.

The unbinned X and `{en=0,y=4}` samples do not reduce this model's percentage:
coverage scores whether each declared bin has reached its goal, not what
fraction of all sample events landed in a bin.

## Deep Q&A

### 1. Why did the report fail even though compilation succeeded?

Compilation only proves that the source is legal. The default `run -all` waited
for an event queue that could never empty because the clock schedules another
toggle every 5 ns. Since simulation never returned, the later coverage-report
command never ran.

### 2. Why is `run 450ns` enough?

The intended stimulus begins at time 0 and the second enabled phase begins at
240 ns. Running through 450 ns includes rising edges through 445 ns, more than
enough to traverse all sixteen counter values during that phase and hit every
wildcard range.

### 3. Could the testbench use `$finish` instead?

Yes, if the flow is designed so the coverage report is produced before
termination or if the simulator continues processing the Tcl script after
`$finish`. A finite Tcl run is clearer here because it stops the forever clock
without depending on simulator-specific finish behavior.

### 4. Why was `wire [3:0] y = 0` harmful?

On a net, that initializer is a continuous assignment, not a one-time
initialization. It permanently drives zero while the DUT also drives the same
net. Conflicting 0 and 1 drivers resolve to X.

### 5. Why is `wire [3:0] y;` correct?

The testbench only observes `y`; the DUT is its sole driver. A net is therefore
appropriate for this module-output connection. `logic [3:0] y` would also be a
clear SystemVerilog declaration in a single-driver testbench.

### 6. Why did the original counter remain X?

Its register had no declaration initialization or asynchronous reset. The
original stimulus selected the increment branch at the first edge, and
four-state arithmetic preserves uncertainty: `4'bxxxx + 1` is still X.

### 7. Why hold `en=0` for two rising edges?

The first edge schedules `y <= 0`, making the value known after coverage has
already sampled that edge. The second edge lets coverage observe the known
zero. It also makes reset establishment obvious and robust to the
pre-NBA sampling rule.

### 8. Does `en=0` mean disabled or reset?

In this RTL it means both “do not count” and “synchronously clear to zero.”
Calling it `en` is legal but slightly misleading. A production design would
often separate `rst_n` from `enable` if hold and clear are distinct behaviors.

### 9. Why combine `en` and `y` into one coverpoint?

The concatenation makes mode part of the coverage goal. It distinguishes a
zero count while disabled from counter ranges while enabled. Separate
coverpoints plus a cross could express the same relationship more explicitly
and would scale better if more modes were added.

### 10. What does `5'b100??` cover?

It fixes `en=1` and `y[3:2]=00` while ignoring `y[1:0]`. It is one scored bin
covering the four known values where `y` is 0, 1, 2, or 3.

### 11. Are the four concrete values four separate bins?

No. A single named `wildcard bins countLow = {5'b100??};` declaration creates
one bin. Any matching value increments that same bin's hit count.

### 12. Does `?` mean the sampled bit may be X?

No. Here `?` is a wildcard digit in the bin definition and represents either
known 0 or known 1 for matching. A sampled X or Z is excluded from a wildcard
bin, which is why the original unknown counter did not produce useful hits.

### 13. Why is there no explicit `ci.sample()` call?

The covergroup declaration already contains the sampling event
`@(posedge clk)`. Constructing `ci` registers that event-driven instance, so it
samples automatically at every rising edge. Calling `sample()` too would add
extra manual samples.

### 14. What does `option.per_instance = 1` do?

It asks the tool to retain and report coverage for each covergroup instance.
It does not create the instance, trigger sampling, add bins, or force 100%
coverage. This example has one instance, `ci`.

### 15. Why does coverage see the old value of `y`?

The DUT uses a nonblocking assignment. Its right-hand side is evaluated at the
edge, but the new value is committed later in the NBA region. Event-triggered
coverage at that same edge observes the value from before the NBA update.

### 16. Is the unbinned disabled/nonzero sample a bug?

It is expected from the chosen model and scheduling. When `en` falls, coverage
sees the new `en=0` together with the old nonzero count for one edge. Add an
ignore bin, a transition bin, delayed sampling, or a separate reset model only
if that boundary matters to the verification plan.

### 17. Does 100% coverage prove the counter is correct?

No. It proves only that every declared coverage bin was hit. The testbench has
no assertions or scoreboard checking increment, reset, rollover, or timing.
Functional checking should be added independently of coverage closure.

### 18. Why is `countHigh` eight values but still worth only one bin?

Coverage percentage is based on declared bins and their goals, not on how many
concrete values each wildcard pattern represents. All eight high values feed
one bin, just as the four mid values feed one bin.

## Recommended self-checking extension

For a stronger verification testbench, maintain an expected four-bit model,
compare it with `y` after each NBA update, assert that `y` is never unknown
after reset establishment, and add a coverpoint or transition bin for
`15 => 0` rollover. The present lesson intentionally focuses on repairing
report generation and explaining wildcard-bin sampling.

## Revision checks

1. Why can a forever clock prevent a post-run Tcl report?
2. What is the difference between a net declaration assignment and variable
   initialization?
3. Why does X remain X through the original increment operation?
4. How is `{en,y}` mapped into five bit positions?
5. Which concrete values are grouped by each wildcard bin?
6. Why are the observed hit counts 2, 16, 9, and 16?
7. Why does the covergroup observe the pre-NBA counter value?
8. What additional checking is required beyond 100% coverage?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera SV-EC wildcard-bin discussion and the two-state sampled-value rule](https://www.accellera.org/images/eda/sv-ec/7634.html)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
