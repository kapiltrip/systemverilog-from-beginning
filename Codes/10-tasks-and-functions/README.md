# Part 10 — Tasks and functions

EDA Playground: [https://edaplayground.com/x/ecCx](https://edaplayground.com/x/ecCx)
EDA Playground Name: `Tasks and Functions`

This part contrasts functions, which return a value without consuming simulation time, with tasks, which can contain timing controls and wait for clock events.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Corrected self-checking source

The deterministic verification version is rendered here and remains available as [`self_checking_testbench.sv`](self_checking_testbench.sv). The exact captured EDA Playground source, including its `$urandom`-driven task stimulus, is preserved separately in [`testbench.sv`](testbench.sv). The corrected version keeps both function and task ideas, replaces random samples with known values for repeatable checking, and stops after five completed clock-driven task calls.

~~~systemverilog
// Code your testbench here
// or browse Examples
// Functions return a value without consuming simulation time; tasks can wait.
`timescale 1ns/1ps

module tb;
  bit [2:0] c;
  bit [2:0] d;
  bit [3:0] e;
  bit [4:0] function_result;
  bit clk;
  int cycle_count;
  int error_count;

  function automatic bit [4:0] add_function(
    input bit [3:0] a,
    input bit [3:0] b
  );
    return a + b;
  endfunction

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

  task automatic add;
    e = {1'b0, c} + {1'b0, d};
    $display("[%0t] task add: %0d + %0d = %0d", $time, c, d, e);
  endtask

  task automatic stimuli_clk(input int next_c, input int next_d);
    @(posedge clk);
    c = next_c;
    d = next_d;
    add();
    cycle_count++;
    check_value("task result", e, next_c + next_d);
  endtask

  always #5 clk = ~clk;

  initial begin
    $timeformat(-9, 0, " ns", 8);
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
    clk = 1'b0;
    c = 3'b0;
    d = 3'b0;
    e = 4'b0;
    cycle_count = 0;
    error_count = 0;

    function_result = add_function(4'd4, 4'd13);
    $display("[%0t] function add: 4 + 13 = %0d", $time, function_result);
    check_value("function result", function_result, 17);

    stimuli_clk(1, 2);
    stimuli_clk(2, 4);
    stimuli_clk(3, 5);
    stimuli_clk(4, 7);
    stimuli_clk(5, 7);
    check_value("completed task cycles", cycle_count, 5);

    if (error_count == 0) begin
      $display("PASS: function return values and timed task calls passed");
    end
    else begin
      $display("FAIL: %0d check(s) failed", error_count);
      $fatal(1, "Part 10 self-check failed");
    end

    $finish;
  end
endmodule
~~~

## Preserved EDA Playground source

This block is the captured EDA Playground testbench, including its commented function example, active random task stimulus, and original comments. It is stored unchanged as [`testbench.sv`](testbench.sv); the self-checking code above is the separate corrected verification version.

~~~systemverilog
// Code your testbench here
// or browse Examples
/*
module tb;
  function bit [4:0] add(input bit [3:0] a , b);
    return a+b;

  endfunction
  bit [4:0] result ;  // so no need to make the result initialized by 0
  bit [3:0] ain= 4'b0100;
  bit [3:0] bin =4'b1101  ;
  // i can rather pass ain, bin to the function

  function void displayAINBIN();
    $display("Inside the function display ain ");
  endfunction
    initial begin
    result = add(4'b0000 , 4'b1110 );
    $display("Value of addition is %0d" , result );
      displayAINBIN();
  end
endmodule
*/
// cannot add delay in function ,
// task
module tb();
  bit [2:0] c;
  bit [2:0] d;
  bit [3:0] e;
  bit clk=0;
  always #10 clk = ~clk;

  //task add (input bit [3:0] c , input bit [3:0] d , output bit [4:0 ]e );
  task add();
    e=c+d;
    $display("THE SUM IS : %0d ", e );
  endtask
 /* bit [3:0] a,b;
  bit [4:0] y ;
  initial begin
      a =7;
      b=4;
    add(a,b,y);
    $display("Value of y is %0d" , y);
  end
  */

  task stimuli_clk();
    @(posedge clk);
    c=$urandom(); // 32 bit unsigned value will be generated
    d=$urandom(); //
    add();
    $display("Clock generated of hte random values after waiting for posedges  are %0d" , e);
  endtask
  task addWithTiming();
    c=1;
    d=3;
    add();
    #10;
    c=2;
    d=4;
    add();
    #30;
    c=5;
    d=8;

  endtask
  initial begin
    //addWithTiming();
    for(int i =0; i<11;i++)begin
      stimuli_clk();
    end
  end
  initial begin
    #110;
    $finish();

  end
endmodule
// passby value task add (reg int x, y )"
~~~

## Answers and notes

- A function has a return type and must complete without a timing control such as `#`, `@`, or `wait`.
- A task can contain timing controls and can therefore model a stimulus sequence that waits for a clock edge.
- The `add_function` call returns 17 immediately at time 0.
- The `stimuli_clk` task waits for a positive edge, drives `c` and `d`, calls the `add` task, and checks the result.
- `always #5 clk = ~clk` produces a 10 ns period. The five task calls complete on positive edges at 5, 15, 25, 35, and 45 ns.
- The original page used `$urandom()` to generate 3-bit samples. Fixed inputs are used here because self-checking tests should not depend on an uncontrolled random sequence.

## Detailed discussion

### Function timing versus task timing

The function is a value-producing calculation:

~~~systemverilog
function automatic bit [4:0] add_function(input bit [3:0] a, b);
  return a + b;
endfunction
~~~

It can be called from a procedural statement and returns before simulation time advances. The active tasks are different. `stimuli_clk` contains `@(posedge clk)`, so the calling process suspends until the clock event occurs. A task is therefore a natural unit for clocked stimulus, transactions, and reusable timing sequences.

### Width handling in the task

The original example used 3-bit operands and a 4-bit result. The active task explicitly zero-extends both operands before adding:

~~~systemverilog
e = {1'b0, c} + {1'b0, d};
~~~

This keeps the carry bit instead of allowing the expression to be evaluated at only the original operand width.

### Expected simulation phases

| Time | Event | Expected result |
| ---: | --- | --- |
| 0 ns | Function call | `4 + 13` returns 17 immediately. |
| 5 ns | First positive edge | Task sum is 3. |
| 15 ns | Second positive edge | Task sum is 6. |
| 25 ns | Third positive edge | Task sum is 8. |
| 35 ns | Fourth positive edge | Task sum is 11. |
| 45 ns | Fifth positive edge | Task sum is 12 and the testbench finishes. |

The saved Riviera-Pro run compiled with zero errors and zero warnings and produced five task results before its original timeout called `$finish` at 110 ns. The repository version finishes immediately after its five expected samples, which removes the original timeout/clock race.

### Points to remember

- Functions calculate and return; tasks can wait and coordinate time-consuming stimulus.
- A clock event inside a task suspends the caller until the event occurs.
- Size arithmetic explicitly when a carry bit must be preserved.
- Use deterministic inputs when the testbench itself is checking expected values.
