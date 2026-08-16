# Part 22 — Constrained Randomization with randc

EDA Playground: [Constrained Randomization with randc](https://edaplayground.com/x/Fqxx)  
EDA Playground Name: `Constrained Randomization with randc`  
Saved code ID: `7358472`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanation below does not replace, correct, or improve the code.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Verbatim design.sv

~~~systemverilog
/* // Code your design here
module dut (
  input [3:0] a,b,
  output [3:0] y 
);
  
endmodule 
*/
~~~

## Verbatim testbench.sv

~~~systemverilog
// Code your testbench here
// or browse Examples
//Generator generate stimuli and sending it to driver 
// How to generate complex sequences 
`timescale 1ns/1ps 
class generator ; 
  //rand bit [3:0] a,b;  // some repetition of values 
  randc bit [3:0] a,b;  // no repetition 
  bit [3:0] y; 
  constraint data {a>16; }
endclass
/*
randc => cyclic rand 
rand -> random number 

*/
module tb;
  generator g ; 
  int i =0;
  int status =0;
  
  initial begin
    g=new();
    //10 random stimuli 
    for(i=0; i<10; i++)begin
      //status = g.randomize();
      if(!g.randomize()) begin
        $display("Randomize failed at time %0t" , $time ); 
        
      end

      
    end
  end
endmodule 
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID Fqxx. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

### How can this playground generate complex sequences?

**Original code question**

> // How to generate complex sequences 

**Where it appears**

`testbench.sv:4`, immediately after the generator-topic comment.

**Context in this playground**

The saved testbench defines a `generator` class with two `randc bit [3:0]` members, a constraint `a>16`, and a loop that calls `g.randomize()` ten times. The block comment records the author's distinction between cyclic randomization and ordinary randomization. The active call is checked with `if(!g.randomize())`, so a failed solve enters the diagnostic display.

**Answer**

SystemVerilog generates constrained stimulus by declaring random variables, declaring constraints that describe legal combinations, and calling `randomize()`; `randc` adds a randomized cyclic, no-repeat traversal of a variable's value range. In this exact source, however, the constraint `a>16` is unsatisfiable for the declared 4-bit `a`, so the requested sequence cannot be generated successfully by the active code.

**Deep explanation**

The official Accellera random-constraints proposal describes `rand` variables as ordinary random variables and `randc` variables as random-cyclic variables that traverse a random permutation of their declared range. It also states that the permutation is recomputed when the remaining values cannot satisfy the active constraints, and that randomization can fail when the constraint set has no solution. See the [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), especially its `rand`/`randc` and constraint-block sections; the proposal explains that constraints are SystemVerilog expressions and that `randomize()` must satisfy them.

The declared `bit [3:0] a` has sixteen unsigned representable values, 0 through 15. Therefore no value of `a` can satisfy `a>16`. That conclusion is a direct consequence of the declared width and the relational constraint; it is not a simulator-specific result. The same Accellera material explains that a constraint expression restricts the random solution space and that randomization may fail when no satisfying solution remains. The current [IEEE 1800 SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/7743/) identifies the standard that defines these language semantics; the [IEEE 1800-2017 LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) is retained as the repository's detailed language reference.

The loop's ten calls do not themselves create a higher-level sequence policy. They request ten successive solves. A more complex legal sequence would be expressed by additional random variables and constraints, by repeated calls to `randomize()`, or by a separate sequence-generation layer around the randomized transaction. None of those additional mechanisms is present in the saved source, so this README explains the question without rewriting the example.

**Practical implication or pitfall**

A `randc` declaration does not override an impossible constraint. In this playground the first `g.randomize()` is expected to report failure because `a>16` has no legal 4-bit value; the ten-iteration loop therefore demonstrates the failure path rather than producing ten random stimuli. The commented-out `status = g.randomize()` line is preserved as an experiment, but it is not the active source of the result.

**Sources**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

