# Part 23 — Constrained Randomization with a Single Constraint

[← Part 22](../22-constrained-randomization-with-randc/README.md) · [Learning index](../README.md) · [Part 24 →](../24-constrained-randc-inside-and-excluded-ranges/README.md)

EDA Playground: [Constrained Randomization with a Single Constraint](https://edaplayground.com/x/gixd)  
EDA Playground Name: `Constrained Randomization with a Single Constraint`  
Saved code ID: `7358850`

## Why this example matters

One constraint block may contain several expressions, and all active expressions must be satisfied together. Here the legal region is the intersection of the bounds on `a` and `b`, not a sequence in which one statement overwrites another.

The loop constructs a fresh generator every iteration, which matters for `randc`: cyclic history belongs to the object. Recreating the object can restart that state, so keeping one object across calls is the clearer experiment when the goal is to observe a full random cycle.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Testbench code

~~~systemverilog
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps 

class generator; 
  randc bit [3:0] a,b;
  bit [3:0] y; 
  /*
  constraint data_a {a>3;a<7; }
  constraint data_b {b==3; }
  */
  //single constraint 
  constraint data_const {a>3 ; a<7 ; b>0 ; }
endclass

module tb;
  generator g;
  int i =0;
  int status =0; 
  
  initial begin
    for(i=0 ; i<10; i++)begin
      g=new();
      status = g.randomize(); 
      $display("value of a,b is %0d %0d with status %0d " , g.a , g.b , status  ); 
    end
  end
endmodule 
~~~

## What happened when it ran

Live EDA run: Questa completed with Errors: 0 and Warnings: 1; ten display lines reported status 1.

The live EDA source and settings were not edited during verification.

