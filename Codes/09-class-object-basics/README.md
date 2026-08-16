# Part 09 — Class object basics

EDA Playground: [https://edaplayground.com/x/qLDu](https://edaplayground.com/x/qLDu)
EDA Playground Name: `Class Object Basics`

This part introduces a class declaration, a class handle, object construction with `new`, four-state class members, and the meaning of a `null` handle.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The exact captured EDA Playground source, including its intentional null-handle dereference, is preserved in [`testbench.sv`](testbench.sv). The corrected verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv); it keeps the lesson and checks the handle before accessing members.

~~~systemverilog
// Code your testbench here
// or browse Examples
// A class handle must point to an object before its members are accessed.
`timescale 1ns/1ps

class first;
  reg [2:0] data;
  reg [1:0] data2;
endclass

module tb;
  first f;
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
    error_count = 0;

    f = new();
    #1;
    $display("[%0t] new object defaults: data=%0d, data2=%0d", $time, f.data, f.data2);
    if (!$isunknown(f.data)) begin
      error_count++;
      $error("FAIL: four-state class members should start as unknown");
    end
    if (!$isunknown(f.data2)) begin
      error_count++;
      $error("FAIL: data2 should start as unknown");
    end

    f.data = 3'b010;
    f.data2 = 2'b10;
    #1;
    $display("[%0t] after member assignments: data=%0d, data2=%0d", $time, f.data, f.data2);
    check_value("data after assignment", f.data, 2);
    check_value("data2 after assignment", f.data2, 2);

    f = null;
    if (f == null) begin
      $display("[%0t] handle is null; member access is intentionally skipped", $time);
    end
    else begin
      error_count++;
      $error("FAIL: f should be null after deallocation");
    end

    if (error_count == 0) begin
      $display("PASS: class construction, member access, and null handling passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 09 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including the final null-handle member access that intentionally demonstrates the runtime failure. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
  class first;
    reg [2:0] data; // attributes
    reg [1:0] data2 ; // reg is a 4 state data type


  endclass
module tb;
  first f;  // f is a handler wont able to access the class
             //class are dynamic object ? meaning
             // Do not keep that object throughout life of the simulation

  initial begin
    f=new(); // constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values
             // Once i call the constructor
             // f now points to that, object


    #1;
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2);
    // Try to add a value
    f.data = 3'b010;
    f.data2= 2'b10 ;
    #1;
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2);
    f=null; // deallocate the memory associated to the class
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2);

  end

endmodule
~~~

## Answers and notes

- `class first` defines the layout and behavior of a class type; it does not allocate an object by itself.
- `first f` declares a handle. The handle can be `null` until it points to an object.
- `f = new()` allocates the object and makes member access legal.
- Because `data` and `data2` are `reg` variables, they are four-state and start as `x` when the object is constructed without explicit member initialization.
- Assigning `f = null` releases the handle's reference. Accessing `f.data` afterward is a null-pointer error, so a testbench must check the handle first.
- The class object is dynamic storage; the lifetime of the object is independent of the declaration of the handle that points to it.

## Detailed discussion

### Handle versus object

The declaration `first f;` creates only a handle. It does not create the object represented by the class. The constructor call `f = new()` creates the object and connects the handle to it. This distinction is why a class handle can exist in a `null` state.

The page's output before member assignment is:

```text
Value of data and data2 is  x, x
```

That result is not a failure. It demonstrates the four-state default values of the `reg` members. After assigning `3'b010` and `2'b10`, the values print as 2 and 2.

### Null handles are not empty objects

`null` does not mean “an object whose members have default values.” It means the handle points to no object. The following operation from the original page therefore causes a runtime failure:

~~~systemverilog
f = null;
$display("Value of data and data2 is %0d, %0d", f.data, f.data2);
~~~

The saved Edge run compiled successfully but stopped at 2 ns with Riviera-Pro `RUNTIME_0029 Null pointer access`. The repository version replaces that unsafe access with an explicit `if (f == null)` check, so the intended concept is verified without crashing the simulation.

### Expected simulation phases

| Time | Phase | Expected observation |
| ---: | --- | --- |
| 0 ns | Construction | `f` points to a new object. |
| 1 ns | Default inspection | `data` and `data2` are unknown four-state values. |
| 2 ns | Assignment | Both members contain the value 2 when printed as unsigned integers. |
| 2 ns | Null handling | `f == null` is true and no member access is attempted. |

### Points to remember

- A class declaration describes an object; a handle points to an object.
- Call `new()` before accessing members through a non-null handle.
- Use four-state members when the distinction between initialized and unknown values matters.
- Check for `null` before dereferencing a class handle.
