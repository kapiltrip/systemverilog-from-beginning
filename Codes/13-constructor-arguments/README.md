# Part 13 — Constructor arguments

EDA Playground: [https://edaplayground.com/x/Ud7M](https://edaplayground.com/x/Ud7M)

This part adds a constructor with default values and demonstrates both positional and explicitly named constructor arguments.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source is preserved separately in [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
// Constructors accept positional or explicitly named arguments.
`timescale 1ns/1ps

class first;
  int data1;
  bit [7:0] data2;
  shortint data3;

  function new(
    input int data1 = 0,
    input bit [7:0] data2 = 8'd0,
    input shortint data3 = 0
  );
    this.data1 = data1;
    this.data2 = data2;
    this.data3 = data3;
  endfunction

  task display;
    $display("[%0t] data1=%0d, data2=%0d, data3=%0d", $time, data1, data2, data3);
  endtask
endclass

module tb;
  first f1;
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

    f1 = new(.data2(5), .data3(5), .data1(11));
    f1.display();
    check_value("named data1", f1.data1, 11);
    check_value("named data2", f1.data2, 5);
    check_value("named data3", f1.data3, 5);

    f1 = new(14, 6, 43);
    f1.display();
    check_value("positional data1", f1.data1, 14);
    check_value("positional data2", f1.data2, 6);
    check_value("positional data3", f1.data3, 43);

    if (error_count == 0) begin
      $display("PASS: named and positional constructor arguments passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 13 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its original named-constructor example and learning comments. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

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
    //$display("Data member of the class first data1  is %0d, data2 is %0d and data 3 is %0d" , f1.data1,f1.data2, f1.data3);
  end

endmodule
~~~

## Answers and notes

- `function new(...)` is the constructor. It runs when an object is created with `new(...)`.
- Default values make omitted constructor arguments predictable.
- Positional arguments are matched left-to-right: `new(14, 6, 43)` assigns `data1`, `data2`, and `data3` in declaration order.
- Named arguments use `.formal(actual)`, so `new(.data2(5), .data3(5), .data1(11))` does not depend on the order in which the actual arguments are written.
- `this.data1` distinguishes the class member from the constructor formal named `data1`.
- The `shortint` member is a 16-bit signed integer, while `data2` is an 8-bit packed two-state vector.

## Detailed discussion

### Why named arguments help

Positional calls are compact but depend on remembering the constructor's parameter order. Named calls make the mapping explicit and are safer when a class has several fields of related types or when the constructor evolves.

The first object is created with the named call and should print:

```text
data1=11, data2=5, data3=5
```

The second call uses positional arguments and should print:

```text
data1=14, data2=6, data3=43
```

### Constructor assignment and `this`

Inside the constructor:

~~~systemverilog
this.data1 = data1;
~~~

The left side is the member belonging to the object currently being constructed. The right side is the constructor input. Without `this`, a same-named formal can hide the member and make the assignment ambiguous or ineffective.

### Expected result

| Call | Expected object state |
| --- | --- |
| `new(.data2(5), .data3(5), .data1(11))` | `data1=11`, `data2=5`, `data3=5` |
| `new(14, 6, 43)` | `data1=14`, `data2=6`, `data3=43` |

The saved Riviera-Pro run compiled with zero errors and zero warnings and printed the named-argument state `11, 5, 5`. The repository version additionally checks the positional form and ends with an explicit PASS result. Icarus 12 reports named-constructor syntax as unsupported even though the saved Riviera-Pro page accepts it.

### Points to remember

- Constructors initialize object state at allocation time.
- Defaults make a constructor usable with partial argument lists.
- Positional arguments follow formal order; named arguments follow formal names.
- Use `this` when a formal parameter and a class member share a name.
