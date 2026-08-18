# Part 29 — Distribution Constraints with := and :/

[← Part 28](../28-constraint-operators-distribution-and-modes/README.md) · [Learning index](../README.md) · [Part 30 →](../30-fifo-transaction-and-weighted-constraints/README.md)

EDA Playground: [Distribution Constraints with := and :/](https://edaplayground.com/x/6Yt4)  
EDA Playground Name: `Distribution Constraints with := and :/`  
Saved code ID: `7359201`

## Why this example matters

Both distribution operators assign relative weight, but they treat ranges differently. With `:=`, every value in a range receives the stated weight; with `:/`, the stated weight is divided across the range as a whole.

That difference changes per-value probability even when the source looks nearly identical. Expand each range into individual values and compute its total weight before interpreting the output; a short run demonstrates tendencies, not exact percentages.

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
//:= equal weight to all the values inside the range 
//:/ divide the weight equally to values between the range 
// 2 bit sel 00 01 10 11 
//
class first ; 
  rand bit wr; 
  rand bit rd;
  rand bit [1:0] var1 ; 
  rand bit [1:0] var2 ; 
  constraint datavar{
    var1 dist {0 := 30 , [1:3] := 90};  // very less probability for 0 
    var2 dist {0 :/ 30 , [1:3] :/ 90}; 
  }
  constraint control{
    wr dist {0 := 30 , 1:= 70 }; // whould get more 1 
    rd dist {0 :/30 , 1:/ 70 } ; 
    
  }
  
endclass
module tb; 
  first f; 
  initial begin
    f=new(); 
    for(int i =0 ; i<30 ; i++ )begin
      f.randomize(); 
      //$display("The value of wr is : %0d and rd is %0d " , f.wr, f.rd );
      $display("The value of var1 is : %0d and var2 is %0d " , f.var1, f.var2 );
    end
  end
 
endmodule 
~~~

## What happened when it ran

Live EDA run: Questa completed with Errors: 0 and Warnings: 3 total; the run printed 30 randomized `var1`/`var2` display lines. The warnings included the preserved stand-alone `randomize()` call and optimization warnings.

The source was captured in two identical complete reads after the page finished loading, and the saved Name, short ID, code ID, and settings were unchanged after the in-place rename and reload.

The live EDA source and settings were not edited during verification.
