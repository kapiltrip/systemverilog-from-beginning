// Code your testbench here
// or browse Examples
// scope is public be default

class first ;
  //local int data = 34;
  int data=34;

  task setter(input int data);
    this.data= data;

  endtask

  function int getter(); // a return type needed for getter ()
    return data ;

  endfunction

  task display();
    $display("value of data , running from class first is %0d "  , data );
  endtask
endclass
class second ;
  first f1;  // second class has access to the data member of the first class

  function new(); // this or i can use initial begin block itself ??
    f1=new();

  endfunction

endclass
module tb;
  second s;
  initial begin
    s=new();
    //$display("The value of data in the class first, is %0d " , s.f1.data );
    //s.f1.display();
    //s.f1.data = 111;
    //s.f1.display();
    s.f1.setter(12);
    // $display("The value of the data , fron getter task is %0d" , s.f1.getter()) ; WILL NOT WORK CAUSE TASK DOES NOT RETURN A VALUE
    $display("value of data %0d is " , s.f1.getter());

  end
endmodule
