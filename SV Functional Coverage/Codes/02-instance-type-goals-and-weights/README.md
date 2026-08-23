# Part 02 — Instance/Type Goals and Coverpoint Weights

[← Part 01](../01-basic-coverpoints/README.md) · [Functional Coverage index](../README.md) · [Part 03 →](../03-conditional-sampling-with-iff/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [pvaX](https://edaplayground.com/x/pvaX) |
| EDA code ID | `7379868` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; 84.375% total coverage |

The design pane contains only EDA Playground's placeholder, so this part stores
only the substantive `testbench.sv` and `run.do` files. Browser spelling is
preserved in the source; corrections belong in the discussion.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
// instance coverage is diff from cover pint coverage
module tb;
  reg [1:0] a ;
  reg [1:0] b ;

  covergroup coverA;
    option.per_instance =1;
    option.goal= 75;  // this is not true for coverage type
    type_option.goal = 75;
    coverpoint a {
      option.weight = 3;
      option.goal = 75;
    }
    coverpoint b {
      option.weight = 5 ;
      option.goal= 75;
    }

  endgroup
  coverA ca = new();
  initial begin
    for(int i =0 ; i<5 ; i++)begin
      a = $urandom();
      b= $urandom();;
      ca.sample();
      #10  ;

    end
  end
endmodule
//weight * coverage for coverpoint for a + weight for b * coverage for coverpoint b / weight1 + weight2
// coverage type -> multiple cover -> multiple cover point
//type for coverage
// option . is for -> coverpoint
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

Local script: [run.do](run.do).

Part 01's explicitly verified Questa configuration used:

~~~text
-coverage -voptargs=+acc=npr
~~~

The captured Part 02 page itself was not rerun during this archive, so its
browser result is not inferred from settings alone. Part 09 later proved that
EDA Playground's current `qrun` flow can collect covergroups without an explicit
`-coverage` switch. A reporting script can print only data the selected flow
actually collected; record the exact verified invocation rather than assuming
one option is universal.

## What is an instance and what is a type?

`coverA` is a covergroup **type**. `ca` is one constructed **instance** of that
type. The distinction matters when the same coverage model is instantiated for
several ports, agents, channels, or DUT instances.

`option.per_instance = 1` tells the tool to retain/report coverage separately
for each instance. It does not create another covergroup, change any bin, or
automatically make instance coverage differ from type coverage. This playground
constructs only `ca`, so the instance and type observe the same five samples.
Multiple instances are needed before their reports can diverge.

The opening comment is therefore directionally useful but incomplete:

- instance coverage answers what one object such as `ca` observed;
- type coverage combines information for the covergroup type according to the
  language/tool's instance-merging rules;
- `per_instance` preserves the first view; it does not disable the second.

## `option.goal` versus `type_option.goal`

The two assignments are legal but describe different scopes:

| Assignment | Scope in this playground | What it changes |
|---|---|---|
| `option.goal = 75` | The `coverA` instance-level covergroup option | The target attached to each constructed instance |
| `type_option.goal = 75` | The `coverA` type | The target attached to the covergroup type as a whole |
| `coverpoint a { option.goal = 75; }` | Coverpoint `a` in each instance | The target for that coverpoint |
| `coverpoint b { option.goal = 75; }` | Coverpoint `b` in each instance | The target for that coverpoint |

A goal is metadata for deciding whether a coverage target has been reached. It
does not create hits, remove uncovered bins, stop the simulation, or make a 75%
raw score become evidence of completeness. The precise presentation of a
reached goal is report/tool dependent. XCRG kept the raw percentages visible
and reported the goal in a separate column.

The source comment `option . is for -> coverpoint` is too narrow. Instance
options exist at covergroup, coverpoint, and cross levels where the particular
option is allowed. `type_option` is the spelling that targets the covergroup
type.

## How weights produce the displayed percentage

Each two-bit coverpoint has four automatic bins. In the verified XSim run:

| Coverpoint | Weight | Covered bins | Raw coverage |
|---|---:|---:|---:|
| `a` | 3 | 4/4 | 100% |
| `b` | 5 | 3/4 | 75% |

The covergroup score is the weighted average:

$$
C_\text{coverA}=\frac{3(100)+5(75)}{3+5}=84.375\%.
$$

The larger weight on `b` makes its missing bin matter more to the aggregate.
Weights do **not** increase the hit count of a bin and do not make `b` more
likely to receive stimulus. They affect score aggregation only.

If both weights were 1, the same raw coverpoint results would produce
$(100+75)/2=87.5\%$. If a weight is 0, that item does not contribute to the
weighted score; using zero to hide an important coverage hole would be a model
mistake rather than closure.

## Sampling and run interpretation

The covergroup has no event in its declaration, so only `ca.sample()` updates
coverage. It is called five times, immediately after assigning both variables.
There is no DUT and no delta-cycle propagation to wait for, so the values being
sampled are the newly assigned `a` and `b` values.

Five random samples do not guarantee all four values for either variable. The
local run happened to hit every `a` value and three `b` values. A different
simulator or random seed may produce a different percentage without any source
change. The extra semicolon in `b= $urandom();;` is an empty statement and is
legal, though it should normally be removed for clarity.

After the fifth `#10`, the only initial process ends and the simulation has no
future events. `run -all` therefore finishes by quiescence even though the
source has no explicit `$finish`.

## Questions from the source, answered

### Is instance coverage different from coverpoint coverage?

They are different levels of the hierarchy, not competing calculation modes.
A coverpoint reports its own bins. A covergroup instance combines its weighted
coverpoints/crosses. A covergroup type can then combine or merge information
from its instances. `option.per_instance` asks the database to retain the
instance layer.

### Does `goal = 75` mean only 75 hits are required?

No. `goal` is a percentage target, while `option.at_least` is the option that
sets the minimum hit count required for an individual bin to count as covered.
This source leaves `at_least` at its default of 1.

### Why is the total not the simple average of 100% and 75%?

Because the coverpoints use weights 3 and 5. The higher-weight `b` result has
five eighths of the influence on the aggregate.

## Revision checks

1. Which declaration creates the covergroup type, and which creates its instance?
2. What does `per_instance` preserve when two instances are constructed?
3. Why does `goal` not repair an uncovered bin?
4. Recalculate the score if `a=50%`, `b=100%`, and the weights remain 3 and 5.
5. Which setting is missing from the saved EDA Playground Run Options?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
