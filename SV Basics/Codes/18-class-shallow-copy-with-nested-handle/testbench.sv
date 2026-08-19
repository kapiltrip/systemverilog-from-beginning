// Code your testbench here
// or browse Examples
// Shallow copy copies data members or methods ? verify this 
// but it cant copy  
// Whats wrong with shallow copy cause it is copying the data members and its not copying the variables that are in the heap 
// Understanding shallow copy 
class first; 
  int data1 =12; 
  
endclass

class second ; 
  first f1; 
  int data2=34; 
  function new(); 
    f1=new();
    
  endfunction 
  /*
  initial begin
    f1=new();
    
  end
  */ // i cant have a initial begin in class 
  
  endclass
  module tb();
    second s1,s2;
    initial begin
      s1=new();  // handler for class second 
      s1.data2=45; 
      
      s2=new s1; // copy data members of handler s1 to s2 
      $display("value of second data member is : %0d " , s2.data2 );
      $display("value of first class data member is : %0d " , s2.f1.data1 );
      // the data members of class first and second are not related 
      
      //ahh so so only handler is different the object its pointing to is 1 only i.e class first, in our case cause its a dynamically created class 
      
      
      
      //now 
      s2.f1.data1=56; 
      $display("Value of data from original object is %0d " , s1.f1.data1 ) ; 
    end
  endmodule
