# Part 02 — SV 02 - Clock Generation

EDA Playground: [SV 02 - Clock Generation](https://edaplayground.com/x/gi86)  
EDA Playground Name: `SV 02 - Clock Generation`  
Saved code ID: `7356140`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace or correct the code.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
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
//`timescale 1ns/1ns //1 digits valid after the decimal point
`timescale 1ns/1ps //3 digits valid after the decimal point

module tb();
  //in tb we dont need a sensitivity list in the always block why ? 
  // in the design we need to evaluate for change hence in sensitivity list 
  /*
  always // ignoring sensitivity list 
    always begin
        
    end
    */ 
  reg clk ;  // x by default so i have to initialize 
  reg clk50MHZ;
  reg clk25Mhz; 
  reg clk16Mhz;
  reg clk8Mhz; 
  
  reg rst; 
  //always block to generate a clock signal 
  //100 MHZ 
  //period == 10 ns , and half clock period is 5 ns 
  // run forever 
  initial begin
    rst = 1'b0 ; 
    clk = 1'b0 ;
    clk50MHZ= 1'b0 ; // 20 ns and half is 10 ns 
    
    clk25Mhz = 1'b0 ; 
    clk16Mhz = 1'b0 ; 
    
    clk8Mhz = 1'b0 ; 
    
  end
  always begin
      #5 ; 
      clk50MHZ =1'b1; 
      //#10 clk50MHZ= ~clk50MHZ  ;
      #10 ; 
      clk50MHZ =1'b0; // this is 50 mhz
      #5; 

  end
  always begin
      #31.25 clk16Mhz = ~clk16Mhz ; 
    
  end
  always begin
      #62.5 clk8Mhz = ~clk8Mhz ; 
    
  end
  /*
  always begin
      #20 clk25Mhz = ~ clk25Mhz ;
    
  end
  */
  always begin
      #5;
      clk25Mhz= 1'b1; 
      #20 clk25Mhz = 1'b0 ;
      #5; 
    
  end
  always begin
      #5 clk = ~clk ; 
    
  end
  initial begin
   #200; 
    $finish(); // since im using always block to generate clock 
  end 
  //edges aligned for both clocks
  
  
  initial begin
    $dumpfile("demo.vcd");
    $dumpvars();
  end 
  
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Why does the testbench always block not need a sensitivity list?

**Original code question**

>   //in tb we dont need a sensitivity list in the always block why ? 

**Where it appears**

`testbench.sv:7` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The testbench uses an always process to generate a repeating clock by executing a delay and assignment sequence.

**Answer**

Because this always block is an infinite procedural loop whose timing comes from an explicit delay; it is not an event-controlled combinational process.

**Deep explanation**

An always procedure repeats its statement or statement block forever. In this clock generator, the body contains a delay, so each iteration waits for time to advance before assigning the next clock value. There is no sensitivity list because the process is not waiting for changes on input signals. A sensitivity list is used with an event control to suspend a procedure until selected signals or events occur; it is not a general requirement for every always process. The testbench's job is to create a stimulus waveform, so an explicit delay is the intended trigger.

**Practical implication or pitfall**

A delay-based clock generator and a combinational always_comb block solve different problems. Adding a sensitivity list would change what wakes the process and could prevent the intended free-running clock.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why does the design use a sensitivity list?

**Original code question**

>   // in the design we need to evaluate for change hence in sensitivity list 

**Where it appears**

`testbench.sv:8` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

This comment contrasts the design-side event-driven process with the testbench-side clock-generation process in the same playground.

**Answer**

A sensitivity list identifies the signals whose changes should wake the design process, so the design can reevaluate its response when its inputs change.

**Deep explanation**

A level-sensitive event control such as `always @(a or b)` suspends the process until an event occurs on one of the listed expressions. Once awakened, the statements execute using the current values. That is why a design process that models combinational response lists its input signals: changes to those inputs are the events that require reevaluation. The list is not a declaration of what the design can ever read; it is the set of events that resumes this process. SystemVerilog's specialized always_comb construct can infer sensitivity for combinational logic, but the handwritten example is illustrating the explicit form.

**Practical implication or pitfall**

If a read signal is omitted from a handwritten sensitivity list, an input change can occur without reevaluating the process, producing stale output in simulation.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why must the initial value be assigned?

**Original code question**

>   reg clk ;  // x by default so i have to initialize 

**Where it appears**

`testbench.sv:15` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is beside the clock or testbench signal declaration and its first assignment.

**Answer**

For a four-state variable, an uninitialized value is X, so the testbench assigns an explicit starting value to avoid beginning with unknown stimulus.

**Deep explanation**

Four-state variables represent 0, 1, X, and Z. The LRM's default-value rules give an uninitialized four-state integral variable an unknown X value. A clock-like signal that starts as X can make edge controls and displayed output ambiguous until a real 0 or 1 is assigned. The explicit initialization establishes the known starting phase used by the rest of this testbench. This is initialization of the variable's simulation state, not a sensitivity-list requirement.

**Practical implication or pitfall**

If the first transition is expected to be a clean 0-to-1 edge, initialize to 0 before generating the clock; starting at X can change which transitions event controls recognize.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).





