# Part 19 — Class Inheritance Basics

[← Part 18](../18-class-shallow-copy-with-nested-handle/README.md) · [Learning index](../README.md) · [Part 20 →](../20-polymorphism-with-virtual-methods/README.md)

EDA Playground: [Class Inheritance Basics](https://edaplayground.com/x/uVqk)  
EDA Playground Name: `Class Inheritance Basics`  
Saved code ID: `7358359`

## Why this example matters

Inheritance gives the derived class the accessible members and methods of its base class, then lets it add or specialize behavior. Code inside the derived class can use inherited members directly because they are part of the derived object's class structure.

Do not confuse inheritance with composition: a derived object is also a base-class object, while a composed object merely contains a handle to another object. That difference controls assignment compatibility and later polymorphic behavior.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### Does the derived class inherit the attributes and methods of first?

**Question in the source**

>   // it has access to the attributes and methods of class 1 

**Where it appears**

`testbench.sv:13`, inside class second.

**What the code is doing**

second extends first and adds data2 and add. The testbench creates one second object and calls both the inherited display method and the derived add method through s.

**Answer**

Yes. Extending first makes its accessible members available through a second object, subject to the language's visibility rules.

**Why this works**

The declaration second extends first establishes an inheritance relationship. The handle s is declared as second and s=new() creates a second object, so s can select inherited data1 and display as well as its own data2 and add. The source does not need a separate first object or a separate base-class allocation to make inherited members available. The declaration and object handle are the important pieces: declaring a class type alone does not allocate an object.

**Watch for**

Inheritance provides the member relationship; new provides the object. Do not confuse a derived handle with automatic allocation of an unrelated base object.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Can the derived handle access inherited members without another handler?

**Question in the source**

>     // ohh actually i have access to all the things without using handler 

**Where it appears**

`testbench.sv:23`, after s=new().

**What the code is doing**

The source reads s.data2 and s.data1, calls s.display(), and calls s.add().

**Answer**

Yes. s is already the object handle for the second object, and that object includes the inherited first portion, so no additional base-class handle is needed for these selections.

**Why this works**

A class variable holds an object handle. Here s is declared second and is assigned a newly constructed second object. The inheritance relationship makes data1 and display available through that second object, while data2 and add are declared by second. The expressions s.data1 and s.display therefore select inherited members through the same handle; they do not mean that s is bypassing object allocation or that handles are unnecessary in general.

**Watch for**

Use the handle whose declared class exposes the members you need. If a base-class handle is used instead, the visible member set and virtual-dispatch behavior must be considered separately.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

