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
