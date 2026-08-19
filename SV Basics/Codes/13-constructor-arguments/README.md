# Part 13 — Constructor Arguments

[← Part 12](../12-array-reference-passing/README.md) · [Learning index](../README.md) · [Part 14 →](../14-class-composition-and-scope/README.md)

EDA Playground: [Constructor Arguments](https://edaplayground.com/x/Ud7M)  
EDA Playground Name: `Constructor Arguments`  
Saved code ID: `7357115`

## Why this example matters

Constructor arguments let object creation establish a valid starting state in one operation. Default values support the common case, positional arguments are compact, and named arguments make the meaning of each supplied value explicit.

Named arguments become especially helpful as constructors grow because they reduce dependence on parameter order. Whichever call form is used, the constructor remains `new`; the arguments only control how that newly allocated object is initialized.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
class first; 
  int data1;
  bit [7:0] data2 ; 
  shortint data3;
  
  function new( input int data1=0, input bit [7:0] data2=8'd0, input shortint data3=0 );  // constructor cannot add a void to a constructor 
    this.data1=data1;
    this.data2=data2;
    this.data3=data3;
    
  endfunction 
  task display();
    $display("Value of data 1 , data 2 adn data 3 are %0d , %0d , %0d  (calling from the class)" , data1, data2,data3);
    
  endtask 
endclass

module tb; 
  first f1;
  initial begin
    //f1=new(14,5,43); // following the positions ----> METHOD 1 
    f1= new(.data2(5) , .data3(5) , .data1(11));  //------> METHOD 2 BY specifically naming 
    
    //f1 will have address of the class now 
    f1.display();
    //$display("Data member of the class first data1  is %0d , data2 is %0d and data 3 is %0d" , f1.data1,f1.data2, f1.data3);
  end
  
endmodule
~~~

## Questions from the code, explained

### Why can a constructor not have void as a return type?

**Question in the source**

>   function new( input int data1=0, input bit [7:0] data2=8'd0, input shortint data3=0 );  // constructor cannot add a void to a constructor 

**Where it appears**

`testbench.sv:8` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment is on the function new declaration inside class first.

**Answer**

A SystemVerilog class constructor is the special function named new and has no return type; writing void new would not be a constructor declaration.

**Why this works**

The constructor syntax is special: new is a function-like method invoked by a class construction expression, but it does not declare a return type. Its result is the constructed object handle produced by the new operation, not a user-declared function return value. The active declaration correctly begins function new( ... ) and assigns the arguments into this object's properties. A task display method is separate and has no constructor role.

**Watch for**

Do not add a conventional function return type to new. Keep constructor arguments and property assignments inside the special new declaration.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

### What does f1 hold after construction?

**Question in the source**

>     //f1 will have address of the class now 

**Where it appears**

`testbench.sv:26` — the exact comment in the live EDA Playground testbench pane.

**What the code is doing**

The comment follows the named-argument construction f1= new(.data2(5), .data3(5), .data1(11)).

**Answer**

f1 holds a handle to the newly constructed first object; calling it an address is informal, not a portable promise about a numeric address.

**Why this works**

The class variable f1 is a handle. The new expression constructs an object, initializes its members through the named constructor arguments, and returns a handle that is assigned to f1. The subsequent f1.display() call dereferences that handle to execute the method on the same object. SystemVerilog exposes handle identity and nullness, not a C-style numeric address that should be printed or relied on. The named arguments select formals by name, so their source order does not have to match the constructor declaration order.

**Watch for**

Use class handles for object identity and member access; do not write code that depends on an implementation's memory address representation.

**References**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf)

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).



