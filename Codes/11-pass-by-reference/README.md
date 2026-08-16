# Part 11 — Pass by Reference

EDA Playground: [Pass by Reference](https://edaplayground.com/x/Ua2v)  
EDA Playground Name: `Pass by Reference`  
Saved code ID: `7357015`

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
module tb;
  task automatic swap(ref bit [1:0] a, b);
    //task automatic swap(const ref bit [1:0] a, ref bit b); 
  //task automatic swap(ref bit [1:0] a, b); 

    bit [1:0] temp; 
    temp = a;
    a  = b;
    b = temp; 
    $display ("value of a is : %0d and b is : %0d " , a,b ) ; 
  endtask
  bit [1:0] c;
  bit [1:0] d; 
  initial begin
    c=1;
    d=2;
    swap(c,d);
    $display ("value of c is : %0d and d is : %0d " , c,d ) ; 
    //wont be reflected to the varaibles outside the task
    // WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING 
    
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Will a value-argument update be reflected outside the task?

**Original code question**

>     //wont be reflected to the varaibles outside the task

**Where it appears**

`testbench.sv:21` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is inside a task experiment that declares swap with ref arguments, and it sits above the explicit swap call on c and d.

**Answer**

Not for pass-by-value arguments; changes to a value formal are local. But the active task here uses ref, so its assignments are intended to update the caller's c and d.

**Deep explanation**

A value argument supplies the task with a copy of the actual value. Assigning the formal then changes that copy and leaves the caller unchanged. A ref argument instead aliases the caller's variable for the duration of the call, so temp=a; a=b; b=temp updates the original c and d. The comment is therefore describing the behavior of the commented or imagined value form, not the active ref declaration. The display after swap is the source's direct observation of the ref behavior.

**Practical implication or pitfall**

Read the formal declaration before interpreting the comment. Replacing ref with a value formal would change the swap's visible result; this pass preserves the original ref code.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why discuss pass by value for scalar arguments?

**Original code question**

>     // WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING 

**Where it appears**

`testbench.sv:22` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The question is beside the two-bit scalar task arguments and the commented alternative signatures.

**Answer**

For a scalar, pass-by-value gives the task an independent copy, which is often the simplest safe input model; it does not let a scalar swap update the caller.

**Deep explanation**

A scalar has a small, directly representable value, so copying it into a task formal is usually straightforward. The task can read the value without affecting the caller. The active example needs the caller's c and d to change, so it declares ref and performs a true swap through the caller's storage. This is a semantic choice, not a judgment that scalar value passing is always better: value is appropriate for read-only input snapshots, while ref is appropriate when the task intentionally mutates caller variables.

**Practical implication or pitfall**

For scalar inputs, value prevents accidental caller updates. Use ref only when the caller-visible mutation is part of the task contract, and document that choice.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



