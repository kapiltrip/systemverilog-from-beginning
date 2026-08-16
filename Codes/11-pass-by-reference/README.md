# Part 11 — Pass by reference

EDA Playground: [https://edaplayground.com/x/Ua2v](https://edaplayground.com/x/Ua2v)

This part shows how a task can receive `ref` arguments and modify the caller's variables directly.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source is preserved separately in [`testbench.sv`](testbench.sv).

~~~systemverilog
// Code your testbench here
// or browse Examples
// ref task arguments update the caller's variables directly.
`timescale 1ns/1ps

module tb;
  bit [1:0] c;
  bit [1:0] d;
  int error_count;

  task automatic swap(ref bit [1:0] a, b);
    bit [1:0] temp;
    temp = a;
    a = b;
    b = temp;
    $display("[%0t] inside swap: a=%0d, b=%0d", $time, a, b);
  endtask

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
    c = 1;
    d = 2;

    #1;
    swap(c, d);
    $display("[%0t] after swap: c=%0d, d=%0d", $time, c, d);
    check_value("c after ref swap", c, 2);
    check_value("d after ref swap", d, 1);

    if (error_count == 0) begin
      $display("PASS: ref arguments changed the caller variables");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 11 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its commented alternatives and original learning notes. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
module tb;
  task automatic swap(ref bit [1:0] a, b);
    //task automatic swap(const ref bit [1:0] a, ref bit b);
  //task automatic swap(ref bit [1:0] a, b);

    bit [1:0] temp;
    temp = a;
    a  = b;
    b = temp;
    $display ("value of a is : %0d and b is : %0d " , a,b ) ;
  endtask
  bit [1:0] c;
  bit [1:0] d;
  initial begin
    c=1;
    d=2;
    swap(c,d);
    $display ("value of c is : %0d and d is : %0d " , c,d ) ;
    //wont be reflected to the varaibles outside the task
    // WHY PASS BY VALUE IN TERMS OF SCALAR HE IS SAYING

  end
endmodule
~~~

## Answers and notes

- `ref` passes a reference to the caller's variable rather than a separate value copy.
- The task's local names `a` and `b` refer to the same storage as `c` and `d` in the calling process.
- The temporary variable is local to the task, but the final assignments remain visible after the task returns.
- `automatic` gives each task call its own stack storage, which is important when calls can overlap or recurse.
- Passing by reference is useful for swap operations, output-like updates, and procedures that must fill an existing object or array.

## Detailed discussion

### What changes at the call boundary

At the call site, `swap(c, d)` passes the variables themselves. The task executes:

1. Save `a` (the caller's `c`) in `temp`.
2. Write `b` (the caller's `d`) into `a` (the caller's `c`).
3. Write `temp` into `b` (the caller's `d`).

The values are therefore 2 and 1 both inside the task and after it returns. With ordinary pass-by-value arguments, the task would modify temporary formal values and the caller would remain 1 and 2.

### Expected result

| Time | Observation |
| ---: | --- |
| 0 ns | `c=1`, `d=2` are initialized. |
| 1 ns | `swap(c,d)` prints `a=2`, `b=1`; the caller sees `c=2`, `d=1`. |
| 1 ns | The self-check prints PASS and the simulation finishes. |

The saved Riviera-Pro page compiled with zero errors and zero warnings and printed the same before/after values. The local Icarus Verilog 12 installation reports reference ports as unsupported; that is a simulator limitation, not a failure of the SystemVerilog construct demonstrated here.

### Points to remember

- Pass by value protects the caller from formal-argument assignments.
- Pass by reference deliberately shares the caller's storage.
- Use `automatic` for local temporaries in reusable tasks.
- Verify both the value inside the task and the value after return when learning reference semantics.
