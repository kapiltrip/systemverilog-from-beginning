# Part 11 — Pass by Reference

[← Part 10](../10-tasks-and-functions/README.md) · [Learning index](../README.md) · [Part 12 →](../12-array-reference-passing/README.md)

EDA Playground: [Pass by Reference](https://edaplayground.com/x/Ua2v)  
EDA Playground Name: `Pass by Reference`  
Saved code ID: `7357015`

## Why this example matters

Passing by `ref` gives the callee direct access to the caller's variable, so an assignment inside the task is visible after the call returns. This is aliasing for the duration of the call, not a copy-in/copy-out approximation.

The benefit is efficient, intentional mutation; the risk is hidden side effects. At each call site, identify which arguments may be changed and avoid treating a `ref` task like a pure calculation.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### Will a value-argument update be reflected outside the task?

**Question in the source**

>     //wont be reflected to the varaibles outside the task

**Where it appears**

`testbench.sv:21` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is inside a task experiment that declares swap with ref arguments, and it sits above the explicit swap call on c and d.

**Answer**

Not for pass-by-value arguments; changes to a value formal are local. But the active task here uses ref, so its assignments are intended to update the caller's c and d.

**Why this works**

A value argument supplies the task with a copy of the actual value. Assigning the formal then changes that copy and leaves the caller unchanged. A ref argument instead aliases the caller's variable for the duration of the call, so temp=a; a=b; b=temp updates the original c and d. The comment is therefore describing the behavior of the commented or imagined value form, not the active ref declaration. The display after swap is the source's direct observation of the ref behavior.

**Watch for**

Read the formal declaration before interpreting the comment. Replacing ref with a value formal would change the swap's visible result; this pass preserves the original ref code.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why discuss pass by value for scalar arguments?

**Question in the source**

>     // WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING 

**Where it appears**

`testbench.sv:22` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The question is beside the two-bit scalar task arguments and the commented alternative signatures.

**Answer**

For a scalar, pass-by-value gives the task an independent copy, which is often the simplest safe input model; it does not let a scalar swap update the caller.

**Why this works**

A scalar has a small, directly representable value, so copying it into a task formal is usually straightforward. The task can read the value without affecting the caller. The active example needs the caller's c and d to change, so it declares ref and performs a true swap through the caller's storage. This is a semantic choice, not a judgment that scalar value passing is always better: value is appropriate for read-only input snapshots, while ref is appropriate when the task intentionally mutates caller variables.

**Watch for**

For scalar inputs, value prevents accidental caller updates. Use ref only when the caller-visible mutation is part of the task contract, and document that choice.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



