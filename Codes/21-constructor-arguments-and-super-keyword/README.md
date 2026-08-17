# Part 21 — Constructor Arguments and Super Keyword

EDA Playground: [Constructor Arguments and Super Keyword](https://edaplayground.com/x/bpmE)  
EDA Playground Name: `Constructor Arguments and Super Keyword`  
Saved code ID: `7358446`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace, correct, or improve the code.

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
// DISTINGUISH BETWEEN CUSTOM CONSTRUCTOR WE NEED  A KEYWORD ITS SUPER KEYWORD 
class first ; 
  int data1; 
  function new(input int data1);
    this.data1=data1; 
    
  endfunction 
endclass 
class second extends first ; 
  int data2;
  function new (int data1 , int data2);  // can i have an output direction in a constructor 
    super.new(data1);
    this.data2=data2;
    
  endfunction 
endclass
module tb;
  second s;
  initial begin
    s=new(15,16);
    $display("The values of parent class is %0d and child class is %0d " , s.data1,s.data2 );
  end
  // constructor name is always new in sv
endmodule 
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID bpmE. No corrected, reformatted, or self-checking replacement is included. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Which keyword calls the parent constructor?

**Original code question**

> // DISTINGUISH BETWEEN CUSTOM CONSTRUCTOR WE NEED  A KEYWORD ITS SUPER KEYWORD 

**Where it appears**

`testbench.sv:3`, before the class declarations.

**Context in this playground**

first has a constructor that initializes data1. second extends first, declares its own constructor, and invokes super.new(data1) before assigning data2.

**Answer**

super.new(data1) explicitly calls the constructor of the immediate superclass, first, while function new declares the constructor for the current class.

**Deep explanation**

The child constructor is responsible for the second-specific initialization, but the inherited first portion must be initialized through the superclass constructor. The super.new call passes the child constructor's data1 argument to first.new. SystemVerilog requires the superclass constructor call to be the first executable statement when it is written explicitly; after it completes, the child constructor assigns data2. The source's two new methods therefore have different owners even though both use the constructor name.

**Practical implication or pitfall**

Do not replace super.new with an unrelated new call. Calling new() creates or initializes an object in the current construction path; super.new initializes the inherited portion.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), [Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Can a constructor have an output-direction argument?

**Original code question**

>   function new (int data1 , int data2);  // can i have an output direction in a constructor 

**Where it appears**

`testbench.sv:13`, in second.new.

**Context in this playground**

The saved constructor currently declares two unqualified int formals and passes data1 upward with super.new(data1). The comment asks about changing a constructor formal to output.

**Answer**

Yes, constructor formals use the function argument mechanism, so an output formal is syntactically possible; it would be a copy-out argument, not the constructor's object return mechanism.

**Deep explanation**

SystemVerilog functions can declare input, output, and inout formal arguments. An unqualified formal defaults to input, which is how both data1 and data2 are declared in the saved source. An output formal is copied out to the actual argument when the function completes, subject to the normal function-call rules. A class constructor is special: new is the construction method and has no ordinary declared return type, while the newly allocated object handle is produced by the construction operation. Therefore an output argument would be an additional communication channel, not a replacement for new or for the child-to-parent super.new call.

**Practical implication or pitfall**

Do not use an output formal to try to return the constructed class object. Keep constructor inputs for initialization and use a separately declared output only when the caller genuinely needs a copy-out result.

**Sources**

[Accellera SystemVerilog function argument reference](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf), [Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### Is the constructor name always new in SystemVerilog?

**Original code question**

>   // constructor name is always new in sv

**Where it appears**

`testbench.sv:25`, immediately before endmodule.

**Context in this playground**

Both first and second declare their object constructors with the name new, and the testbench calls the child constructor with s=new(15,16).

**Answer**

Yes for SystemVerilog class constructors: the constructor method is named new.

**Deep explanation**

The constructor name is part of the class-method syntax rather than a user-chosen method name. The class type determines which new method is invoked, and the argument list selects the initialization inputs. Other methods, such as display or copy, can have arbitrary names and ordinary return types. In this source, first.new receives data1 through super.new, while second.new receives both data1 and data2 from s=new(15,16).

**Practical implication or pitfall**

A method named construct or initialize would be an ordinary method unless it is called explicitly; it would not replace the class constructor. Keep the constructor name and its argument contract aligned with the class definition.

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

