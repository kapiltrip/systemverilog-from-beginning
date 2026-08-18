# Part 12 — Array Reference Passing

[← Part 11](../11-pass-by-reference/README.md) · [Learning index](../README.md) · [Part 13 →](../13-constructor-arguments/README.md)

EDA Playground: [Array Reference Passing](https://edaplayground.com/x/ADYn)  
EDA Playground Name: `Array Reference Passing`  
Saved code ID: `7357071`

## Why this example matters

This example applies reference passing to an entire fixed unpacked array. The formal and actual must be type-compatible, and element updates made through the formal operate on the caller's array rather than on a private duplicate.

Use this pattern when the procedure is explicitly responsible for modifying shared array state. If the procedure only needs to inspect values, an input-style argument communicates that intent more clearly and reduces accidental mutation.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### Why is copying an array to the stack considered non-optimal?

**Question in the source**

> //Copying an array to stack is not an optimum choice 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment precedes a commented function that initializes a sixteen-element array and contrasts an array formal passed by ref.

**Answer**

Passing the array by value can require a copy of the entire aggregate, while ref lets the function operate on the caller's array without that value copy; the standard does not require a particular physical stack implementation.

**Why this works**

An unpacked array is an aggregate of elements. A value argument represents a separate argument value, so an implementation may need to copy the elements when the function is called. The ref formal in init_arr instead refers to the caller's res array, and the loop writes res[i] through that reference. This avoids the value-copy semantics and makes the caller-visible update explicit. The phrase stack is an implementation metaphor, not a portable promise about where a simulator stores an array; the portable language distinction is value versus reference and the resulting visibility/cost behavior.

**Watch for**

Use ref when a large aggregate should be updated in place and the lifetime/aliasing contract is understood. Do not infer stack layout from source syntax.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



