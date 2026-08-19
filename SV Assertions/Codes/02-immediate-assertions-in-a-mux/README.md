# Part 02 — Immediate Assertions in a Multiplexer

[← Part 01](../01-observed-deferred-immediate-assertion/README.md) · [SV Assertions index](../README.md) · [Part 03 →](../03-clocked-immediate-assertion-and-nba-timing/README.md)

| Saved-playground field | Value |
|---|---|
| EDA Playground Name | `SVA 02 - Immediate Assertions in a Mux` |
| Stable playground | [FfSr](https://edaplayground.com/x/FfSr) |
| Simulator used for verification | Aldec Riviera Pro 2025.04 |
| Compile result | 0 errors; simulator diagnostic for implicit net `y` |
| Observed run | Finishes at 300 ns with no assertion failure message |

This lesson puts four simple immediate assertions beside a 4:1 multiplexer. It is useful for syntax, but it also exposes a subtle verification problem: the combinational calculation and the assertions are placed in separate Active-region processes, so the absence of an error message is not yet proof that the checker is race-free.

## Exact browser testbench

~~~systemverilog
// Code your testbench here
// or browse Examples
//simple immediate assertions => precedural block 
//observed deffered / final deffered immediate assertion . can use outside the procedural block for combinational blocks / 
// observed final deffered simple immediate assertion and final deffered immediate assertion required a procedural block 
/* 
assert (s == a ^ b ) $info("pass action "); else $error("Fail action "); 
assert #0 () $info("pass action "); // deffered assert 
assert final () ; final assert 
*/
module tb(); 
  reg a=0, b=0,c=0,d=0;
  reg [1:0] sel =0;
  mux dut (
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .sel(sel),
    .y(y)
  );
  always #5 a = ~a ; 
  always #10 b = ~b;
  always #15 c = ~c; 
  always #20 d = ~d; 
  initial begin
    sel= 2'b00; 
    #50;
    sel= 2'b01; 
    #50;
    sel= 2'b10; 
    #50;
    sel= 2'b11;                
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars; 
    #300; 
    $finish; 
    
  end
endmodule
~~~

Local source: [testbench.sv](testbench.sv)

## Exact browser design

~~~systemverilog
// Code your design here
module mux(
  input a,b,c,d,
  input [1:0] sel , 
  output reg y // to be used in procedural block 
);
  always @(*) begin
    case (sel)
      2'b00: y=a; 
      2'b01: y=b; 
      2'b10: y=c; 
      2'b11: y=d; 
      
    endcase
  end
  always @(*)begin
    case (sel)
      2'b00 : y_equals_a :assert (y==a) else $error("Y is not equals to a at time %0t" , $time) ; 
      2'b01 : y_equals_b :assert (y==b) else $error("Y is not equals to b at time %0t" , $time) ; 
      2'b10 : y_equals_c :assert (y==c) else $error("Y is not equals to c at time %0t" , $time) ; 
      2'b11 : y_equals_d :assert (y==d) else $error("Y is not equals to d at time %0t" , $time) ; 
      
    endcase
  end
endmodule
~~~

Local source: [design.sv](design.sv)

## 1. What a simple immediate assertion does

Each case item contains a labeled assertion such as:

~~~systemverilog
y_equals_a: assert (y == a)
  else $error("Y is not equals to a at time %0t", $time);
~~~

This is equivalent in control-flow spirit to an `if` test, with standardized assertion semantics and tool reporting. When procedural execution reaches the statement:

1. `y == a` is evaluated immediately;
2. `1` means pass;
3. `0`, `X`, or `Z` means failure for the assertion decision;
4. no pass statement is present, so a pass prints nothing;
5. the `else` action executes immediately on failure in the region of the calling process.

The label `y_equals_a` gives the assertion a useful hierarchical identity. It is not a variable and it does not store the result.

## 2. Correction and confirmation of the source comments

### “Simple immediate assertions require a procedural block”

Correct. A simple immediate assertion is a procedural statement. Typical homes include `always_comb`, `always_ff`, `initial`, a task, or a function.

### “Observed/final deferred assertions can be outside a procedural block”

This idea is valid, with precise wording: SystemVerilog permits a **standalone deferred immediate assertion** in a suitable static scope. A standalone form is treated as if it were placed in an implicit `always_comb` process sensitive to the assertion expression.

For example:

~~~systemverilog
module m(input logic a, b);
  equal_after_settling: assert #0 (a == b)
    else $error("a and b differ after settling");
endmodule
~~~

Deferred immediate assertions can also be embedded inside explicit procedural code. They are not restricted to only one placement style.

### The commented skeletons are incomplete

These lines are study mnemonics, not compilable statements:

~~~systemverilog
assert #0 () ...
assert final () ; final assert
~~~

Both empty parentheses need a Boolean expression. The words `final assert` would also need to be a comment if the block were uncommented. Valid forms look like:

~~~systemverilog
assert #0    (condition) else $error("observed-deferred failure");
assert final (condition) else $error("final-deferred failure");
~~~

## 3. The important race hidden in this design

The multiplexer output is assigned in one process:

~~~systemverilog
always @(*) begin
  case (sel)
    // y is assigned here
  endcase
end
~~~

The assertions run in a second process:

~~~systemverilog
always @(*) begin
  case (sel)
    // y is checked here
  endcase
end
~~~

When an input or `sel` changes, both processes can be scheduled in the Active region. SystemVerilog guarantees neither process will execute first. Two legal orders therefore exist:

~~~text
Order A: calculate new y -> check new y        (usually passes)
Order B: check old y       -> calculate new y  (can fail transiently)
~~~

The second assertion process also reads `y`, so a later change to `y` can awaken it again and make a subsequent evaluation pass. A simple immediate assertion has already printed any first failure; it cannot retract it.

That is exactly the kind of same-time-slot combinational behavior for which an observed-deferred assertion is useful.

## 4. Why simultaneous input toggles make the risk easier to see

The stimulus periods overlap:

- `a` toggles every 5 ns;
- `b` toggles every 10 ns;
- `c` toggles every 15 ns;
- `d` toggles every 20 ns;
- `sel` changes every 50 ns.

At times such as 20 ns, more than one source process can update during the same time slot. Continuous combinational logic may require multiple Active iterations to settle. The timestamp alone does not reveal which intermediate value an immediate checker observed.

The live run happened to finish without a failure message, but the code structure still permits an ordering-dependent transient. “It passed once” and “it is race-free” are different claims.

## 5. Two robust checker structures

### Option A — calculate, then check in one process

~~~systemverilog
always_comb begin
  unique case (sel)
    2'b00: y = a;
    2'b01: y = b;
    2'b10: y = c;
    2'b11: y = d;
    default: y = 1'bx;
  endcase

  mux_result: assert (y == ({a, b, c, d} >> (3-sel)) & 1'b1)
    else $error("mux mismatch");
end
~~~

The main idea is the ordering inside one process: assign `y` before checking it. In production code, use an expression that is clear to your team; a `case`-based expected value is often easier to review than compact bit arithmetic.

### Option B — keep independent logic but defer the report

~~~systemverilog
always_comb begin
  case (sel)
    2'b00: y_equals_a: assert #0 (y == a) else $error("y != a");
    2'b01: y_equals_b: assert #0 (y == b) else $error("y != b");
    2'b10: y_equals_c: assert #0 (y == c) else $error("y != c");
    2'b11: y_equals_d: assert #0 (y == d) else $error("y != d");
  endcase
end
~~~

Here an early pending failure can be flushed when the combinational checker executes again after `y` settles. `assert final` is another choice when the requirement is specifically to report only from the Postponed end of the current time slot.

## 6. The implicit-net diagnostic

The testbench connects `.y(y)` without declaring `y`. Because implicit nets are enabled, the compiler creates a one-bit wire and reports:

~~~text
Implicit net declaration, symbol y has not been declared in module tb.
~~~

Make intent explicit:

~~~systemverilog
wire y;
// or: logic y;
~~~

Many projects add `` `default_nettype none `` so misspelled signal names become compile errors instead of silently created wires.

## 7. Additional design details

- `output reg y` is legal because the design assigns `y` procedurally. In modern SystemVerilog, `output logic y` communicates the intent more directly.
- The `case` covers all four known two-state values of `sel`, but it has no `default`. If `sel` contains `X` or `Z`, `y` keeps its previous value and the block behaves like a latch during that unknown condition.
- A pass action is optional. Therefore the empty assertion portion of the live log means “no fail action executed,” not “the simulator printed four pass confirmations.”
- Wave dumping records signal activity but does not repair an ordering race.

## 8. Live result interpretation

The Edge run compiled with 0 errors and reached `$finish` at 300 ns. The tool emitted an implicit-net diagnostic for `y`, and no `$error` action ran.

The correct conclusion is:

> The captured stimulus did not expose a failing ordering in this run, but the two-`always @(*)` checker architecture remains race-prone and should be made deterministic or deferred.

## References

- [IEEE Std 1800-2023 — active SystemVerilog standard](https://standards.ieee.org/ieee/1800/7743/)
- [IEEE Std 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F24/documentation/1800-2017.pdf) — Clauses 4.4, 9.2, and 16.3–16.4
- [Accellera deferred-immediate-assertion proposal and standalone example](https://www.accellera.org/images/eda/sv-bc/att-7234/AssertDefer071026es.pdf)
