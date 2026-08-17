# Part 28 — Constraint Operators, Distribution, and Modes

EDA Playground: [Constraint Operators, Distribution, and Modes](https://edaplayground.com/x/Lb86)  
EDA Playground Name: `Constraint Operators, Distribution, and Modes`  
Saved code ID: `7359263`

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
//types of operator 
// 1) -> implication operator 
// 2) -> equivalence <-> working with control signal , and  if else 
// turning on and off the constraints 

class generator ; 
  randc bit [3:0] a; 
  rand bit ce;
  rand bit rst; 
  rand bit wr; //write 
  rand bit readen ; // readenable 
  rand bit [3:0] raddr , waddr ; 
  
  constraint control_rst{
    rst dist {0:= 80 , 1:= 20} ;  // what if i do 40 for 1 in rst 
    
  }
  constraint control_ce{
    ce dist {1:= 80 , 0 := 20 }; 
  }
  constraint control_rst_ce{
    // implication 
    (rst ==0 ) -> (ce == 1 ) ; 
  }
  constraint wr_readenable{
    //equivalence operator 
    (wr==1) <-> (readen==0); 
  }
  //constraint on wr and readen // both 50 50 distribution 
  constraint wr_const{
    wr dist {0 := 50 , 1:= 50} ; 
  }
  constraint readen_const {
    readen dist {0 := 50 , 1:= 50 }; 
  }
  constraint write_read{
    if(wr==1){
      waddr inside {[11:15]};
      raddr ==0; 
      
    }else {
      waddr ==0; // we have to do == not =  
      raddr inside {[11:15]}; // inside th ehigher valued range 
      
    }
  }
endclass
module tb; 
  generator g ; 
  initial begin
    g=new(); 
    g.write_read.constraint_mode(0) ; // 1-> constraint on 0 - > constraint off 
    $display("The condition of the constraint is %0d" , g.write_read.constraint_mode());
    for(int i =0 ; i<10 ; i++)begin
      assert(g.randomize()) else $display("Randomization failed ") ; 
      $display("The values for rst is %0b ,and ce is %0b  " , g.rst, g.ce); 
      $display("The values for write is %0b ,and readEnable  is %0b  " , g.wr, g.readen); 
      $display("The values for raddr is %0d ,and waddr  is %0d  " , g.raddr, g.waddr); 
      
    end
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID Lb86. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

### What happens if the `rst` distribution weight for `1` changes to 40?

**Original code question**

> what if i do 40 for 1 in rst

**Where it appears**

`testbench.sv:17`, in `constraint control_rst`.

**Context in this playground**

The source declares `rst` as a one-bit random variable and gives `rst == 0` a `:= 80` weight and `rst == 1` a `:= 20` weight. The same class also constrains `ce`, relates `rst` to `ce` with implication, relates `wr` and `readen` with equivalence, and disables `write_read` before the loop. Thus the randomizer solves a connected set of active constraints rather than sampling `rst` in isolation.

**Answer**

Changing the `rst == 1` weight from 20 to 40 increases its relative distribution weight; for the two `rst` items alone, the ratio would change from 80:20 to 80:40, or 2:1. The complete playground is not guaranteed to print `rst == 1` exactly one third of the time, because the other active constraints participate in the joint solution space.

**Deep explanation**

The `dist` construct both restricts the legal set and supplies relative weights. The Accellera random-constraints proposal states that `:=` applies the specified weight to the item (and to every value when the item is a range), and that increasing a weight increases the likelihood of the associated values. The weights are mixing ratios, not required percentages; 80 and 40 therefore express the same relative preference as 2 and 1.

Here, `rst` is also part of `(rst ==0) -> (ce == 1)`. When `rst` is 0, the implication requires `ce` to be 1; when `rst` is 1, that implication is satisfied without forcing `ce`. The solver must find legal combinations for all active random variables and constraints, so the marginal frequency observed for `rst` depends on the joint constraint problem and the simulator's implementation of weighted solving. The standard source establishes the monotonic weighting rule, but it does not justify treating this particular multi-variable experiment as an exact 80/20 or 80/40 print-count test.

**Practical implication or pitfall**

Use weights to express relative preference, then measure a sufficiently large run if you want to study the observed distribution. Do not infer an exact percentage from the ten iterations in this source, and do not read `:= 40` as “40 percent.”

**Sources**

[Accellera SystemVerilog random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) defines `dist`, `:=`, `:/`, weighted ranges, and monotonic weighting. The [IEEE 1800-2023 SystemVerilog standard page](https://standards.ieee.org/ieee/1800/7743/) identifies the current language standard governing constrained-random verification.

### Why is `==` used instead of `=` in this constraint?

**Original code question**

> we have to do == not =

**Where it appears**

`testbench.sv:44`, on the inline comment attached to `waddr ==0` in the `else` branch of `constraint write_read`.

**Context in this playground**

The `write_read` constraint uses `if (wr==1)` to select the write case and `else` to select the read case. In the write case, `waddr` is inside `[11:15]` and `raddr` is 0. In the read case, `waddr` is 0 and `raddr` is inside `[11:15]`. These are relationships the constraint solver must satisfy for the randomized values.

**Answer**

`==` expresses an equality relation for the constraint solver; `=` is the assignment operator. The line needs a relation saying that the legal value of `waddr` is zero, not a procedural assignment that executes and changes `waddr`.

**Deep explanation**

Constraint expressions use SystemVerilog expression syntax and describe a solution set. The Accellera proposal's operator table distinguishes `==` among equality operators from `=` among assignment operators, and its constraint examples use relations such as `z == x + y`. In this source, `waddr == 0` excludes every candidate value except zero when the `else` branch is active. The other line, `waddr inside {[11:15]}`, similarly describes a legal set rather than performing a procedural update.

A procedural assignment such as `waddr = 0` belongs to a procedural statement context. It is not the equality relation intended by this constraint block, so substituting it would change the language construct rather than merely changing punctuation. The `if`/`else` constraint form itself selects which relation must hold; it does not execute an imperative assignment.

**Practical implication or pitfall**

When writing a constraint, use relational operators to describe legal values (`==`, `<`, `inside`, and so on). Keep procedural assignments in procedural code. The two forms may look similar to a beginner, but they have different roles and are not interchangeable in this context.

**Sources**

[Accellera SystemVerilog random-constraints proposal](https://www.accellera.org/images/eda/sv-ec/att-0248/01-Random-Constraints_Proposal.pdf) lists the equality and assignment operators and gives equality-based constraint examples. The [IEEE 1800-2023 SystemVerilog standard page](https://standards.ieee.org/ieee/1800/7743/) identifies the authoritative language standard.

## Verification observed

Live EDA run: Questa completed with Errors: 0 and Warnings: 1 total; the run printed the constraint-mode state as 0 and ten iterations of the randomized values.

The source was captured in two identical complete reads after the page finished loading, and the saved Name, short ID, code ID, and settings were unchanged after the in-place rename and reload.

The live EDA source and settings were not edited during verification.
