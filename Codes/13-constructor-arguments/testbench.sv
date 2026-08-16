// Code your testbench here
// or browse Examples
class first;
  int data1;
  bit [7:0] data2 ;
  shortint data3;

  function new( input int data1=0, input bit [7:0] data2=8'd0, input shortint data3=0 );  // constructor cannot add a void to a constructor
    this.data1=data1;
    this.data2=data2;
    this.data3=data3;

  endfunction
  task display();
    $display("Value of data 1 , data 2 adn data 3 are %0d , %0d , %0d  (calling from the class)" , data1, data2,data3);

  endtask
endclass

module tb;
  first f1;
  initial begin
    //f1=new(14,5,43); // following the positions ----> METHOD 1
    f1= new(.data2(5) , .data3(5) , .data1(11));  //------> METHOD 2 BY specifically naming

    //f1 will have address of the class now
    f1.display();
    //$display("Data member of the class first data1  is %0d, data2 is %0d and data 3 is %0d" , f1.data1,f1.data2, f1.data3);
  end

endmodule
