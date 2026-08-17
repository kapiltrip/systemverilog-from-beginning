# Part 29 — Distribution Constraints with := and :/

EDA Playground: [Distribution Constraints with := and :/](https://edaplayground.com/x/6Yt4)  
EDA Playground Name: `Distribution Constraints with := and :/`  
Saved code ID: `7359201`

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

## Source fidelity

The two code blocks above are rendered from the corresponding live EDA Playground editor panes for short ID 6Yt4. No corrected, reformatted, or self-checking replacement is included. The linked short ID, saved name, and simulator settings are retained for running the original experiment.

## Questions and Answers from the Code

No explicit or implicit natural-language question appears in the design.sv or testbench.sv source. The comments define the `:=` and `:/` topic and record distribution observations; they are declarative study notes rather than questions, so no Q&A entry is invented.

## Verification observed

Live EDA run: Questa completed with Errors: 0 and Warnings: 3 total; the run printed 30 randomized `var1`/`var2` display lines. The warnings included the preserved stand-alone `randomize()` call and optimization warnings.

The source was captured in two identical complete reads after the page finished loading, and the saved Name, short ID, code ID, and settings were unchanged after the in-place rename and reload.

The live EDA source and settings were not edited during verification.
