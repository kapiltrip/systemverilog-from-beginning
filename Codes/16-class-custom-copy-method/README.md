# Part 16 — Class custom copy method

EDA Playground: [https://edaplayground.com/x/X4c6](https://edaplayground.com/x/X4c6)

The page has no saved EDA Playground Name and its browser title is the generic `Edit code - EDA Playground`. This topic name is inferred from the visible editor's `// custom methods to copy` comment and its `function first copy()` method. Both the saved field and the visible editor buffer are preserved below: [`testbench.sv`](testbench.sv) records the saved source, while [`editor_testbench.sv`](editor_testbench.sv) records the visible buffer that was open during capture.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). It implements the visible editor's intended custom copy method as a supported `copy_from` procedure, correcting the missing call parentheses while checking that later mutations of the copied object do not change the original.

~~~systemverilog
// Code your testbench here
// or browse Examples
// A class method can make an explicit value copy of selected members.
`timescale 1ns/1ps

class first;
  int data = 34;
  bit [7:0] temp = 8'h11;

  function void copy_from(input first source);
    data = source.data;
    temp = source.temp;
  endfunction
endclass

module tb;
  first f1;
  first f2;
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

  task automatic check_byte(
    input string label,
    input bit [7:0] actual,
    input bit [7:0] expected
  );
    if (actual !== expected) begin
      error_count++;
      $error("FAIL: %s expected %0h, got %0h", label, expected, actual);
    end
  endtask

  initial begin
    $timeformat(-9, 0, " ns", 8);
    error_count = 0;

    f1 = new();
    f1.data = 45;
    f1.temp = 8'h11;
    f2 = new();
    f2.copy_from(f1);
    $display("[%0t] copied data=%0d, temp=%0h", $time, f2.data, f2.temp);
    check_value("copied data", f2.data, 45);
    check_byte("copied temp", f2.temp, 8'h11);

    f2.data = 56;
    f2.temp = 8'h22;
    $display("[%0t] after changing copy: f1.data=%0d, f2.data=%0d", $time, f1.data, f2.data);
    check_value("original data after copy mutation", f1.data, 45);
    check_byte("original temp after copy mutation", f1.temp, 8'h11);
    check_value("copy data after mutation", f2.data, 56);
    check_byte("copy temp after mutation", f2.temp, 8'h22);

    if (error_count == 0) begin
      $display("PASS: custom class copy method made an independent member copy");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 16 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved saved EDA Playground source

This block is the exact saved testbench field from the page and is stored as [`testbench.sv`](testbench.sv). It contains the custom method experiment and its original incomplete `f1.copy` call.

~~~systemverilog
// Code your testbench here
// or browse Examples
class first ;
  int data = 34 ;
  bit [7:0] temp= 8'h11;

  // custom methods to copy
  function first copy();
    copy= new();
    copy.data = data;    // why am i not using this here,
    copy.temp = temp ;

  endfunction
endclass

module tb ;
  first f1;
  first f2 ;
  // to store copy of f1 to f2
  /*
  initial begin
    f1=new();
    f1.data = 45;

    f2=new f1;  // copy of the data members of f1 to f2

    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    // this is not changing f1

    f2.data = 56;
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    $display("Data member of f1 now becomes a copy %0d " , f1.data );

  end
  */
  initial begin
    f1=new();
    f2=new();
    f2= f1.copy;     //automatically copies  why i havent used f1.copy()
    $display("Data : %0d and temp is %0h" , f2.data, f2.temp); // he called hex by using %0x
  end
endmodule
~~~

## Preserved visible editor buffer

The following is the complete visible CodeMirror buffer captured from the open tab. It is kept separately as [`editor_testbench.sv`](editor_testbench.sv) so the visible page state can be reviewed without silently rewriting the saved file.

~~~systemverilog
// Code your testbench here
// or browse Examples
class first ;
  int data = 34 ;
  bit [7:0] temp= 8'h11;

  // custom methods to copy
  function first copy();
    copy= new();
    copy.data = data;    // why am i not using this here,
    copy.temp = temp ;

  endfunction
endclass

module tb ;
  first f1;
  first f2 ;
  // to store copy of f1 to f2
  /*
  initial begin
    f1=new();
    f1.data = 45;

    f2=new f1;  // copy of the data members of f1 to f2

    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    // this is not changing f1

    f2.data = 56;
    $display("Data member of f2 now becomes a copy %0d " , f2.data );
    $display("Data member of f1 now becomes a copy %0d " , f1.data );

  end
  */
  initial begin
    f1=new();
    f2=new();
    f2= f1.copy;     //automatically copies  why i havent used f1.copy()
    $display("Data : %0d and temp is %0h" , f2.data, f2.temp); // he called hex by using %0x
  end
endmodule
~~~

## Answers and notes

- A class handle assignment such as `f2 = f1` aliases the same object; `f2 = new f1` constructs a separate object and copies the member values.
- A custom `copy()` method makes the copy operation explicit and can select or transform which members are copied.
- The visible experiment uses `f1.copy` without call parentheses. The self-checking file expresses the same explicit member-copy idea as `f2.copy_from(f1)` so it is portable to the local simulator.
- The page's completed copy experiment prints 56 for `f2.data` and 45 for `f1.data`, demonstrating independent scalar storage.
