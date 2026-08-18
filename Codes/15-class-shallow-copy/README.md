# Part 15 — Class Shallow Copy

[← Part 14](../14-class-composition-and-scope/README.md) · [Learning index](../README.md) · [Part 16 →](../16-class-custom-copy-method/README.md)

EDA Playground: [Class Shallow Copy](https://edaplayground.com/x/sVdz)  
EDA Playground Name: `Class Shallow Copy`  
Saved code ID: `7357619`

## Why this example matters

A shallow object copy creates a different outer object and copies its member values. Scalar members therefore become independent values, but any member that is itself an object handle still points to the same nested object.

This particular stage focuses on the outer copy. The stronger test is always to mutate after copying: change a scalar and then, in a nested-object example, change a nested member. The different results expose exactly where independence ends and aliasing begins.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
//Copy the data somethimes 
class first ; 
  int data = 41; 
  
endclass 
module tb;
  first f1;
  first p1; 
  
  initial begin
    f1=new();  // constructor copy from 1 object to another object 
    f1.data=24; // Data to be used , now i want to keep it safe 
    //p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy)
    p1 = new f1 ; 
    $display("Value fo the data member is %0d " , p1.data);
    //if i change in p1 object handle , it wont reflect on f1 
    p1.data= 123; 
    $display("Shallow copy behaviour ......................");
    $display("Value fo the data member f1 is %0d " , f1.data);
    $display("Value fo the data member p1 is %0d " , p1.data);
    //task creating copy , just to copy data members attributes 
  end
endmodule
~~~

## Questions from the code, explained

### When is a copy of the data needed?

**Question in the source**

> //Copy the data somethimes 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment introduces a class example that first creates f1, changes f1.data, and then constructs p1 from f1.

**Answer**

A copy is useful when a second object should start with the source object's current member values but then have independent object state.

**Why this works**

The active source creates f1, writes 24, and uses p1 = new f1. The copy construction creates a second object initialized from the source object's members. Because data is an integer value member, changing p1.data later does not change f1.data. The value-copy purpose is different from assigning p1=f1, which would make both handles refer to the same object.

**Watch for**

Copy only when independent state is intended. A handle assignment is an alias, not a new object.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does the constructor-copy comment mean?

**Question in the source**

>     f1=new();  // constructor copy from 1 object to another object 

**Where it appears**

`testbench.sv:13` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is beside f1=new() and describes the following p1 construction from f1.

**Answer**

It describes constructing a new class object using an existing object as the source for member initialization.

**Why this works**

SystemVerilog supports a class copy-construction form using new with an existing class object. The destination handle p1 then refers to the new object, while f1 continues to refer to the original. For scalar members such as data, the copied value starts equal and later assignments are independent. For class-handle members, shallow copying preserves the referenced handle, so nested state would still be shared; this example contains only scalar members.

**Watch for**

The word copy does not promise deep copying of nested objects. Inspect each member's type when deciding whether a copy is independent.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Does new(f1) copy all data into a separate handle?

**Question in the source**

>     //p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy)

**Where it appears**

`testbench.sv:15` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

This is a commented alternative to the active p1 = new f1; statement.

**Answer**

The intended form constructs p1 from f1 and performs a shallow member copy; it is separate from assigning the handle p1=f1.

**Why this works**

The commented line distinguishes a copy construction from handle assignment. With a copy construction, the new object receives copied member values. Shallow means that a scalar is copied as a value but a member that is itself a class handle would be copied as the same nested handle rather than recursively cloned. The active source uses the equivalent no-parentheses spelling for this zero-argument-looking constructor-copy form, and then demonstrates independence for its int member.

**Watch for**

Use the copy-construction syntax when a new object is required. Do not replace it with p1=f1 unless shared identity is intended.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Will changing p1 change f1?

**Question in the source**

>     //if i change in p1 object handle , it wont reflect on f1 

**Where it appears**

`testbench.sv:18` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment precedes p1.data=123 and the displays of f1.data and p1.data.

**Answer**

For the scalar data member in this example, no: p1 and f1 are separate objects, so changing p1.data leaves f1.data at 24.

**Why this works**

The source constructs p1 from f1 rather than assigning the same handle. That gives each handle a different object identity. The integer member is copied into p1, so the later p1.data=123 writes only p1's storage. If the class had a member that was another class handle, shallow copying would leave that nested handle shared and a mutation through it could be visible from both outer objects.

**Watch for**

The demonstrated independence is specific to the scalar field. Test nested handle members separately before assuming a shallow copy is deep.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What is the purpose of a task that creates a copy?

**Question in the source**

>     //task creating copy , just to copy data members attributes 

**Where it appears**

`testbench.sv:23` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The final comment summarizes the copy operation after the output comparing f1 and p1.

**Answer**

Such a task or method can centralize the policy for creating a new object and copying its members, but the saved source does not define that task.

**Why this works**

A copy method can construct a destination object, assign each required property, and return the new handle. That lets a class choose which members are copied and whether nested objects receive deep copies. The current playground demonstrates the built-in shallow copy behavior directly and has no active user-defined copy task, so this comment is a design idea rather than an executed method.

**Watch for**

Do not infer a method's behavior from a comment alone. A custom copy method must explicitly copy every member whose state should be independent.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).


