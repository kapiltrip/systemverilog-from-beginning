# Part 14 — Class composition and scope

EDA Playground: [https://edaplayground.com/x/EasK](https://edaplayground.com/x/EasK)
EDA Playground Name: `Class Composition and Scope`

This part combines class scope, setter/getter methods, and composition: class `second` contains a handle to an object of class `first`.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source is preserved separately in [`testbench.sv`](testbench.sv). The original page exercised the setter/getter path with the value 12; the corrected version also checks the default value before the update.

~~~systemverilog
// Code your testbench here
// or browse Examples
// Class methods can encapsulate access, and one class can contain another.
`timescale 1ns/1ps

class first;
  // Class members are public by default when no access qualifier is given.
  int data = 34;

  task setter(input int data);
    this.data = data;
  endtask

  function int getter();
    return data;
  endfunction

  task display;
    $display("[%0t] first.data=%0d", $time, data);
  endtask
endclass

class second;
  first f1;

  function new();
    f1 = new();
  endfunction
endclass

module tb;
  second s;
  int error_count;

  task automatic check_value(
    input string label,
    input int actual,
    input int expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s expected %0d, got %0d", label, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    error_count = 0;

    s = new();
    check_value("default composed object value", s.f1.getter(), 34);
    s.f1.display();

    s.f1.setter(12);
    check_value("value after setter", s.f1.getter(), 12);
    $display("[%0t] getter returned %0d", $time, s.f1.getter());

    if (error_count == 0) begin
      $display("PASS: composed classes and setter/getter scope passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 14 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its commented access experiments and original learning notes. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
// scope is public be default

class first ;
  //local int data = 34;
  int data=34;

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

## Answers and notes

- Class members are public by default unless an access qualifier such as `local` or `protected` changes that visibility.
- `setter` is a task because it performs an update; `getter` is a function because it returns a value without consuming time.
- `this.data = data` writes the member using the task input as the new value.
- `second` demonstrates composition rather than inheritance: it contains a `first` handle named `f1`.
- `second.new()` allocates the nested `first` object, so `s.f1` is valid immediately after `s = new()`.
- The original page comments out direct member access and uses the setter/getter methods to show a cleaner interface.

## Detailed discussion

### Composition creates a handle graph

The object relationships after `s = new()` are:

```text
s  --->  second object
          |
          `-- f1 ---> first object, data = 34
```

The outer constructor creates the inner object. This is why the testbench can call `s.f1.getter()` without a separate `s.f1 = new()` statement in the module.

### Setter and getter behavior

`setter(12)` updates the inner object, and `getter()` returns the updated value. The calls are intentionally separate so the testbench demonstrates both directions of the interface:

1. Read the default member value 34 through `getter()`.
2. Write 12 through `setter(12)`.
3. Read 12 back through `getter()`.

The `display` task provides a third observation path from inside the class.

### Expected result

| Phase | Expected observation |
| --- | --- |
| Outer construction | `s.f1` is a valid `first` object with `data=34`. |
| Initial getter | Returns 34. |
| Setter | Stores 12 in the inner object. |
| Final getter | Returns 12 and the testbench prints PASS. |

The saved Riviera-Pro page compiled with zero errors and zero warnings and printed `value of data 12 is`. The repository version adds the default-value check and an explicit PASS endpoint. Icarus 12 cannot elaborate nested class method paths such as `s.f1.getter()`, so a SystemVerilog simulator with class-composition support is required.

### Points to remember

- A class can own handles to other class objects.
- Constructors should initialize nested handles before use.
- Setter/getter methods provide a controlled interface even when members are public.
- Functions return values; tasks perform actions and may contain timing controls.
