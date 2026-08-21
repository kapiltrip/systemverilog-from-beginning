# Part 21 — Constructor Arguments and Super Keyword

[← Part 20](../20-polymorphism-with-virtual-methods/README.md) · [Learning index](../README.md) · [Part 22 →](../22-constrained-randomization-with-randc/README.md)

EDA Playground: [Constructor Arguments and Super Keyword](https://edaplayground.com/x/bpmE)  
EDA Playground Name: `Constructor Arguments and Super Keyword`  
Saved code ID: `7358446`

## Why this example matters

A derived constructor is responsible for establishing the complete object, including the inherited portion. `super.new(...)` delegates initialization of that base-class state to the base constructor instead of duplicating its rules in the derived class.

Constructor arguments are normally inputs used while building the object, but SystemVerilog also permits ordinary function argument directions on constructor formals. An `output` formal is an additional copy-out channel; it is not how `new` returns the constructed object handle.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Questions from the code, explained

### Which keyword calls the parent constructor?

**Question in the source**

> // DISTINGUISH BETWEEN CUSTOM CONSTRUCTOR WE NEED  A KEYWORD ITS SUPER KEYWORD 

**Where it appears**

`testbench.sv:3`, before the class declarations.

**What the code is doing**

first has a constructor that initializes data1. second extends first, declares its own constructor, and invokes super.new(data1) before assigning data2.

**Answer**

super.new(data1) explicitly calls the constructor of the immediate superclass, first, while function new declares the constructor for the current class.

**Why this works**

The child constructor is responsible for the `second`-specific initialization, but the inherited `first` portion must be initialized through the superclass constructor. `super.new(data1)` passes the child constructor's `data1` argument to `first.new`. SystemVerilog requires an explicit superclass-constructor call to be the first executable statement in the derived constructor; after it completes, the child assigns `data2`.

If a derived constructor omits `super.new`, the language inserts an implicit zero-argument `super.new()` call. That would fail for this source because `first.new` requires `data1`. The explicit call is therefore not only descriptive—it supplies the required base-constructor argument. The two `new` definitions have different owners even though the constructor name is fixed by the language.

**Watch for**

Do not replace super.new with an unrelated new call. Calling new() creates or initializes an object in the current construction path; super.new initializes the inherited portion.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), [Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Can a constructor have an output-direction argument?

**Question in the source**

>   function new (int data1 , int data2);  // can i have an output direction in a constructor 

**Where it appears**

`testbench.sv:13`, in second.new.

**What the code is doing**

The saved constructor currently declares two unqualified int formals and passes data1 upward with super.new(data1). The comment asks about changing a constructor formal to output.

**Answer**

Yes, constructor formals use the function argument mechanism, so an output formal is syntactically possible; it would be a copy-out argument, not the constructor's object return mechanism.

**Why this works**

SystemVerilog functions can declare `input`, `output`, and `inout` formals, and the standard explicitly permits those directions on constructors. An unqualified constructor formal defaults to `input`, which is how both `data1` and `data2` behave in the saved source.

An `output` formal has normal copy-out semantics: the caller must pass a writable actual variable, the constructor writes its local formal, and the final value is copied back when the constructor returns. For example, a constructor could allocate an ID and copy that ID back to a caller-owned variable. That side result is independent of the special construction result: the `new(...)` expression still yields the newly allocated object handle, and a constructor still has no user-declared return type.

Output formals are therefore legal, but they are rarely needed for simple member initialization. In this example both values flow into the object, so `input` is the correct direction.

**Watch for**

Do not use an output formal to try to return the constructed class object, and do not pass a literal or non-writable expression as its actual. Use a separately declared output only when the caller genuinely needs a copy-out result in addition to the new object handle.

**References**

[Accellera SystemVerilog function argument reference](https://accellera.org/images/eda/vlog-pp/att-0614/01-SystemVerilog_draft7.pdf), [Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### Is the constructor name always new in SystemVerilog?

**Question in the source**

>   // constructor name is always new in sv

**Where it appears**

`testbench.sv:25`, immediately before endmodule.

**What the code is doing**

Both first and second declare their object constructors with the name new, and the testbench calls the child constructor with s=new(15,16).

**Answer**

Yes for SystemVerilog class constructors: the constructor method is named new.

**Why this works**

The constructor name is part of the class-method syntax rather than a user-chosen method name. The class type determines which new method is invoked, and the argument list selects the initialization inputs. Other methods, such as display or copy, can have arbitrary names and ordinary return types. In this source, first.new receives data1 through super.new, while second.new receives both data1 and data2 from s=new(15,16).

**Watch for**

A method named construct or initialize would be an ordinary method unless it is called explicitly; it would not replace the class constructor. Keep the constructor name and its argument contract aligned with the class definition.

**References**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf), [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf), and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

