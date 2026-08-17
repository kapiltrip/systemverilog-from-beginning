# Part 15 — Class Shallow Copy

EDA Playground: [Class Shallow Copy](https://edaplayground.com/x/sVdz)  
EDA Playground Name: `Class Shallow Copy`  
Saved code ID: `7357619`

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

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### When is a copy of the data needed?

**Original code question**

> //Copy the data somethimes 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment introduces a class example that first creates f1, changes f1.data, and then constructs p1 from f1.

**Answer**

A copy is useful when a second object should start with the source object's current member values but then have independent object state.

**Deep explanation**

The active source creates f1, writes 24, and uses p1 = new f1. The copy construction creates a second object initialized from the source object's members. Because data is an integer value member, changing p1.data later does not change f1.data. The value-copy purpose is different from assigning p1=f1, which would make both handles refer to the same object.

**Practical implication or pitfall**

Copy only when independent state is intended. A handle assignment is an alias, not a new object.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does the constructor-copy comment mean?

**Original code question**

>     f1=new();  // constructor copy from 1 object to another object 

**Where it appears**

`testbench.sv:13` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is beside f1=new() and describes the following p1 construction from f1.

**Answer**

It describes constructing a new class object using an existing object as the source for member initialization.

**Deep explanation**

SystemVerilog supports a class copy-construction form using new with an existing class object. The destination handle p1 then refers to the new object, while f1 continues to refer to the original. For scalar members such as data, the copied value starts equal and later assignments are independent. For class-handle members, shallow copying preserves the referenced handle, so nested state would still be shared; this example contains only scalar members.

**Practical implication or pitfall**

The word copy does not promise deep copying of nested objects. Inspect each member's type when deciding whether a copy is independent.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Does new(f1) copy all data into a separate handle?

**Original code question**

>     //p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy)

**Where it appears**

`testbench.sv:15` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

This is a commented alternative to the active p1 = new f1; statement.

**Answer**

The intended form constructs p1 from f1 and performs a shallow member copy; it is separate from assigning the handle p1=f1.

**Deep explanation**

The commented line distinguishes a copy construction from handle assignment. With a copy construction, the new object receives copied member values. Shallow means that a scalar is copied as a value but a member that is itself a class handle would be copied as the same nested handle rather than recursively cloned. The active source uses the equivalent no-parentheses spelling for this zero-argument-looking constructor-copy form, and then demonstrates independence for its int member.

**Practical implication or pitfall**

Use the copy-construction syntax when a new object is required. Do not replace it with p1=f1 unless shared identity is intended.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Will changing p1 change f1?

**Original code question**

>     //if i change in p1 object handle , it wont reflect on f1 

**Where it appears**

`testbench.sv:18` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment precedes p1.data=123 and the displays of f1.data and p1.data.

**Answer**

For the scalar data member in this example, no: p1 and f1 are separate objects, so changing p1.data leaves f1.data at 24.

**Deep explanation**

The source constructs p1 from f1 rather than assigning the same handle. That gives each handle a different object identity. The integer member is copied into p1, so the later p1.data=123 writes only p1's storage. If the class had a member that was another class handle, shallow copying would leave that nested handle shared and a mutation through it could be visible from both outer objects.

**Practical implication or pitfall**

The demonstrated independence is specific to the scalar field. Test nested handle members separately before assuming a shallow copy is deep.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What is the purpose of a task that creates a copy?

**Original code question**

>     //task creating copy , just to copy data members attributes 

**Where it appears**

`testbench.sv:23` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The final comment summarizes the copy operation after the output comparing f1 and p1.

**Answer**

Such a task or method can centralize the policy for creating a new object and copying its members, but the saved source does not define that task.

**Deep explanation**

A copy method can construct a destination object, assign each required property, and return the new handle. That lets a class choose which members are copied and whether nested objects receive deep copies. The current playground demonstrates the built-in shallow copy behavior directly and has no active user-defined copy task, so this comment is a design idea rather than an executed method.

**Practical implication or pitfall**

Do not infer a method's behavior from a comment alone. A custom copy method must explicitly copy every member whose state should be independent.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).


