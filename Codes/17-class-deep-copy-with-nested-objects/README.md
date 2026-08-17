# Part 17 — Class Deep Copy with Nested Objects

EDA Playground: [Class Deep Copy with Nested Objects](https://edaplayground.com/x/gchG)  
EDA Playground Name: `Class Deep Copy with Nested Objects`  
Saved code ID: `7358337`

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
// deep copy copies dynamically created things such as class as well , and 
// in cpp it should be a user defined constructor 
// so we can have different objects copies shared and those 2 objects are independent copies 
class first ;
  int data1 =12; 
  function first copy();
    copy= new();
    copy.data1=data1 ; 
    
  endfunction 
endclass
class second;
  int data2=14;
  first f1;
  
  function new();
    f1=new();
  endfunction 
  
  function second copy();
    copy = new(); // copy becomes a handler of class second 
    
    copy.data2= data2;
    
    copy.f1 = f1.copy() ;  // why copy called without ()
    
  endfunction
endclass

module tb; 
  second s1,s2;
  
  initial begin
    s1=new(); // s1 is a different object handler and s2 is independent prove at line 43 
    s2=new();
    s1.data2= 45;
    s2 = s1.copy();
    $display("Value of data 2 is %0d " , s2.data2);
    s2.data2=555;
    $display("Value of data 2 of handler s2  is %0d " , s2.data2); // they have to be different
    $display("Value of data 2 of handler s1  is %0d " , s1.data2);
    //Till now handler are independent 
    s2.f1.data1=98;
    $display("The value of data 1 seen from handler s2 that i have written is  %0d" , s2.f1.data1);

    $display("The value of data 1 seen from handler s1 is %0d" , s1.f1.data1);
  end 
  
endmodule 









/*
## Questions You Asked in the Recent Discussion

1. **Shallow copy:** In a shallow copy, is only the handle different while the nested object it points to remains the same/shared object?

2. In this code, **what exactly am I doing?**

   ```systemverilog
   function first copy();
     copy = new();
     copy.data = data;
   endfunction
   ```

3. Why am I using a custom `copy()` function instead of simply using `function new()` and initializing the class members there?

4. What is this called?

   ```systemverilog
   function new();
     ...
   endfunction
   ```

5. Are both `function new()` and `function first copy()` **constructors**?

6. If they are not both constructors, **what exactly is the difference between a constructor and a `copy()` method?**

7. Why can't I use `new()` and `copy()` **interchangeably**?

8. What is the difference between:

   ```systemverilog
   f2 = new();
   ```

   and:

   ```systemverilog
   f2 = f1.copy();
   ```

9. Why does `new()` give me a **fresh/default object**, while `f1.copy()` gives me a **new object containing the values of `f1`**?

10. More generally, what is the relationship between:

* `function new()` → constructor **definition**
* `f1 = new()` → constructor **call / object creation**
* `function first copy()` → user-defined **copy method**
* `copy = new()` inside `copy()` → constructor call **inside the copy method**?

*/
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID gchG. No corrected, reformatted, or self-checking replacement is included. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

### Does a shallow copy duplicate the nested object?

**Original code question**

> 1. **Shallow copy:** In a shallow copy, is only the handle different while the nested object it points to remains the same/shared object?

**Where it appears**

`testbench.sv:64` inside the saved block comment.

**Context in this playground**

The active example has a second object with a nested first handle. The custom second.copy method allocates a new second object, copies data2, and then calls first.copy for the nested f1 object.

**Answer**

A SystemVerilog shallow copy creates a new outer object, but a nested class handle is copied as the same handle; it does not recursively create a new nested object.

**Deep explanation**

The language-level shallow-copy operation allocates a duplicate of the referenced class object and copies its properties. Scalar properties such as data2 receive their own values, while a property whose type is another class is a handle, so the handle value is copied and both outer objects refer to the same nested object. The saved code deliberately goes further: copy.f1 = f1.copy() invokes the user-defined first.copy method, which allocates another first object and copies data1. That nested call is why this particular custom method is deep for the f1 relationship even though the built-in operation is shallow.

**Practical implication or pitfall**

Do not infer deep independence from a new outer handle. Check every nested class handle and clone it explicitly when independent nested state is required.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

### What exactly does the custom first.copy method do?

**Original code question**

> 2. In this code, **what exactly am I doing?**

**Where it appears**

`testbench.sv:66–73` inside the saved block comment.

**Context in this playground**

The question shows a function returning first, allocates a result with new, and assigns the source data into the result.

**Answer**

It is a normal user-defined method that creates a new first object, copies the selected member values into it, and returns the new object handle.

**Deep explanation**

The function name first is its return type. The local function result named copy receives a newly allocated first object from new(), then copy.data = data transfers the source value into that object. In the live active code the corresponding member is data1, but the mechanism is the same: an implicit this handle identifies the source object on which the method was called, while copy identifies the destination object. The caller can assign the returned handle to another variable.

**Practical implication or pitfall**

A custom method copies only what its body assigns. If the class later gains a member, especially a nested class handle, the method must be extended deliberately.

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### Why use copy() instead of only new()?

**Original code question**

> 3. Why am I using a custom `copy()` function instead of simply using `function new()` and initializing the class members there?

**Where it appears**

`testbench.sv:75` inside the saved block comment.

**Context in this playground**

The active second.copy method first uses new() to obtain an empty second object and then fills data2 and the nested f1 object from the source object.

**Answer**

new() creates and initializes a fresh object; copy() is the user-defined operation that transfers an existing object's state into a new object.

**Deep explanation**

A constructor belongs to object creation. It establishes the initial state of the object being allocated, using property initializers and constructor arguments. A copy method has a different responsibility: it receives the already-existing source through the method handle, decides which state to transfer, and may call new() internally to allocate the destination. In this example, new() alone would give s2 a new second object with its default data2 and a newly constructed f1; s1.copy() additionally transfers s1.data2 and recursively copies s1.f1.data1.

**Practical implication or pitfall**

Replacing a copy method with a constructor call loses the source-state transfer. Replacing a constructor with a copy method also changes the meaning of a fresh object into a clone of an existing one.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

### What is function new() called?

**Original code question**

> 4. What is this called?

**Where it appears**

`testbench.sv:77–83` inside the saved block comment.

**Context in this playground**

The block comment shows a function new declaration and the live classes also define new methods for second.

**Answer**

It is the class constructor, also called the new method.

**Deep explanation**

SystemVerilog gives the class constructor the special name new. A class variable declaration alone creates a handle variable; the new operation allocates an object and invokes the constructor associated with the class. The constructor declaration has constructor-specific syntax and does not declare an ordinary return type. That is distinct from the return type first on function first copy().

**Practical implication or pitfall**

Do not read the word function in function new() as meaning that new is an ordinary copy routine. Its role is tied to construction, while ordinary methods may perform any class operation.

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf) and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Are function new() and function first copy() both constructors?

**Original code question**

> 5. Are both `function new()` and `function first copy()` **constructors**?

**Where it appears**

`testbench.sv:85` inside the saved block comment.

**Context in this playground**

The first class defines first.copy(), while both classes use new() for object construction.

**Answer**

No. The method named new is the constructor; first.copy is an ordinary user-defined function that happens to allocate and return a new object.

**Deep explanation**

The language identifies a constructor by the special new name and constructor declaration rules. The return type on function first copy() is an ordinary function return type, so the call produces a first handle as a function result. Its body chooses to call new() and copy members, but calling new inside a method does not turn the enclosing method into a constructor. This distinction matters when reading who owns initialization and when object allocation occurs.

**Practical implication or pitfall**

Classify a method by its declaration and invocation, not by whether its body contains new. A custom clone method still needs an explicit call such as s1.copy().

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### What is the difference between a constructor and a copy method?

**Original code question**

> 6. If they are not both constructors, **what exactly is the difference between a constructor and a `copy()` method?**

**Where it appears**

`testbench.sv:87` inside the saved block comment.

**Context in this playground**

The source uses constructors to establish first and second objects, then uses copy methods to duplicate scalar and nested state.

**Answer**

A constructor initializes the object being created; a copy method describes how state from an existing source object is transferred into another object.

**Deep explanation**

The constructor runs as part of the new allocation path and can use arguments such as data1 and data2. The copy method has an existing receiver: f1.copy() reads the receiver's current members, allocates a destination, and assigns selected values. The custom nested call f1.copy() is therefore a recursive policy decision, not an automatic property of the constructor. The two operations can share implementation details, but their inputs and purpose are different.

**Practical implication or pitfall**

A constructor call without a source does not preserve an object's current values. A copy method also needs an explicit policy for nested handles, queues, arrays, and other reference-like state.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

### Why cannot new() and copy() be used interchangeably?

**Original code question**

> 7. Why can't I use `new()` and `copy()` **interchangeably**?

**Where it appears**

`testbench.sv:89` inside the saved block comment.

**Context in this playground**

s1=new() creates a fresh second object, while s2=s1.copy() is intended to retain s1's data2 value and duplicate its nested f1 state.

**Answer**

They are not interchangeable because new() starts construction without a source object, whereas copy() reads and transfers the state of a particular source object.

**Deep explanation**

new() selects the class construction path and uses defaults or the supplied constructor arguments. copy() is an ordinary method call whose receiver is s1; the method body then decides what is copied and how deeply. In the saved example, s1.data2 is set to 45 before s2=s1.copy(), so s2.data2 begins with 45 rather than the class default 14. The nested first.copy call gives s2.f1 its own data1 object as well.

**Practical implication or pitfall**

Use new() when the desired state is fresh construction. Use copy() only when you intentionally want a clone policy; otherwise stale or partially copied members can be mistaken for a complete duplicate.

**Sources**

[Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### What is the difference between f2 = new() and f2 = f1.copy()?

**Original code question**

> 8. What is the difference between:
>
> ```systemverilog
> f2 = new();
> ```
>
> and:
>
> ```systemverilog
> f2 = f1.copy();
> ```

**Where it appears**

`testbench.sv:91–101` inside the saved block comment.

**Context in this playground**

The two expressions are presented as alternatives for creating f2, with one having no source object and the other invoking a method on f1.

**Answer**

f2=new() creates a fresh object using construction defaults; f2=f1.copy() receives the new object returned by the copy method after it has been initialized from f1.

**Deep explanation**

The first expression calls the constructor directly and does not read f1. The second expression evaluates f1.copy(), so the copy method allocates a destination and assigns the source's members before the returned handle is stored in f2. In this repository's live code, second.copy also calls f1.copy for the nested member, which makes the nested object independent. A built-in shallow-copy expression such as new f1 would have different nested-handle behavior.

**Practical implication or pitfall**

When comparing output, record both object identity and member values. Equal initial scalar values do not prove that nested objects are independent.

**Sources**

[IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf).

### Why does new() create a fresh object while f1.copy() preserves f1 values?

**Original code question**

> 9. Why does `new()` give me a **fresh/default object**, while `f1.copy()` gives me a **new object containing the values of `f1`**?

**Where it appears**

`testbench.sv:103` inside the saved block comment.

**Context in this playground**

The live source sets s1.data2 to 45, then calls s1.copy and later changes s2.data2 to 555 to compare s2 with s1.

**Answer**

new() performs construction from defaults and arguments; f1.copy() performs additional assignments from the source object's current state after allocating the destination.

**Deep explanation**

Construction does not have a source object to read. It creates the object and applies property initializers and constructor statements, so second's data2 starts from its declared initialization of 14 unless later assigned. The custom method first.copy assigns the current data1 into the newly allocated first object, and second.copy assigns data2 before recursively copying f1. Therefore s2 starts with s1's current state, and the later s2.data2=555 changes only the destination scalar. The displays in the source are written to expose that distinction.

**Practical implication or pitfall**

A clone is only as current as the instant it is called and only as complete as the assignments in its method. Do not assume future source changes propagate to the clone.

**Sources**

[Accellera class handles and copying reference](https://www.accellera.org/images/eda/sv-ec/att-0051/01-sv3.1_donation_VeraLite.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

### What is the relationship between the constructor and copy-method lines?

**Original code question**

> 10. More generally, what is the relationship between:
> * `function new()` → constructor **definition**
> * `f1 = new()` → constructor **call / object creation**
> * `function first copy()` → user-defined **copy method**
> * `copy = new()` inside `copy()` → constructor call **inside the copy method**?

**Where it appears**

`testbench.sv:105–110` inside the saved block comment.

**Context in this playground**

The block comment separates declarations from calls: new is declared as a constructor, new is invoked to allocate, copy is declared as a normal method, and copy calls new internally.

**Answer**

The first and third lines are method definitions; the second is a constructor invocation; the fourth is a copy-method invocation; and the last is a constructor invocation nested inside that copy method.

**Deep explanation**

function new() defines the special constructor method for a class. f1=new() invokes construction and returns a handle to a new object. function first copy() defines a separate ordinary function whose receiver is an existing first object. Inside that function, copy=new() invokes construction to obtain the destination object. The same keyword therefore appears in a declaration name and in an allocation expression, while copy remains a user-defined method name.

**Practical implication or pitfall**

Trace both the syntactic role and the receiver for every new or copy occurrence. A new inside a copy routine is not evidence that the copy routine itself is a constructor.

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf) and [IEEE SA IEEE 1800 standard page](https://standards.ieee.org/ieee/1800/7743/).

### Why does the comment say copy is called without parentheses?

**Original code question**

>     copy.f1 = f1.copy() ;  // why copy called without ()

**Where it appears**

`testbench.sv:27`, beside the active nested copy call.

**Context in this playground**

The saved source literally contains f1.copy() with an empty pair of parentheses, so the comment's wording conflicts with the expression immediately before it.

**Answer**

In the captured gchG source, copy is called with parentheses: f1.copy(). The code does not demonstrate a parenthesis-free call.

**Deep explanation**

The parentheses are the empty argument list of the ordinary function method call. The call executes first.copy, allocates a new first object, and returns its handle for assignment to copy.f1. The authoritative object-method reference shows method calls in the form p.current_status(), while the constructor syntax has its own new forms. A broader claim that an ordinary zero-argument user method may omit the parentheses is not verified from the authoritative sources opened for this pass; that claim should not be inferred from this line.

**Practical implication or pitfall**

Use the exact saved expression when reasoning about this playground. Do not silently rewrite f1.copy() to another spelling or treat the comment as proof that the parentheses are absent.

**Sources**

[Accellera object-method and constructor reference](https://www.accellera.org/images/eda/sv-bc/att-2957/Issue_266_CliffCummings_rev3.pdf) and [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf).

