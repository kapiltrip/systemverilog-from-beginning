# Part 12 — Array Reference Passing

EDA Playground: [Array Reference Passing](https://edaplayground.com/x/ADYn)  
EDA Playground Name: `Array Reference Passing`  
Saved code ID: `7357071`

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
//Copying an array to stack is not an optimum choice 
module tb ; 
  bit [3:0] res[16] ; 
  
  function automatic void init_arr( ref bit [3:0] a [16]); // 4 bit 16 elements 
    for(int i=0;i<16 ; i++ )begin
      a[i] = i ; 
      
    end
  endfunction 
  initial begin
    init_arr(res); 
    $display("Values the array res is having are : %0p" , res) ; 
  end
endmodule
*/
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Why is copying an array to the stack considered non-optimal?

**Original code question**

> //Copying an array to stack is not an optimum choice 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment precedes a commented function that initializes a sixteen-element array and contrasts an array formal passed by ref.

**Answer**

Passing the array by value can require a copy of the entire aggregate, while ref lets the function operate on the caller's array without that value copy; the standard does not require a particular physical stack implementation.

**Deep explanation**

An unpacked array is an aggregate of elements. A value argument represents a separate argument value, so an implementation may need to copy the elements when the function is called. The ref formal in init_arr instead refers to the caller's res array, and the loop writes res[i] through that reference. This avoids the value-copy semantics and makes the caller-visible update explicit. The phrase stack is an implementation metaphor, not a portable promise about where a simulator stores an array; the portable language distinction is value versus reference and the resulting visibility/cost behavior.

**Practical implication or pitfall**

Use ref when a large aggregate should be updated in place and the lifetime/aliasing contract is understood. Do not infer stack layout from source syntax.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



