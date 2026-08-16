// Code your testbench here
// or browse Examples
// DISTINGUISH BETWEEN CUSTOM CONSTRUCTOR WE NEED  A KEYWORD ITS SUPER KEYWORD 
class first ; 
  int data1; 
  function new(input int data1);
    this.data1=data1; 
    
  endfunction 
endclass 
class second extends first ; 
  int data2;
  function new (int data1 , int data2);  // can i have an output direction in a constructor 
    super.new(data1);
    this.data2=data2;
    
  endfunction 
endclass
module tb;
  second s;
  initial begin
    s=new(15,16);
    $display("The values of parent class is %0d and child class is %0d " , s.data1,s.data2 );
  end
  // constructor name is always new in sv
endmodule 
