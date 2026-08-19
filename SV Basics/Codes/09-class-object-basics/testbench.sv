// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
  class first; 
    reg [2:0] data; // attributes 
    reg [1:0] data2 ; // reg is a 4 state data type 
    
    
  endclass 
module tb; 
  first f;  // f is a handler wont able to access the class 
             //class are dynamic object ? meaning 
             // Do not keep that object throughout life of the simulation  
  
  initial begin
    f=new(); // constructor to the handler allocate the memory space to all the data members of the class and also assigns the default values 
             // Once i call the constructor 
             // f now points to that, object 
    
    
    #1;
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 
    // Try to add a value 
    f.data = 3'b010; 
    f.data2= 2'b10 ; 
    #1; 
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 
    f=null; // deallocate the memory associated to the class 
    $display("Value of data and data2 is  %0d, %0d" , f.data , f.data2); 

  end
  
endmodule
