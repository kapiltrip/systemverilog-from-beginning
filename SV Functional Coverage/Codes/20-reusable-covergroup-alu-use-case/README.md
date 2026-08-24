# Part 20 — Reusable Covergroup ALU Use Case

[← Part 19](../19-generic-covergroup-rules/README.md) · [Functional Coverage index](../README.md) · [Part 21 →](../21-reusable-covergroup-memory-range-use-case/README.md)

| Field | Value |
|---|---|
| Course lesson | Section 6, V087 — Used Cases I |
| Source playground | [`KXaD`](https://edaplayground.com/x/KXaD) |
| EDA code ID / saved Name | `7382343` / **FC S06 V087 - ALU Use Case** |
| Simulator and options | Questa 2025.2; `-timescale 1ns/1ns`; `-voptargs=+acc=npr`; custom `run.do` enabled |
| Exact-source result | 14/14 coverage bins, 100%; 0 compile/simulation errors |
| Functional audit | **Fail:** all eight RTL case items use opcode `3'b000`; opcodes 1–7 execute `default` |
| Corrected local result | XSim 2024.1 self-check PASS; four coverage instances all 100%; total score 100% |

## Coverage closure exposed a functional blind spot

The saved testbench successfully verifies that random stimulus reached all
three input ranges for `a` and `b` and all eight opcode values. It does **not**
check `y`. The design repeats the same case item eight times:

~~~systemverilog
3'b000: y = a + b;
3'b000: y = a - b;
...
3'b000: y = ~a;
~~~

For opcode 0, the first matching item executes; for opcodes 1–7, no listed
item matches and `default` assigns zero. The 100% report is therefore a valid
coverage result for the declared input goals and simultaneously a failed ALU
implementation. This is the clearest lesson in the section: coverage measures
the model you wrote, not unmodeled functional correctness.

Your exact source is preserved below. The `verified-*` files separately repair
the opcode map and add a scoreboard, so the archive does not silently rewrite
your implementation.

## Complete saved testbench

~~~systemverilog
`timescale 1ns/1ps

// Video 087: reuse one data-range covergroup and one opcode-range covergroup.
module tb;
  // use cases : alu 8 operations 4 bit input and 5 bit o/p
  // 3 ranges low mid and high ,
  // all the operations to be tested
  reg [3:0] a;
  reg [3:0] b;
  reg [2:0] opcode;
  wire [4:0] y;
  integer i = 0;
  aluWorking dut (a, b, opcode, y);

  covergroup inputVariable (ref reg [3:0] variableAorB, input string varName, input int low, input int mid, input int high);
    option.per_instance = 1;
    option.name = varName; // that user will specify
    coverpoint variableAorB {
      bins lowerVal = {[0:low]};
      bins midVal = {[low+1:mid]};
      bins highVal = {[mid+1:high]};

    }
  endgroup
  //covergroup for verifying all the possible values for opcode
  covergroup coverageOpcode (ref reg [2:0] opcodeType, input string varName, input int low, input int high);
    option.per_instance = 1;
    option.name = varName; // user assigned name will be given here,
    coverpoint opcodeType {
      bins opcodeT[] = {[low:high]};

    }
  endgroup
  // 2 things are getting checked
  inputVariable cia = new(a, "variable a ", 3, 10, 15);
  inputVariable cib = new(b, "variable b ", 3, 10, 15);
  coverageOpcode cArithmetic = new(opcode, "Arithmetic operation ", 0, 3); // according to cases
  coverageOpcode cLogical = new(opcode, "Logical Operation ", 4, 7);
  initial begin
    for(i = 0; i < 50; i++)begin
      a = $urandom();
      b = $urandom();
      opcode = $urandom();
      cia.sample();
      cib.sample();
      cArithmetic.sample();
      cLogical.sample();
      #10; // again why i write it here,
    end
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv).

## Complete saved design

~~~systemverilog
module aluWorking (
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic [2:0] opcode,
  output logic [4:0] y
);
  always_comb begin
    //y = '0; what does it means
    case (opcode)
      // arithmetic operations

      3'b000: y = a + b;
      3'b000: y = a - b;
      3'b000: y = a + 1;
      3'b000: y = 1 + b;
      // logical operations
      3'b000: y = a & b;
      3'b000: y = a | b;
      3'b000: y = a ^+ b;
      3'b000: y = ~a;

      default: y = 5'b00000;
    endcase
  end
endmodule
~~~

Local source: [design.sv](design.sv).

## Complete saved `run.do`

~~~tcl
# Shared Questa run script for every Sections 6-10 boilerplate.
# Each saved EDA Playground copy contains this same script.
run -all;
coverage report -cvg -details;
quit -f;
~~~

Local script: [run.do](run.do).

## Fresh exact-source coverage result

The direct Questa run confirms that all declared coverage goals were reached:

| Instance / bin | Hits | Result |
|---|---:|---:|
| `variable a`: lower / mid / high | 17 / 22 / 11 | 3/3, 100% |
| `variable b`: lower / mid / high | 11 / 24 / 15 | 3/3, 100% |
| Arithmetic opcodes 0 / 1 / 2 / 3 | 10 / 9 / 7 / 3 | 4/4, 100% |
| Logical opcodes 4 / 5 / 6 / 7 | 3 / 6 / 5 / 7 | 4/4, 100% |
| Total | 14/14 bins | **100%** |

Compilation and simulation had zero errors. The only warning was the existing
`+acc` optimization warning from `vopt`.

## Every source comment answered

### “ALU 8 operations, 4-bit input and 5-bit output”

Three opcode bits encode eight operations. A five-bit result is useful for an
addition carry or a subtraction borrow/wrap bit, but merely declaring `y` as
five bits is not enough. In `a + b`, both operands are four bits, so the
addition can be evaluated at four-bit width before assignment and lose the
carry. The verified design explicitly extends both operands:

~~~systemverilog
y = {1'b0, a} + {1'b0, b};
~~~

### “3 ranges low, mid and high”

The two `inputVariable` instances each have three named bins: 0–3, 4–10, and
11–15. These bins prove range visitation, not every individual operand value.
A single hit anywhere in each range closes that instance's three goals.

### “all the operations to be tested”

`opcodeT[]` creates one bin per value in each requested range, so the combined
instances prove opcodes 0–7 were sampled. They do not prove the design returned
the right answer for any opcode. That requires the scoreboard in the verified
testbench.

### “that user will specify” / “user assigned name”

Correct. `option.name = varName` copies the constructor string into the report,
which is why the log shows separate names for `a`, `b`, arithmetic opcodes, and
logical opcodes. It does not select a signal or change coverage math.

### “2 things are getting checked”

There are two categories: operand ranges and opcode values. Concretely there
are two covergroup types and four instances. No output behavior is checked in
the saved source.

### “according to cases”

The intended division—0–3 arithmetic and 4–7 logical—is sensible, but the RTL
case items do not currently follow it. The verified mapping uses 000–011 for
addition, subtraction, increment-A, and increment-B; 100–111 for AND, OR,
XOR, and NOT-A.

### “again why i write `#10` here?”

The blocking assignments make `a`, `b`, and `opcode` immediately visible to
manual coverage sampling, so no delay is needed for those three coverpoints.
The delay advances simulation time, separates waveform transactions, and lets
`always_comb` settle before the next iteration. However, because the saved
code samples **before** `#10`, that delay would not protect an immediate check
of `y`. For output checking, drive inputs, wait `#1` (or an appropriate clocking
event), then compare and sample.

### “`y = '0;` what does it mean?”

`'0` is an unsized unbased literal that fills the destination width with zero.
For five-bit `y`, `y = '0;` means `y = 5'b00000;`. A common combinational style
is to assign this default before a `case` and override it in matching branches.
The saved design instead has a `default:` branch, so every path assigns `y`;
either style avoids a latch. Using both is allowed when it improves clarity.

### What does `a ^+ b` mean?

There is no `^+` binary operator. It is parsed as binary XOR followed by unary
plus on `b`: `a ^ (+b)`. For an unsigned four-bit `b`, that behaves like
`a ^ b`, but the spelling is needlessly confusing. The verified design writes
the intended XOR explicitly.

## Corrected design

~~~systemverilog
`timescale 1ns/1ps

module alu_verified (
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic [2:0] opcode,
  output logic [4:0] y
);
  always_comb begin
    case (opcode)
      3'b000: y = {1'b0, a} + {1'b0, b};
      3'b001: y = {1'b0, a} - {1'b0, b};
      3'b010: y = {1'b0, a} + 5'd1;
      3'b011: y = {1'b0, b} + 5'd1;
      3'b100: y = {1'b0, a & b};
      3'b101: y = {1'b0, a | b};
      3'b110: y = {1'b0, a ^ b};
      3'b111: y = {1'b0, ~a};
      default: y = '0;
    endcase
  end
endmodule
~~~

Local source: [verified-design.sv](verified-design.sv).

The mapping is inferred from the saved source order and the arithmetic/logical
0–3/4–7 coverage split. If the course defines a different opcode contract,
change both the design and expected-result function together.

## Deterministic self-checking testbench

~~~systemverilog
`timescale 1ns/1ps

module tb;
  logic [3:0] a;
  logic [3:0] b;
  logic [2:0] opcode;
  logic [4:0] y;

  alu_verified dut (.*);

  covergroup input_cg(ref logic [3:0] value, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_value: coverpoint value {
      bins low = {[0:3]};
      bins mid = {[4:10]};
      bins high = {[11:15]};
    }
  endgroup

  covergroup opcode_cg(ref logic [2:0] value, input int first_op,
                       input int last_op, input string instance_name);
    option.per_instance = 1;
    option.name = instance_name;
    cp_opcode: coverpoint value {
      bins operations[] = {[first_op:last_op]};
    }
  endgroup

  input_cg cg_a = new(a, "verified input A");
  input_cg cg_b = new(b, "verified input B");
  opcode_cg cg_arithmetic = new(opcode, 0, 3, "verified arithmetic opcodes");
  opcode_cg cg_logical = new(opcode, 4, 7, "verified logical opcodes");

  function automatic logic [4:0] expected_result(
    input logic [3:0] function_a,
    input logic [3:0] function_b,
    input logic [2:0] function_opcode
  );
    case (function_opcode)
      3'b000: expected_result = {1'b0, function_a} + {1'b0, function_b};
      3'b001: expected_result = {1'b0, function_a} - {1'b0, function_b};
      3'b010: expected_result = {1'b0, function_a} + 5'd1;
      3'b011: expected_result = {1'b0, function_b} + 5'd1;
      3'b100: expected_result = {1'b0, function_a & function_b};
      3'b101: expected_result = {1'b0, function_a | function_b};
      3'b110: expected_result = {1'b0, function_a ^ function_b};
      3'b111: expected_result = {1'b0, ~function_a};
      default: expected_result = '0;
    endcase
  endfunction

  task automatic check_operation(
    input logic [3:0] stimulus_a,
    input logic [3:0] stimulus_b,
    input logic [2:0] stimulus_opcode
  );
    a = stimulus_a;
    b = stimulus_b;
    opcode = stimulus_opcode;
    #1;

    if (y !== expected_result(a, b, opcode)) begin
      $error("opcode=%0d a=%0d b=%0d produced y=%0d expected=%0d",
             opcode, a, b, y, expected_result(a, b, opcode));
    end

    cg_a.sample();
    cg_b.sample();
    cg_arithmetic.sample();
    cg_logical.sample();
  endtask

  initial begin
    check_operation(0, 15, 0);
    check_operation(4, 10, 1);
    check_operation(11, 3, 2);
    check_operation(15, 4, 3);
    check_operation(3, 11, 4);
    check_operation(10, 0, 5);
    check_operation(4, 15, 6);
    check_operation(12, 5, 7);
    $display("PASS: all eight ALU operations and reusable coverage models verified");
  end
endmodule
~~~

Local source: [verified-testbench.sv](verified-testbench.sv).

## Verified local `run.do`

~~~tcl
run -all;
coverage report -cvg -details;
quit -f;
~~~

Local script: [verified-run.do](verified-run.do).

## Corrected-variant verification

Vivado/XSim 2024.1 compiled, elaborated, and ran the corrected layer. The
scoreboard printed:

~~~text
PASS: all eight ALU operations and reusable coverage models verified
~~~

XCRG reported score 100 with four instances:

| Instance | Covered / total bins | Result |
|---|---:|---:|
| `verified input A` | 3/3 | 100% |
| `verified input B` | 3/3 | 100% |
| `verified arithmetic opcodes` | 4/4 | 100% |
| `verified logical opcodes` | 4/4 | 100% |

Each opcode bin has exactly one deterministic hit. Both operand instances hit
their low, middle, and high bins. Generated XSim databases and reports remain
outside the tracked lesson files.

## Revision checks

1. Why can 100% opcode coverage coexist with a broken opcode decoder?
2. Which case branch executes for opcode 0, and what happens for opcodes 1–7?
3. Why does a five-bit destination not automatically preserve a four-bit
   addition carry?
4. What does `'0` expand to for five-bit `y`?
5. Why should output checking wait after driving combinational inputs?
6. What two covergroup types and four instances are present?
7. Why does `opcodeT[]` close every opcode while an operand range bin does not
   prove every value in that range?
8. What does the scoreboard add that functional coverage alone does not?

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [Accellera functional-coverage specification material](https://www.accellera.org/images/eda/sv-ec/att-1377/01-functional-coverage.pdf)
- [Accellera generic-covergroup constructor example](https://accellera.org/images/eda/sv-ec/1826.html)
- [AMD Vivado simulation guide UG900](https://docs.amd.com/r/2024.1-English/ug900-vivado-logic-simulation/xsim-Executable-Options)
- [EDA Playground simulator settings](https://eda-playground.readthedocs.io/en/latest/settings.html)
