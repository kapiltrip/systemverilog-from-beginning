# Part 07 — Whole-Array Copying

[← Part 06](../06-array-iteration/README.md) · [Learning index](../README.md) · [Part 08 →](../08-queue-operations/README.md)

EDA Playground: [Whole-Array Copying](https://edaplayground.com/x/CafY)  
EDA Playground Name: `Whole-Array Copying`  
Saved code ID: `7356412`

## Why this example matters

The active example grows a dynamic array with `new[30](arr)`, preserving the existing elements while allocating a larger container, and then assigns that array into a compatible fixed array. Those are value-copy operations; the destination does not become another handle to the same array storage.

That snapshot behavior is why copying appears in scoreboard discussions. Expected data and observed data must remain independently inspectable. Copying records a value state; comparison is a separate step that decides whether the two states agree.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
// compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, 
// CONDITION 1 SAME DATA TYPE AND 
// CONDITION 2 SAME SIZE 
//07 
/*
module tb ;
  int arr1[5];
  int arr2[5];
  int status ; 
  
  initial begin
    for(int i =0; i<5 ; i++)begin
      arr1[i]= 5*i ; 
      
    end
    $display("the content of arr1 is %0p" , arr1); 

    arr2= arr1; 
    $display("the content of arr2 is %0p" , arr2); 
    arr2[2] = 11; 
    $display("the content of arr2 is now  %0p" , arr2); 
    
  end
  initial begin
    status = (arr1 !=  arr2 ); 
    $display("The following arrays are : having status as %0d" , status ); // should return true 
    
  end
endmodule
*/ 
module tb; 
  int arr[];
  int arrfixed[30]; 

  initial begin
    arr = new[5];
    //of storing an element 
    for(int i =0 ; i<5 ; i++)begin
      arr[i] = 5 * i ; 
      
    end
    $display("the values in the array arr is %0p" , arr ) ; 
    $display("the size of array arr is %0d" , arr.size() ) ; 

    //arr.delete();   
    //why its not having default value printed xxxx cause i deleted and its a 4 state logic 
    
    $display("the values in the array arr is %0p" , arr ) ; 
    $display("the size of array arr is %0d" , arr.size() ) ; 
   // arr = new [30]; 
    arr = new [30](arr);
    $display("the values in the array arr is %0p" , arr ) ; 

    $display("the size of array arr is %0d" , arr.size() ) ; 
    //to store that in fixed size array 
    arrfixed = arr ; 
    $display("the values in the fixed size array arr is %0p" , arrfixed ) ; 

  end
  //have to use new keyword when i want to add elements 
  
endmodule
~~~

## Questions from the code, explained

### Why is copying used in a scoreboard?

**Question in the source**

> // compare element in scoreboard , golden data + dut response compare elememnt by element and copy used here, 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The opening comment describes a scoreboard use case before the commented fixed-array experiment and the active dynamic-array copy.

**Answer**

Copying records a value snapshot so expected or observed data can be compared without making the two storage objects aliases.

**Why this works**

A scoreboard commonly keeps a reference model or golden data and compares it with a DUT response. Whole-array assignment copies the compatible elements into the destination. After the assignment, changing one array element does not change the other array's element, so the destination can represent the response at a particular point while the source remains the expected snapshot. The copy itself is not the comparison; an equality or per-element comparison is a separate operation. The exact source also contains a second initial block in its commented experiment, so the timing of that comparison is a separate issue from the storage semantics.

**Watch for**

Copy before mutating the data you want to preserve, and keep the comparison step explicit. A reference handle or shared object would not provide the same independent snapshot.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Should the array comparison return true?

**Question in the source**

>     $display("The following arrays are : having status as %0d" , status ); // should return true 

**Where it appears**

`testbench.sv:28` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is attached to the display of status in the commented fixed-array experiment, where status is assigned from arr1 != arr2.

**Answer**

It should be true only after arr1 and arr2 have been populated and made different; the comment is not enough to guarantee that the two concurrent initial blocks observe that state.

**Why this works**

For compatible integral arrays, != produces a logical comparison of the current values. After arr2[2] is changed from the copied value, arr1 and arr2 differ, so the intended status is 1/true. But both initial blocks begin at time zero. The comparison block can execute before the other block has completed initialization, copy, and mutation. If unknown values participate, a four-state comparison can also yield X rather than a definite Boolean result. Therefore the intended mathematical result is true for the post-mutation state, while the unsynchronized source does not guarantee when that state is sampled.

**Watch for**

A comment saying true is a desired result, not a synchronization mechanism. Schedule the comparison after the copy and mutation if deterministic observation is required; this README does not alter the original source.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why does deleting the array not print XXXX?

**Question in the source**

>     //why its not having default value printed xxxx cause i deleted and its a 4 state logic 

**Where it appears**

`testbench.sv:48` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The question follows a commented arr.delete() call in the active dynamic-array example, which declares arr as int arr[].

**Answer**

delete removes the dynamic-array storage and leaves it with size zero; it does not leave thirty-four-state elements available to print. Also, the declared int is not the four-state logic type assumed by the comment.

**Why this works**

The delete method on a dynamic array deallocates its elements and sets its size to zero. With no elements, there is no indexed collection whose default bits can be displayed as XXXX. If the array is later allocated again, the element type's default-value rules apply to the new elements. The source declares int, whereas the LRM distinguishes two-state and four-state integral types; the comment's four-state assumption should not be silently applied to this declaration. The exact printed representation of an empty aggregate is simulator formatting, but it is not a row of X-valued elements.

**Watch for**

Check both the array size and the declared element type before interpreting %p output. Do not use an expected X pattern to diagnose an array that has already been deleted.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Why is new needed to add elements?

**Question in the source**

>   //have to use new keyword when i want to add elements 

**Where it appears**

`testbench.sv:62` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment follows the declaration and first use of the dynamic array arr[].

**Answer**

A dynamic array needs new[n] to allocate its element storage and establish a size before indexed elements can be assigned.

**Why this works**

The declaration `int arr[]` describes a dynamic-array variable but does not allocate a fixed number of elements. The `new` constructor creates the run-time array object with the requested size. After `arr = new[5]`, indexed assignments have storage to write. The later form `new[30](arr)` creates a new thirty-element dynamic array and initializes it from the old array, which is why the original values can be retained while the capacity changes. This is different from a queue, whose push methods grow the queue directly.

**Watch for**

Use the operation that belongs to the collection type: new for dynamic-array allocation/resizing, and queue methods such as push_front or push_back for queues.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



