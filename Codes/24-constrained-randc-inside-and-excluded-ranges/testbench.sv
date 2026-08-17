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
