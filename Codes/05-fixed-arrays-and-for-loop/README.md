# Part 05 — Fixed arrays and `for` loops

EDA Playground: [https://edaplayground.com/x/8k9Q](https://edaplayground.com/x/8k9Q)

This part introduces unpacked arrays, whole-array display with `%p`, initialization patterns, and procedural population using a `for` loop.

## Complete testbench code

The complete source is rendered here and remains available as [`testbench.sv`](testbench.sv). The commented sections preserve the earlier array experiments that lead to the active `for`-loop example.

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

## Answers and notes

- `int arr[10]` declares a fixed-size unpacked array with ten elements indexed from 0 through 9.
- `%0p` prints an aggregate such as an array in a readable form. `$size(arr)` returns its element count.
- Assignment-pattern syntax uses an apostrophe: `'{1, 2, 3, 4, 5}`.
- `'{5{1'b0}}` repeats the value five times; `'{default: 2}` supplies a value for every otherwise unspecified element.
- A dynamic array declared as `int arr[]` must be sized with `new[n]` before assigning individual indices. It can also receive an assignment from a compatible array value that determines its size.
- A `for` loop is appropriate when the index, limit, and increment are explicit. `foreach` is usually safer when the goal is to visit every legal array index.

## Detailed discussion

### Packed versus unpacked placement

In `int arr[10]`, the dimension appears after the variable name, so it is an unpacked array containing ten separate `int` elements. Each element is itself a 32-bit signed four-state value. This differs from a packed vector such as `logic [9:0] value`, which is one ten-bit integral value.

### Static and dynamic array behavior

`int arr[10]` is fixed-size storage with legal indices 0 through 9. The commented declaration `bit arr[]` describes a dynamic array, whose size is established at runtime. A dynamic array must be allocated before individual indexed writes, or assigned from a compatible aggregate. The intended initialization should use an assignment pattern:

~~~systemverilog
bit arr[] = '{1, 0, 1, 1};
~~~

The apostrophe distinguishes a SystemVerilog assignment pattern from an ordinary packed concatenation.

### Three useful initialization styles

| Form | Meaning |
| --- | --- |
| `'{1, 2, 3, 4, 5}` | Supplies a distinct value for each element. |
| `'{5{1'b0}}` | Repeats one value five times. |
| `'{default: 2}` | Assigns 2 to every element not otherwise named. |

These forms describe the entire array value at once. They are especially useful for deterministic testbench setup because they avoid leaving elements uninitialized.

### What the active loop produces

The active `for` loop begins with `i = 0`, continues while `i < 10`, and increments after every iteration. Consequently, each legal index receives its own index value. The final aggregate is `'{0, 1, 2, 3, 4, 5, 6, 7, 8, 9}`, and `%0p` asks the simulator to print the whole unpacked structure.

### Verification connection

Monitors and scoreboards commonly collect transactions in arrays, queues, or mailboxes. This fixed-array example demonstrates the basic element-access and aggregate-printing operations that later make expected-versus-actual data structures observable during debugging.

### Points to remember

- A dimension after the variable name is unpacked.
- Fixed arrays have compile-time bounds; dynamic arrays need runtime sizing.
- SystemVerilog assignment patterns begin with an apostrophe.
- Prefer `foreach` when array bounds—not a hard-coded count—should control iteration.
