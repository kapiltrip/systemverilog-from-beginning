# Part 24 — User-Defined `sample()` Inside a Task

[← Part 23](../23-manual-prebuilt-sample-method/README.md) · [Functional Coverage index](../README.md) · [Part 25 →](../25-user-defined-sample-in-function/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 7, V097 — User-Defined Sample Method Inside a Task Block |
| Source playground | [`L5Mb`](https://edaplayground.com/x/L5Mb) |
| EDA code ID / saved Name | `7382353` / **FC S07 V097 - User sample() in Task** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Fresh direct result | 14/16 bins, 87.50%; 50 task samples; 0 source errors or warnings |

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 097: pass the processed task value into a user-defined sample method.
module tb;
  reg [3:0] address;
  reg wr;
  integer i = 0;
  reg clk = 0;
  // 100 half-cycles provide exactly 50 rising edges, then run -all can finish.
  initial repeat (100) #5 clk = ~clk;
  covergroup c with function sample (reg [3:0] in);
    coverpoint in;

  endgroup
  c ci;
  task write();
    @(posedge clk);
    wr = 1;
    address = $urandom();
    ci.sample(address);
  endtask
  initial begin
    ci = new();
    for(i = 0; i < 50; i++)begin
      write();
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

| Value bin | Hits | Value bin | Hits |
|---|---:|---|---:|
| `auto[0]` | 5 | `auto[8]` | 4 |
| `auto[1]` | 0 | `auto[9]` | 5 |
| `auto[2]` | 2 | `auto[10]` | 4 |
| `auto[3]` | 5 | `auto[11]` | 5 |
| `auto[4]` | 1 | `auto[12]` | 4 |
| `auto[5]` | 0 | `auto[13]` | 1 |
| `auto[6]` | 2 | `auto[14]` | 5 |
| `auto[7]` | 4 | `auto[15]` | 3 |

The hit counts total 50. Values `1` and `5` were the only misses, producing
14/16 bins and **87.50%** coverage. The run completed with zero source errors
or warnings; the sole summary warning is Questa's generic `+acc` notice.

## How the user-defined method differs from Part 23

`with function sample (reg [3:0] in)` replaces the normal no-argument sampling
signature with a method that accepts a value. The coverpoint observes formal
argument `in`, not module variable `address` directly. Each call therefore
provides an explicit four-bit snapshot:

~~~systemverilog
ci.sample(address);
~~~

This is useful when a task, function, monitor, or assertion has already
processed raw signals into the value that the coverage model should record.
The formal is an input by default, so later changes to `address` do not alter a
sample that was already taken.

## Task execution and ordering

Each call to `write()` blocks until a rising edge. It then executes three
blocking statements in order: assert `wr`, randomize `address`, and sample that
new address. There is no scheduling race between the assignment and the call
because both occur sequentially in the same process.

The task name suggests a bus write, but no DUT consumes `wr` or `address` and
`wr` is never cleared. The code demonstrates task-local placement of a
coverage call; it does not verify a write protocol or memory behavior. A real
task would normally deassert control, transfer data, and synchronize with a
ready/response signal.

## Why the finite-clock repair was necessary

The original saved page used:

~~~systemverilog
always #5 clk = ~clk;
~~~

That process schedules an event forever. The 50-task loop completed, but
`run -all` could never return to the following `coverage report` command. The
repair uses exactly 100 half-cycles:

~~~systemverilog
initial repeat (100) #5 clk = ~clk;
~~~

Starting from zero, rising edges are transitions 1, 3, ..., 99, so all 50 task
calls receive a rising edge at 5 through 495 ns. Transition 100 returns the
clock low at 500 ns; then no process schedules another event, `run -all`
returns, and the detailed report executes. Using only 50 half-cycles would
provide 25 rising edges and strand the loop halfway through.

## Random closure versus sampling correctness

The 50 calls prove that the task invoked the user-defined method correctly.
They do not guarantee all 16 values; the observed seed missed two. To close the
model deterministically, iterate `address` from 0 through 15 or add targeted
stimulus for the missing bins. Coverage closure still would not prove the
functional correctness of a write operation because this testbench has no DUT
or scoreboard.

## Revision checks

1. What expression does the coverpoint observe: `address` or formal `in`?
2. Why does sampling see the newly randomized address?
3. Why did the original infinite clock prevent the Tcl report from executing?
4. Why are 100 half-cycles required for 50 rising-edge task calls?
5. What behavior remains unverified even if all 16 address bins close?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
