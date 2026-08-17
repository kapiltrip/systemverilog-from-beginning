# Part 25 — Constraint outside a class

EDA Playground: [Constraint outside a class](https://edaplayground.com/x/BCGE)  
EDA Playground Name: `Constraint outside a class`  
Saved code ID: `7358881`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace, correct, or improve the code.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

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

## Source fidelity
The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID BCGE. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

### How does `assert(g.randomize())` work in this loop?

**Original code question**

> // explain how assert works 

**Where it appears**

testbench.sv:31, as the trailing comment on the immediate assertion.

**Context in this playground**

The class declares an external constraint body and an external display function. The initial block constructs g, then evaluates g.randomize() ten times. The return value is used directly as the assertion condition; there is no separate status variable.

**Answer**

The assertion tests g.randomize() at that statement. Success returns 1, so the assertion passes and the else action is skipped; failure returns 0, so the else $display executes.

**Deep explanation**

The [Accellera procedural-assertion draft](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf) defines an immediate assertion as a procedural test of a boolean expression when the statement executes, with the form assert ( expression ) statement_or_null [ else statement_or_null ]. This is the immediate, non-temporal form here. The [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) defines randomize() as returning 1 for a successful assignment and 0 otherwise, so that return value is the asserted expression. The [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/) identifies the standard covering assertions and constrained-random verification.

**Practical implication or pitfall**

This checks solver success but treats failure as a printed message only. The observed Questa run had ten successful randomizations; a different constraint state could enter the else branch without stopping the simulation.

**Sources**

[Accellera procedural-assertion draft](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf), [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), and [IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

## Verification observed

Live EDA run: Questa completed with Errors: 0 and Warnings: 1; ten values were displayed by the external function.

The live EDA source and settings were not edited during verification.

