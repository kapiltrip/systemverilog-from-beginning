# Part 04 — Data types and simulation time

EDA Playground: [https://edaplayground.com/x/giAN](https://edaplayground.com/x/giAN)

This part explores two-state and four-state types, integer widths, `$time`, `$realtime`, procedural outputs, and hierarchical construction from half adders.

## Complete testbench code

This page reproduces the complete experimental source from [`testbench.sv`](testbench.sv), including the commented type, multiplexer, and adder explorations.

~~~systemverilog
// Code your testbench here
// or browse Examples
//Simulation - > fixed (time) , variable (realtime)
`timescale 1ns/1ps
/*

module tb; 
  bit a = 0 ; 
  byte b=0;
  shortint c = 0 ; 
  int d =0 ; // 32 bit integer 
  longint e = 0 ; 
  bit [7:0] f = 8'b00000000;
  bit [15:0] g = 16'h0000;
  //since 4 hex digits 
  real h= 0;  // 64 bit 
  
  
  byte 
  initial begin
    a = 1'b1; 
    
  end
  // 2 state and signed type 
  //2 state initial value = 0 ; 
  //4 state initial value will be x
endmodule
*/
module tb ; 
  /*
  byte varr = -126; // -128 to + 127
  initial begin
      #10; 
    $display("Value of varr %0d" , varr );
  end 
  shortint var2 =0; 
  */ 
  time fix_time =0;        //$time
  realtime real_time =0;    //$realtime current simulation time in floating point format
  initial begin
      #12.23;
    fix_time = $time(); 
    $display ("current simulation time is %0t" , fix_time);
    real_time = $realtime(); 
    $display ("current simulation time is %0t" , real_time);    
  end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
endmodule
/*
module mux(
    input wire a,b,
    input wire sel, 
    output reg y //cant use wire here 
);
  always @(*)begin
    if(sel)
      y= b;
    else 
      y=a; 
    
  end  
endmodule
*/
/*
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.08.2026 19:08:33
// Design Name: 
// Module Name: ha
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ha (
    input wire a,b,
    output wire cout,sum
);
  assign sum = a ^b ; 
  assign cout = a & b ; 
  
endmodule
module fa(
    input a,b,cin, 
    output wire cout,sum
);
reg f,g,h; // here, reg cant be allowed in the output of ha1 
ha ha1(
   .a(a),
   .b(b),
   .sum(f),
   .cout(g)
);
ha ha2(
   .a(cin),
   .b(f),
   .sum(sum),
   .cout(h)
);
assign cout = g|h ; 

endmodule
*/
//to verify the reg and putting logic inprefix to the wires, 
~~~

## Answers and notes

- `bit` is a two-state type (`0` or `1`) and defaults to `0`. `logic` and legacy `reg` are four-state types (`0`, `1`, `x`, `z`) and default to `x`.
- `byte`, `shortint`, `int`, and `longint` are signed two-state integer atom types with widths of 8, 16, 32, and 64 bits respectively. `integer` is the legacy signed four-state 32-bit integer type.
- `$time` returns an integer simulation time rounded to the current time unit. `$realtime` returns a real value, preserving fractional time such as 12.23 ns.
- `%0t` formats a time value using the simulator's time-format settings. `%0f` is useful when the exact fractional `realtime` value is the focus.
- A signal assigned inside a procedural block cannot be a Verilog net (`wire`). Legacy Verilog uses `output reg y`; idiomatic SystemVerilog uses `output logic y` with `always_comb`.
- The half-adder outputs are driven continuously. Intermediate connections `f`, `g`, and `h` should be declared as `wire` in Verilog or `logic` in SystemVerilog. A `logic` may have a single driver, including a module output.
- Two half adders create the full-adder sum, and OR-ing their carry signals produces the full-adder carry output.

## Detailed discussion

### Two-state versus four-state storage

Two-state types model only 0 and 1, which is efficient when unknown and high-impedance states are not meaningful. Four-state types also represent `x` and `z`, which makes them valuable for detecting uninitialized signals, conflicting drivers, and disconnected nets. In verification code, an unexpected `x` is often evidence of a real setup or connectivity problem rather than a value to hide.

| Type | Width | Default signedness | State model |
| --- | ---: | --- | --- |
| `bit` | Declared width | Unsigned unless declared `signed` | Two-state |
| `byte` | 8 bits | Signed | Two-state |
| `shortint` | 16 bits | Signed | Two-state |
| `int` | 32 bits | Signed | Two-state |
| `longint` | 64 bits | Signed | Two-state |
| `logic` / `reg` | Declared width | Unsigned unless declared `signed` | Four-state |
| `integer` | 32 bits | Signed | Four-state |
| `time` | 64 bits | Unsigned | Integral simulation-time value |
| `realtime` | Real-valued | Not an integral signedness case | Floating-point simulation time |

The commented type experiment contains a standalone `byte` token immediately before an `initial` block. If that block is uncommented, the incomplete declaration must be removed or completed before compilation.

### What happens at 12.23 ns

The directive gives a 1 ns time unit and 1 ps precision, so `#12.23` advances to exactly 12.230 ns. `$time` returns an integral time value and therefore rounds according to the active time-unit rules. `$realtime` retains the fractional value. Simulator formatting can display `%0t` in a globally selected unit, which is why a tool may print values such as 12000 and 12230 in picoseconds. Use an explicit `$timeformat` when output units must be unambiguous, and use `%0f` when examining the raw real value.

### Why the multiplexer output is procedural

The commented multiplexer assigns `y` inside an `always @(*)` block. A Verilog `wire` is a net and cannot store a procedural assignment, so legacy Verilog declares that output as `reg`. In SystemVerilog, the clearer form is `output logic y` with `always_comb`. The word `logic` does not automatically imply a hardware register; the surrounding procedural behavior determines the synthesized circuit.

### Connecting the two half adders

Each half adder continuously drives `sum` and `cout`. The full adder uses the first sum as an intermediate input to the second half adder, then ORs the two carry terms. Under Verilog net rules, `f`, `g`, and `h` should be `wire` because submodule outputs drive them. In SystemVerilog, single-driver `logic` declarations are also a clear choice when the port and tool rules permit variable connections.

### Points to remember

- `byte`, `shortint`, `int`, and `longint` are two-state; `logic`, `reg`, and `integer` are four-state.
- Choose two-state types for efficiency and four-state types when unknown-state detection matters.
- `$time` is integral; `$realtime` preserves fractions.
- A procedural assignment needs a variable data type, while a continuous/module-output connection behaves as a driver.
- Commented experiments can still contain syntax that must be corrected before reactivation.

## Reference

The type widths, signedness, and state models above follow [Accellera SystemVerilog 3.0 draft, section 3.3 and Table 3-1](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf).
