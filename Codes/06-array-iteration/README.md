# Part 06 — SV 06 - Array Iteration

[← Part 05](../05-fixed-arrays-and-for-loop/README.md) · [Learning index](../README.md) · [Part 07 →](../07-array-copying/README.md)

EDA Playground: [SV 06 - Array Iteration](https://edaplayground.com/x/GK3p)  
EDA Playground Name: `SV 06 - Array Iteration`  
Saved code ID: `7356382`

## Why this example matters

`foreach` follows the indexes that actually belong to an array, whereas `repeat` only repeats a statement a requested number of times. A `repeat` loop therefore needs separate index management when the body must visit different elements.

This distinction becomes important when dimensions or bounds change. Prefer an iteration construct that expresses the intent directly: use `foreach` to walk array indexes and `repeat` when the count itself is the behavior being modeled.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### Why does foreach visit indices zero through nine?

**Question in the source**

>   // why j is going from 0 to 9 cause im not specifying anything , is it because of foreach loop ? 

**Where it appears**

`testbench.sv:6` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The testbench uses foreach on an array and prints the loop index variable j without writing explicit bounds in the loop header.

**Answer**

Yes. foreach derives the index traversal from the array's declared bounds; for a ten-element zero-based array, j takes values 0 through 9.

**Why this works**

The foreach construct iterates over the index space of the array expression named in its header. It does not use an implicit universal 0-to-9 rule: if the array had different bounds or dimensions, the index variables would follow those bounds and dimensions. In this example the array has ten elements with the usual zero-based range, so the observed sequence is 0,1,...,9. The loop variable is an index, and the body can use it to read or write the corresponding element.

**Watch for**

If the array shape changes, hard-coded expectations about j can become wrong. Let foreach follow the declaration, especially for nonzero or descending bounds.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



