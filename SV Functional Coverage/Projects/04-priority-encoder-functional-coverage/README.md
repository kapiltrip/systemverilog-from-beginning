# Project 04 — Priority Encoder Functional Coverage

[Functional Coverage home](../../README.md) · [Projects index](../README.md) · [Section 10 plates](../../PLATES.md)

| Playground field | Value |
|---|---|
| EDA Playground Name | `FC S10 V134 - Priority Encoder` |
| Stable playground | [vYdX](https://edaplayground.com/x/vYdX) |
| Course position | Section 10, Video 134 — Priority Encoder with Verilog TB |
| Simulator | Siemens Questa 2025.2 |
| Compile / run options | `-timescale 1ns/1ns` / `-voptargs=+acc=npr` / custom `run.do` |
| Fresh live result | 0 compile errors; 8/67 scored bins; 6.25% covergroup metric |
| Review status | The page runs, but the DUT and output-bin model contain substantive defects |

This saved page is one of Namaste FPGA's Section 10 projects, so it is archived
under `Projects/` rather than consuming a numbered entry in `Codes/`. The
source remains exactly auditable even though the fresh run demonstrates that
the current version is not a correct priority-encoder verification result.

Browser spelling and tokens are preserved with horizontal formatting
normalized. Discussion records the defects instead of silently repairing the
captured source.

Whitespace-insensitive fingerprints match the captured browser panes:

| Pane | SHA-256 |
|---|---|
| `design.sv` | `883ffeb068a2ee7e0761d136e1e2fcdec46ec417e50e5465cf3a72eb153e9542` |
| `testbench.sv` | `f8b53eca94cd89f0d3b5ec76b7e3f3a40b22b26433954498438c0f4021982ca7` |
| `run.do` | `65de6824eb8c4baf3c4a6e4a236852a4b3efae55a53c971ffabde972ecdf41bc` |

## Exact browser design

```systemverilog
module penc(
  input [7:0] x,
  output reg [2:0] y
);

  always @(*) begin
    casez (y)
      8'b00000001: y = 3'b000;
      8'b0000001?: y = 3'b001;
      8'b000001??: y = 3'b010;
      8'b00001???: y = 3'b011;
      8'b0001????: y = 3'b100;
      8'b001?????: y = 3'b101;
      8'b01??????: y = 3'b110;
      8'b1???????: y = 3'b111;
      default: y = 3'bzzz;
    endcase
  end
endmodule
```

Local source: [design.sv](design.sv).

## Exact browser testbench and coverage model

```systemverilog
module tb;
  reg [7:0] x;
  wire [2:0] y;
  integer i = 0;

  covergroup c;
    option.per_instance = 1;
    coverpoint y {
      bins zeroes = {'b00000001};
      wildcard bins one = {8'b0000001?};
      wildcard bins two = {8'b000001??};
      wildcard bins three = {8'b00001???};
      wildcard bins four = {8'b0001????};
      wildcard bins five = {8'b001?????};
      wildcard bins six = {8'b01??????};
      wildcard bins seven = {8'b1???????};
    }
    coverpoint x;
  endgroup

  c ci;
  penc dut (x, y);

  initial begin
    ci = new();
    for (i = 0; i < 10; i++) begin
      x = $urandom();
      ci.sample();
      #10;
    end
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

### Why does the encoder output stay unknown instead of following `x`?

The decisive RTL defect is here:

```systemverilog
casez (y)
```

The case expression should be the 8-bit request input `x`, not the 3-bit
output `y`. The process reads `y` in order to decide what value to assign back
to `y`, creating combinational feedback. Questa correctly warns that `y` may
be read before it is written. Starting from an unknown value, no intended
8-bit item reliably matches and the `default` branch drives `3'bzzz`.

The minimal RTL correction is `casez (x)`. The item ordering then gives bit 7
the highest priority, followed by bits 6 down to 0.

### Why are the wildcard bins on `y` the wrong width and meaning?

`y` is only three bits wide and represents an encoded result from 0 through 7.
The declarations use eight-bit request masks such as `8'b001?????`; those
patterns describe which input request wins, not the numeric output code.

Questa reports the consequence directly. The `three` through `seven` patterns
contain set bits above the range of a three-bit coverpoint, so their values are
invalid and the bins collapse to empty lists. Only three scored output bins
remain, and all three receive zero hits because `y` is unknown.

The request masks belong on `coverpoint x`. Output coverage should instead use
three-bit codes, for example:

```systemverilog
coverpoint y iff (x != 0) {
  bins each_code[] = {[3'd0:3'd7]};
}
```

The bin name `zeroes` is also misleading: its literal is numeric 1, not 0.

### Why did `coverpoint x` create 64 bins rather than 256 bins?

No explicit bins are declared for `x`, so the simulator creates automatic
bins. The default `auto_bin_max` is 64. An 8-bit domain has 256 values, so
Questa partitions them into 64 four-value bins: `0:3`, `4:7`, and so on.

Ten random assignments cannot guarantee all 64 bins. In the fresh run eight
automatic bins were hit, producing 12.50% for `x`; two random samples landed
in already-covered buckets.

### Why is the total metric 6.25% when 8 of 67 raw bins were hit?

The covergroup has two equally weighted coverpoints. `y` is 0% and `x` is
12.50%, so the default equal-weight aggregate is:

```text
(0.00% + 12.50%) / 2 = 6.25%
```

The raw ratio `8 / 67 = 11.94%` is also printed, but it is not the displayed
covergroup metric because coverpoints, rather than all bins globally, receive
equal default weight.

### Is `ci.sample()` observing the new encoder result?

Not reliably. The testbench assigns `x` and calls `ci.sample()` immediately in
the same time slot. Even after changing the DUT to `casez(x)`, its combinational
process may not have updated `y` before sampling. Drive `x`, allow a delta or
small time delay for settling, and then sample/check the output.

### What else is required before this becomes a real priority-encoder test?

Coverage alone does not compare the result with an expected priority. A robust
test needs an expected-code function or reference model, a `valid` indication
for `x == 0`, deterministic examples for every winning bit, and an assertion
or scoreboard that checks both `y` and validity after combinational settling.

The corrected verification intent is therefore:

1. cover the eight wildcard request classes on `x` plus a no-request bin;
2. cover output codes 0 through 7 only when a request is present;
3. check that the highest set request bit determines `y`;
4. check the defined no-request policy separately.

## Revision checks

1. Why must the DUT use `casez(x)` rather than `casez(y)`?
2. Why do eight-bit wildcard request masks not belong on a three-bit output?
3. How does a 256-value input domain become 64 automatic bins?
4. Why is the equal-coverpoint metric 6.25% rather than the raw 8/67 ratio?
5. Why should stimulus and sampling be separated in simulation time?
6. What does a scoreboard prove that functional coverage does not?
