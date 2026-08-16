// Code your testbench here
// or browse Examples
//Generator generate stimuli and sending it to driver 
// How to generate complex sequences 
`timescale 1ns/1ps 
class generator ; 
  //rand bit [3:0] a,b;  // some repetition of values 
  randc bit [3:0] a,b;  // no repetition 
  bit [3:0] y; 
  constraint data {a>16; }
endclass
/*
randc => cyclic rand 
rand -> random number 

*/
module tb;
  generator g ; 
  int i =0;
  int status =0;
  
  initial begin
    g=new();
    //10 random stimuli 
    for(i=0; i<10; i++)begin
      //status = g.randomize();
      if(!g.randomize()) begin
        $display("Randomize failed at time %0t" , $time ); 
        
      end

      
    end
  end
endmodule 
