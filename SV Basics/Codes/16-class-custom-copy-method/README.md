# Part 16 — Class Custom Copy Method

[← Part 15](../15-class-shallow-copy/README.md) · [Learning index](../README.md) · [Part 17 →](../17-class-deep-copy-with-nested-objects/README.md)

EDA Playground: [Class Custom Copy Method](https://edaplayground.com/x/X4c6)  
EDA Playground Name: `Class Custom Copy Method`  
Saved code ID: `7357655`

## Why this example matters

A custom `copy()` method makes the copy policy explicit: it allocates a destination object, assigns the members that should be preserved, and returns the new handle. Unlike the constructor, it starts from an existing object's state rather than only from call arguments or defaults.

The method is easy to reason about because every copied field is visible, but that is also its maintenance cost. When the class gains a member, the copy method must deliberately include it or deliberately document why it is excluded.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
class first ; 
  int data = 34 ; 
  bit [7:0] temp= 8'h11; 
  
  // custom methods to copy 
  function first copy();
    copy= new(); 
    copy.data = data;    // why am i not using this here, 
    copy.temp = temp ; 
    
  endfunction 
endclass

module tb ; 
  first f1;
  first f2 ; 
  // to store copy of f1 to f2
  /*
  initial begin
    f1=new();
    f1.data = 45; 
    
    f2=new f1;  // copy of the data members of f1 to f2
    
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    // this is not changing f1 
    
    f2.data = 56;
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    $display("Data member of f1 now becomes a copy %0d " , f1.data );

  end
  */
  initial begin
    f1=new();
    f2=new();
    f2= f1.copy;     //automatically copies  why i havent used f1.copy() 
    $display("Data : %0d and temp is %0h" , f2.data, f2.temp); // he called hex by using %0x 
  end
endmodule
~~~

## Preserved editor copy (`editor_testbench.sv`)

~~~systemverilog
// Code your testbench here
// or browse Examples
class first ; 
  int data = 34 ; 
  bit [7:0] temp= 8'h11; 
  
  // custom methods to copy 
  function first copy();
    copy= new(); 
    copy.data = data;    // why am i not using this here, 
    copy.temp = temp ; 
    
  endfunction 
endclass

module tb ; 
  first f1;
  first f2 ; 
  // to store copy of f1 to f2
  /*
  initial begin
    f1=new();
    f1.data = 45; 
    
    f2=new f1;  // copy of the data members of f1 to f2
    
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    // this is not changing f1 
    
    f2.data = 56;
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    $display("Data member of f1 now becomes a copy %0d " , f1.data );

  end
  */
  initial begin
    f1=new();
    f2=new();
    f2= f1.copy;     //automatically copies  why i havent used f1.copy() 
    $display("Data : %0d and temp is %0h" , f2.data, f2.temp); // he called hex by using %0x 
  end
endmodule
~~~

## Questions from the code, explained

### What is a custom method for copying?

**Question in the source**

>   // custom methods to copy 

**Where it appears**

`testbench.sv:7` — the exact comment in the live EDA Playground testbench pane; the identical baseline capture is also in `editor_testbench.sv:7`.

**What the code is doing**

The comment precedes function first copy(), which constructs a new first object and assigns its members.

**Answer**

It is a user-defined class method that controls how a new object is created and which members receive copied values.

**Why this works**

The copy function returns first, allocates a new object with copy=new(), and explicitly assigns data and temp from the source object. This is different from relying on the language's shallow copy construction because the method makes the copy policy visible in source and can be extended for nested objects or selected fields. The returned handle is then used by the caller.

**Watch for**

A custom method must be maintained when the class gains new state. An omitted member is not copied merely because another member is.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why is this not used in the member assignments?

**Question in the source**

>     copy.data = data;    // why am i not using this here, 

**Where it appears**

`testbench.sv:10` — the exact comment in the live EDA Playground testbench pane; the identical baseline capture is also in `editor_testbench.sv:10`.

**What the code is doing**

The comment is beside copy.data = data and asks why the method does not write this.data or this.temp on the right-hand side.

**Answer**

Inside the copy method, unqualified data and temp refer to the source object's members; this is also available, but this.data would explicitly name that same source member.

**Why this works**

A method executes with an implicit this handle referring to the object on which it was called. Therefore the right-hand-side data and temp resolve to the source object's properties. The left-hand side copy.data selects the newly constructed destination object through the returned local handle named copy. Writing copy.data = this.data would be more explicit but would express the same source-to-destination relationship for these members.

**Watch for**

Use this when clarity or name disambiguation requires it. The absence of this does not mean the method is copying from an unrelated object.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why is a copy of f1 stored in f2?

**Question in the source**

>   // to store copy of f1 to f2

**Where it appears**

`testbench.sv:19` — the exact comment in the live EDA Playground testbench pane; the identical baseline capture is also in `editor_testbench.sv:19`.

**What the code is doing**

The comment labels the active initial block before f1 and f2 are constructed and f2 is assigned the result of f1.copy.

**Answer**

f2 receives the new handle returned by f1.copy so it refers to a distinct object initialized from f1.

**Why this works**

The method call constructs a fresh first object and returns its handle. Assigning that handle to f2 gives the testbench a second object whose data and temp initially match f1. Subsequent mutations of f2's scalar members can be compared with f1 to demonstrate independent state. The assignment is to a handle variable, but the handle points to a newly allocated object because copy created it.

**Watch for**

Keep the source handle f1 alive while the copy is made, and remember that f2=f1.copy is not the same operation as f2=f1.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does copying the data members mean?

**Question in the source**

>     f2=new f1;  // copy of the data members of f1 to f2

**Where it appears**

`testbench.sv:25` — the exact comment in the live EDA Playground testbench pane; the identical baseline capture is also in `editor_testbench.sv:25`.

**What the code is doing**

This comment is inside a block-commented alternative that uses f2=new f1 and displays f2.data.

**Answer**

It means initializing the corresponding members of a new f2 object from the current member values of f1.

**Why this works**

The phrase describes member-wise state transfer, not copying the handle bits as an alias. In the active custom method, data and temp are explicitly assigned into the new destination object. The commented alternative illustrates the language's built-in shallow copy path. For these scalar fields both approaches give f2 its own value storage; for nested class handles a shallow copy would share the nested object.

**Watch for**

State which members are copied and whether nested handles are cloned. “Copy the object” is too broad to determine aliasing by itself.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why can f1.copy be called without parentheses?

**Question in the source**

>     f2= f1.copy;     //automatically copies  why i havent used f1.copy() 

**Where it appears**

`testbench.sv:39` — the exact comment in the live EDA Playground testbench pane; the identical baseline capture is also in `editor_testbench.sv:39`.

**What the code is doing**

The active assignment is f2= f1.copy; and the comment asks about the missing empty parentheses on the zero-argument copy function.

**Answer**

For a zero-argument method, SystemVerilog permits the empty argument list to be omitted in this method-call context, so f1.copy invokes copy and returns its handle.

**Why this works**

copy is declared as a function with no formal arguments and a return type first. The expression f1.copy is therefore the no-argument method call form accepted by the language; f1.copy() is the explicit spelling. In either form, the function body runs, allocates a new first object, copies data and temp, and returns the new handle. This is not a property read: the function call is what performs the allocation and copy.

**Watch for**

If a method gains arguments, write and preserve the explicit argument list. When readability matters, f1.copy() can make the call intent clearer even where omission is legal.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



