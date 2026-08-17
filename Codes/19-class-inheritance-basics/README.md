# Part 19 — Class Inheritance Basics

EDA Playground: [Class Inheritance Basics](https://edaplayground.com/x/uVqk)  
EDA Playground Name: `Class Inheritance Basics`  
Saved code ID: `7358359`

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
// INHERITANCE 
class first ; 
  int data1=12;
  function void display();
    $display("Value of data called from class first is %0d " , data1); 
    
  endfunction 
  
endclass
class second extends first ; 
  // it has access to the attributes and methods of class 1 
  int data2=34; 
  function void add();
    $display("value after process is %0d " , data2+4);
  endfunction
endclass
module tb;  
  second s;
  initial begin
    s=new();
    // ohh actually i have access to all the things without using handler 
    
    $display("Value of data2 is %0d " , s.data2);
    $display("Value of data1 is %0d " , s.data1);
    s.display(); 
    s.add();
    
  end
endmodule 
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID uVqk. No corrected, reformatted, or self-checking replacement is included. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Does the derived class inherit the attributes and methods of first?

**Original code question**

>   // it has access to the attributes and methods of class 1 

**Where it appears**

`testbench.sv:13`, inside class second.

**Context in this playground**

second extends first and adds data2 and add. The testbench creates one second object and calls both the inherited display method and the derived add method through s.

**Answer**

Yes. Extending first makes its accessible members available through a second object, subject to the language's visibility rules.

**Deep explanation**

The declaration second extends first establishes an inheritance relationship. The handle s is declared as second and s=new() creates a second object, so s can select inherited data1 and display as well as its own data2 and add. The source does not need a separate first object or a separate base-class allocation to make inherited members available. The declaration and object handle are the important pieces: declaring a class type alone does not allocate an object.

**Practical implication or pitfall**

Inheritance provides the member relationship; new provides the object. Do not confuse a derived handle with automatic allocation of an unrelated base object.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Can the derived handle access inherited members without another handler?

**Original code question**

>     // ohh actually i have access to all the things without using handler 

**Where it appears**

`testbench.sv:23`, after s=new().

**Context in this playground**

The source reads s.data2 and s.data1, calls s.display(), and calls s.add().

**Answer**

Yes. s is already the object handle for the second object, and that object includes the inherited first portion, so no additional base-class handle is needed for these selections.

**Deep explanation**

A class variable holds an object handle. Here s is declared second and is assigned a newly constructed second object. The inheritance relationship makes data1 and display available through that second object, while data2 and add are declared by second. The expressions s.data1 and s.display therefore select inherited members through the same handle; they do not mean that s is bypassing object allocation or that handles are unnecessary in general.

**Practical implication or pitfall**

Use the handle whose declared class exposes the members you need. If a base-class handle is used instead, the visible member set and virtual-dispatch behavior must be considered separately.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

