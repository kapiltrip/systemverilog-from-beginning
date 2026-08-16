# Part 20 — Polymorphism with Virtual Methods

EDA Playground: [Polymorphism with Virtual Methods](https://edaplayground.com/x/sPne)  
EDA Playground Name: `Polymorphism with Virtual Methods`  
Saved code ID: `7358419`

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
class first ; 
  int data1 = 12;
  virtual function void display(); // IF I EXTEND IT IN second class the overridden method will be executed 
    $display("Value of data1 from class first is %0d " , data1);
  endfunction
endclass

class second extends first ; 
  int data2= 34;
  function void add();
    $display("Value of data2 from class second is %0d" , data2);
  endfunction 
  
  function void display();
    $display("Value of data2 from class second is %0d " , data2);
  endfunction
  
endclass

module tb; 
  first f;
  second s; 
  
  initial begin
    f = new();
    s=new();
    f=s;
    f.display(); // getting parent class display I NEED DIFFERENT BEHAVIOUR 
    // display hence will have different behaviour same name different behaviour polymorphism 
  end
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID sPne. No corrected, reformatted, or self-checking replacement is included. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Will extending first cause the overridden display method to execute?

**Original code question**

> // IF I EXTEND IT IN second class the overridden method will be executed 

**Where it appears**

`testbench.sv:5`, beside the virtual display declaration.

**Context in this playground**

first declares virtual display, second defines a same-named display, and the testbench stores a second object in both s and the base-typed handle f.

**Answer**

Yes. Because first.display is virtual, a call through f can dispatch to second.display when f refers to the second object.

**Deep explanation**

The assignment f=s keeps the dynamic object as second while the handle variable is typed as first. The virtual method declaration tells the language that overrides participate in runtime dispatch. Therefore f.display() is resolved using the implementation appropriate to the dynamic second object, so the display of data2 is selected rather than the base implementation. This is the polymorphic behavior the source is setting up; it is distinct from the non-virtual case where the handle's declared type controls method selection.

**Practical implication or pitfall**

A derived object plus a base handle is not enough by itself for override dispatch. The base method must be virtual, and the override must match the method signature.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/), and [Accellera SystemVerilog inheritance discussion](https://www.accellera.org/images/eda/sv-ec/1988.html).

### Why does the source need different behavior through f.display?

**Original code question**

> // getting parent class display I NEED DIFFERENT BEHAVIOUR 

**Where it appears**

`testbench.sv:30`, beside f.display().

**Context in this playground**

f is a first handle, s is a second handle, and f=s is followed by f.display(). The source wants the call to reflect the actual second object.

**Answer**

The different behavior is the purpose of virtual dispatch: f keeps the base-class interface while the second implementation supplies the runtime behavior.

**Deep explanation**

The base handle lets code use the common display interface without changing its declared type for each derived class. At runtime the handle still refers to the second allocation. Since display was declared virtual in first and overridden in second, the call uses the most-derived matching implementation. The returned text is consequently based on data2 in second.display, not data1 in first.display. The source's assignment f=s is the exact bridge between static type and dynamic object.

**Practical implication or pitfall**

If the base method is not virtual, an apparently similar call can bind differently. When polymorphism is intended, mark the base method virtual and keep the override signature compatible.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### What does same name and different behavior mean here?

**Original code question**

>     // display hence will have different behaviour same name different behaviour polymorphism 

**Where it appears**

`testbench.sv:31`, immediately after the f.display call.

**Context in this playground**

Both first and second define display, but the implementations print different data members. The base handle f refers to a second object.

**Answer**

It describes overriding and polymorphism: one interface name, display, selects different implementation bodies according to the dynamic object when the method is virtual.

**Deep explanation**

first.display prints data1 and second.display prints data2. The declarations share a method name, but the bodies are not the same. With f=s, the handle's static type is first while the object type is second; virtual dispatch uses the second body. The class hierarchy therefore lets the caller write f.display while the object supplies the specialized behavior.

**Practical implication or pitfall**

Do not use the word polymorphism to mean that any same-named method is automatically virtual. The base declaration and compatible override determine whether the dynamic selection occurs.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

