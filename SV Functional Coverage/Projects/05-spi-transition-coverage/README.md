# Project 05 — SPI Transition Coverage

[Functional Coverage home](../../README.md) · [Projects index](../README.md) · [Section 10 plates](../../PLATES.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `FC S10 V140 - SPI Transition Bins` |
| Stable playground | [T6Uc](https://edaplayground.com/x/T6Uc) |
| Course position | Section 10, Video 140 — Usage of Transition bins: Serial Peripheral Interface |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` / custom `run.do` |
| Fresh live result | Source parsing succeeds; elaboration fails with undefined module `spi_controller` |
| Exit result | `vopt` 1 error; qrun expected 0 but received 2; no coverage report |

This is a Namaste FPGA Section 10 project and therefore belongs in
`Projects/`, not `Codes/`. The folder preserves the actual used page exactly:
its testbench targets a compact `spi_controller`, while its design pane
contains a different `dac` state machine. The mismatch is retained as learning
evidence and diagnosed below rather than hidden by replacing either pane.

Whitespace-insensitive fingerprints match the captured browser panes:

| Pane | SHA-256 |
|---|---|
| `design.sv` | `3917e8252d4b171733496f6232b53821d6d10865b9d1c0e12444face7f34b145` |
| `testbench.sv` | `9b9423204066c126240cf3520f0500bd51853c108da743aa8ead3ba5294c41e7` |
| `run.do` | `65de6824eb8c4baf3c4a6e4a236852a4b3efae55a53c971ffabde972ecdf41bc` |

## Exact browser design

```systemverilog
module dac(
  input clk,
  input [11:0] din, // 12 bit resolution for dac
  input start,
  output reg mosi, cs
);
  typedef enum {
    idle = 0,
    init = 1,
    send = 3,
    data_gen = 2,
    cont = 4
  } state_type;

  state_type state;
  reg [31:0] setup = 32'h08000001;
  reg [31:0] dac_data = 32'h00000000;
  integer count = 0;

  always @(posedge clk) begin
    case (state)
      idle: begin
        cs <= 1'b1;
        mosi <= 1'b0;
        if (start) state <= init;
        else state <= idle;
      end
      init: begin
        if (count < 32) begin
          count <= count + 1;
          mosi <= setup[31 - count];
          cs <= 1'b0;
          state <= init;
        end else begin
          cs <= 1'b1;
          count <= 0;
          state <= data_gen;
        end
      end
      data_gen: begin
        dac_data <= {12'h030, din, 8'h00};
        state <= send;
      end
      send: begin
        if (count < 32) begin
          count <= count + 1;
          mosi <= dac_data[31 - count];
          cs <= 1'b0;
          state <= send;
        end else begin
          cs <= 1'b1;
          count <= 0;
          state <= cont;
        end
      end
      cont: begin
        if (start) state <= data_gen;
        else state <= idle;
      end
    endcase
  end
endmodule
```

The full source with every original comment is in [design.sv](design.sv).

## Exact browser testbench and transition model

```systemverilog
`timescale 1ns/1ps
// to do , this make a note in the readme in the outermost dir somewhere

// Video 140: use transition bins to describe a complete SPI transaction path.
module tb;
  logic clk = 0;
  logic reset, start;
  logic [1:0] state;
  logic busy;

  spi_controller dut (.*);

  covergroup spi_state_cg @(posedge clk);
    option.per_instance = 1;
    cp_state: coverpoint state {
      bins transaction = (0 => 1 => 2[*8] => 3 => 0);
      bins start_path = (0 => 1 => 2);
      bins finish_path = (2 => 3 => 0);
    }
  endgroup

  spi_state_cg cg;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    cg = new();
    reset = 1; start = 0;
    repeat (2) @(posedge clk);
    reset = 0;
    @(negedge clk) start = 1;
    @(negedge clk) start = 0;
    wait (!busy);
    // TODO: add back-to-back transfers and protocol/data coverage.
    #20 $finish;
  end
endmodule
```

Local source: [testbench.sv](testbench.sv).

## Exact Questa report script

```tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
```

Local source: [run.do](run.do).

## Discussion

### What note did the source ask to preserve in the outer README?

The note is now explicit in the Functional Coverage home page and project
index: Namaste FPGA Section 10 material is a **project track**, so its used
playgrounds are archived under `Projects/`, never appended to the ordered
lesson `Codes/` sequence. The exact SPI page is also marked as a reviewed
failing snapshot; “archived project” must not be mistaken for “passing test.”

### Why does the saved SPI page fail before simulation?

The testbench instantiates:

```systemverilog
spi_controller dut (.*);
```

but the design pane declares:

```systemverilog
module dac(...);
```

Both modules parse, which is why `vlog` reports zero errors. During
optimization/elaboration, Questa must bind every instance and cannot find a
definition for `spi_controller`. It emits one `vopt` error and stops before
`run.do` can simulate or report coverage.

This is not a coverage-percentage problem; there is no elaborated DUT and
therefore no valid coverage result.

### Should the testbench be changed to instantiate `dac`?

Only if the coverage plan is redesigned for the DAC interface and state
machine. A simple module-name substitution is insufficient:

- `dac` requires `din`, `mosi`, and `cs`, which the current testbench does not
  declare;
- it has no `reset`, `busy`, or two-bit `state` output for `(.*)` to connect;
- its states are `idle`, `init`, `data_gen`, `send`, and `cont`, including
  numeric state 4, while the current coverage model expects states 0–3;
- its `init` and `send` phases each last roughly 32 clocks, not eight.

There are two coherent repair paths: restore a matching four-state
`spi_controller` for this testbench, or write a DAC-specific testbench and
coverage plan. Mixing the two designs would create misleading coverage.

### What does `(0 => 1 => 2[*8] => 3 => 0)` mean?

It is one transition-bin sequence. The samples must show state 0, then 1, then
state 2 on exactly eight consecutive sampling events, then 3, then return to
0. In the intended compact controller those values mean:

```text
IDLE → LOAD → TRANSFER for 8 sampled clocks → DONE → IDLE
```

`start_path` and `finish_path` are smaller diagnostic goals. If the whole
transaction misses, they reveal whether entry into transfer or exit back to
idle was observed.

### Does the positive-edge covergroup see the state before or after the RTL update?

Both the covergroup event and a clocked DUT process react to the same positive
edge. Nonblocking assignments update state later in the NBA region, so the
coverage sample normally observes the pre-edge state. Transition coverage can
still describe the state history, but expected hit timing is shifted by one
edge. A monitor clocking block or deliberate opposite-edge sampling makes that
relationship clearer.

Reset deassertion should likewise occur away from the active positive edge to
avoid a race between testbench stimulus and the DUT.

### What should “back-to-back transfers and protocol/data coverage” add?

The existing model observes only control-state history. A completed SPI plan
should also exercise two transactions with the minimum legal gap, different
payload classes, busy/start interaction, chip-select framing, bit count, and
serial-data order. Assertions or a scoreboard must check protocol behavior;
transition bins merely report that declared sequences were seen.

### What independent defect exists inside the captured `dac` design?

`state` has no reset or declaration initializer. At time zero it can be X, no
`case` item matches, and there is no `default` branch to recover to `idle`.
Even with a matching DAC testbench, the FSM can remain unknown forever. A
reset input and reset branch—or, less portably, an intentional initialization
for simulation—must establish the initial state and outputs.

## Revision checks

1. Why can parsing succeed even though elaboration fails?
2. Why is renaming `spi_controller` to `dac` not a complete repair?
3. How many consecutive state-2 samples does `[*8]` require?
4. What do `start_path` and `finish_path` diagnose separately?
5. Why does a positive-edge coverage event usually see pre-NBA state?
6. Which checks are needed beyond state-transition coverage for an SPI
   transaction?
7. Why can the captured DAC FSM remain X from time zero?
