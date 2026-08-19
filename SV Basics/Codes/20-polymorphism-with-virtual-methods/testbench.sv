// Code your testbench here
// or browse Examples
class first ; 
  int data1 = 12;
  virtual function void display(); // IF I EXTEND IT IN second class the overridden method will be executed 
    $display("Value of data1 from class first is %0d " , data1);
  endfunction
endclass

class second extends first ; 
  int data2= 34;
  function void add();
    $display("Value of data2 from class second is %0d" , data2);
  endfunction 
  
  function void display();
    $display("Value of data2 from class second is %0d " , data2);
  endfunction
  
endclass

module tb; 
  first f;
  second s; 
  
  initial begin
    f = new();
    s=new();
    f=s;
    f.display(); // getting parent class display I NEED DIFFERENT BEHAVIOUR 
    // display hence will have different behaviour same name different behaviour polymorphism 
  end
endmodule
