# Part 05 — SV 05 - Fixed Arrays and For Loop

EDA Playground: [SV 05 - Fixed Arrays and For Loop](https://edaplayground.com/x/8k9Q)  
EDA Playground Name: `SV 05 - Fixed Arrays and For Loop`  
Saved code ID: `7356341`

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
// arrays to start collecting the transactions that monitor send to scoreboards 

`timescale 1ns/1ps 
/*
module tb;
  bit arr1[8]; // array of 8 elements  // 2 state bit type 
  
  bit arr[] = {1,0,1,1}; // compiler will make the size ==4
  initial begin
    $display("size of arr1 is %0d and that of arr is %0d " , $size(arr1) , $size(arr)); 
    $display("value of first element if %0d" , arr[0]); 
    arr[1]= 1; 
    $display("value of second element if %0d" , arr[1]); 
    $display ("value of all the elements fo arr is : %0p" , arr  ); 
    // if the array is not initialize or given size i cant put any element inside 
    
  end
  //INITIALIZATION 
  
  //to initialize with unique values , or repetitive value or default value 
  
  
endmodule
*/
/*
module tb;
  int arr[5] = '{1,2,3,4,5}; 
  initial begin
    $display("all the elements of arr is %0p" , arr ); 
  end
  int arr2[5] = '{5{1'b0}}; 
  initial begin
    $display("all the elements of arr2 is %0p" , arr2 ); 
  end
  int arr3[5] = '{default : 2 }; 
  initial begin
    $display("all the elements of arr3 is %0p" , arr3 ); 
  end
  // repetition operator 
  
  int arr5[3] = '{3{3'd3}}; 
  initial begin
    $display("all the elements of arr5 is %0p" , arr5 ); 
  end
  
endmodule
*/
//REPEATING OPERATIONS 
// FOR , REPEAT AND FOR EACH LOOP 

module tb; 
  int arr [10];
  int i=0; 
  // need a procedural block 
  initial begin
    for(i =0;i<10 ; i++)begin
      arr[i]= i; 
      
    end
    $display("The values of the arr are  : %0p" , arr); 
  end
endmodule




















~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### How is the fixed array size determined?

**Original code question**

>   bit arr[] = {1,0,1,1}; // compiler will make the size ==4

**Where it appears**

`testbench.sv:10` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is next to a fixed unpacked array declaration with an explicitly written range.

**Answer**

The declared range determines the number of elements; the compiler does not choose an arbitrary size.

**Deep explanation**

A fixed unpacked array has bounds in its declaration. For a declaration using four element positions, the compiler knows the array shape at elaboration/compile time and allocates that fixed set of elements. This is different from a dynamic array, whose size is set at run time with new. The comment is therefore best read as an observation that the declared form makes the size known to the compiler, not that the tool infers four from no information.

**Practical implication or pitfall**

When changing a fixed array, count the actual index range rather than assuming the size from the type name. Dynamic and fixed arrays use different sizing mechanisms.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Can an unsized or uninitialized array accept an element?

**Original code question**

>     // if the array is not initialize or given size i cant put any element inside 

**Where it appears**

`testbench.sv:17` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment appears before the example allocates or fills an array and contrasts run-time allocation with a fixed declaration.

**Answer**

A dynamic array must be allocated with a nonzero size before an indexed element can be stored; a fixed array already has storage from its declaration.

**Deep explanation**

A dynamic array declaration creates a variable whose elements are allocated later. Until new[n] has supplied a size, there is no indexed element storage to receive arr[i]. A fixed unpacked array, by contrast, gets its bounds from the declaration and can be indexed immediately. The exact source also experiments with initialization forms, so the comment is about storage availability, not about whether an assignment statement is syntactically possible.

**Practical implication or pitfall**

Call new with the intended size before indexing a dynamic array. Resizing later can replace the dynamic storage, so use the constructor-with-initializer form when old values must be preserved.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### What does the initialization comment distinguish?

**Original code question**

>   //to initialize with unique values , or repetitive value or default value 

**Where it appears**

`testbench.sv:22` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is beside the array initialization examples in the fixed-array and for-loop experiment.

**Answer**

It distinguishes aggregate initialization patterns: explicitly different element values, a repeated value, and default initialization.

**Deep explanation**

SystemVerilog array literals and assignment patterns can initialize collections in more than one way. An explicit list gives position-specific values; a repeated/default pattern applies one value or a type default across the selected elements. The visible result depends on the element type: integral four-state elements can show X when left at their default, while an explicit integer pattern produces known values. This playground is comparing initialization syntax with later indexed traversal.

**Practical implication or pitfall**

Do not confuse a repeated pattern with a sequence of unique values. Inspect the initializer and the element type before predicting the printed aggregate.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why is a procedural block needed here?

**Original code question**

>   // need a procedural block 

**Where it appears**

`testbench.sv:56` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment precedes a loop or assignment sequence that performs work after simulation starts.

**Answer**

A loop containing procedural assignments needs a procedural context such as initial or always so the simulator knows when and how to execute it.

**Deep explanation**

Declarations and constant expressions can be elaborated without a run-time process, but assignments and control-flow statements execute procedurally. An initial block starts once, while an always-family process can repeat in response to time or events. The example's loop is doing run-time array work, so placing it in an initial block gives it an execution thread at time zero. The block is a scheduling container; it is not what allocates a fixed array's compile-time storage.

**Practical implication or pitfall**

Putting a procedural statement at module scope or outside a valid process leads to a syntax or elaboration problem. Put the run-time sequence in the process that matches its intended timing.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).





