// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples
// values of a certain range 
// Code your testbench here
// or browse Examples
`timescale 1ns/1ps 

class generator; 
  randc bit [3:0] a,b;
  bit [3:0] y; 
  extern constraint data_const ;  // EXTERNAL CONSTRAINT 
  extern function void display(); 
  
  
endclass
constraint generator::data_const {
  a inside {[0:3]}; 
  b inside {[14:15]}; 
  
};
function void generator::display();
  $display("Value of a is %0d and b is %0d " , a,b); 
endfunction 
module tb;
  generator g; 
  initial begin
    g=new(); 
    for(int i =0 ; i<10 ; i++)begin
      assert(g.randomize()) else $display("randomization failed ") ;  // explain how assert works 
      
      g.display(); 
      #10; 
      
    end 
  end
endmodule 
