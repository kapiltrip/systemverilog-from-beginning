# Part 06 — SV 06 - Array Iteration

EDA Playground: [SV 06 - Array Iteration](https://edaplayground.com/x/GK3p)  
EDA Playground Name: `SV 06 - Array Iteration`  
Saved code ID: `7356382`

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
module tb; 
  /*
  int arr[10]; 
  // why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? 
  
  initial begin
  foreach(arr[j])begin
    arr[j]=j; 
    $display("the value here, locally update at index %0d   is %0d " , j, arr[j]);
    
  end
  end
  */
  int arr[10]; 
  int i =0; 
  initial begin
    repeat(10)begin
      arr[i]=i ; 
      i++; 
    end
    $display("The array values are %0p" , arr); 
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Why does foreach visit indices zero through nine?

**Original code question**

>   // why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? 

**Where it appears**

`testbench.sv:6` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The testbench uses foreach on an array and prints the loop index variable j without writing explicit bounds in the loop header.

**Answer**

Yes. foreach derives the index traversal from the array's declared bounds; for a ten-element zero-based array, j takes values 0 through 9.

**Deep explanation**

The foreach construct iterates over the index space of the array expression named in its header. It does not use an implicit universal 0-to-9 rule: if the array had different bounds or dimensions, the index variables would follow those bounds and dimensions. In this example the array has ten elements with the usual zero-based range, so the observed sequence is 0,1,...,9. The loop variable is an index, and the body can use it to read or write the corresponding element.

**Practical implication or pitfall**

If the array shape changes, hard-coded expectations about j can become wrong. Let foreach follow the declaration, especially for nonzero or descending bounds.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



