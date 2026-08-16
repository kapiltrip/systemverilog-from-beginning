# Part 03 — SV 03 - Phase-Shifted Clocks

EDA Playground: [SV 03 - Phase-Shifted Clocks](https://edaplayground.com/x/gi8n)  
EDA Playground Name: `SV 03 - Phase-Shifted Clocks`  
Saved code ID: `7356180`

This README documents the exact source currently saved in the linked EDA Playground. The source panes are preserved verbatim; the explanations below do not replace or correct the code.

## Saved playground settings

- Simulator: Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Verbatim design.sv

~~~systemverilog
// Code your design here
~~~

## Verbatim testbench.sv

~~~systemverilog
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module tb() ; 
  reg clk100Mhz = 0; 
  reg clk50Mhz=0;
  always #5 clk100Mhz = ~clk100Mhz ;  
  real phase = 10 ; // b/w reference and new clock is 10 ns 
  real ton =5 ; 
  real toff= 5; 
  initial begin
    #phase; 
    while(1)begin
        clk50Mhz =1; 
        #ton;
        clk50Mhz=0;
        #ton; 
      
    end
  end
  //integrate the code of demonstration part 1 here, 
  // also include demonstration part 2 of section 2 
  
  
endmodule
~~~

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes. No corrected or self-checking replacement is included in this part. The linked short ID and saved settings are retained for running the original experiment.

## Questions and Answers from the Code

No natural-language question or doubt was found in the comments of the canonical source for this part. Its comments describe the phase-shifted clock construction and timing intent; those comments are preserved verbatim in the source block above.

## Source references

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).

