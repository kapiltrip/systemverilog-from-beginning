# Part 24 — Constrained randc: inside and Excluded Ranges

[← Part 23](../23-constrained-randomization-with-a-single-constraint/README.md) · [Learning index](../README.md) · [Part 25 →](../25-constraint-outside-a-class/README.md)

EDA Playground: [Constrained randc: inside and Excluded Ranges](https://edaplayground.com/x/A7hT)  
EDA Playground Name: `Constrained randc: inside and Excluded Ranges`  
Saved code ID: `7358861`

## Why this example matters

`inside` describes set membership directly. Wrapping it in logical negation turns an allowed set into an excluded set, so the active constraints remove `a` values 3 through 7 and `b` values 5 through 9 from their 4-bit domains.

Think of each constraint as filtering a candidate set before random selection. Writing the remaining legal values on paper makes overlapping ranges, singleton values, and negated membership much easier to verify.

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
// values of a certain range 
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps 

class generator; 
  randc bit [3:0] a,b;
  bit [3:0] y; 
  // for working with range 
  /*
  constraint data_valid {a inside {[0:8], [10:11], 15} ;
                   b inside {[3:11]} ; 
                  }
  */
  // to skip some values 
  constraint data_skipped {
    !(a inside {[3:7]});
    !(b inside {[5:9]});
  }
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

