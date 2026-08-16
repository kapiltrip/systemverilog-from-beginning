# Part 01 — SV 01 - Simulation Basics

EDA Playground: [SV 01 - Simulation Basics](https://edaplayground.com/x/Ucnp)  
EDA Playground Name: `SV 01 - Simulation Basics`  
Saved code ID: `7356115`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace or correct the code.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

~~~systemverilog
// Code your testbench here
// or browse Examples
//Types of signals global , data , control 
`timescale 1ns/1ps  // time unit  / time precision 

/*

module tb();
  reg a =0;
  initial begin  // will start from time 0 (start of the simulation ) 
    
    a =1; 
    #10;
    a=0; 
    
  end   //variable will hold the value =0 till the end of the simulation 
  
endmodule
*/
module tb();
  reg clk ; 
  reg [3:0] temp ; 
  // coulld be used to initialize a golbal varialbe 
  // to generate random signal for data / control signal 
  // 
  initial begin
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    
  end
  reg reset; 
  initial begin
    clk =1'b0;  //single bit value in the binary format 
    reset=1'b0 ; 
    
  end
  // at the start of simuation 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  // to analyse the values of the variabl es from the beginning of the time 
  initial begin
    $monitor( "Temp : %0d at time %0t  " , temp , $time);
  end
  // analyzing values of variable in console 
  // stop simulation by forcefully calling finish 
  
  initial begin
      #200 ; 
    $finish();
  end
  initial begin
      reset=1'b1; 
    #10;
    reset = 1'b0;
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### What does the time-zero comment mean?

**Original code question**

>   initial begin  // will start from time 0 (start of the simulation ) 

**Where it appears**

`testbench.sv:10` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment sits above an initial block whose first statement initializes the clock-like signal and then uses delays.

**Answer**

Yes. An initial procedure is started once at simulation time zero, so its first statement is eligible to execute in the time-zero activity of this example.

**Deep explanation**

The comment is about the start of the process, not about every statement completing at time zero. The procedure begins at simulation time 0; the assignment before the first delay can therefore establish the initial value at that time. When the procedure reaches a delay such as `#10`, it suspends and resumes at the later simulation time. Other initial or always procedures also start concurrently, so their time-zero statements can interleave according to the simulator's scheduling rules. The exact ordering of same-time updates is a scheduling question; the important point here is that the first activation is anchored at time zero. This is the time model used by this testbench's clock and finish sequence.

**Practical implication or pitfall**

A zero-time start does not make a delayed statement happen immediately. Separate the time-zero initialization from each later delayed assignment.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### What value does the variable retain through the simulation?

**Original code question**

>   end   //variable will hold the value =0 till the end of the simulation 

**Where it appears**

`testbench.sv:16` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment follows an assignment of zero and appears near a later delay or transition in the simulation-basics testbench.

**Answer**

It holds zero until a later procedural assignment changes it; a delay by itself does not change the variable.

**Deep explanation**

A procedural assignment writes the variable, and the value remains stored until another assignment, a force/release, or a related state change affects it. A delay control only suspends the current procedure; it does not implicitly toggle or clear the variable. Thus, if the testbench assigns 0 and no later statement assigns a different value before `$finish`, the observed value remains 0 for the rest of that run. If a later statement drives 1, the interval of zero ends at that assignment's scheduled time.

**Practical implication or pitfall**

Do not infer a new value from the passage of simulation time. Look for the next statement that assigns the signal.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).





