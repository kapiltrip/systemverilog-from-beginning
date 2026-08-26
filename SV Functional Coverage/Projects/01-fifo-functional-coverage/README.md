# Project 01 — Synchronous FIFO Design and Functional Coverage

[Functional Coverage home](../../README.md) · [Projects index](../README.md) · [Section 10 plates](../../PLATES.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `FC S10 V136 - FIFO P1` |
| Stable playground | [Au83](https://edaplayground.com/x/Au83) |
| EDA code ID | `7382381` |
| Course position | Section 10, Video 136 — FIFO P1 |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` / custom `run.do` |
| Verified live result | 0 compile errors; 17/26 scored bins; 64.10% covergroup metric |
| Open EPWave after run | Disabled |

This is a project rather than another numbered syntax lesson because it joins a
parameterized synchronous FIFO, procedural read/write behavior, finite
stimulus, and a multi-signal functional-coverage model. V136 is the single FIFO
plate that was actually used. V137 and V138 remain untouched starters and are
not copied into `Projects/`.

The source files preserve the completed playground's code and comments with
horizontal formatting normalized for readability. Corrections and explanations
are kept in Discussion instead of silently rewriting the learning evidence.

Whitespace-insensitive fingerprints match the captured browser panes exactly:

| Pane | SHA-256 |
|---|---|
| `design.sv` | `e56c21dc12a070e5e39887e17f85924a31c3cb1b952a37d1be08fae80a69a207` |
| `testbench.sv` | `85c122332bff684d086c44dfc64a848c0b677c0ecc716cf90288219421f48baf` |
| `run.do` | `65de6824eb8c4baf3c4a6e4a236852a4b3efae55a53c971ffabde972ecdf41bc` |

## Exact browser design

```systemverilog
`timescale 1ns/1ps

// Video 136: interface-first FIFO shell; implement behavior after the plan.
module sync_fifo #(
  parameter integer dw = 8,
  parameter integer aw = 8
) (
  input wire clk, rst, wr_en, rd_en,
  input wire [dw-1:0] din,
  output reg [dw-1:0] dout,
  output wire full, empty
);
  localparam integer depth = (1 << aw);
  reg [dw-1:0] mem [0:depth-1];
  reg [aw-1:0] raddr; // reg or wire to be decided
  reg [aw-1:0] waddr; // basically pointers i call them address
  reg [aw:0] count;
  wire canRead = !empty && rd_en;
  wire canWrite = !full && wr_en;

  assign empty = (count == 0);
  assign full = (count == depth);

  always @(posedge clk) begin
    if (rst) begin
      count <= {(aw+1){1'b0}};
      dout <= {dw{1'b0}};
      raddr <= {aw{1'b0}};
      waddr <= {aw{1'b0}};
    end else begin
      if (canRead) begin
        dout <= mem[raddr];
        raddr <= raddr + 1;
      end

      if (canWrite) begin
        mem[waddr] <= din;
        waddr <= waddr + 1;
      end

      case ({canRead, canWrite})
        2'b01: count <= count + 1'b1;
        2'b10: count <= count - 1'b1;
        default: count <= count;
      endcase
    end
  end
endmodule
```

Local source: [design.sv](design.sv).

## Exact browser testbench and coverage model

```systemverilog
// both read and write high to be handled later
module tb;
  parameter dw = 8;
  parameter aw = 6;

  reg clk = 0;
  reg rst = 0;
  reg wr_en = 0;
  reg rd_en = 0;
  reg [dw-1:0] din = 0;
  wire [dw-1:0] dout;
  wire empty, full;

  sync_fifo #(
    .dw(dw),
    .aw(aw)
  ) dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .din(din),
    .dout(dout),
    .full(full),
    .empty(empty)
  );

  initial
    repeat (40)
      #5 clk = ~clk;

  task write();
    for (int i = 0; i < 20; i++) begin
      wr_en = 1'b1;
      rd_en = 1'b0;
      din = $urandom();
      @(posedge clk);
      $display("writing a value of din : %0d , and full is %0d , at an address of %0d ", din, full, dut.waddr);
      wr_en = 0;
      @(posedge clk);
    end
  endtask

  task read();
    for (int i = 0; i < 20; i++) begin
      wr_en = 1'b0;
      rd_en = 1'b1;
      din = {dw{1'b0}}; // lol just playing
      @(posedge clk);
      rd_en = 1'b0;
      @(posedge clk);
      $display("reading a value of dout : %0d , and empty is %0d , at an address of %0d ", dout, empty, dut.raddr);
    end
  endtask

  initial begin
    rst = 1;
    wr_en = 0;
    rd_en = 0;
    repeat (5) @(posedge clk);
    rst = 0;
    write();
    read();
  end

  covergroup c @(posedge clk);
    option.per_instance = 1;

    coverpoint empty {
      bins empty_low = {0};
      bins empty_high = {1};
    }

    coverpoint full {
      bins full_low = {0};
      bins full_high = {1};
    }

    coverpoint rst {
      bins rst_low = {0};
      bins rst_high = {1};
    }

    coverpoint wr_en {
      bins wr_en_low = {0};
      bins wr_en_high = {1};
    }

    coverpoint rd_en {
      bins rd_en_low = {0};
      bins rd_en_high = {1};
    }

    coverpoint din {
      bins lower_din = {[0:84]};
      bins mid_din = {[85:169]};
      bins high_din = {[170:255]};
    }

    coverpoint dout {
      bins lower_dout = {[0:84]};
      bins mid_dout = {[85:169]};
      bins high_dout = {[170:255]};
    }

    // now i will use cross coverage cause i want to see them working in a relation not just individually
    cross_wr_en_rst: cross rst, wr_en {
      ignore_bins reset_high = binsof(rst) intersect {1}; // when reset is 1 wr doesnt matter
      ignore_bins wr_en_low = binsof(wr_en) intersect {0}; // when wr_en is 0 ignore
    }

    cross_rd_en_rst: cross rst, rd_en {
      ignore_bins reset_high = binsof(rst) intersect {1}; // when reset is 1 wr doesnt matter
      ignore_bins rd_en_low = binsof(rd_en) intersect {0}; // when wr_en is 0 ignore
    }

    cross_wr_din: cross rst, wr_en, din {
      ignore_bins reset_high = binsof(rst) intersect {1};
      ignore_bins wr_en_low = binsof(wr_en) intersect {0};
    }

    cross_rd_din: cross rst, rd_en, dout {
      ignore_bins reset_high = binsof(rst) intersect {1};
      ignore_bins rd_en_low = binsof(rd_en) intersect {0};
    }

    cross_full_wr: cross rst, wr_en, full {
      ignore_bins full_wr_en = binsof(full) intersect {1}; // full is high, means ignore
      ignore_bins rst_high = binsof(rst) intersect {1};
      ignore_bins wr_en_low = binsof(wr_en) intersect {0};
    }

    cross_empty_rd: cross rst, rd_en, empty {
      ignore_bins empty_rd_en = binsof(empty) intersect {1}; // full is not high
      ignore_bins rst_high = binsof(rst) intersect {1};
      ignore_bins rd_en_low = binsof(rd_en) intersect {0};
    }
  endgroup

  c ci;

  initial begin
    ci = new();
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

### What do `parameter` and `localparam` mean beyond configurable and constant?

Beyond “configurable” and “constant,” the important shared meaning is that
`parameter` and `localparam` are **elaboration-time values**. Their values are
decided before runtime simulation, while SystemVerilog is constructing the
module instance.

The FIFO declares:

```systemverilog
parameter integer aw = 8;
localparam integer depth = (1 << aw);
```

Because both values are known during elaboration, they can determine hardware
structure:

```systemverilog
reg [aw-1:0] raddr;
reg [dw-1:0] mem [0:depth-1];
```

With `aw = 8`, elaboration effectively constructs:

```systemverilog
reg [7:0] raddr;
reg [7:0] mem [0:255];
```

The distinction is:

```text
parameter
    = externally configurable
    + constant for one elaborated instance
    + known during elaboration
    + can define hardware width and structure

localparam
    = internal to the module
    + not overrideable by an instance
    + constant
    + known during elaboration
    + can define hardware width and structure
```

Here `dw` and `aw` are public design settings. `depth` is a derived internal
fact, so `localparam` prevents an instance from supplying a `depth` that
contradicts `aw`.

The testbench overrides `aw` to 6:

```systemverilog
sync_fifo #(
  .dw(dw),
  .aw(aw)
) dut (...);
```

Therefore, this captured instance is an 8-bit-wide, 64-entry FIFO: `mem` is
`[0:63]`, each pointer is 6 bits, and `count` is 7 bits so it can represent the
inclusive occupancy range 0 through 64.

A normal variable such as:

```systemverilog
integer aw = 8;
```

is runtime state. It can store or change simulation data, but it is not the
right mechanism for deciding a declaration's width or array depth. FIFO `aw`
is not data moving through the circuit; it describes how the circuit is built.

### Answer to the earlier question: should `raddr` be `reg` or `wire`?

In this Verilog-style source, `raddr`, `waddr`, `count`, and `dout` must be
variables (`reg`) because the clocked `always` block assigns them procedurally:

```systemverilog
always @(posedge clk) begin
  raddr <= raddr + 1;
end
```

`full`, `empty`, `canRead`, and `canWrite` are driven by continuous expressions,
so declaring them as nets (`wire`) is appropriate:

```systemverilog
assign empty = (count == 0);
assign full = (count == depth);
```

The word `reg` does not by itself mean “physical register.” It means a Verilog
procedural variable. In this particular design, however, these variables are
assigned in a positive-edge process, so synthesis does infer flip-flops for
the pointers, count, and registered output. In idiomatic SystemVerilog the
same signals could be declared `logic`, with the sequential process written as
`always_ff`.

### FIFO operation and occupancy update

The guarded operations are:

```systemverilog
wire canRead = !empty && rd_en;
wire canWrite = !full && wr_en;
```

They prevent an empty read and a full write. The concatenation is ordered as
`{canRead, canWrite}`, so the count table is:

| `canRead` | `canWrite` | Action | Occupancy change |
|---:|---:|---|---:|
| 0 | 0 | Idle or blocked operation | 0 |
| 0 | 1 | Write one item | +1 |
| 1 | 0 | Read one item | -1 |
| 1 | 1 | Read and write in the same cycle | 0 |

The `default` branch covers both `2'b00` and `2'b11`. Therefore the earlier
testbench note about both enables being high has a defined RTL outcome: when
the FIFO is neither full nor empty, both operations occur, both pointers move,
and occupancy stays unchanged. Boundary policy still deserves explicit tests;
at empty, only the write is accepted, and at full, only the read is accepted.

### What the coverage model asks

The independent coverpoints ask whether reset, enables, status flags, and the
three data ranges were sampled. The crosses then ask more useful relational
questions:

- was a write-enable sample seen while reset was low;
- was a read-enable sample seen while reset was low;
- did writes and reads exercise each data range;
- did legal writes occur while the FIFO was not full;
- did legal reads occur while the FIFO was not empty.

The `ignore_bins` clauses remove combinations that do not represent an
accepted operation. For example, a write-disabled tuple is irrelevant to
write-data coverage, and a read while `empty == 1` cannot return valid FIFO
data.

Two copied comments need correction. In `cross_rd_en_rst`, “wr doesn't matter”
should say **read enable doesn't matter while reset is high**. In
`cross_empty_rd`, “full is not high” should say **empty is high, so the read is
blocked**. The declarations themselves select the intended bins; the issue is
only the wording of those comments.

### Why the verified run stopped at 64.10%

The fresh saved-page run compiled both modules with zero source errors and
printed 17/26 covered bins. The covergroup metric was 64.10%.

The result follows directly from the finite clock:

```systemverilog
initial
  repeat (40)
    #5 clk = ~clk;
```

Forty half-period toggles create only 20 positive edges. Reset consumes the
first five. Each loop iteration in `write()` waits for two positive edges, so
the remaining clock budget supports only eight attempted writes. The Log
indeed prints eight write messages. The 20-iteration write task never returns,
so `read()` never starts; once the finite clock stops, no future event can
resume the blocked process and `run -all` reaches quiescence.

That explains the main holes:

| Metric | Live result | Reason |
|---|---:|---|
| `rd_en` high | 0 hits | `read()` never begins |
| read-related crosses | 0% | No accepted read is sampled |
| `dout` middle/high ranges | 0 hits | `dout` remains at its reset value |
| `full` high | 0 hits | Only eight of 64 entries are written |
| write-data ranges | 100% | The eight random values happened to hit all three bins |

Coverage below 100% is therefore useful evidence, not a compiler failure. It
shows exactly which intended scenarios the current stimulus did not reach.
Extending the clock or using an intentional forever clock plus an explicit
`$finish` would let both tasks complete; deterministic boundary stimulus would
then be needed to guarantee empty/full and simultaneous-operation coverage.

### What 64.10% does and does not prove

The live result proves that the model was constructed, sampled, and reported,
and that several write-side scenarios occurred. It does not prove FIFO data
ordering, pointer wraparound, overflow/underflow prevention, simultaneous
read/write correctness, or full coverage closure. Those require a scoreboard,
targeted boundary stimulus, and assertions in addition to coverpoints.

## Revision checks

1. Why can `aw` determine a pointer width while an ordinary runtime integer
   cannot?
2. Why is `depth` safer as a `localparam` than as an independently overrideable
   `parameter`?
3. With `aw = 6`, what are the memory depth, pointer width, and count width?
4. Why are the pointers `reg` in this source while `full` and `empty` are
   `wire`?
5. Why does `{canRead, canWrite} == 2'b11` leave `count` unchanged?
6. Why did the run print eight writes but no reads?
7. Why can all three `din` bins reach 100% while the overall project remains
   at 64.10%?
8. What additional checker is required to prove FIFO order rather than merely
   observe coverage?
