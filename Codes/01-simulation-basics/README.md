# Part 01 — Simulation basics

EDA Playground: [https://edaplayground.com/x/Ucnp](https://edaplayground.com/x/Ucnp)

This first example introduces simulation time, initialization, delays, waveform dumping, console monitoring, reset stimulus, and explicit simulation termination.

## Complete testbench code

The code below is reproduced completely from [`testbench.sv`](testbench.sv), so the example can be studied without leaving this page.

~~~systemverilog
// Code your testbench here
// or browse Examples
//Types of signals global , data , control 
`timescale 1ns/1ps  // time unit  / time precision 

/*

module tb();
  reg a =0;
  initial begin  // will start from time 0 (start of the simulation ) 
    
    a =1; 
    #10;
    a=0; 
    
  end   //variable will hold the value =0 till the end of the simulation 
  
endmodule
*/
module tb();
  reg clk ; 
  reg [3:0] temp ; 
  // coulld be used to initialize a golbal varialbe 
  // to generate random signal for data / control signal 
  // 
  initial begin
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    temp=4'b0100;
    #10; // 10 * 1ns (time unit )
    temp = 4'b0011;
    
  end
  reg reset; 
  initial begin
    clk =1'b0;  //single bit value in the binary format 
    reset=1'b0 ; 
    
  end
  // at the start of simuation 
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  // to analyse the values of the variabl es from the beginning of the time 
  initial begin
    $monitor( "Temp : %0d at time %0t  " , temp , $time);
  end
  // analyzing values of variable in console 
  // stop simulation by forcefully calling finish 
  
  initial begin
      #200 ; 
    $finish();
  end
  initial begin
      reset=1'b1; 
    #10;
    reset = 1'b0;
  end
endmodule
~~~

## Answers and notes

- `` `timescale 1ns/1ps `` means one delay unit is 1 ns and simulation time is rounded to a precision of 1 ps. Therefore, `#10` represents 10 ns.
- Every `initial` block starts concurrently at simulation time 0. Statements inside one block execute sequentially.
- A `reg` that is not initialized starts as `x` in four-state Verilog simulation. Assigning `clk = 1'b0` and `reset = 1'b0` removes that unknown initial state.
- `$dumpfile` selects the VCD output file and `$dumpvars` records signal changes for waveform viewing.
- `$monitor` prints once when it is called and again whenever one of its arguments changes.
- `$finish` ends the simulation. It is necessary here as a safety endpoint and becomes essential when free-running `always` blocks are added later.
- In the `temp` stimulus, two assignments at the same simulation time overwrite one another. A delay is needed between them if both values must be visible in the waveform.

## Detailed discussion

### How the concurrent blocks execute

The module contains five active `initial` blocks. They all begin at simulation time 0; source-file order does not make one block finish before another. Each block advances independently until it reaches a delay.

| Simulation time | Important activity |
| ---: | --- |
| 0 ns | `temp` becomes 4, `clk` becomes 0, reset initialization and reset assertion both execute, waveform dumping starts, and monitoring starts. |
| 10 ns | `temp` is assigned 3 and then immediately 4 in the same block; reset is deasserted. |
| 20 ns | `temp` becomes 3. |
| 200 ns | `$finish` terminates the simulation. |

The assignments `temp = 4'b0011` and `temp = 4'b0100` at 10 ns have no delay between them. They occur in the same simulation time slot, so the value 3 may not appear as a stable waveform interval. Adding a delay or waiting for an event between those assignments would make both states observable.

### Why initialization matters

`reg` is a four-state Verilog variable, so an uninitialized value begins as `x`. Explicitly initializing `clk`, `reset`, and `temp` makes the waveform interpretable and prevents unknown values from propagating into later expressions. Notice that `clk` is initialized but never toggled in this part; clock generation is introduced in Part 02.

### Waveform and console observability

`$dumpfile("dump.vcd")` chooses the waveform file and `$dumpvars` enables value-change recording. These tasks support waveform inspection, whereas `$monitor` supports textual observation. `$monitor` remains active after it is called and prints after an argument changes, making it suitable for following `temp` over time.

### Points to remember

- Delays control when a procedural block resumes; they do not pause the other concurrent blocks.
- Multiple assignments without a delay can occur at the same timestamp.
- Initialize four-state testbench variables before using them.
- Give every potentially unbounded simulation an explicit stopping condition.
