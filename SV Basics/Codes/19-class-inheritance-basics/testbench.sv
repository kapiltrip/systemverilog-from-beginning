// Code your testbench here
// or browse Examples
// INHERITANCE 
class first ; 
  int data1=12;
  function void display();
    $display("Value of data called from class first is %0d " , data1); 
    
  endfunction 
  
endclass
class second extends first ; 
  // it has access to the attributes and methods of class 1 
  int data2=34; 
  function void add();
    $display("value after process is %0d " , data2+4);
  endfunction
endclass
module tb;  
  second s;
  initial begin
    s=new();
    // ohh actually i have access to all the things without using handler 
    
    $display("Value of data2 is %0d " , s.data2);
    $display("Value of data1 is %0d " , s.data1);
    s.display(); 
    s.add();
    
  end
endmodule 
