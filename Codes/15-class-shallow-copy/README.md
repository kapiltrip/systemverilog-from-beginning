# Part 15 — Class shallow copying

EDA Playground: [https://edaplayground.com/x/sVdz](https://edaplayground.com/x/sVdz)

This part demonstrates class-object copying. A new object is created from an existing object, its scalar member value is copied, and later changes to the copy do not change the original object.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The exact captured EDA Playground source, including the missing semicolon after the “Shallow copy behaviour” `$display`, is preserved in [`testbench.sv`](testbench.sv). Riviera-Pro reported that syntax error. The corrected verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv); it fixes only the syntax needed for a runnable, deterministic check and adds explicit assertions.

~~~systemverilog
// Code your testbench here
// or browse Examples
// Copying a class object creates a separate object with copied member values.
`timescale 1ns/1ps

class first;
  int data = 41;
endclass

module tb;
  first f1;
  first p1;
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

    f1 = new();
    f1.data = 24;

    p1 = new f1;
    $display("[%0t] copied data: p1.data=%0d", $time, p1.data);
    check_value("copied member", p1.data, 24);

    p1.data = 123;
    $display("[%0t] after changing p1: f1.data=%0d, p1.data=%0d", $time, f1.data, p1.data);
    check_value("original after copy mutation", f1.data, 24);
    check_value("copy after mutation", p1.data, 123);

    if (error_count == 0) begin
      $display("PASS: class copy preserved independent scalar member values");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 15 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including the missing semicolon that caused the saved page's syntax error. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
//Copy the data somethimes
class first ;
  int data = 41;

endclass
module tb;
  first f1;
  first p1;

  initial begin
    f1=new();  // constructor copy from 1 object to another object
    f1.data=24; // Data to be used , now i want to keep it safe
    //p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy)
    p1 = new f1 ;
    $display("Value fo the data member is %0d " , p1.data);
    //if i change in p1 object handle , it wont reflect on f1
    p1.data= 123;
    $display("Shallow copy behaviour ......................")
    $display("Value fo the data member f1 is %0d " , f1.data);
    $display("Value fo the data member p1 is %0d " , p1.data);

  end
endmodule
~~~

## Answers and notes

- `f1` and `p1` are handles, not objects. Each `new` operation creates an object that a handle can reference.
- `p1 = new f1` creates a new object initialized from `f1`. The scalar `data` value is copied into the new object.
- After the copy, `p1.data = 123` changes only the new object, while `f1.data` remains 24.
- This is called a shallow copy because nested class handles inside the object would be copied as handles; both objects could then refer to the same nested object.
- For the single scalar member in this example, the copied values are independent and the distinction is easy to observe.
- The source page's missing semicolon was a syntax error, not a class-copying rule. It is corrected in the repository version.

## Detailed discussion

### Copying the object versus copying the handle

These two statements have different meanings:

~~~systemverilog
p1 = f1;       // Both handles refer to the same object.
p1 = new f1;   // A new object is initialized from f1.
~~~

The first statement would make `p1.data = 123` change the object observed through `f1` as well. The second statement creates independent object storage, so changing the copied scalar member leaves the original unchanged.

### Why the copy is called shallow

If `first` later contained another class handle, the copy operation would copy that handle value rather than recursively allocate a complete duplicate object graph. The two outer objects would then share the nested object. A deep copy requires an explicit copy method that allocates and copies nested objects recursively.

### Expected result

| Phase | Expected observation |
| --- | --- |
| Construction | `f1.data` is set to 24. |
| `p1 = new f1` | `p1.data` is 24. |
| Copy mutation | `p1.data` becomes 123 while `f1.data` remains 24. |
| Completion | The self-check prints PASS. |

The saved Edge run used Riviera-Pro 2025.04 but failed before elaboration because the original source omitted a semicolon after a `$display` call. The repository copy records that failure and verifies the corrected experiment with an explicit PASS endpoint. Icarus 12 has limited support for class copy-constructor syntax, so Riviera-Pro or another full SystemVerilog simulator is the reference environment for this part.

### Points to remember

- Handle assignment aliases an existing object; `new old_handle` creates a copied object.
- Scalar members are copied by value in this example.
- Shallow copying does not recursively duplicate nested class objects.
- Always distinguish a source syntax error from a semantic simulator failure.
