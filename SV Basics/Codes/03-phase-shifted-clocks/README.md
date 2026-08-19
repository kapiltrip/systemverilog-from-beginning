# Part 03 — SV 03 - Phase-Shifted Clocks

[← Part 02](../02-clock-generation/README.md) · [Learning index](../README.md) · [Part 04 →](../04-data-types-and-time/README.md)

EDA Playground: [SV 03 - Phase-Shifted Clocks](https://edaplayground.com/x/gi8n)  
EDA Playground Name: `SV 03 - Phase-Shifted Clocks`  
Saved code ID: `7356180`

## Why this example matters

This example separates two ideas that are easy to mix up: period tells you how often a waveform repeats, while phase tells you where one waveform sits relative to another. Two clocks can have the same frequency and still reach their edges at different simulation times.

Read the initial offset and the repeated half-period delays independently. The offset establishes the phase relationship once; the repeating logic preserves the period afterward. A timing table of rising edges is often clearer than looking only at the clock declarations.

## Saved playground settings

- Simulator: Aldec Riviera Pro 2025.04
- Compile options: `-timescale 1ns/1ns`
- Run options: `+access+r`

## Testbench code

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

## Further reading

The language explanations use [IEEE 1800-2017 SystemVerilog LRM](https://rfsoc.mit.edu/6S965/_static/F25/documentation/1800-2017.pdf) and [IEEE SystemVerilog standard overview](https://standards.ieee.org/ieee/1800/4934/). The page's editor panes and settings are described by [EDA Playground settings documentation](https://eda-playground.readthedocs.io/en/latest/settings.html) and [EDA Playground compile/run options](https://eda-playground.readthedocs.io/en/latest/compile_run_options.html).

