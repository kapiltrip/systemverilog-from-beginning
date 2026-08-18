# Part 30 — FIFO Transaction and Weighted Constraints

[← Part 29](../29-distribution-constraints-with-colon-equal-and-colon-slash/README.md) · [Learning index](../README.md) · [Part 31 →](../31-event-trigger-and-wait-semantics/README.md)

| Saved-playground field | Value |
|---|---|
| Original queue label | `000` |
| Indexed EDA name | `SV 30 - FIFO Transaction and Weighted Constraints` |
| Stable playground | [gjeT](https://edaplayground.com/x/gjeT) |
| Saved code ID | `7361120` |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` |
| Live result | **Compile failure:** 1 error, 0 warnings |

This part starts a verification-oriented transaction model for a synchronous FIFO. The design pane contains the FIFO RTL; the testbench pane contains only the transaction class, so this stage is about describing stimulus and sampled response rather than driving the DUT yet.

## Concept map

| Transaction member | Role | Why it is or is not randomized |
|---|---|---|
| `clk` | Testbench timing infrastructure | A transaction should not invent clock edges; a clock generator owns this signal. |
| `rst` | Control stimulus | It can be randomized in a deliberate reset scenario, but usually with strong timing and frequency constraints. |
| `wr_en`, `rd_en`, `wr_data` | FIFO request stimulus | These are inputs the generator is meant to choose. |
| `rd_data`, `empty`, `full` | DUT response | A monitor samples these; randomizing them would fabricate a result instead of observing the FIFO. |

The FIFO uses a count-based implementation. `do_write` and `do_read` qualify requests with `!full` and `!empty`; the two-bit case expression then increments, decrements, or retains `fifo_count`. Simultaneous accepted read and write requests keep the count unchanged.

## Questions from the code, explained

### Why use `wr_en != rd_en` instead of implication or `if`/`else`?

**Question in the source**

> `wr_en != rd_en ;  // why i didnt used implication here, or if else`

**Where it appears**

`testbench.sv:22`

**Answer**

For one-bit variables, `wr_en != rd_en` is a compact XOR-style constraint: exactly one enable must be 1. It directly states the required relationship. An implication expresses a one-way condition, so `wr_en -> !rd_en` alone still permits `wr_en=0, rd_en=0`. Two implications, or an `if`/`else` constraint, could express the same two-state relationship, but they are longer:

~~~systemverilog
if (wr_en)
  rd_en == 0;
else
  rd_en == 1;
~~~

The more important modeling question is whether simultaneous read and write should truly be forbidden. The FIFO RTL explicitly supports `{do_write, do_read} == 2'b11`, so excluding `wr_en==rd_en` prevents both idle cycles and simultaneous transfers. That may be suitable for an early isolated read/write test, but a complete FIFO test plan should eventually exercise all four request combinations and let `full`/`empty` determine which operations are accepted.

### Why does the saved playground not compile?

The first live error is at `testbench.sv:16`. Inside a `dist` list, alternatives are separated with commas, not semicolons. The saved source has:

~~~systemverilog
wr_en dist {0:=30 ; 1:= 70 ; }
~~~

The syntactically corrected form is:

~~~systemverilog
wr_en dist {0 := 30, 1 := 70};
~~~

The same correction is required for `rd_en`. The repository keeps the original pane unchanged; this corrected fragment is explanatory only.

### Are the weights percentages?

They are relative weights. For the two alternatives `0 := 30` and `1 := 70`, the total is 100, so the resulting proportions are naturally read as 30% and 70%. The language does not require weights to total 100: `3` and `7` describe the same ratio. A finite random sample will not necessarily contain the exact theoretical proportions.

## Design code

~~~systemverilog
module sync_fifo
  #(parameter DW = 8,
    parameter AW = 4)
(
    input  wire               clk,
    input  wire               rst,
    input  wire               wr_en,
    input  wire               rd_en,
    input  wire [DW-1:0]      wr_data,
    output reg  [DW-1:0]      rd_data,
    output wire               full,
    output wire               empty
);

    localparam [AW:0] DEPTH = (1 << AW);

    reg [DW-1:0] mem [0:DEPTH-1];
    reg [AW-1:0] wr_ptr;
    reg [AW-1:0] rd_ptr;
    reg [AW:0]   fifo_count;

    wire do_write;
    wire do_read;

    assign do_write = wr_en && !full;
    assign do_read  = rd_en && !empty;

    assign full  = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);

    always @(posedge clk) begin
        if (rst) begin
            wr_ptr     <= {AW{1'b0}};
            rd_ptr     <= {AW{1'b0}};
            fifo_count <= {(AW+1){1'b0}};
            rd_data    <= {DW{1'b0}};
        end else begin
            if (do_write) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr      <= wr_ptr + 1'b1;
            end

            if (do_read) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1'b1;
            end

            case ({do_write, do_read})
                2'b10: fifo_count <= fifo_count + 1'b1;
                2'b01: fifo_count <= fifo_count - 1'b1;
                default: fifo_count <= fifo_count;
            endcase
        end
    end

endmodule
~~~

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
//Transaction class  will hold all the input and output together in a single class
class Transaction ;
  bit clk;  // it should not be random rather, rst can be random value sometimes

  bit rst;
  rand bit wr_en,rd_en;
  rand bit [7:0] wr_data;
  bit [7:0] rd_data;

  bit empty;
  bit full;

  constraint control_wr_en{
    wr_en dist {0:=30 ; 1:= 70 ; }
  }
  constraint control_rd_en{
    rd_en dist {0 := 30 ; 1:= 70 ; }
  }
  constraint write_read{
    wr_en != rd_en ;  // why i didnt used implication here, or if else

  }

endclass
~~~

## What happened when it ran

The live EDA run on 2026-08-18 selected Questa and compiled the FIFO module, then stopped at `testbench.sv:16` with `vlog-13069`: an unexpected semicolon in the `dist` list. Total: 1 error, 0 warnings. No source or setting was changed during the run.

## Points to remember

- Model generated inputs and observed outputs differently inside a transaction.
- A hard inequality constraint removes both `00` and `11`; confirm that this matches the coverage goal.
- `dist` assigns relative probability weights; commas separate its alternatives.
- A verification repository should keep a failing learning snapshot visible and explain the failure rather than silently replacing it.

## References

[IEEE 1800-2023 SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/) · [Accellera SystemVerilog 3.1 donation](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) · [EDA Playground settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
