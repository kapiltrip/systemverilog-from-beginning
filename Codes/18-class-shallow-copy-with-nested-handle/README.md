# Part 18 — Class Shallow Copy with Nested Handle

EDA Playground: [Class Shallow Copy with Nested Handle](https://edaplayground.com/x/9FTS)  
EDA Playground Name: `Class Shallow Copy with Nested Handle`  
Saved code ID: `7358251`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace, correct, or improve the code.

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
// Shallow copy copies data members or methods ? verify this 
// but it cant copy  
// Whats wrong with shallow copy cause it is copying the data members and its not copying the variables that are in the heap 
// Understanding shallow copy 
class first; 
  int data1 =12; 
  
endclass

class second ; 
  first f1; 
  int data2=34; 
  function new(); 
    f1=new();
    
  endfunction 
  /*
  initial begin
    f1=new();
    
  end
  */ // i cant have a initial begin in class 
  
  endclass
  module tb();
    second s1,s2;
    initial begin
      s1=new();  // handler for class second 
      s1.data2=45; 
      
      s2=new s1; // copy data members of handler s1 to s2 
      $display("value of second data member is : %0d " , s2.data2 );
      $display("value of first class data member is : %0d " , s2.f1.data1 );
      // the data members of class first and second are not related 
      
      //ahh so so only handler is different the object its pointing to is 1 only i.e class first, in our case cause its a dynamically created class 
      
      
      
      //now 
      s2.f1.data1=56; 
      $display("Value of data from original object is %0d " , s1.f1.data1 ) ; 
    end
  endmodule

~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID 9FTS. No corrected, reformatted, or self-checking replacement is included. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Does a shallow copy copy data members or methods?

**Original code question**

> // Shallow copy copies data members or methods ? verify this 
> // but it cant copy  

**Where it appears**

`testbench.sv:3–4` at the top of the saved testbench.

**Context in this playground**

The source has scalar data1 and data2 members and a nested first handle f1, then uses s2=new s1.

**Answer**

A shallow copy copies the object's class properties; it does not copy methods as per-object data, and a nested class property is copied as a handle rather than as a new nested object.

**Deep explanation**

Methods are part of the class type and are invoked through an object handle; they are not independent data stored inside each object instance. The shallow-copy operation creates a new outer object and copies its properties. Thus data2 is copied as a scalar value, while f1 is copied as the same nested handle. The later s2.f1.data1=56 is therefore visible through s1.f1.data1 in this exact source.

**Practical implication or pitfall**

Separate method availability from object state. A new outer object can still share nested state, so changing a nested member may affect both outer objects.

**Sources**

[Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### What does the note “but it cant copy” mean here?

**Original code question**

> // but it cant copy  

**Where it appears**

`testbench.sv:4`, continuing the shallow-copy note.

**Context in this playground**

The next comments distinguish scalar data members from the f1 object allocated inside second.

**Answer**

The saved example shows that shallow copy can copy the top-level property value but cannot recursively copy the object reached through f1.

**Deep explanation**

For an integer, copying the property produces a separate integer value in the new outer object. For f1, the property itself is a class handle, so copying the property copies the handle value. Both second objects then reach the same first object. This is the specific limitation the fragment expresses; it is not a statement that no property is copied at all.

**Practical implication or pitfall**

When a comment says an object cannot be copied, identify the level: outer object, scalar property, handle, or nested object. The levels have different aliasing behavior.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

### What is wrong with shallow copy when a nested object is on the heap?

**Original code question**

> // Whats wrong with shallow copy cause it is copying the data members and its not copying the variables that are in the heap 

**Where it appears**

`testbench.sv:5` in the saved explanation before the classes.

**Context in this playground**

second owns a first handle f1. The source constructs s1, makes s2=new s1, changes s2.f1.data1, and displays s1.f1.data1.

**Answer**

Nothing is inherently wrong with shallow copy, but it is wrong for a requirement that nested objects be independent; this code intentionally demonstrates the shared nested handle.

**Deep explanation**

The new second object receives its own data2 value, but the f1 property is copied as a handle. Consequently s1.f1 and s2.f1 designate one first object. The assignment s2.f1.data1=56 changes that one object, so the display through s1 observes 56. A deep-copy method would allocate a new first object and copy data1 into it, as the later deep-copy playground does.

**Practical implication or pitfall**

Use shallow copy when shared nested state is intentional or irrelevant. Use explicit recursive copying when each outer object must own independent nested state.

**Sources**

[Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### Can an initial block be declared inside a class?

**Original code question**

>   */ // i cant have a initial begin in class 

**Where it appears**

`testbench.sv:19–24`, in the block-commented experiment.

**Context in this playground**

The source comments out an initial block inside class second and places the active initial block inside module tb instead.

**Answer**

No. An initial procedural block belongs to a module or another procedural design scope, not to a class declaration; class initialization belongs in a constructor or class method called by a procedural scope.

**Deep explanation**

A class declaration contains class items such as properties and methods. The module tb is the procedural container that can start an initial process. The class constructor function new can initialize an object when the module calls s1=new(), but the class itself does not launch an independent initial process. The source keeps the class-local initial block inside a block comment, so the question is about the language construct rather than an executed process in this saved run.

**Practical implication or pitfall**

Put stimulus and time-consuming processes in the module/program/testbench scope. Put object state setup in new or another method, then call that method from the procedural testbench.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Are only the handles different while the nested object is the same?

**Original code question**

>       //ahh so so only handler is different the object its pointing to is 1 only i.e class first, in our case cause its a dynamically created class 

**Where it appears**

`testbench.sv:38`, after the first shallow-copy displays.

**Context in this playground**

The comment records the observation that the second handles differ while the dynamically created first object reached through f1 is shared.

**Answer**

Yes for this source: s1 and s2 are distinct outer objects, but s1.f1 and s2.f1 refer to the same first object.

**Deep explanation**

The expression s2=new s1 creates a shallow copy of the outer second object. Its scalar data2 is copied, and its f1 handle is copied. Therefore the outer identities differ, while dereferencing f1 reaches one shared nested allocation. The later write through s2.f1 and the display through s1.f1 are a direct observation of that aliasing relationship.

**Practical implication or pitfall**

Track a class handle at every level of a chain. Two different top-level handles do not prove that their nested handles are different.

**Sources**

[Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

