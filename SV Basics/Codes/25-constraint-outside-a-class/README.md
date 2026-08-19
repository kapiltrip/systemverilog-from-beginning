# Part 25 — Constraint outside a class

[← Part 24](../24-constrained-randc-inside-and-excluded-ranges/README.md) · [Learning index](../README.md) · [Part 26 →](../26-dynamic-range-constraints-with-post-randomize/README.md)

EDA Playground: [Constraint outside a class](https://edaplayground.com/x/BCGE)  
EDA Playground Name: `Constraint outside a class`  
Saved code ID: `7358881`

## Why this example matters

An external constraint body separates the class declaration from the implementation of its constraint while keeping the constraint a member of that class. The declaration establishes the name and ownership; the out-of-class definition supplies the expressions the solver must satisfy.

This is organization, not runtime attachment. The body must match its class-scoped declaration, just as an externally defined class method must match its prototype. The immediate assertion around `randomize()` then checks the solve result at the call site.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
// values of a certain range 
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps 

class generator; 
  randc bit [3:0] a,b;
  bit [3:0] y; 
  extern constraint data_const ;  // EXTERNAL CONSTRAINT 
  extern function void display(); 
  
  
endclass
constraint generator::data_const {
  a inside {[0:3]}; 
  b inside {[14:15]}; 
  
};
function void generator::display();
  $display("Value of a is %0d and b is %0d " , a,b); 
endfunction 
module tb;
  generator g; 
  initial begin
    g=new(); 
    for(int i =0 ; i<10 ; i++)begin
      assert(g.randomize()) else $display("randomization failed ") ;  // explain how assert works 
      
      g.display(); 
      #10; 
      
    end 
  end
endmodule 
~~~

## Questions from the code, explained

### How does `assert(g.randomize())` work in this loop?

**Question in the source**

> // explain how assert works 

**Where it appears**

testbench.sv:31, as the trailing comment on the immediate assertion.

**What the code is doing**

The class declares an external constraint body and an external display function. The initial block constructs g, then evaluates g.randomize() ten times. The return value is used directly as the assertion condition; there is no separate status variable.

**Answer**

The assertion tests g.randomize() at that statement. Success returns 1, so the assertion passes and the else action is skipped; failure returns 0, so the else $display executes.

**Why this works**

The [Accellera procedural-assertion draft](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf) defines an immediate assertion as a procedural test of a boolean expression when the statement executes, with the form assert ( expression ) statement_or_null [ else statement_or_null ]. This is the immediate, non-temporal form here. The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) defines randomize() as returning 1 for a successful assignment and 0 otherwise, so that return value is the asserted expression. The [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/) identifies the standard covering assertions and constrained-random verification.

**Watch for**

This checks solver success but treats failure as a printed message only. The observed Questa run had ten successful randomizations; a different constraint state could enter the else branch without stopping the simulation.

**References**

[Accellera procedural-assertion draft](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf), [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

## What happened when it ran

Live EDA run: Questa completed with Errors: 0 and Warnings: 1; ten values were displayed by the external function.

The live EDA source and settings were not edited during verification.

