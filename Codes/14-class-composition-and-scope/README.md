# Part 14 — Class Composition and Scope

EDA Playground: [Class Composition and Scope](https://edaplayground.com/x/EasK)  
EDA Playground Name: `Class Composition and Scope`  
Saved code ID: `7357152`

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
// scope is public be default 

class first ; 
  //local int data = 34; 
  int data = 34;
  
  task setter(input int data); 
    this.data= data; 
    
  endtask
  
  function int getter(); // a return type needed for getter ()
    return data ; 
    
  endfunction
  
  task display();
    $display("value of data , running from class first is %0d "  , data ); 
  endtask 
endclass
class second ; 
  first f1;  // second class has access to the data member of the first class
  
  function new(); // this or i can use initial begin block itself ?? 
    f1=new();
    
  endfunction 
  
endclass
module tb; 
  second s; 
  initial begin
    s=new();
    //$display("The value of data in the class first, is %0d " , s.f1.data ); 
    //s.f1.display();
    //s.f1.data = 111;
    //s.f1.display();
    s.f1.setter(12);
    // $display("The value of the data , fron getter task is %0d" , s.f1.getter()) ; WILL NOT WORK CAUSE TASK DOES NOT RETURN A VALUE 
    $display("value of data %0d is " , s.f1.getter());
    
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Is class scope public by default?

**Original code question**

> // scope is public be default 

**Where it appears**

`testbench.sv:3` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is at the top of the class-composition example before class first declares data and methods.

**Answer**

Yes for ordinary class members: class properties and methods are public unless an explicit access qualifier such as local or protected changes their visibility.

**Deep explanation**

The active data property, setter, getter, and display method are declared without a qualifier, so code with a handle can select them when the handle and object are valid. The commented local declaration illustrates the contrasting restriction. Public visibility answers who may select a member; it does not determine whether the member is initialized or whether a containing object has been constructed.

**Practical implication or pitfall**

Visibility and lifetime are separate. A public member still cannot be selected through a null handle, and a local member still exists inside its object.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What would local do to the data member?

**Original code question**

>   //local int data = 34; 

**Where it appears**

`testbench.sv:6` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

This is a commented-out alternative declaration immediately before the active public int data = 34 declaration.

**Answer**

local would restrict direct access to the class in which the member is declared; it is not the declaration used by the active example.

**Deep explanation**

The line is commented, so the saved running source actually uses an ordinary public data member. If enabled, local would make outside code unable to select first.data directly; class methods in first could still use it. The keyword changes access control, not the integer's value, storage width, or default initialization. The question is therefore about the visibility experiment represented by the commented line, not about the active field.

**Practical implication or pitfall**

When reading a class example, distinguish commented alternatives from active declarations. A public-access explanation must not be applied to a local member.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why does getter need a return type?

**Original code question**

>   function int getter(); // a return type needed for getter ()

**Where it appears**

`testbench.sv:14` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment follows function int getter(), which returns data from class first.

**Answer**

Because getter is a function that returns the value of data, its declaration must specify the return type int; a task would not return a value.

**Deep explanation**

The function declaration's int states the type of the value produced by return data. The caller can use s.f1.getter() as an expression in the display call. That is different from the commented display that tries to call a task as though it returned a value. A function's return type and a method's visibility are independent properties; this example uses a public int-returning function inside the nested object.

**Practical implication or pitfall**

Use a function for a value-producing query and a task for an operation that may consume time or has output/ref behavior. Do not infer a return value from a task name.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Can the second-class constructor be replaced by an initial block?

**Original code question**

>   function new(); // this or i can use initial begin block itself ?? 

**Where it appears**

`testbench.sv:26` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is on function new inside class second, where f1=new() constructs the contained first object.

**Answer**

An initial block can create the object in a module process, but it is not a general replacement for a class constructor when every second object must initialize its own f1.

**Deep explanation**

The class second constructor runs as part of new for each second object, so each instance gets its own first object through f1=new(). A module initial block runs once for the module instance and would initialize only the handles it names; it would not automatically initialize f1 for every separately constructed second object. The two mechanisms also have different ownership and timing: a constructor is tied to object construction, while initial is a simulation process.

**Practical implication or pitfall**

Use a constructor for per-object invariants and initial for module-level stimulus/setup. Moving the assignment between them changes the lifecycle contract.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### Why does the commented task call not work as a getter?

**Original code question**

>     // $display("The value of the data , fron getter task is %0d" , s.f1.getter()) ; WILL NOT WORK CAUSE TASK DOES NOT RETURN A VALUE 

**Where it appears**

`testbench.sv:41` — the exact comment in the live EDA Playground testbench pane.

**Context in this playground**

The comment is beside the active display that calls the int-returning getter function, and it contrasts an earlier task-style call.

**Answer**

A task does not produce a function return value that can occupy the %0d expression argument; the active getter is a function, so its int result can be displayed.

**Deep explanation**

The active class defines task setter and function int getter. setter performs an update and has no return value; getter evaluates an expression and returns data. A task call is a procedural statement, not a value expression, so placing a task call where the display argument expects an integer is invalid or semantically wrong. The active s.f1.getter() call is legal because getter is declared as a function returning int and the setter has already written 12.

**Practical implication or pitfall**

Choose the call form from the declaration, not from the method name. If an operation must be used inside an expression, make it a function with an appropriate return type.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).


