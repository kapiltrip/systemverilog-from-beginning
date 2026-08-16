// Code your testbench here
// or browse Examples
//Copy the data somethimes 
class first ; 
  int data = 41; 
  
endclass 
module tb;
  first f1;
  first p1; 
  
  initial begin
    f1=new();  // constructor copy from 1 object to another object 
    f1.data=24; // Data to be used , now i want to keep it safe 
    //p1 =new(f1); // Copy all the data of the object handle f1 to f2 (shallow copy)
    p1 = new f1 ; 
    $display("Value fo the data member is %0d " , p1.data);
    //if i change in p1 object handle , it wont reflect on f1 
    p1.data= 123; 
    $display("Shallow copy behaviour ......................");
    $display("Value fo the data member f1 is %0d " , f1.data);
    $display("Value fo the data member p1 is %0d " , p1.data);
    //task creating copy , just to copy data members attributes 
  end
endmodule
