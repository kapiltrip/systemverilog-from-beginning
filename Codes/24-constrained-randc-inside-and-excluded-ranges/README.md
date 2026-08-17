# Part 24 — Constrained randc: inside and Excluded Ranges

EDA Playground: [Constrained randc: inside and Excluded Ranges](https://edaplayground.com/x/A7hT)  
EDA Playground Name: `Constrained randc: inside and Excluded Ranges`  
Saved code ID: `7358861`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace, correct, or improve the code.

## Saved playground settings

- Testbench language: SystemVerilog/Verilog
- Simulator: Siemens Questa 2025.2
- Compile options: `-timescale 1ns/1ns`
- Run options: `-voptargs=+acc=npr`
- run.do, run.bash, EPWave, output-file, and download options: off

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

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

## Source fidelity
The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID A7hT. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

No explicit or implicit natural-language question appears in the design.sv or testbench.sv source. The comments are topic labels rather than questions, so no Q&A entry is invented.

## Verification observed

Live EDA run: Questa completed with Errors: 0 and Warnings: 1; ten display lines reported status 1.

The live EDA source and settings were not edited during verification.

