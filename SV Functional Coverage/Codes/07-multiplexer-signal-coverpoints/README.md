# Part 07 — Multiplexer Signal Coverpoints

[← Part 06](../06-default-bins-for-unused-values/README.md) · [Functional Coverage index](../README.md) · [Part 08 →](../08-enumerated-state-coverpoint/README.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | Blank in the captured browser field |
| Stable playground | [J_mr](https://edaplayground.com/x/J_mr) |
| EDA code ID | `7380513` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Custom `run.do` | Enabled; unchanged saved Questa configuration was not rerun during this archive |
| Local verification | Vivado/XSim 2024.1: compile/elaboration/run pass; 14/14 bins covered, 100% |

This playground has substantive code in both editor panes, so both files are
stored. The 100% result is real for the declared bins, but it does not prove the
multiplexer function and it hides a sampling-order defect on `y`.

## Exact browser design

~~~systemverilog
// Code your design here
module top (
  input a,b,c,d,
  input [1:0] sel,
  output reg y
);
  always @(*) begin
    case (sel)
      2'b00: y=a;
      2'b01: y=b;
      2'b10: y=c;
        2'b11: y=d;
      default : y=1'b0 ;
    endcase
  end
endmodule
~~~

Local source: [design.sv](design.sv).

The design is a combinational 4-to-1 multiplexer. Every case item assigns `y`,
and the default handles selector values containing `X`/`Z` that match no case
item, so the block does not infer storage. The extra indentation before
`2'b11` is cosmetic.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  reg a , b, c, d;
  reg [1:0] sel ;
  wire y ;
  top dut(a,b,c,d,sel,y);
  covergroup cover_mux;
    option.per_instance = 1;
    coverpoint a {
      bins a_values[] = {0,1};
    }
    coverpoint b {
      bins b_values[] = {0,1};
    }
    coverpoint c {
      bins c_values[] = {0,1};
    }
    coverpoint d {
      bins d_values[] = {0,1};
    }
    coverpoint sel {
      bins sel_values[] = {0,1,2,3};

    }
    coverpoint y {
      bins y_values[]= {0,1};
    }

  endgroup
  cover_mux ci = new();
  initial begin
    for(int i =0 ; i<20 ; i++)begin
      a= $urandom();
      b= $urandom();
      c= $urandom();
      d= $urandom();
      sel= $urandom();
      ci.sample();
      #10 ;

    end
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

## What the declared model measures

Each one-bit data input and the one-bit output has two explicit bins. `sel` has
four explicit bins. The model therefore contains:

$$
4(2)+4+2=14\text{ scored bins}.
$$

The verified run covered all of them:

| Coverpoint | Hit counts | Result |
|---|---|---:|
| `a` | 0: 7, 1: 13 | 2/2 |
| `b` | 0: 7, 1: 13 | 2/2 |
| `c` | 0: 7, 1: 13 | 2/2 |
| `d` | 0: 11, 1: 9 | 2/2 |
| `sel` | 0: 6, 1: 3, 2: 8, 3: 3 | 4/4 |
| `y` | 0: 10, 1: 9 | 2/2 |

Random stimulus happened to close every declared bin. That outcome is not
guaranteed by 20 iterations; another seed can miss a selector or binary value.
`$urandom()` returns a wider unsigned value, and assignment truncates it to the
destination width.

## Why `y` has only 19 counted samples

The input assignments and `ci.sample()` execute consecutively in one process.
Changing an input schedules the DUT's `always @(*)` process, but that process
cannot update `y` until the running stimulus process yields. The first yield is
the following `#10`, after coverage has already sampled.

Consequently:

- on the first iteration, `y` is still `X`, so neither ordinary `y_values` bin
  matches;
- after the delay, the DUT computes the first result;
- on each later iteration, coverage samples the **previous iteration's** `y`;
- the final newly computed `y` is never sampled after the loop ends.

The XCRG evidence is the 19 total known `y` hits even though `ci.sample()` is
called 20 times. All input/selector coverpoints total 20 hits because their
blocking assignments complete in the sampling process itself.

This is a scheduler bug in the testbench, not a combinational-DUT bug. A simple
untimed teaching repair is to wait for combinational propagation before both
sampling and checking:

~~~systemverilog
sel = $urandom();
#1;
ci.sample();
~~~

In a clocked verification environment, sample through a monitor/clocking block
at the protocol's defined observation event instead of inserting an arbitrary
delay.

## Why 100% does not verify the multiplexer

Every individual signal took every individually requested value, but the model
never relates the signals. It does not ask whether:

- `sel == 0` was observed with both `a` values;
- `sel == 1` was observed with both `b` values;
- each selected input propagated to `y`;
- the unselected inputs had no effect;
- `y` matched the same iteration's expected value.

A broken design such as `assign y = a;` can still reach all 14 bins under this
stimulus. Functional coverage records scenarios; a scoreboard or assertion
must check correctness.

A first requirement-backed extension could cross `sel` with the selected
input's value, but blindly crossing all six coverpoints would create a large,
mostly meaningless Cartesian product. A direct checker remains clearer:

~~~systemverilog
logic expected_y;
case (sel)
  2'd0: expected_y = a;
  2'd1: expected_y = b;
  2'd2: expected_y = c;
  2'd3: expected_y = d;
endcase
if (y !== expected_y)
  $error("mux mismatch");
~~~

The check must run after `y` settles. Coverage and checking should use the same
stable observation point.

## Model-quality notes

- Explicit `{0,1}` bin arrays are legal but redundant for one-bit signals;
  automatic bins would create the same two-value partition.
- The explicit names can still improve report readability.
- Positional DUT connection works because the order matches the module ports,
  but named connections are safer when declarations change.
- `option.per_instance = 1` retains the `ci` instance view; only one instance
  exists here.
- The loop ends at time 200 and simulation exits by quiescence without an
  explicit `$finish`.

## Revision checks

1. Why do the input coverpoints each have 20 hits but `y` has 19?
2. Which value of `y` is sampled on the second loop iteration?
3. Can all 14 bins be covered by a functionally incorrect multiplexer?
4. What additional relationship should a mux coverage plan measure?
5. Where should the checker and covergroup sample in a clocked environment?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground settings and custom `run.do`](https://eda-playground.readthedocs.io/en/latest/settings.html)
- [AMD Vivado Design Suite User Guide: Logic Simulation (UG900)](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation)
