# Part 05 — SV 05 - Fixed Arrays and For Loop

[← Part 04](../04-data-types-and-time/README.md) · [Learning index](../README.md) · [Part 06 →](../06-array-iteration/README.md)

EDA Playground: [SV 05 - Fixed Arrays and For Loop](https://edaplayground.com/x/8k9Q)  
EDA Playground Name: `SV 05 - Fixed Arrays and For Loop`  
Saved code ID: `7356341`

## Why this example matters

This lesson builds the basic array-reading discipline used later in scoreboards: identify the element type, the unpacked dimensions, and the legal index range before writing the loop. `$size` makes the traversal depend on the declared array rather than a duplicated magic number.

`%p` is useful for seeing an aggregate at once, while an indexed loop is better when each element needs separate processing. The two views answer different questions: one shows the container, the other exposes the operation performed on every entry.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### How does `bit arr[] = {1,0,1,1}` get a size of four?

**Question in the source**

>   bit arr[] = {1,0,1,1}; // compiler will make the size ==4

**Where it appears**

`testbench.sv:10` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is next to a **dynamic unpacked array** declaration. The empty brackets in `arr[]` do not declare a fixed range; the declaration initializer supplies a four-element unpacked value.

**Answer**

`bit arr[]` declares a dynamic array whose initial size would otherwise be zero. In this declaration-assignment context, `{1,0,1,1}` is treated as a four-element unpacked array concatenation, so assignment allocates/resizes `arr` to four elements and copies one value into each element. The size comes from the initializer—not from a fixed bound in the declaration.

**Why this works**

Compare the declarations directly:

| Declaration | Collection kind | When the size is established |
|---|---|---|
| `bit arr1[8];` | Fixed unpacked array | The declaration creates eight elements, indexed `0` through `7` |
| `bit arr[];` | Dynamic unpacked array | It starts empty; `arr.size()` is zero |
| `bit arr[] = {1,0,1,1};` | Dynamic unpacked array with initializer | Whole-array assignment creates four elements |
| `bit arr[] = new[4];` | Dynamic unpacked array with explicit allocation | `new[4]` creates four default-valued elements |

An assignment pattern such as `'{1,0,1,1}` is another clear aggregate spelling. The saved source's `{...}` is legal here because the unpacked-array target supplies the required context. Neither spelling turns `arr[]` into a fixed array; later assignment or `new[n]` may resize it.

**Watch for**

Do not use empty `[]` as evidence of a fixed array. A fixed unpacked dimension contains a size or range; an empty unpacked dimension denotes a dynamic array.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Can an unsized or uninitialized array accept an element?

**Question in the source**

>     // if the array is not initialize or given size i cant put any element inside 

**Where it appears**

`testbench.sv:17` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment appears before the example allocates or fills an array and contrasts run-time allocation with a fixed declaration.

**Answer**

A dynamic array must already contain the indexed element before `arr[i]` can store into it. Storage may be established by `new[n]` **or** by a compatible whole-array assignment/initializer such as the four-element initializer above. An indexed write does not append to or grow an empty dynamic array.

**Why this works**

A bare dynamic-array declaration creates a size-zero array. Until allocation or whole-array assignment supplies elements, index `0` is already out of bounds, so `arr[0] = value` cannot create the first element. A fixed unpacked array, by contrast, gets all of its storage from its declared bounds and can be indexed immediately. A queue is different again: methods such as `push_back` are designed to grow it one element at a time.

**Watch for**

Check `arr.size()` before indexing. Use `new[n]`, `new[n](old_arr)`, or a compatible whole-array assignment according to whether you want default elements, a resized copy, or replacement contents.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### What does the initialization comment distinguish?

**Question in the source**

>   //to initialize with unique values , or repetitive value or default value 

**Where it appears**

`testbench.sv:22` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is beside the array initialization examples in the fixed-array and for-loop experiment.

**Answer**

It distinguishes aggregate initialization patterns: explicitly different element values, a repeated value, and default initialization.

**Why this works**

SystemVerilog assignment patterns begin with an apostrophe: `'{1,2,3,4,5}` supplies position-specific values, `'{5{1'b0}}` repeats a value five times, and `'{default:2}` assigns the default arm to every otherwise-unmatched element. The saved dynamic-array example instead uses an unpacked array concatenation, `{1,0,1,1}`, in an assignment-like context. Both constructs can produce aggregate values, but their grammar and their type/context rules are not interchangeable in every expression.

The element type still matters. In this source the later fixed arrays have `int` elements, and `int` is a 2-state, 32-bit signed type, so a newly created/default `int` element is zero rather than X. Four-state types such as `integer` or `logic` can retain X in an uninitialized element.

**Watch for**

Do not confuse a repeated pattern with a sequence of unique values. Inspect the initializer and the element type before predicting the printed aggregate.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why is a procedural block needed here?

**Question in the source**

>   // need a procedural block 

**Where it appears**

`testbench.sv:56` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment precedes a loop or assignment sequence that performs work after simulation starts.

**Answer**

A loop containing procedural assignments needs a procedural context such as initial or always so the simulator knows when and how to execute it.

**Why this works**

Declarations and constant expressions can be elaborated without a run-time process, but assignments and control-flow statements execute procedurally. An initial block starts once, while an always-family process can repeat in response to time or events. The example's loop is doing run-time array work, so placing it in an initial block gives it an execution thread at time zero. The block is a scheduling container; it is not what allocates a fixed array's compile-time storage.

**Watch for**

Putting a procedural statement at module scope or outside a valid process leads to a syntax or elaboration problem. Put the run-time sequence in the process that matches its intended timing.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).





