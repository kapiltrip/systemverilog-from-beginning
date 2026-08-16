# Part 09 — Class Object Basics

EDA Playground: [Class Object Basics](https://edaplayground.com/x/qLDu)  
EDA Playground Name: `Class Object Basics`  
Saved code ID: `7356678`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace or correct the code.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
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
`timescale 1ns/1ps
  class first; 
    reg [2:0] data; // attributes 
    reg [1:0] data2 ; // reg is a 4 state data type 
    
    
  endclass 
module tb; 
  first f;  // f is a handler wont able to access the class 
             //class are dynamic object ? meaning 
             // Do not keep that object throughout life of the simulation  
  
  initial begin
    f=new(); // constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values 
             // Once i call the constructor 
             // f now points to that, object 
    
    
    #1;
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 
    // Try to add a value 
    f.data = 3'b010; 
    f.data2= 2'b10 ; 
    #1; 
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 
    f=null; // deallocate the memory associated to the class 
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 

  end
  
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Can a class handle access the class before construction?

**Original code question**

>   first f;  // f is a handler wont able to access the class 

**Where it appears**

`testbench.sv:11` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

f is declared as a class handle before the initial block calls f=new().

**Answer**

No. Before new assigns an object, f is a null handle and cannot dereference class members.

**Deep explanation**

A class variable is a handle, not the object storage itself. The declaration creates a handle whose initial value is null. The new expression constructs a class object and returns a handle; assigning that result to f makes member selection such as f.data meaningful. Before that assignment, f.data is a null-handle dereference. The source calls new before accessing the members, so the comment is describing the distinction between the handle declaration and the constructed object.

**Practical implication or pitfall**

Declare and construct a handle before dereferencing it. Testing a handle against null can make this boundary explicit, but the original example intentionally remains unchanged.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does it mean that class objects are dynamic?

**Original code question**

>              //class are dynamic object ? meaning 

**Where it appears**

`testbench.sv:12` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The question is beside the class-handle declaration and precedes f=new() in the basic class example.

**Answer**

The class object is created at run time by new and is accessed through a handle; its lifetime is governed by references rather than a fixed module-instance declaration.

**Deep explanation**

A class declaration defines the type and its members. It does not itself instantiate one object. Each new call allocates a class object during simulation and returns a handle to it. Handles can be assigned, passed, and set to null independently of the object. This dynamic allocation is why the example separates first f; from f=new();. The class members become storage in the constructed object, while f is the reference used to reach them.

**Practical implication or pitfall**

Do not confuse a class type declaration with an object. A handle can be null, and two handles can refer to the same object unless a separate object is constructed.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf); [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/)

### Does the object need to be kept for the whole simulation?

**Original code question**

>              // Do not keep that object throughout life of the simulation  

**Where it appears**

`testbench.sv:13` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment follows the handle declaration and is paired with the later f=null statement.

**Answer**

No. A class object need not be referenced for the whole simulation; once no handle can reach it, it can become eligible for automatic reclamation.

**Deep explanation**

The object and its handle have different lifetimes. Setting f to null removes that handle's reference, but it does not retroactively change the object or make a second handle disappear. If no other handle refers to the object, it is unreachable and the simulator may reclaim it through SystemVerilog's class-object garbage collection. The standard does not make f=null a manual deallocation call in the C sense. In this playground, after f=null the later f.data display attempts to dereference a null handle, so the source demonstrates a dangerous access rather than a safe lifetime test.

**Practical implication or pitfall**

Do not use a null handle as if it were a valid empty object. After dropping the last handle, construct a new object before accessing members again.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does new do to the handle and members?

**Original code question**

>     f=new(); // constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values 

**Where it appears**

`testbench.sv:16` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The inline comment follows f=new() and precedes the first display of the class members.

**Answer**

new constructs the object, returns its handle, and initializes its properties according to their declared/default initialization rules.

**Deep explanation**

The constructor call is the point at which the class object exists. The returned handle is assigned to f, so member selections through f refer to that object's data. Properties not explicitly assigned by the constructor receive their type-appropriate default or declaration-time initialization. In this source the members are four-state reg vectors, so their initial values are unknown until the later procedural assignments write known bit patterns. The constructor does not mean that every member has a meaningful application value; it establishes the object and its initialization state.

**Practical implication or pitfall**

Distinguish object construction from application initialization. A constructed object can still contain X-valued four-state members.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What changes after the constructor is called?

**Original code question**

>              // Once i call the constructor 
>              // f now points to that, object 

**Where it appears**

`testbench.sv:17–18` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

These two adjacent comments explain the transition from the null handle declaration to f=new().

**Answer**

After f=new() completes, f contains a handle to the newly constructed object.

**Deep explanation**

The new expression returns a handle, and the assignment stores that handle in f. The object is therefore reachable through f, and the subsequent f.data and f.data2 expressions select properties in that object. This is a reference transition, not a copy of the class's members into the handle variable itself. If another handle were assigned from f, both handles would refer to the same object until one was redirected or a custom copy was made.

**Practical implication or pitfall**

When debugging class code, inspect both the handle state and the member state. A non-null handle only proves that an object can be reached; it does not prove its properties are known.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### How is a value added through the handle?

**Original code question**

>     // Try to add a value 

**Where it appears**

`testbench.sv:23` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment immediately precedes f.data=3'b010 and f.data2=2'b10.

**Answer**

A member is updated by selecting it through the non-null handle and assigning a value to that member.

**Deep explanation**

Once f points to the constructed object, f.data and f.data2 are ordinary property selections. The procedural assignments write the corresponding members in that object; the later display observes the new values. This is not a new object construction and does not change f itself. The widths of the assigned literals also matter: the values are sized to the declared member widths in this example.

**Practical implication or pitfall**

A member assignment requires a live handle. If f is null, the same syntax becomes a null-handle access rather than a valid write.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



