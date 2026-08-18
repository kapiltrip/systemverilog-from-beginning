# Part 04 — SV 04 - Data Types and Time

[← Part 03](../03-phase-shifted-clocks/README.md) · [Learning index](../README.md) · [Part 05 →](../05-fixed-arrays-and-for-loop/README.md)

EDA Playground: [SV 04 - Data Types and Time](https://edaplayground.com/x/giAN)  
EDA Playground Name: `SV 04 - Data Types and Time`  
Saved code ID: `7356270`

## Why this example matters

The useful comparison in this playground is not simply one type name versus another. It is whether a variable can represent unknown and high-impedance states, how its width controls the stored value, and how simulation time is reported under the active `timescale`.

Treat `$time` and `$realtime` as observations of the simulator's time model, not as ordinary counters maintained by the testbench. When reading the output, connect each printed value to the time unit, time precision, and the delay that preceded it.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### What is the initial value of a four-state variable?

**Question in the source**

>   //4 state initial value will be x

**Where it appears**

`testbench.sv:26` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment appears alongside the data-type declarations that compare four-state and two-state variables.

**Answer**

An uninitialized four-state integral variable defaults to X.

**Why this works**

Four-state integral types preserve the four logic values 0, 1, X, and Z. X represents an unknown value, so the simulator uses it as the default state for an uninitialized four-state integral variable. A two-state type cannot represent X or Z and has a different default. This experiment uses the declaration choices and displays to make that representation difference visible; it is not showing an assigned X literal being overwritten by a tool-specific default.

**Watch for**

An X is not the same as 0 and should not be treated as a harmless placeholder. It can propagate through expressions and make equality or control decisions unknown.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why can a wire not be used in this declaration?

**Question in the source**

>     output reg y //cant use wire here 

**Where it appears**

`testbench.sv:58` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is attached to a declaration in the data-types example where a signal is assigned procedurally.

**Answer**

A net such as wire is not a procedural variable, so it cannot be used as the left-hand side of an ordinary procedural assignment in the way this example requires.

**Why this works**

SystemVerilog distinguishes nets, which model connectivity driven by sources, from variables, which store values written by procedural statements. A wire declaration describes a net; an assignment inside an initial or always block requires a variable-compatible procedural destination. The exact legal alternatives depend on the surrounding declaration and driver model, but this testbench's assignment pattern calls for a variable rather than a plain wire. A logic variable is commonly used when there is one procedural driver, while a net remains appropriate when connectivity and multiple drivers are being modeled.

**Watch for**

Changing a type just to silence an error can hide a driver-model mistake. First decide whether the signal is a stored procedural variable or a driven net.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why is reg not allowed at the output of the half adder?

**Question in the source**

> reg f,g,h; // here, reg cant be allowed in the output of ha1 

**Where it appears**

`testbench.sv:103` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is in the half-adder portion of the data-types testbench and concerns an output connection driven by a module instance.

**Answer**

The output connection must be compatible with how the instantiated module drives it; a net-style connection is required when the module output is driving the signal as a port connection, whereas a variable declaration is used for procedural assignment.

**Why this works**

A module output drives the connected expression through the port connection. In traditional Verilog, an output driven by a module instance is connected to a net, not a procedural reg written by an initial or always block. SystemVerilog broadened port and variable rules in several contexts, so the precise legality depends on the port kind, direction, and whether the connected object is otherwise procedurally driven. In this example the comment reflects the older net-versus-reg distinction exposed by module-instantiation wiring. The safest interpretation is that the receiving signal's driver type must match the port connection, rather than that every output can never be a variable in SystemVerilog.

**Watch for**

Do not generalize this comment to all SystemVerilog output ports. Check the port declaration and the connection's other drivers; the example is about this module-instance connection.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).





