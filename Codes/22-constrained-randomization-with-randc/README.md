# Part 22 — Constrained Randomization with randc

EDA Playground: [Constrained Randomization with randc](https://edaplayground.com/x/Fqxx)  
EDA Playground Name: `Constrained Randomization with randc`  
Saved code ID: `7358472`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanation below does not replace, correct, or improve the code.

## Saved playground settings

- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`

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
  constraint data {a>10; }
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
    /*
    //10 random stimuli 
    for(i=0; i<10; i++)begin
      //status = g.randomize();
      if(!g.randomize()) begin
        $display("Randomize failed at time %0t" , $time ); 
        
      end

      
    end
    */
    assert(g.randomize()) else begin
      $display("Randomization failed : at time %0t " , $time) ; 
      
    end
    $display("Values for a is %0d and for b is %0d" , g.a, g.b) ; 
    #10;
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

The saved testbench defines a `generator` class with two `randc bit [3:0]` members and the constraint `a>10`. The ten-iteration random-stimulus loop is preserved inside a block comment; the active code calls `assert(g.randomize())`, displays `a` and `b`, and then delays for 10 time units. The block comment records the author's distinction between cyclic randomization and ordinary randomization.

**Answer**

SystemVerilog generates constrained stimulus by declaring random variables, declaring constraints that describe legal combinations, and calling `randomize()`; `randc` adds a randomized cyclic, no-repeat traversal of a variable's value range. In this exact source, `a>10` restricts the declared 4-bit `a` to legal values 11 through 15, so the active `assert(g.randomize())` can request a valid constrained solution.

**Deep explanation**

The official Accellera random-constraints proposal describes `rand` variables as ordinary random variables and `randc` variables as random-cyclic variables that traverse a random permutation of their declared range. It also states that the permutation is recomputed when the remaining values cannot satisfy the active constraints, and that randomization can fail when the constraint set has no solution. See the [Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), especially its `rand`/`randc` and constraint-block sections; the proposal explains that constraints are SystemVerilog expressions and that `randomize()` must satisfy them.

The declared `bit [3:0] a` has sixteen unsigned representable values, 0 through 15. Therefore `a>10` leaves the five-value solution set 11, 12, 13, 14, and 15. That conclusion follows from the declared width and relational constraint; it is not a simulator-specific result. The Accellera material explains that a constraint expression restricts the random solution space and that `randomize()` solves for values satisfying the active constraints. The current [IEEE 1800 SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/7743/) identifies the standard that defines these language semantics; the [IEEE 1800-2017 LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) is retained as the repository's detailed language reference.

The commented-out loop shows one possible repeated-stimulus structure, but it is not active in the saved source. The active code makes one constrained solve, prints the resulting `a` and `b`, and delays. A more complex legal sequence would require additional active randomization calls, variables, constraints, or a separate sequence-generation layer; none is added here.

**Practical implication or pitfall**

A `randc` declaration does not remove the active constraint. In this playground `a>10` is satisfiable, but it still limits `a` to 11–15. The commented-out `status = g.randomize()` and ten-iteration loop are preserved as experiments; the active source instead uses one assertion-checked randomization and a display.

**Sources**

[Accellera random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf), [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

